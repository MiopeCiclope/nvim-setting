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
                    if not entry.sha then return end
                    local sha = entry.sha
                    local diff_entries = gd.name_status_entries(sha .. "^.." .. sha)
                    if #diff_entries == 0 then
                        diff_entries = gd.name_status_entries("4b825dc642cb6eb9a060e54bf8d69288fbee4904.." .. sha)
                    end
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
            {
                key = "c",
                desc = "checkout (detached)",
                fn = function(entry)
                    if not entry.sha then return end
                    local sha = entry.sha
                    vim.ui.select({ "Yes", "No" }, { prompt = "Checkout " .. sha .. "? (detached HEAD)" }, function(choice)
                        if choice == "Yes" then
                            vim.fn.system("git checkout " .. vim.fn.shellescape(sha))
                            if vim.v.shell_error ~= 0 then
                                vim.notify("checkout failed: " .. sha, vim.log.levels.ERROR)
                            else
                                vim.notify("Checked out " .. sha, vim.log.levels.INFO)
                            end
                        end
                    end)
                end,
            },
            {
                key = "r",
                desc = "soft reset to commit",
                fn = function(entry)
                    if not entry.sha then return end
                    local sha = entry.sha
                    vim.ui.select({ "Yes", "No" }, { prompt = "Soft reset to " .. sha .. "?" }, function(choice)
                        if choice == "Yes" then
                            vim.fn.system("git reset --soft " .. vim.fn.shellescape(sha))
                            if vim.v.shell_error ~= 0 then
                                vim.notify("soft reset failed: " .. sha, vim.log.levels.ERROR)
                            else
                                vim.notify("Soft reset to " .. sha, vim.log.levels.INFO)
                            end
                        end
                    end)
                end,
            },
        },
    })
end

return M
