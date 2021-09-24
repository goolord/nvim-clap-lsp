-- local inspect = require('inspect')

local code_action_cache = {}

local function preview(action)
    local res = {}
    local function render_preview(lines)
        vim.fn['clap#preview#show_lines'](lines, 'txt', -1)
    end

    if action.edit ~= nil and action.edit.changes ~= nil then
        for file, x in ipairs(action.edit.changes) do
            table.insert(res,tostring(file))
            for _, line in ipairs(x) do
                table.insert(res,line.newText)
            end
        end
    end

    if action.command ~= nil then
        -- todo?
    end

    if #res ~= 0 then render_preview(res) end
end

local function get_index(input)
    return tonumber(string.match(input, "^(%d*)"))
end

local function on_move_impl()
    vim.cmd('let g:clap_lsp_curline = g:clap.display.getcurline()')
    local curline = vim.api.nvim_get_var('clap_lsp_curline')
    local index = get_index(curline)
    preview(code_action_cache[index])
end

local function codeaction_sink(selected)
    local index = get_index(selected)
    local action = code_action_cache[index]
    if action.edit or type(action.command) == "table" then
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit)
        end
        if type(action.command) == "table" then
            vim.lsp.buf.execute_command(action.command)
        end
    else
        vim.lsp.buf.execute_command(action)
    end
end

-- codeAction event callback handler
-- use customSelectionHandler for defining custom way to handle selection
local code_action_handler = function(_, actions, _, _, _)
    if actions == nil or vim.tbl_isempty(actions) then
        print("No code actions available")
        return
    end
    local data = {}
    for i, action in ipairs (actions) do
        table.insert(code_action_cache, i, action)
        local title = action.title:gsub('\r\n', '\\r\\n')
        title = title:gsub('\n','\\n')
        data[i] = i .. ': ' .. title
        data[i] = data[i]:gsub("\n", "")
    end
    local provider = {
        source = data,
        sink = codeaction_sink,
        on_move = on_move_impl,
        -- syntax = 'clap-lsp-symbol'
    }
    vim.fn['clap#run'](provider)
    on_move_impl()
    vim.api.nvim_input('<ESC>')
end

return {
    code_action_handler = code_action_handler,
}
