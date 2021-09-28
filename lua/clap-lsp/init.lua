Clap_preview = {}

local function get_index(input)
    return tonumber(string.match(input, "^(%d*)"))
end

local function converter_impl(input)
    return input:gsub("^%d*: ", "")
end

function vim.ui.select(items, opts, on_choice)
    local data = {}
    for i, item in ipairs (items) do
        data[i] = tostring(i) .. ': ' .. opts.format_item(item)
    end
    local function sink(curline)
        return on_choice(items[get_index(curline)])
    end
    local function on_move_impl()
        local curline = vim.api.nvim_call_dict_function('g:clap.display' , 'getcurline', {})
        if opts.prompt then
            return Clap_preview[opts.prompt] (items[get_index(curline)])
        end
    end
    local provider = {
        source = data,
        sink = sink,
        on_move = on_move_impl,
        on_enter = on_move_impl,
        converter = converter_impl
        -- syntax = 'clap-lsp-symbol'
    }

    if opts.prompt then
        provider.prompt_format = '%spinner%%forerunner_status%* ' .. opts.prompt
    end

    vim.fn['clap#run'](provider)
    vim.api.nvim_input('<ESC>')
end

-- codeaction previewer
Clap_preview['Code actions:'] = function (action)
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
        local str = vim.inspect(action.command)
        local lines = {'Command: '}
        for s in str:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end
        render_preview(lines, 'txt')
    end

    if #res ~= 0 then render_preview(res, syntax or 'txt') end
end
