local path = minetest.get_modpath("witch_puzzles")
local puzzle = dofile(path .. "/puzzle.lua")
local gifts_path = minetest.get_modpath("witch_gifts")
local gifts = dofile(gifts_path .. "/gifts.lua")

minetest.register_node("witch_puzzles:puzzle_node", {
    description = "A puzzle...",
    drawtype = "mesh",
    mesh = "puzzle.obj",
    visual_scale = 0.25,
    paramtype = "light",
    tiles = { "puzzle.png" },
    drop = "",
    stack_max = 1,
    light_source = 12,
    selection_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
    },
    collision_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
    },
    inventory_image = "puzzle_src.png",
    use_texture_alpha = "clip",
    groups = { cracky = 2 },
    on_rightclick = function(pos, node, puncher, pointed_thing)
        if puncher:is_player() then
            if not puncher or not puncher:is_player() then
                return
            end

            local player_name = puncher:get_player_name()

            if not player_name or player_name == "" then
                return
            end

            local meta = minetest.get_meta(pos)

            local qr_view = meta:get_string("qr_matrix")
            local qr_word = meta:get_string("qr_word")
            local gift = meta:get_string("gift")

            if qr_view == "" or qr_word == "" or gift == "" then
                local qr_data = puzzle.generate_qr()
                gift = gifts.generate_gift(player_name)

                qr_view = qr_data.matrix
                qr_word = qr_data.word

                meta:set_string("qr_matrix", qr_view)
                meta:set_string("qr_word", qr_word)
                meta:set_string("gift", gift)
            end

            local alphabet = "Алфавит: А Б В Г Д Е Ё Ж З И Й К..."
            local combinations = table.concat(puzzle.runas)
            local instructions =
            "Инструкция: Сопоставьте символы QR-кода с алфавитом\nи введите полученное слово в поле ниже."

            local formspec = {
                "formspec_version[6]",
                "size[10,12]",
                "real_coordinates[true]",

                "scroll_container[0.5,0.5;9,11;scroll_box;vertical;0.1]",

                -- 1. "QR-код" (View)
                "label[0,0.5;Визуальный код:]",
                "textarea[0,1;9,4;qr_display;;" .. minetest.formspec_escape(qr_view) .. "]",

                -- НОВОЕ: Отображение награды (между QR и вводом)
                "label[0,5.1;Награда за решение:]",
                "label[3.5,5.1; " .. minetest.formspec_escape(gift) .. "]",
                -- Если gift — это техническое имя, можно добавить цвет (например, зеленый #00FF00)

                -- 2. Поле ввода и кнопка (сдвинули чуть ниже, y изменился с 5.5 на 6.0)
                "field[0,6.2;6,0.8;answer;Введите ответ;]",
                "button[6.5,6.2;2.5,0.8;sendbtn;Отправить]",

                -- 3. Алфавит (тоже сдвигаем ниже)
                "label[0,7.5;Доступные символы:]",
                "textarea[0,7.8;9,1;alphabet_lbl;;" .. minetest.formspec_escape(alphabet) .. "]",

                -- 4. Комбинации слов
                "label[0,9.0;Таблица комбинаций:]",
                "textarea[0,9.3;9,1;combos_lbl;;" .. minetest.formspec_escape(combinations) .. "]",

                -- 5. Инструкция
                "label[0,10.5;Как решать:]",
                "textarea[0,10.8;9,1.2;inst_lbl;;" .. minetest.formspec_escape(instructions) .. "]",
                "scroll_container_end[]",

                "scrollbar[9.6,0.5;0.3,11;vertical;scroll_bar;0]"
            }

            local formname = "witch_puzzles:dialog:" .. pos.x .. ":" .. pos.y .. ":" .. pos.z
            minetest.show_formspec(puncher:get_player_name(), formname, table.concat(formspec, ""))
        end
    end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if string.sub(formname, 1, 21) ~= "witch_puzzles:dialog:" then
        return false
    end

    local x, y, z = formname:match("witch_puzzles:dialog:(%-?%d+):(%-?%d+):(%-?%d+)")
    local pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }

    if fields.sendbtn then
        local meta = minetest.get_meta(pos)
        local correct_answer = meta:get_string("qr_word")
        local user_answer = fields.answer or ""

        if user_answer:lower() == correct_answer:lower() then
            minetest.chat_send_player(player:get_player_name(), "Правильно!")

            minetest.add_particlespawner({
                amount = 20,
                time = 0.1,
                minpos = pos,
                maxpos = pos,
                minvel = { x = -1, y = 1, z = -1 },
                maxvel = { x = 1, y = 2, z = 1 },
                minacc = { x = 0, y = -5, z = 0 },
                maxacc = { x = 0, y = -9, z = 0 },
                minexptime = 1,
                maxexptime = 3,
                minsize = 1,
                maxsize = 2,
                texture = "default_paper.png",
            })

            minetest.sound_play("default_break_glass", { pos = pos, gain = 0.5 })
            minetest.remove_node(pos)
        else
            minetest.chat_send_player(player:get_player_name(), "Неверно.")
        end
        return true
    end
end)

minetest.register_decoration({
    name = "witch_puzzles:puzzle_node_decor",
    deco_type = "simple",
    place_on = { "default:dirt_with_grass", "default:desert_sand", "default:dirt_with_snow", "default:dirt",
        "default:sand", "default:stone", "default:gravel", 'everness:moss_block', 'everness:dirt_with_grass_1',
        'everness:coral_forest_deep_ocean_sand', 'everness:coral_sand', 'everness:coral_sand',
        'everness:coral_white_sand', 'everness:dirt_with_coral_grass', 'everness:crystal_forest_deep_ocean_sand',
        'everness:crystal_sand', 'everness:crystal_cave_dirt_with_moss', 'everness:dirt_with_crystal_grass',
        'everness:cursed_lands_deep_ocean_sand', 'everness:dirt_with_cursed_grass',
        'everness:cursed_dirt', 'everness:cursed_sand', 'everness:cursed_stone', 'everness:soul_sandstone_veined',
        'everness:forsaken_desert_sand', 'everness:forsaken_desert_chiseled_stone', 'everness:forsaken_desert_brick',
        'everness:forsaken_desert_engraved_stone', 'everness:forsaken_tundra_beach_sand', 'everness:mold_stone_with_moss',
        'everness:blue_crying_obsidian', 'everness:blue_weeping_obsidian', 'everness:weeping_obsidian',
        'everness:volcanic_sulfur', 'everness:sulfur_stone', 'everness:ancient_emerald_ice',
        'everness:dense_emerald_ice', 'everness:emerald_ice', 'everness:frosted_ice',
        'everness:frosted_ice_translucent', 'everness:frosted_snowblock', 'everness:mineral_cave_stone',
        'everness:mineral_lava_stone', 'everness:mineral_cave_stone', 'everness:mineral_sand',
        "mcl_core:dirt_with_grass", "ethereal:grove_dirt", "ethereal:prairie_dirt", "default:dirt_with_rainforest_litter",
        "ethereal:bamboo_dirt", "default:dirt_with_coniferous_litter", "ethereal:grove_dirt" },
    sidelen = 16,
    fill_ratio = 0.0005,
    decoration = "witch_puzzles:puzzle_node",
    height = 1,
    param2 = 0,
    param2_max = 3,
})
