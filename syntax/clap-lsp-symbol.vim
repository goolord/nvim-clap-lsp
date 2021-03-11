syn match clap_lsp_intro /^\[\w*\] .*- / contains=clap_lsp_type,clap_lsp_symbol,clap_lsp_sep

syn match clap_lsp_type /^\[\w*\]/ contained nextgroup=clap_lsp_symbol
hi def link clap_lsp_type Type

syn match clap_lsp_ln /\d*$/
hi def link clap_lsp_ln Number

syn match clap_lsp_symbol / .\{-} / contained nextgroup=clap_lsp_sep
hi def link clap_lsp_symbol Tag

syn match clap_lsp_sep / - / contained
hi def link clap_lsp_sep NONE
