local function to_fp(selected)
    return string.match(selected, ".* - (.*):(%d*)")
end

local function symbol_sink(selected)
    local fp,lnum = to_fp(selected)
    vim.cmd('edit +' .. lnum .. ' ' .. fp)
end

local function on_move_impl()
    local curline = vim.api.nvim_call_dict_function('g:clap.display' , 'getcurline', {})
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
        local text = item.text
        text = text:gsub("\n", "\\n")
        data[i] = text
        local add = vim.fn.fnamemodify(item.filename, ':~:.')
        data[i] = data[i] .. ' - ' .. add .. ':' .. item.lnum
        item.text = nil
    end
    local provider = {
        source = data,
        sink = symbol_sink,
        on_move = on_move_impl,
        on_enter = on_move_impl,
        support_open_actoin = true,
        syntax = 'clap-lsp-symbol'
    }
    vim.fn['clap#run'](provider)
end

return {
    document_handler = symbol_handler,
    workspace_handler = symbol_handler,
}
