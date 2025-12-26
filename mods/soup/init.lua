minetest.register_craftitem("soup:tomato_soup", {
    description = "Tomato Soup",
    inventory_image = "tomato_soup.png",
    on_use = minetest.item_eat(4),
})

minetest.register_craftitem("soup:mushroom_soup", {
    description = "Mushroom Soup",
    inventory_image = "mushroom_soup.png",
    on_use = minetest.item_eat(4),
})

minetest.register_craftitem("soup:chicken_noodle_soup", {
    description = "Chicken Noodle Soup",
    inventory_image = "chicken_noodle_soup.png",
    on_use = minetest.item_eat(20),
})