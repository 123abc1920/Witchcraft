local path = minetest.get_modpath("witch_puzzles")
local puzzle = dofile(path .. "/puzzle.lua")

minetest.register_node("witch_puzzles:puzzle_node", {
    description = "A puzzle...",
    drawtype = "mesh",
    mesh = "puzzle.obj",
    visual_scale = 0.25,
    paramtype = "light",
    tiles = { "puzzle.png" },
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

            minetest.chat_send_player(player_name, qr_word)

            if qr_view == "" or qr_word == "" then
                local qr_data = puzzle.generate_qr()

                qr_view = qr_data.matrix
                qr_word = qr_data.word

                meta:set_string("qr_matrix", qr_view)
                meta:set_string("qr_word", qr_word)
            end

            local alphabet = "Алфавит: А Б В Г Д Е Ё Ж З И Й К..."
            local combinations = table.concat(puzzle.runas)
            local instructions =
            "Инструкция: Сопоставьте символы QR-кода с алфавитом\nи введите полученное слово в поле ниже."

            local formspec = {
                "formspec_version[6]",
                "size[10,12]",            -- Увеличили размер окна
                "real_coordinates[true]", -- Используем современную сетку координат

                -- Начало контейнера прокрутки
                -- [позиция_x, y; ширина, высота; имя; ориентация; коэф_прокрутки]
                "scroll_container[0.5,0.5;9,11;scroll_box;vertical;0.1]",

                -- 1. "QR-код" (View)
                "label[0,0.5;Визуальный код:]",
                -- Используем textarea для вывода многострочного кода (readonly)
                "textarea[0,1;9,4;qr_display;;" .. minetest.formspec_escape(qr_view) .. "]",

                -- 2. Поле ввода и кнопка
                "field[0,5.5;6,0.8;answer;Введите ответ;]",
                "button[6.5,5.5;2.5,0.8;sendbtn;Отправить]",

                -- 3. Алфавит
                "label[0,7;Доступные символы:]",
                "textarea[0,7.3;9,1;alphabet_lbl;;" .. minetest.formspec_escape(alphabet) .. "]",

                -- 4. Комбинации слов
                "label[0,8.5;Таблица комбинаций:]",
                "textarea[0,8.8;9,1;combos_lbl;;" .. minetest.formspec_escape(combinations) .. "]",

                -- 5. Инструкция
                "label[0,10;Как решать:]",
                "textarea[0,10.3;9,1.5;inst_lbl;;" .. minetest.formspec_escape(instructions) .. "]",
                "scroll_container_end[]",

                -- Добавляем полосу прокрутки, чтобы управлять контейнером
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
        else
            minetest.chat_send_player(player:get_player_name(), "Неверно.")
        end
        return true
    end
end)
