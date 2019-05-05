local presets = {}

--merge 2 presets,
--requests and trash are set to max(current, preset)
--if one preset has trash set to false it is set to a non false value
--slot from current are kept
function presets.merge(current, preset)
    local result = util.table.deepcopy(current)
    local b = util.table.deepcopy(preset)
    local no_slot = {}
    local tmp
    local max_slot = 0

    for j, result_config in pairs(result.config) do
        tmp = result_config
        for i, config in pairs(b.config) do
            if config.name == result_config.name then
                tmp.request = (config.request > tmp.request) and config.request or tmp.request
                tmp.trash = (config.trash and tmp.trash and config.trash > tmp.trash) and config.trash or tmp.trash
                tmp.trash = (tmp.trash and tmp.trash < tmp.request) and tmp.request or tmp.trash
                b.config[i] = nil
                max_slot = max_slot > tmp.slot and max_slot or tmp.slot
                break
            end
        end
    end
    for i, config in pairs(b.config) do
        assert(i==config.slot)
        if not result.config[config.slot] then
            result.config[config.slot] = config
        else
            no_slot[#no_slot + 1] = config
        end
        max_slot = max_slot > config.slot and max_slot or config.slot
    end

    local start = 1
    --log(max_slot .. " " .. #no_slot)
    for _, s in pairs(no_slot) do
        for i = start, max_slot + #no_slot do
            if not result.config[i] then
                s.slot = i
                result.config[i] = s
                start = i + 1
                break
            end
        end
    end
    --log(serpent.block(result, {name="test"}))
    return result
end

return presets