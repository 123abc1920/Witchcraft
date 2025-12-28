local puzzles = {}

puzzles.alphabet = {
    a = 0,
    b = 1,
    c = 2,
    d = 3,
    e = 4,
    f = 5,
    g = 6,
    h = 7,
    i = 8,
    j = 9,
    k = 10,
    l = 11,
    m = 12,
    n = 13,
    o = 14,
    p = 15,
    q = 16,
    r = 17,
    s = 18,
    t = 19,
    u = 20,
    v = 21,
    w = 22,
    x = 23,
    y = 24,
    z = 25
}

puzzles.runas = {
    "feh", "ur", "os", "rada"
}

local function print_matrix(matrix)
    for i = 1, #matrix do
        local row = ""
        for j = 1, #matrix[i] do
            row = row .. tostring(matrix[i][j]) .. " "
        end
        print(row)
    end
end

local function bin(num)
    if num == 0 then return "0" end

    local binary = ""
    while num > 0 do
        binary = tostring(num % 2) .. binary
        num = math.floor(num / 2)
    end

    return binary
end

local function fill_matrix(word_code, qr_matrix)
    local x = 6
    local y = 6
    local dy = -1
    for i = 1, #word_code do
        if y > 6 then
            x = x - 1
            y = 6
            dy = -1
        end
        if y < 1 then
            x = x - 1
            y = 1
            dy = 1
        end

        if qr_matrix[y][x] == 1 then
            dy = -dy
            y = y + dy
            x = x - 1
            if x < 1 then break end
        end

        if qr_matrix[y][x] ~= 1 then
            qr_matrix[y][x] = tonumber(string.sub(word_code, i, i))
        end

        y = y + dy
    end

    return qr_matrix
end

local function prepare_random()
    math.randomseed(os.time())
    for i = 1, 5 do
        math.random()
    end
end

puzzles.generate_qr = function()
    prepare_random()
    local index1 = math.random(1, #puzzles.runas)
    local index2 = math.random(1, #puzzles.runas)
    local text = puzzles.runas[index1] .. puzzles.runas[index2]

    local word_code = ""

    for i = 1, #text do
        local letter = string.sub(text, i, i)
        local number = puzzles.alphabet[letter]
        local code = bin(number)
        word_code = word_code .. code
    end

    local qr_matrix = { { 0, 1, 0, 0, 1, 0 }, { 1, 1, 0, 0, 1, 1 },
        { 1, 1, 0, 0, 1, 1 }, { 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0 },
        { 0, 0, 0, 0, 0, 0 } }

    qr_matrix = fill_matrix(word_code, qr_matrix)

    local rotations = math.random(0, 3)
    for r = 1, rotations do
        local rotated = { { 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0 } }
        for y = 1, 6 do
            for x = 1, 6 do
                rotated[x][7 - y] = qr_matrix[y][x]
            end
        end
        qr_matrix = rotated
    end

    for y = 1, 6 do
        for x = 1, 6 do
            if math.random() < 0.2 then
                qr_matrix[y][x] = " "
            end
        end
    end

    local symbols = {
        [0] = " ",
        [1] = "█",
        [2] = "▒"
    }
    local draw_matrix = ""
    for y = 1, 6 do
        for x = 1, 6 do
            local val = qr_matrix[y][x]
            local draw = symbols[0]
            if val == 1 then
                draw = symbols[1]
            end
            if val == 0 then
                draw = symbols[2]
            end
            draw_matrix = draw_matrix .. draw
        end
        draw_matrix = draw_matrix .. "\n"
    end

    return { word = text, matrix = draw_matrix }
end

return puzzles
