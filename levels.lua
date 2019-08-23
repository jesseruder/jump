function getLevelData(level)
    local LEVEL_DATA = {}

    if level == 1 then
        for i=0,64 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = -1, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 0, width = 1, height = 1})
        end

        table.insert(LEVEL_DATA, {type = 'block', x = 16, y = 4, width = 1, height = 1}) -- question

        table.insert(LEVEL_DATA, {type = 'block', x = 20, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 21, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 22, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 23, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 24, y = 4, width = 1, height = 1})

        table.insert(LEVEL_DATA, {type = 'mushroom', x = 23, y = 5})

        table.insert(LEVEL_DATA, {type = 'block', x = 22, y = 8, width = 1, height = 1}) -- question

        -- pipe
        table.insert(LEVEL_DATA, {type = 'block', x = 28, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 28, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 29, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 29, y = 2, width = 1, height = 1})

        table.insert(LEVEL_DATA, {type = 'mushroom', x = 31, y = 1})

        -- pipe
        table.insert(LEVEL_DATA, {type = 'block', x = 37, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 37, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 37, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 38, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 38, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 38, y = 3, width = 1, height = 1})

        -- pipe
        table.insert(LEVEL_DATA, {type = 'block', x = 44, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 44, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 44, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 44, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 45, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 45, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 45, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 45, y = 4, width = 1, height = 1})

        -- pipe
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 4, width = 1, height = 1})

        for i=67,200 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = -1, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 0, width = 1, height = 1})
        end

        -- goal
        table.insert(LEVEL_DATA, {type = 'goal', x = 70, y = 2, width = 2, height = 2})
    else
        for i=0,64 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = -1, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 0, width = 1, height = 1})
        end

        -- goal
        table.insert(LEVEL_DATA, {type = 'goal', x = 60, y = 2, width = 2, height = 2})
    end

    return LEVEL_DATA
end