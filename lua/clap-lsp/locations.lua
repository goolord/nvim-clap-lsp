local util = require'clap-lsp.util'

local function to_fp(selected)
    return string.match(selected, ".* - (.*):(%d*)")
end

local function on_move_impl()
    vim.cmd('let g:clap_lsp_curline = g:clap.display.getcurline()')
    local curline = vim.api.nvim_get_var('clap_lsp_curline')
    local curfp,lnum = to_fp(curline)
    vim.fn['clap#preview#file_at'](curfp,lnum)
end

local function references_sink(selected)
    local fp,lnum = to_fp(selected)
    vim.cmd('edit +' .. lnum .. ' ' .. fp)
end

-- callback for lsp definition, implementation and declaration handler
local function definition_handler(_, locations, _, _)
    -- local bufnr = ctx.bufnr
    if locations == nil or vim.tbl_isempty(locations) then
        return
    end
    if vim.tbl_islist(locations) then
        if #locations > 1 then
            local data = {}
            -- local filename = vim.api.nvim_buf_get_name(bufnr)
            local items = vim.lsp.util.locations_to_items(locations)
            for i, item in ipairs(items) do
                data[i] = item.text
                local add = vim.fn.fnamemodify(item.filename, ':~:.')
                data[i] = data[i] .. ' - ' .. add
                data[i] = data[i]:gsub("\n", "")
                item.text = nil
            end
            local provider = {
                source = data,
                sink = 'e',
            }
            vim.fn['clap#run'](provider)
        else
            vim.lsp.util.jump_to_location(locations[1])
        end
    else
        vim.lsp.util.jump_to_location(locations)
    end
end

local function references_handler(_, locations, _, _)
    -- local bufnr = ctx.bufnr
    if locations == nil or vim.tbl_isempty(locations) then
        print "No references found"
        return
    end
    local data = {}
    -- local filename = vim.api.nvim_buf_get_name(bufnr)
    local items = vim.lsp.util.locations_to_items(locations)
    for i, item in ipairs(items) do
        data[i] = item.text
        local add = vim.fn.fnamemodify(item.filename, ':~:.')
        data[i] = data[i] .. ' - ' .. add .. ':' .. item.lnum
        data[i] = data[i]:gsub("\n", "")
        data[i] = data[i]:gsub("^%s+", "")
        data[i] = data[i]:gsub("%s+$", "")
        items.text = nil
    end

    local provider = {
        source = data,
        sink = references_sink,
        on_move = on_move_impl,
        syntax = 'clap-lsp-locations'
    }
    vim.fn['clap#run'](provider)
    on_move_impl()
end

return {
    definition_handler = definition_handler,
    references_handler = references_handler,
}
