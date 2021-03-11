local util = require'clap-lsp.util'

-- callback for lsp definition, implementation and declaration handler
local definition_handler = function(_,_,locations, _, bufnr)
    if locations == nil or vim.tbl_isempty(locations) then
        return
    end
    if vim.tbl_islist(locations) then
        if #locations > 1 then
            local data = {}
            local filename = vim.api.nvim_buf_get_name(bufnr)
            items = vim.lsp.util.locations_to_items(locations)
            for i, item in pairs(items) do
                data[i] = item.text
                if filename ~= item.filename then
                    local cwd = vim.fn.getcwd(0)..'/'
                    local add = util.get_relative_path(cwd, item.filename)
                    data[i] = data[i]..' - '..add
                end
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

return {
    definition_handler = definition_handler,
}
