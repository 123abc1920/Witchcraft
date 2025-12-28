local storage = minetest.get_mod_storage()

local function get_knowledge(player_name)
    return minetest.deserialize(storage:get_string(player_name)) or {}
end

local function save_knowledge(player_name, data)
    storage:set_string(player_name, minetest.serialize(data))
end

minetest.register_on_craft(function(itemstack, crafter, recipe, inventory)
    local player_name = crafter:get_player_name()
    local item_name = itemstack:get_name()
    local knowledge = get_knowledge(player_name)

    if not knowledge[item_name] then
        minetest.chat_send_player(player_name, "Вы еще не знаете, как собрать этот предмет!")
        return ItemStack("")
    end
end)

function unlock_recipe(player_name, item_name)
    local knowledge = get_knowledge(player_name)
    if not knowledge[item_name] then
        knowledge[item_name] = true
        save_knowledge(player_name, knowledge)
        minetest.chat_send_player(player_name, "Новое знание: вы научились крафтить " .. item_name)
    end
end

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
    if not player then return end

    local item_name = itemstack:get_name()
    local player_name = player:get_player_name()

    local knowledge = get_knowledge(player_name)

    if not knowledge[item_name] then
        itemstack:clear()
    end
end)

local STARTING_KNOWLEDGE = {
    "default:wood",
    "default:stick",
    "default:torch",
    "default:fence_wood",
    "default:fence_acacia_wood",
    "default:fence_junglewood",
    "default:fence_pine_wood",
    "default:fence_aspen_wood",
    "default:chest",
    "default:furnace",
    "default:sword_wood"
}

minetest.register_on_newplayer(function(player)
    local player_name = player:get_player_name()
    local knowledge = get_knowledge(player_name)

    for _, item in ipairs(STARTING_KNOWLEDGE) do
        knowledge[item] = true
    end

    save_knowledge(player_name, knowledge)
end)
