local function to_fp(selected)
    return string.match(selected, ".* - (.*):(%d*)")
end

local function on_move_impl()
    local curline = vim.api.nvim_call_dict_function('g:clap.display' , 'getcurline', {})
    local curfp,lnum = to_fp(curline)
    vim.fn['clap#preview#file_at'](curfp,lnum)
end

local function locations_sink(selected)
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
                local text = item.text
                text = text:gsub("\n", "\\n")
                text = text:gsub("^%s+", "")
                text = text:gsub("%s+$", "")
                data[i] = item.text
                local fn = vim.fn.fnamemodify(item.filename, ':~:.')
                data[i] = data[i] .. ' - ' .. fn .. ':' .. item.lnum
                item.text = nil
            end
            local provider = {
                source = data,
                sink = locations_sink,
                on_move = on_move_impl,
                support_open_actoin = true,
                syntax = 'clap-lsp-locations'
            }
            vim.fn['clap#run'](provider)
            on_move_impl()
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
        local text = item.text
        text = text:gsub("\n", "\\n")
        text = text:gsub("^%s+", "")
        text = text:gsub("%s+$", "")
        data[i] = text
        local fn = vim.fn.fnamemodify(item.filename, ':~:.')
        data[i] = data[i] .. ' - ' .. fn .. ':' .. item.lnum
        items.text = nil
    end

    local provider = {
        source = data,
        sink = locations_sink,
        on_move = on_move_impl,
        on_enter = on_move_impl,
        support_open_actoin = true,
        syntax = 'clap-lsp-locations'
    }
    vim.fn['clap#run'](provider)
end

return {
    definition_handler = definition_handler,
    references_handler = references_handler,
}
