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

return M
