local M = {}

function M._parse_log(lines)
    local entries = {}
    for _, line in ipairs(lines) do
        local sha, subject = line:match("^(%x+)%s+(.+)$")
        if sha then
            entries[#entries + 1] = { sha = sha, subject = subject, display = sha .. " " .. subject }
        end
    end
    return entries
end

function M.open()
    local lines = vim.fn.systemlist("git log --oneline")
    local entries = M._parse_log(lines)
    if #entries == 0 then
        vim.notify("commits: no commits found", vim.log.levels.INFO)
        return
    end
    local gd = require("gitdiff")
    gd.open({
        title = "Commits",
        entries = entries,
        resolve = function(_) return { left = nil, right = nil } end,
        actions = {
            {
                key = "<CR>",
                desc = "drill into commit",
                fn = function(entry)
                    local sha = entry.sha
                    local diff_entries = gd.name_status_entries(sha .. "^.." .. sha)
                    gd.open({
                        title = sha,
                        entries = diff_entries,
                        resolve = function(e)
                            return {
                                left = e.left_path and { ref = sha .. "^", path = e.left_path } or nil,
                                right = e.right_path and { ref = sha, path = e.right_path } or nil,
                            }
                        end,
                    })
                end,
            },
        },
    })
end

return M
