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

local gifts_path = minetest.get_modpath("witch_gifts")
local gifts = dofile(gifts_path .. "/gifts.lua")

minetest.register_on_craft(function(itemstack, crafter, recipe, inventory)
    local player_name = crafter:get_player_name()
    local item_name = itemstack:get_name()
    local knowledge = gifts.get_knowledge(player_name)

    if not knowledge[item_name] then
        minetest.chat_send_player(player_name, "Вы еще не знаете, как собрать этот предмет!")
        return ItemStack("")
    end
end)

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
    if not player then return end

    local item_name = itemstack:get_name()
    local player_name = player:get_player_name()

    local knowledge = gifts.get_knowledge(player_name)

    if not knowledge[item_name] then
        itemstack:clear()
    end
end)

minetest.register_on_newplayer(function(player)
    local player_name = player:get_player_name()
    local knowledge = gifts.get_knowledge(player_name)

    for _, item in ipairs(STARTING_KNOWLEDGE) do
        knowledge[item] = true
    end

    gifts.save_knowledge(player_name, knowledge)
end)