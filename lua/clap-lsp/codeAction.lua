local code_action_cache = {}
local ctx

local function preview(action)
    local res = {}
    local syntax
    local function render_preview(lines, hl_syn)
        vim.fn['clap#preview#show_lines'](lines, hl_syn, -1)
        vim.fn['clap#preview#highlight_header']()
    end
    if action.edit ~= nil and action.edit.changes ~= nil then
        for file, x in pairs(action.edit.changes) do
            syntax = vim.fn['clap#ext#into_filetype'](tostring(file))
            table.insert(res,tostring(file))
            for _, line in ipairs(x) do
                table.insert(res,line.newText)
            end
        end
    end

    if action.command ~= nil then
        print('action.command ~= nil\n', vim.inspect(action.command))
        -- todo?
    end

    if #res ~= 0 then render_preview(res, syntax or 'txt') end
end

local function get_index(input)
    return tonumber(string.match(input, "^(%d*)"))
end

local function on_move_impl()
    local curline = vim.api.nvim_call_dict_function('g:clap.display' , 'getcurline', {})
    local index = get_index(curline)
    preview(code_action_cache[index])
end

local function codeaction_sink(selected)
    local index = get_index(selected)
    local action = code_action_cache[index]
    if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if action.command then
        local command = type(action.command) == 'table' and action.command or action
        local fn = vim.lsp.commands[command.command]
        if fn then
            fn(command, ctx)
        else
            vim.lsp.buf.execute_command(action.command)
        end
    end
end

-- codeAction event callback handler
-- use customSelectionHandler for defining custom way to handle selection
local code_action_handler = function(_, actions, ctx_l, _, _)
    ctx = ctx_l
    if actions == nil or vim.tbl_isempty(actions) then
        print("No code actions available")
        return
    end
    local data = {}
    for i, action in ipairs (actions) do
        code_action_cache[i] = action
        local title = action.title:gsub('\r\n', '\\r\\n')
        title = title:gsub('\n','\\n')
        title = title:gsub(string.char(0),'')
        data[i] = i .. ': ' .. title
    end
    local provider = {
        source = data,
        sink = codeaction_sink,
        on_move = on_move_impl,
        on_enter = on_move_impl,
        -- syntax = 'clap-lsp-symbol'
    }
    vim.fn['clap#run'](provider)
    vim.api.nvim_input('<ESC>')
end

return {
    code_action_handler = code_action_handler,
}
