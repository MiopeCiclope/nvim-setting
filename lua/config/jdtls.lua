local function get_jdtls()
  -- Get the Mason Registry to gain access to downloaded binaries
  local mason_registry = require("mason-registry")
  -- Find the JDTLS package in the Mason Regsitry
  local jdtls = mason_registry.get_package("jdtls")
  -- Find the full path to the directory where Mason has downloaded the JDTLS binaries
  local jdtls_path = jdtls:get_install_path()
  -- Obtain the path to the jar which runs the language server
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  -- Declare white operating system we are using, windows use win, macos use mac
  local SYSTEM = "mac"
  -- Obtain the path to configuration files for your specific operating system
  local config = jdtls_path .. "/config_" .. SYSTEM
  -- Obtain the path to the Lomboc jar
  local lombok = jdtls_path .. "/lombok.jar"
  return launcher, config, lombok
end

local function get_workspace()
  -- Get the home directory of your operating system
  local home = os.getenv("HOME")
  -- Declare a directory where you would like to store project information
  local workspace_path = home .. "/code/workspace/"
  -- Determine the project name
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  -- Create the workspace directory by concatenating the designated workspace path and the project name
  local workspace_dir = workspace_path .. project_name
  return workspace_dir
end

local function setup_jdtls()
  -- Get access to the jdtls plugin and all of its functionality
  local jdtls = require("jdtls")

  -- Get the paths to the jdtls jar, operating specific configuration directory, and lombok jar
  local launcher, os_config, lombok = get_jdtls()

  -- Get the path you specified to hold project information
  local workspace_dir = get_workspace()

  -- Determine the root directory of the project by looking for these specific markers
  local root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

  -- Tell our JDTLS language features it is capable of
  local capabilities = {
    workspace = {
      configuration = true,
    },
    textDocument = {
      completion = {
        snippetSupport = false,
      },
    },
  }

  local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()
  -- Add incremental sync capabilities
  lsp_capabilities.textDocument = lsp_capabilities.textDocument or {}
  lsp_capabilities.textDocument.synchronization = {
    dynamicRegistration = false,
    willSave = true,
    willSaveWaitUntil = true,
    didSave = true,
  }

  for k, v in pairs(lsp_capabilities) do
    capabilities[k] = v
  end

  -- Get the default extended client capablities of the JDTLS language server
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  -- Set the command that starts the JDTLS language server jar
  local cmd = {
    "java",
    "-Xmx12g",
    "-XX:MaxMetaspaceSize=1g",   -- Increase Metaspace size
    "-XX:ReservedCodeCacheSize=512m",
    "-XX:+UseG1GC",              -- Use G1 Garbage Collector for better performance
    "-XX:+UseStringDeduplication", -- Deduplicate strings to save memory
    "-XX:CICompilerCount=7",     -- Limit JIT compiler threads (adjust based on CPU cores)
    "-Dlog.level=WARN",          -- Reduce logging level to avoid unnecessary output
    "-Dfile.encoding=UTF-8",
    "-javaagent:" .. lombok,
    "-jar",
    launcher,
    "-configuration",
    os_config,
    "-data",
    workspace_dir,
  }

  -- Configure settings in the JDTLS server
  local settings = {
    java = {
      -- Enable code formatting
      format = {
        enabled = true,
        -- Use the Google Style guide for code formattingh
        settings = {
          url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      -- Enable downloading archives from eclipse automatically
      eclipse = {
        downloadSource = true,
      },
      -- Enable downloading archives from maven automatically
      maven = {
        downloadSources = true,
      },
      -- Enable method signature help
      signatureHelp = {
        enabled = true,
      },
      -- Use the fernflower decompiler when using the javap command to decompile byte code back to java code
      contentProvider = {
        preferred = "fernflower",
      },
      imports = {
        exclusions = {
          "**/node_modules/**",
          "**/build/**",
          "**/target/**",
          "**/.metadata/**",
          "**/archetype-resources/**",
          "**/META-INF/**",
        },
      },
      -- Setup automatical package import oranization on file save
      saveActions = {
        organizeImports = true,
      },
      -- Customize completion options
      completion = {
        -- When using an unimported static method, how should the LSP rank possible places to import the static method from
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        -- Try not to suggest imports from these packages in the code action window
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
        -- Set the order in which the language server should organize imports
        importOrder = {
          "java",
          "jakarta",
          "javax",
          "com",
          "org",
        },
      },
      sources = {
        -- How many classes from a specific package should be imported before automatic imports combine them all into a single import
        organizeImports = {
          starThreshold = 9999,
          staticThreshold = 9999,
        },
      },
      -- How should different pieces of code be generated?
      codeGeneration = {
        -- When generating toString use a json format
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        -- When generating hashCode and equals methods use the java 7 objects method
        hashCodeEquals = {
          useJava7Objects = true,
        },
        -- When generating code use code blocks
        useBlocks = true,
      },
      -- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
      configuration = {
        updateBuildConfiguration = "interactive",
      },
      -- enable code lens in the lsp
      referencesCodeLens = {
        enabled = false,
      },
      -- enable inlay hints for parameter names,
      inlayHints = {
        parameterNames = {
          enabled = "none",
        },
      },
    },
  }

  -- Create a table called init_options to pass the bundles with debug and testing jar, along with the extended client capablies to the start or attach function of JDTLS
  local init_options = {
    extendedClientCapabilities = extendedClientCapabilities,
  }

  -- Function that will be ran once the language server is attached
  local on_attach = function(_, bufnr)
    require("jdtls.setup").add_commands()
    vim.lsp.codelens.refresh()

    -- Setup a function that automatically runs every time a java file is saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.java" },
      callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
      end,
    })
  end

  -- Create the configuration table for the start or attach function
  local config = {
    cmd = cmd,
    root_dir = root_dir,
    settings = settings,
    capabilities = capabilities,
    init_options = init_options,
    on_attach = on_attach,
  }

  -- Start the JDTLS server
  require("jdtls").start_or_attach(config)
end

return {
  setup_jdtls = setup_jdtls,
}
