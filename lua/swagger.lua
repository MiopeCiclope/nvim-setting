local M = {}

local METHODS = { "get", "post", "put", "patch", "delete", "head", "options" }

local function pretty_json(raw)
	local out = vim.fn.system(
		{ "python3", "-c", "import json,sys; print(json.dumps(json.loads(sys.stdin.read()), indent=2))" },
		raw
	)
	return vim.v.shell_error == 0 and vim.trim(out) or raw
end

local function resolve_ref(ref, spec)
	if not ref then return nil end
	local node = spec
	for part in ref:gsub("^#/", ""):gmatch("[^/]+") do
		if type(node) ~= "table" then return nil end
		node = node[part]
	end
	return node
end

local function schema_to_example(schema, spec, depth)
	if depth > 5 or not schema then return nil end
	if schema["$ref"] then
		schema = resolve_ref(schema["$ref"], spec)
		if not schema then return nil end
	end
	if schema.example ~= nil then return schema.example end
	if schema.allOf then
		local merged = {}
		for _, s in ipairs(schema.allOf) do
			local ex = schema_to_example(s, spec, depth + 1)
			if type(ex) == "table" then
				merged = vim.tbl_extend("force", merged, ex)
			end
		end
		return merged
	end
	local t = schema.type
	if t == "object" or schema.properties then
		local obj = {}
		for k, v in pairs(schema.properties or {}) do
			obj[k] = schema_to_example(v, spec, depth + 1)
		end
		return obj
	end
	if t == "array" then return { schema_to_example(schema.items, spec, depth + 1) } end
	if t == "string" then return schema.enum and schema.enum[1] or "string" end
	if t == "integer" or t == "number" then return 0 end
	if t == "boolean" then return false end
	return nil
end

local function request_body_json(operation, spec)
	local rb = operation.requestBody
	if not rb then return nil end
	if rb["$ref"] then rb = resolve_ref(rb["$ref"], spec) end
	local content = rb and rb.content
	if not content then return nil end
	local jc = content["application/json"]
	if not jc or not jc.schema then return nil end
	local example = schema_to_example(jc.schema, spec, 0)
	if example == nil then return "{}" end
	local raw = vim.json.encode(example)
	return pretty_json(raw)
end

local function query_params(operation)
	local params = {}
	for _, p in ipairs(operation.parameters or {}) do
		if p["$ref"] then p = resolve_ref(p["$ref"], {}) end
		if p and p["in"] == "query" then
			table.insert(params, p.name .. "=")
		end
	end
	return params
end

function M.import(base_url)
	base_url = (base_url and base_url ~= "") and base_url:gsub("/$", "") or "http://localhost:8085"

	local raw, spec_path
	for _, path in ipairs({ "/v3/api-docs", "/v2/api-docs", "/swagger.json", "/openapi.json" }) do
		local out = vim.fn.system({ "curl", "-sf", "--max-time", "5", base_url .. path })
		if vim.v.shell_error == 0 and out ~= "" then
			raw, spec_path = out, path
			break
		end
	end

	if not raw then
		vim.notify("[swagger] Could not fetch spec from " .. base_url, vim.log.levels.ERROR)
		return
	end

	local ok, spec = pcall(vim.json.decode, raw)
	if not ok then
		vim.notify("[swagger] Failed to parse spec: " .. tostring(spec), vim.log.levels.ERROR)
		return
	end

	local server_url = base_url
	if spec.servers and spec.servers[1] then
		local u = spec.servers[1].url
		server_url = u:match("^https?://") and u
			or (base_url:match("^(https?://[^/]+)") or base_url) .. u
	end

	-- Group by tag
	local tag_order, tagged = {}, {}
	for path, path_item in pairs(spec.paths or {}) do
		for _, method in ipairs(METHODS) do
			local op = path_item[method]
			if type(op) == "table" then
				local tag = (op.tags and op.tags[1]) or "default"
				if not tagged[tag] then
					tagged[tag] = {}
					table.insert(tag_order, tag)
				end
				table.insert(tagged[tag], { method = method:upper(), path = path, op = op })
			end
		end
	end
	table.sort(tag_order)

	-- Collect all unique path and query params across all operations
	local all_params = {}
	for _, tag in ipairs(tag_order) do
		for _, entry in ipairs(tagged[tag]) do
			-- Path params from URL pattern
			for param in entry.path:gmatch("{([^}]+)}") do
				all_params[param] = true
			end
			-- Query params from operation
			for _, p in ipairs(entry.op.parameters or {}) do
				if p["$ref"] then p = resolve_ref(p["$ref"], spec) end
				if p and (p["in"] == "query" or p["in"] == "path") then
					all_params[p.name] = true
				end
			end
		end
	end

	local lines = {}

	-- Each request: ### [tag] summary \n METHOD url \n headers \n \n body
	for _, tag in ipairs(tag_order) do
		for _, entry in ipairs(tagged[tag]) do
			local op = entry.op
			local summary = op.summary or op.operationId or (entry.method .. " " .. entry.path)

			local qp = query_params(op)
			-- Convert OpenAPI {param} to kulala {{param}}
			local url = "{{baseUrl}}" .. entry.path:gsub("{([^}]+)}", "{{%1}}")
			if #qp > 0 then
				url = url .. "?" .. table.concat(qp, "&")
			end

			-- ### is both separator and request label
			table.insert(lines, "### [" .. tag .. "] " .. summary)
			table.insert(lines, entry.method .. " " .. url)
			table.insert(lines, "Content-Type: {{contentType}}")
			table.insert(lines, "Accept: application/json")

			if vim.tbl_contains({ "POST", "PUT", "PATCH" }, entry.method) then
				table.insert(lines, "")
				local body = request_body_json(op, spec) or "{}"
				for _, body_line in ipairs(vim.split(body, "\n", { plain = true })) do
					table.insert(lines, body_line)
				end
			end

			table.insert(lines, "")
		end
	end

	-- Write/merge http-client.env.json — preserve user variables, only update baseUrl/contentType
	local env_fname = vim.fn.getcwd() .. "/http-client.env.json"
	local env = { dev = {}, prod = {} }
	local existing = vim.fn.filereadable(env_fname) == 1 and vim.fn.readfile(env_fname) or {}
	if #existing > 0 then
		local ok, parsed = pcall(vim.json.decode, table.concat(existing, "\n"))
		if ok then env = parsed end
	end
	env.dev = env.dev or {}
	env.dev.baseUrl = server_url
	env.dev.contentType = "application/json"
	-- Add discovered params with empty value only if not already set by user
	for param in pairs(all_params) do
		if env.dev[param] == nil then
			env.dev[param] = ""
		end
	end
	vim.fn.writefile(vim.split(pretty_json(vim.json.encode(env)), "\n", { plain = true }), env_fname)

	local fname = vim.fn.getcwd() .. "/api-calls.http"
	vim.fn.writefile(lines, fname)
	vim.cmd("edit " .. vim.fn.fnameescape(fname))

	local op_count = 0
	for _, ops in pairs(tagged) do op_count = op_count + #ops end
	vim.notify(string.format("[swagger] %d endpoints -> %s", op_count, fname), vim.log.levels.INFO)
end

return M
