-- apple pie

minetest.register_craftitem("pies:apple_pie", {
    description = "Apple Pie",
    inventory_image = "apple_pie.png",
    on_use = minetest.item_eat(3)
})

minetest.register_craft({
    output = "pies:apple_pie",
    recipe = {
        { "farming:wheat",        "default:apple",              "farming:wheat" },
        { "witch_items:sugar", "bottles:bottle_of_water",    "witch_items:sugar" },
        { "animalia:bucket_milk", "animalia:chicken_egg_fried", "" }
    }
})

-- blueberry pie

minetest.register_craftitem("pies:blueberry_pie", {
    description = "Blueberry Pie",
    inventory_image = "apple_pie.png",
    on_use = minetest.item_eat(3)
})

minetest.register_craft({
    output = "pies:blueberry_pie",
    recipe = {
        { "farming:wheat",        "default:blueberries",        "farming:wheat" },
        { "witch_items:sugar", "bottles:bottle_of_water",    "witch_items:sugar" },
        { "animalia:bucket_milk", "animalia:chicken_egg_fried", "" }
    }
})
