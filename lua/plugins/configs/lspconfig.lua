local present, lspconfig = pcall(require, "lspconfig")

if not present then
  return
end

require("base46").load_highlight "lsp"
require "nvchad_ui.lsp"

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad_ui.signature").setup(client)
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

lspconfig.sumneko_lua.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

lspconfig.clangd.setup{
  cmd = {
        'clangd',
        '--background-index',
        '--pch-storage=memory',
        '--suggest-missing-includes',
        '--clang-tidy',
        '--fallback-style=google',
        '-j=4',
    },
    extensions = {
        inlay_hints = {
            only_current_line = false,
            only_current_line_autocmd = 'CursorHold',
            show_parameter_hints = true,
            parameter_hints_prefix = '<- ',
            other_hints_prefix = '=> ',
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
            highlight = 'Keyword',
            priority = 100,
        },
    },
    settings = {
        clangd = {
            init_options = {
                clangdFileStatus = true,
                usePlaceholders = true,
                completeUnimported = true,
                semanticHighlighting = true,
            },
            filetypes = {
                'c',
                'cpp',
                'objc',
                'objcpp',
                'cuda',
                'cc',
                'hpp',
                'h',
                'cxx',
            },
            root_dir = {
                '.git',
                '.clangd',
                '.clang-tidy',
                '.clang-format',
                'configure.ac',
                'build/',
                'Build/',
                'CMakeLists.txt',
            },
            single_file_support = true,
            flags = {
                debounce_text_change = 150,
            },
        },
    },
}

return M
