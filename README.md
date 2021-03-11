# nvim-clap-lsp

nvim lsp handlers a la [nvim-lsputils](https://github.com/RishabhRD/nvim-lsputils), but using [vim-clap](https://github.com/liuchengxu/vim-clap) as the UI

## example

```lua
vim.lsp.handlers['textDocument/codeAction']     = require'clap-lsp.codeAction'.code_action_handler
vim.lsp.handlers['textDocument/definition']     = require'clap-lsp.locations'.definition_handler
vim.lsp.handlers['textDocument/documentSymbol'] = require'clap-lsp.symbols'.document_handler
vim.lsp.handlers['textDocument/references']     = require'clap-lsp.locations'.references_handler
vim.lsp.handlers['workspace/symbol']            = require'clap-lsp.symbols'.workspace_handler
```

if you don't want to input a query for the workspace_symbol handler, you may create a binding for the command:
```viml
:lua vim.lsp.buf.workspace_symbol("")<CR>
```

## screenshots
![img](./screenshots/workspace_symbol.png "screenshot of the workspace/symbol handler")
