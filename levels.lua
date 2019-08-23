function blockOfBlocks(leveldata, x, y, width, height)
    for xx=x,x+width-1 do
        for yy=y-height+1,y do
            table.insert(leveldata, {type = 'block', x = xx, y = yy})
        end
    end
end

function rowOfGems(leveldata, x, y, width)
    for xx=x,x+width-1 do
        table.insert(leveldata, {type = 'gem', x = xx, y = y})
    end
end

function getLevelData(level)
    local LEVEL_DATA = {}

    if level == 1 then
        for i=0,8 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = -1, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 0, width = 1, height = 1})
        end

        for i=9,17 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 3, width = 1, height = 1})
        end

        table.insert(LEVEL_DATA, {type = 'mushroom', x = 13, y = 4})

        for i=18,30 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = -1, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 0, width = 1, height = 1})
        end

        for i=18,22 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 8, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'gem', x = i, y = 9, width = 1, height = 1})
        end

        table.insert(LEVEL_DATA, {type = 'goal', x = 25, y = 2, width = 2, height = 2})

    elseif level == 2 then
        for i=0,64 do
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = -1, width = 1, height = 1})
            table.insert(LEVEL_DATA, {type = 'block', x = i, y = 0, width = 1, height = 1})
        end

        table.insert(LEVEL_DATA, {type = 'block', x = 16, y = 4, width = 1, height = 1}) -- question
        table.insert(LEVEL_DATA, {type = 'gem', x = 16, y = 5})

        table.insert(LEVEL_DATA, {type = 'block', x = 20, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 21, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 22, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 23, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 24, y = 4, width = 1, height = 1})

        table.insert(LEVEL_DATA, {type = 'mushroom', x = 20, y = 1, initialDirection = -1})
        table.insert(LEVEL_DATA, {type = 'mushroom', x = 23, y = 5})

        table.insert(LEVEL_DATA, {type = 'block', x = 22, y = 8, width = 1, height = 1}) -- question
        table.insert(LEVEL_DATA, {type = 'gem', x = 22, y = 9})

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


        table.insert(LEVEL_DATA, {type = 'mushroom', x = 48, y = 1})
        table.insert(LEVEL_DATA, {type = 'mushroom', x = 51, y = 1})

        -- pipe
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 54, y = 4, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 1, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 2, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 3, width = 1, height = 1})
        table.insert(LEVEL_DATA, {type = 'block', x = 55, y = 4, width = 1, height = 1})

        blockOfBlocks(LEVEL_DATA, 67, 3, 5, 2)
        blockOfBlocks(LEVEL_DATA, 61, 6, 3, 2)

        blockOfBlocks(LEVEL_DATA, 61, 10, 1, 4)

        blockOfBlocks(LEVEL_DATA, 52, 13, 3, 1)
        rowOfGems(LEVEL_DATA, 52, 14, 3)

        blockOfBlocks(LEVEL_DATA, 67, 9, 6, 1)

        -- goal
        table.insert(LEVEL_DATA, {type = 'goal', x = 71, y = 11, width = 2, height = 2})
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