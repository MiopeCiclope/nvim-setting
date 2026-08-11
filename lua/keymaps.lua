local map = vim.keymap.set
local opts = { noremap = true }

-- Pane navigation
map("n", "<c-k>", ":wincmd k<CR>", opts)
map("n", "<c-j>", ":wincmd j<CR>", opts)
map("n", "<c-l>", ":wincmd l<CR>", opts)
map("n", "<c-h>", ":wincmd h<CR>", opts)

-- Buffer navigation (history-based, like browser back/forward)
map("n", "ö", function()
	require("buffer_history").back()
end, opts)
map("n", "ä", function()
	require("buffer_history").forward()
end, opts)
map("n", "<C-e>", ":bnext | bd #<CR>", opts)

-- Quick commands
map("n", "<C-a>", "ggVG", opts)
map("n", "<Leader>%", ":vsplit<CR>", opts)
map("n", '<Leader>"', ":split<CR>", opts)
map("n", "<Leader>l", "<Cmd>noh<CR>", opts)
map("n", "<C-x>", ":Explore<CR>", opts)

-- Movement remaps
map("i", "<C-v>", "<C-o>$", opts)
map("i", "<C-c>", "<C-o>0", opts)
map({ "n", "o", "v" }, "t", "$", opts)
map({ "n", "o", "v" }, "r", "^", opts)
map({ "n", "o", "v" }, "w", "b", opts)

-- Toggle diagnostics (from utils)
map("n", "<Leader>d", function()
	require("utils").toggle_diagnostics()
end, opts)

-- Search inside visual selection
map("x", "/", ":<C-u>/\\%V", opts)

-- fzf integration
map("n", "<C-p>", '<cmd>lua require("fzf_searches").git_files()<CR>', opts)
map("n", "<Leader>b", '<cmd>lua require("fzf_searches").buffers()<CR>', opts)
map("n", "<Leader>z", '<cmd>lua require("fzf_searches").grep_search()<CR>', opts)

map("n", "<Leader>c", "<cmd>CopyRepoPath<CR>", opts)

-- Fugitive (git) — space + right hand
-- u: git status  i: diff arquivo  o: blame  n: log  m: review PR (quickfix + vimdiff seguindo a lista)
local review_ref = "origin/master" -- objeto git contra o qual cada arquivo é diffado
local review_root = "" -- raiz do repo (pra rodar git show)
local review_items = {} -- [i] = { status, base_path, work_path, display }
local previewing = false

local function detect_base()
	-- local ref, sem rede: refs/remotes/origin/HEAD -> "origin/<branch>"
	local out = vim.fn.system("git rev-parse --abbrev-ref origin/HEAD 2>/dev/null"):gsub("%s+", "")
	local base = out:gsub("^origin/", "")
	return base ~= "" and base or "master"
end

-- Conteúdo do arquivo em review_ref (vazio = arquivo novo, sem versão base)
local function base_content(relpath)
	local out = vim.fn.systemlist(
		"git -C " .. vim.fn.shellescape(review_root) .. " show " .. vim.fn.shellescape(review_ref .. ":" .. relpath)
	)
	if vim.v.shell_error ~= 0 then return {} end
	return out
end

-- Janelas persistentes do diff: esquerda = base, direita = worktree.
local review_left, review_right

local function layout_ok(qf_win)
	return review_left
		and review_right
		and review_left ~= review_right
		and review_left ~= qf_win
		and review_right ~= qf_win
		and vim.api.nvim_win_is_valid(review_left)
		and vim.api.nvim_win_is_valid(review_right)
end

-- Constrói o layout uma vez (fecha janelas extras + cria o split). Só roda no
-- primeiro review ou se o usuário fechou uma das janelas — nunca por navegação.
local function build_layout(qf_win)
	local main
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if w ~= qf_win and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "qf" then
			main = w
			break
		end
	end
	if main then
		vim.api.nvim_set_current_win(main)
	else
		vim.cmd("aboveleft new")
		main = vim.api.nvim_get_current_win()
	end
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if w ~= main and w ~= qf_win and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "qf" then
			pcall(vim.api.nvim_win_close, w, false)
		end
	end
	vim.cmd("leftabove vnew")
	review_left = vim.api.nvim_get_current_win()
	review_right = main
end

-- Diff da entrada atual: worktree (direita) vs base num scratch (esquerda).
-- Reaproveita as duas janelas trocando só os buffers — sem fechar/abrir, não pisca.
-- Scratch em vez de fugitive porque entrar no quickfix esvazia buffers fugitive.
-- Trata add/delete/rename via review_items. Mantém o foco na lista.
local function preview_entry()
	local qf_win = vim.api.nvim_get_current_win()
	local idx = vim.fn.line(".")
	local it = review_items[idx]
	if not it then return end

	if not layout_ok(qf_win) then
		build_layout(qf_win)
	end

	-- reset do diff nas duas janelas ANTES de trocar os buffers; sem isso o diff
	-- herda o filler da entrada anterior e marca o arquivo inteiro como alterado.
	vim.api.nvim_win_call(review_right, function() vim.cmd("diffoff") end)
	vim.api.nvim_win_call(review_left, function() vim.cmd("diffoff") end)

	-- direita: worktree (vazio se o arquivo foi deletado)
	local work_buf
	if it.status == "D" then
		work_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[work_buf].bufhidden = "wipe"
	else
		work_buf = vim.fn.bufadd(it.work_path)
		vim.fn.bufload(work_buf)
	end
	vim.api.nvim_win_set_buf(review_right, work_buf)
	local ft
	vim.api.nvim_win_call(review_right, function()
		-- :cc/bufload dentro do autocmd pula detecção de filetype; força pelo nome
		if vim.bo.filetype == "" then
			local d = vim.filetype.match({ buf = work_buf }) or vim.filetype.match({ filename = it.base_path })
			if d then vim.bo.filetype = d end
		end
		ft = vim.bo.filetype
		vim.cmd("diffthis")
	end)

	-- esquerda: versão base num scratch novo (vazio se o arquivo é novo)
	local base = vim.api.nvim_create_buf(false, true)
	vim.bo[base].bufhidden = "wipe"
	local blines = it.status == "A" and {} or base_content(it.base_path)
	vim.api.nvim_buf_set_lines(base, 0, -1, false, blines)
	vim.bo[base].modifiable = false
	pcall(vim.api.nvim_buf_set_name, base, review_ref .. ":" .. it.base_path)
	vim.api.nvim_win_set_buf(review_left, base)
	vim.api.nvim_win_call(review_left, function()
		vim.bo.filetype = ft -- dispara treesitter (FileType autocmd)
		-- mesmo highlight do arquivo normal: anexa os LSP clients do arquivo de
		-- trabalho pro scratch ganhar semantic tokens; diagnostics off (versão base)
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = work_buf })) do
			pcall(vim.lsp.buf_attach_client, base, client.id)
		end
		pcall(vim.diagnostic.enable, false, { bufnr = base })
		vim.cmd("diffthis")
	end)

	if vim.api.nvim_win_is_valid(qf_win) then
		vim.api.nvim_set_current_win(qf_win)
	end
end

local function preview_guarded()
	if previewing then return end
	previewing = true
	pcall(preview_entry)
	previewing = false
end

local function qf_is_review()
	return vim.fn.getqflist({ title = 0 }).title == "PR Review"
end

-- Formata a lista de review: "M  path" / "A  path" / "D  path" / "R  old → new"
-- em vez do fname|lnum|text padrão do quickfix.
function _G.ReviewQftf(info)
	local out = {}
	for i = info.start_idx, info.end_idx do
		out[#out + 1] = (review_items[i] and review_items[i].display) or ""
	end
	return out
end

-- Converte linhas de `git diff --name-status -M` em review_items + quickfix.
local function build_items(status_lines)
	review_items = {}
	local qf = {}
	for _, line in ipairs(status_lines) do
		local parts = vim.split(line, "\t", { trimempty = true })
		if parts[2] then -- ignora lixo (ex.: mensagens de erro do git)
			local st = parts[1]:sub(1, 1)
			local it
			if st == "R" or st == "C" then -- rename/move ou copy: base = caminho antigo
				it = {
					status = "R",
					base_path = parts[2],
					work_path = review_root .. "/" .. parts[3],
					display = string.format("R  %s → %s", parts[2], parts[3]),
				}
			else
				it = {
					status = st,
					base_path = parts[2],
					work_path = review_root .. "/" .. parts[2],
					display = string.format("%s  %s", st, parts[2]),
				}
			end
			review_items[#review_items + 1] = it
			qf[#qf + 1] = { filename = it.work_path, lnum = 1, text = it.display }
		end
	end
	return qf
end

-- Monta a quickfix a partir das linhas `--name-status` e abre o diff de cada
-- arquivo contra `ref`, seguindo a navegação na lista.
-- ponytail: o diff é worktree vs `ref`; fiel pro commit do topo/branch, mas
-- pra commits antigos alterados depois mostra o acumulado, não só aquele commit.
local function load_review(ref, status_lines)
	review_ref = ref
	review_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+", "")
	if #status_lines == 0 then
		vim.notify("Sem arquivos alterados", vim.log.levels.INFO)
		return
	end
	local qf = build_items(status_lines)
	vim.fn.setqflist({}, "r", { title = "PR Review", items = qf, quickfixtextfunc = "v:lua.ReviewQftf" })
	vim.cmd("copen")
	preview_guarded()
end

-- u: review das mudanças não-commitadas (worktree vs HEAD) com vimdiff-follow,
-- incluindo arquivos novos ainda não rastreados (entram como "A")
map("n", "<Leader>u", function()
	local lines = vim.fn.systemlist("git diff --name-status -M HEAD")
	for _, f in ipairs(vim.fn.systemlist("git ls-files --others --exclude-standard")) do
		lines[#lines + 1] = "A\t" .. f
	end
	load_review("HEAD", lines)
end, opts)
map("n", "<Leader>i", function()
	if vim.bo.filetype == "qf" then vim.cmd("cc") end
	vim.cmd("Gvdiffsplit")
end, opts)
map("n", "<Leader>o", "<cmd>G blame<CR>", opts)
map("n", "<Leader>n", function()
	vim.cmd("G log --oneline")
	vim.keymap.set("n", "<CR>", function()
		local sha = vim.fn.getline("."):match("%x%x%x%x%x%x%x+")
		if not sha then return end
		load_review(sha .. "^", vim.fn.systemlist("git diff --name-status -M " .. sha .. "^ " .. sha))
	end, { buffer = true, noremap = true })
end, opts)
map("n", "<Leader>m", function()
	local base = "origin/" .. detect_base()
	load_review(base, vim.fn.systemlist("git diff --name-status -M " .. base .. "...HEAD"))
end, opts)

-- Diff segue a navegação enquanto o cursor anda na lista de review
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("PRReviewFollow", { clear = true }),
	callback = function()
		if vim.bo.filetype == "qf" and qf_is_review() then
			preview_guarded()
		end
	end,
})

-- Fechar diff e quickfix, sobrando só o arquivo de trabalho
map("n", "<Leader>q", function()
	vim.cmd("diffoff!")
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		-- fecha janelas não-normais: quickfix, scratch base (nofile), fugitive
		if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
			pcall(vim.api.nvim_win_close, win, false)
		end
	end
end, opts)

-- Quickfix navigation — j/k na própria lista já move e o diff segue
map("n", "<Leader>j", "<cmd>silent! cnext<CR>", opts)
map("n", "<Leader>k", "<cmd>silent! cprev<CR>", opts)

map("n", "<Leader>rc", function()
	require("review").clear()
end, opts)
