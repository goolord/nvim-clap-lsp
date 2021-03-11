local function get_base(path)
    local len = #path
    for i = len , 1, -1 do
        if path:sub(i,i) == '/' then
            local ret =  path:sub(i+1,len)
            return ret
        end
    end
end

local function getDirectores(path)
    local data = {}
    local len = #path
    if len <= 1 then return nil end
    local last_index = 1
    for i = 2, len do
        local cur_char = path:sub(i,i)
        if cur_char == '/' then
            local my_data = path:sub(last_index + 1, i - 1)
            table.insert(data, my_data)
            last_index = i
        end
    end
    return data
end

local function get_relative_path(base_path, my_path)
    local base_data = getDirectores(base_path)
    local my_data = getDirectores(my_path)
    local base_len = #base_data
    local my_len = #my_data

    if base_len > my_len then
        return my_path
    end

    if base_data[1] ~= my_data[1] then
        return my_path
    end

    local cur = 0
    for i = 1, base_len do
        if base_data[i] ~= my_data[i] then
            break
        end
        cur = i
    end
    local data = ''
    for i = cur+1, my_len do
        data = data..my_data[i]..'/'
    end
    data = data..get_base(my_path)
    return data
end

return {
    get_relative_path = get_relative_path,
}
