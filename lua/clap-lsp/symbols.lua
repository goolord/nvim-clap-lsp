local util = require'clap-lsp.util'

local function to_fp(selected)
    return string.match(selected, ".* - (.*):(%d*)")
end

local function symbol_sink(selected)
    local fp,lnum = to_fp(selected)
    vim.cmd('edit +' .. lnum .. ' ' .. fp)
end

local function on_move_impl()
    vim.cmd('let g:clap_lsp_curline = g:clap.display.getcurline()')
    local curline = vim.api.nvim_get_var('clap_lsp_curline')
    local curfp,lnum = to_fp(curline)
    vim.fn['clap#preview#file_at'](curfp,lnum)
end

local function symbol_handler(_, result, ctx, _)
    local bufnr = ctx.bufnr
    if not result or vim.tbl_isempty(result) then return end
    -- local filename = vim.api.nvim_buf_get_name(bufnr)
    local items = vim.lsp.util.symbols_to_items(result, bufnr)
    local data = {}
    for i, item in ipairs(items) do
        data[i] = item.text
        local add = vim.fn.fnamemodify(item.filename, ':~:.')
        data[i] = data[i]..' - ' .. add .. ':' ..item.lnum
        data[i] = data[i]:gsub("\n", "")
        item.text = nil
    end
    local provider = {
        source = data,
        sink = symbol_sink,
        on_move = on_move_impl,
        syntax = 'clap-lsp-symbol'
    }
    vim.fn['clap#run'](provider)
    on_move_impl()
end

return {
    document_handler = symbol_handler,
    workspace_handler = symbol_handler,
}
