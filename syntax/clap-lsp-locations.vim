syn match clap_lsp_intro /^\[\w*\] .*- / contains=clap_lsp_sep

syn match clap_lsp_ln /\d*$/
hi def link clap_lsp_ln Number

syn match clap_lsp_sep / - /
hi def link clap_lsp_sep Delimiter
