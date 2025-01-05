-- Sugar
minetest.register_craftitem("witch_items:sugar", {
    description = "Sugar",
    inventory_image = "sugar.png"
})

minetest.register_craft({
    type = "shapeless",
    output = "witch_items:sugar",
    recipe = {"default:papyrus"},
})