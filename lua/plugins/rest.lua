return {
  "rest-nvim/rest.nvim",
  dependencies = {
    'nvim-neotest/nvim-nio',
    'manoelcampos/xml2lua',
    'j-hui/fidget.nvim',
    "nvim-lua/plenary.nvim",  -- Ensure Plenary is loaded as a dependency
  },
  opts = {
    rocks = {
      hererocks = true,  -- Use hererocks to install LuaRocks dependencies
    },
    result_split_horizontal = false,  -- Result window splits horizontally.
    skip_ssl_verification = false,  -- Skip SSL verification for self-signed certs.
    encode_url = true,  -- Encode URLs automatically.
    highlight = {
      enabled = true,  -- Enable request syntax highlighting.
      timeout = 150,   -- Duration of highlighting in ms.
    },
  },
  config = function(_, opts)
    require("rest-nvim").setup(opts)

    -- Check if mimetypes is available
    local has_mimetypes, mimetypes = pcall(require, "mimetypes")
    if not has_mimetypes then
      vim.notify(
        "Dependency 'mimetypes' is missing. Attempting to install it...",
        vim.log.levels.WARN
      )
      -- Try to install mimetypes via LuaRocks
      local install_output = vim.fn.system("luarocks install mimetypes")

      -- If installation fails, use fallback
      if not install_output:match("successfully installed") then
        vim.notify(
          "Failed to install 'mimetypes' via LuaRocks. Using a local fallback...",
          vim.log.levels.ERROR
        )

        -- Fallback implementation for MIME types
        mimetypes = {
          get_mime_type = function(filename)
            local mime_map = {
              html = "text/html",
              json = "application/json",
              xml = "application/xml",
              txt = "text/plain",
            }
            local ext = filename:match("^.+%.(.+)$")
            return mime_map[ext] or "application/octet-stream"
          end,
        }
      end
    end

    -- Make mimetypes globally available
    _G.mimetypes = mimetypes
  end,
}

