local gifts = {}

gifts.storage = minetest.get_mod_storage()

gifts.get_knowledge = function(player_name)
    local data = gifts.storage:get_string(player_name)
    return minetest.deserialize(data) or {}
end

gifts.save_knowledge = function(player_name, data)
    gifts.storage:set_string(player_name, minetest.serialize(data))
end

local function collect_recipes(knowledge)
    local locked_items={}
    
    for name, def in pairs(minetest.registered_items) do
        local recipes = minetest.get_all_craft_recipes(name)
        if recipes and #recipes > 0 and name ~= "air" and name ~= "ignore" and not knowledge[name] then
            table.insert(locked_items, name)
        end
    end

    return locked_items
end

gifts.generate_gift = function(player_name)
    local knowledge = gifts.get_knowledge(player_name)
    local locked_items = collect_recipes(knowledge)

    if #locked_items == 0 then
        return "все рецепты собраны"
    else
        local random_index = math.random(#locked_items)
        return locked_items[random_index]
    end
end

gifts.unlock_recipe = function(player_name, item_name)
    local knowledge = gifts.get_knowledge(player_name)
    if not knowledge[item_name] then
        knowledge[item_name] = true
        gifts.save_knowledge(player_name, knowledge)
        minetest.chat_send_player(player_name, "Новое знание: вы научились крафтить " .. item_name)
    end
end

return gifts
