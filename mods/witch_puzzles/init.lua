minetest.register_node("witch_puzzles:puzzle_node", {
    description = "A puzzle...",
    drawtype = "mesh",
    mesh = "puzzle.obj",
    visual_scale = 0.25,
    paramtype = "light",
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
    },
    collision_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
    },
    inventory_image = "puzzle_src.png",
    use_texture_alpha = "clip",
    groups = {cracky = 2},
	on_punch = function(pos, node, puncher, pointed_thing)
        if puncher:is_player() then
			if not puncher or not puncher:is_player() then
				return
			end
			
			local player_name = puncher:get_player_name()
			
			if not player_name or player_name == "" then
				return
			end
			
			minetest.show_formspec(player_name, "witch_puzzles:dialog",
				"size[8,5]" ..
				"label[0.5,0.5;Диалог с пазлом]" ..
				"checkbox[0.5,1.5;glow;Свечение;]" ..
				"dropdown[0.5,2.5;3,1;color;Красный,Зеленый,Синий,Желтый;]" ..
				"field[0.5,4;3,1;rotation;Вращение (градусы);]" ..
				"textarea[4,1;3.5,5;hint;Подсказка;]" ..
				"button[0.5,5.5;3,1;save;Сохранить]" ..
				"button[4,5.5;3,1;reset;Сбросить]" ..
				"button_exit[6.5,6;1.5,1;close;X]"
			)
			end
    end
})