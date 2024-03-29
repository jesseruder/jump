-- https://web.archive.org/web/20130807122227/http://i276.photobucket.com/albums/kk21/jdaster64/smb_playerphysics.png

require "levels"

-- Render constants
local RENDER_SCALE = 2.0

-- Game constants
local BLOCK_SIZE = 16
local ORIGINAL_FPS = 60

function TO_WORLD_UNITS(x)
  -- https://web.archive.org/web/20130807122227/http://i276.photobucket.com/albums/kk21/jdaster64/smb_playerphysics.png
  return (x / 0x10000) * BLOCK_SIZE
end

-- horizontal movement
local MINIMUM_WALK_VELOCITY = 0x00130
local MAXIMUM_WALK_VECLOCITY = 0x01900
local WALK_ACCELERATION = 0x00098
local MAXIMUM_WALK_VELOCITY_UNDERWATER = 0x01100
local RUN_ACCELERATION = 0x000E4
local MAXIMUM_WALK_VELOCITY_LEVEL_ENTRY = 0x00D00
local RELEASE_DECELERATION = 0x000D0
local MAXIMUM_RUN_VELOCITY = 0x02900
local SKID_DECELERATION = 0x001A0
local SKID_TURNAROUND_SPEED = 0x00900
local ENEMY_STOMP_SPEED = -0x06000

-- Game variables
local player
local platforms
local goal
local gems
local enemies
local lastCollisionSoundTime = 0.0
local level = 1
local score = 0

-- Assets
local playerImage
local objectsImage
local walkSounds
local jumpSound
local landSound
local gemSound

function die()
  score = score - 5
  if score < 0 then
    score = 0
  end
  resetGame()
end

function resetGame()
  -- Create platforms and game objects from the level data
  platforms = {}
  gems = {}
  enemies = {}

  -- Create the player
  player = {
    x = BLOCK_SIZE * 1,
    y = BLOCK_SIZE * 15,
    vx = 0,
    vy = 0,
    lastDirection = 1,
    landingTimer = 0,
    walkTimer = 0,
    holdingAGravity = 0x00280,
    fallingGravity = 0x00280,
    elapsedTime = 0,
    runUntilTime = 0,
    width = BLOCK_SIZE,
    height = BLOCK_SIZE,
    isGrounded = false,
    isHoldingA = false,
    startJumpVx = 0,
    screenScrollX = 0,
    screenScrollY = 0,
  }

  local levelData = getLevelData(level)
  for _, obj in ipairs(levelData) do
    if obj.type == 'block' then
      table.insert(platforms, {
        x = gridXToWorldX(obj.x),
        y = gridYToWorldY(obj.y),
        width = BLOCK_SIZE,
        height = BLOCK_SIZE,
      })
    elseif obj.type == 'movingblock' then
      table.insert(platforms, {
        x = gridXToWorldX(obj.x),
        y = gridYToWorldY(obj.y),
        width = BLOCK_SIZE,
        height = BLOCK_SIZE,

        originalX = gridXToWorldX(obj.x),
        originalY = gridYToWorldY(obj.y),
        offsetX = BLOCK_SIZE * obj.offsetX,
        offsetY = -BLOCK_SIZE * obj.offsetY,
        cycleTime = obj.cycleTime,
        cycleOffset = obj.cycleOffset or 0
      })
    elseif obj.type == 'mushroom' then
      table.insert(enemies, {
        x = gridXToWorldX(obj.x),
        y = gridYToWorldY(obj.y),
        width = BLOCK_SIZE,
        height = BLOCK_SIZE,
        type = 'mushroom',
        vx = 0x00800 * (obj.initialDirection or 1),
        vy = 0,
        isActive = true
      })
    elseif obj.type == 'goal' then
      goal = {
        x = gridXToWorldX(obj.x),
        y = gridYToWorldY(obj.y),
        width = obj.width * BLOCK_SIZE,
        height = obj.height * BLOCK_SIZE
      }
    elseif obj.type == 'gem' then
      table.insert(gems, {
        x = gridXToWorldX(obj.x),
        y = gridYToWorldY(obj.y),
        width = BLOCK_SIZE,
        height = BLOCK_SIZE,
        isCollected = false
      })
    end
  end
end

function gridXToWorldX(x)
  return x * BLOCK_SIZE
end

function gridYToWorldY(y)
  return (16 - y) * BLOCK_SIZE
end

-- Initializes the game
function love.load()
  -- Load assets
  playerImage = love.graphics.newImage('img/player.png')
  objectsImage = love.graphics.newImage('img/objects.png')
  playerImage:setFilter('nearest', 'nearest')
  objectsImage:setFilter('nearest', 'nearest')
  walkSounds = {
    love.audio.newSource('sfx/walk1.wav', 'static'),
    love.audio.newSource('sfx/walk2.wav', 'static')
  }
  jumpSound = love.audio.newSource('sfx/jump.wav', 'static')
  landSound = love.audio.newSource('sfx/land.wav', 'static')
  gemSound = love.audio.newSource('sfx/gem.wav', 'static')

  BigFont = love.graphics.newFont(20)

  resetGame()
end

function isJumpKey(key)
  return key == 'space' or key == 'up'
end

function love.keypressed(key, scancode, isrepeat)
  local moveX = (key == 'left' and -1 or 0) + (key == 'right' and 1 or 0)

  if player.vx == 0 then
    player.vx = moveX * MINIMUM_WALK_VELOCITY
  end

  if isJumpKey(key) and player.isGrounded then
    player.isHoldingA = true
    player.startJumpVx = player.vx

    if math.abs(player.vx) < 0x01000 then
      player.vy = -0x4000
      player.holdingAGravity = 0x00200
      player.fallingGravity = 0x00700
    elseif math.abs(player.vx) < 0x02500 then
      player.vy = -0x4000
      player.holdingAGravity = 0x001E0
      player.fallingGravity = 0x00600
    else
      player.vy = -0x5000
      player.holdingAGravity = 0x00280
      player.fallingGravity = 0x00900
    end
  end
end


local accumulator = 0.0
local FPS = 60

-- Updates the game state
function love.update(dt)

  accumulator = accumulator + dt
  if accumulator < 1.0 / FPS then
    return
  end
  accumulator = accumulator - 1.0 / FPS

  player.elapsedTime = player.elapsedTime + dt
  player.landingTimer = player.landingTimer - dt

  if love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift') then
    player.runUntilTime = player.elapsedTime + 10 / ORIGINAL_FPS
  end

  if not love.keyboard.isDown('space') and not love.keyboard.isDown('up') then
    player.isHoldingA = false
  end

  local maxVelocity = MAXIMUM_WALK_VECLOCITY
  local acceleration = WALK_ACCELERATION
  local gravity = player.isHoldingA and player.holdingAGravity or player.fallingGravity
  if player.vy > 0 then
    gravity = player.fallingGravity
  end

  if player.elapsedTime < player.runUntilTime then
    maxVelocity = MAXIMUM_RUN_VELOCITY
    acceleration = RUN_ACCELERATION
  end

  local moveX = (love.keyboard.isDown('left') and -1 or 0) + (love.keyboard.isDown('right') and 1 or 0)
  
  if player.isGrounded then
    if moveX > 0 and player.vx > 0 then
      if player.vx > maxVelocity then
        -- player was running and then released
        player.vx = player.vx - RELEASE_DECELERATION
      else
        player.vx = player.vx + acceleration
        if player.vx > maxVelocity then
          player.vx = maxVelocity
        end
      end
    elseif moveX < 0 and player.vx < 0 then
      if player.vx < -maxVelocity then
        -- player was running and then released
        player.vx = player.vx + RELEASE_DECELERATION
      else
        player.vx = player.vx - acceleration
        if player.vx < -maxVelocity then
          player.vx = -maxVelocity
        end
      end
    end

    if moveX == 0 and player.vx > 0 then
      player.vx = player.vx - RELEASE_DECELERATION
      if player.vx < 0 then
        player.vx = 0
      end
    elseif moveX == 0 and player.vx < 0 then
      player.vx = player.vx + RELEASE_DECELERATION
      if player.vx > 0 then
        player.vx = 0
      end
    end

    if moveX > 0 and player.vx <= 0 then
      if player.vx > -SKID_TURNAROUND_SPEED then
        player.vx = MINIMUM_WALK_VELOCITY
      else
        player.vx = player.vx + SKID_DECELERATION
      end
    elseif moveX < 0 and player.vx >= 0 then
      if player.vx < SKID_TURNAROUND_SPEED then
        player.vx = -MINIMUM_WALK_VELOCITY
      else
        player.vx = player.vx - SKID_DECELERATION
      end
    end
  else
    -- midair physics

    if moveX > 0 and player.vx > 0 then
      if player.vx < 0x01900 then
        player.vx = player.vx + 0x00098
      else
        player.vx = player.vx + 0x000E4
      end
    end

    if moveX < 0 and player.vx < 0 then
      if player.vx > -0x01900 then
        player.vx = player.vx - 0x00098
      else
        player.vx = player.vx - 0x000E4
      end
    end

    -- these values didn't feel big enough so doubled them
    if moveX > 0 and player.vx <= 0 then
      if player.vx < -0x01900 then
        player.vx = player.vx + 0x000E4 * 2
      else
        --- TODOOOO
        player.vx = player.vx + 0x000D0 * 2
      end
    end

    if moveX < 0 and player.vx >= 0 then
      if player.vx > 0x01900 then
        player.vx = player.vx - 0x000E4 * 2
      else
        --- TODOOOO
        player.vx = player.vx - 0x000D0 * 2
      end
    end


    local maxJumpVx = math.abs(player.startJumpVx) <= 0x01900 and 0x01900 or 0x02900
    if player.vx > maxJumpVx then
      player.vx = maxJumpVx
    elseif player.vx < -maxJumpVx then
      player.vx = -maxJumpVx
    end
  end

  -- gravity
  player.vy = player.vy + gravity

  if player.vy > 0x04000 then
    player.vy = 0x04000
  end

  -- Apply the player's velocity to her position
  player.x = player.x + TO_WORLD_UNITS(player.vx)
  player.y = player.y + TO_WORLD_UNITS(player.vy)
  player.walkTimer = player.walkTimer + math.abs(TO_WORLD_UNITS(player.vx))

  if player.vx > 0 then
    player.lastDirection = 1
  elseif player.vx < 0 then
    player.lastDirection = -1
  end

  -- Check for collisions with platforms
  local wasGrounded = player.isGrounded
  player.isGrounded = false
  for _, platform in ipairs(platforms) do
    if platform.cycleTime then
      local elapsedTime = player.elapsedTime + platform.cycleOffset
      local cyclePercent = (elapsedTime % platform.cycleTime) / platform.cycleTime
      local percentToOffset = 0
      if cyclePercent < 0.5 then
        percentToOffset = cyclePercent
      else
        percentToOffset = 1.0 - cyclePercent
      end

      platform.x = platform.originalX + percentToOffset * platform.offsetX
      platform.y = platform.originalY + percentToOffset * platform.offsetY
    end

    local collisionDir = checkForCollision(player, platform)
    if collisionDir == 'top' then
      player.y = platform.y + platform.height
      player.vy = 0x01000
    elseif collisionDir == 'bottom' then
      player.y = platform.y - player.height
      player.vy = math.min(0, player.vy)
      player.isGrounded = true
      if not wasGrounded then
        player.landingTimer = 0.1
        collisionSound()
      end
    elseif collisionDir == 'left' then
      --print('left')
      player.x = platform.x + platform.width
      player.vx = math.max(-MINIMUM_WALK_VELOCITY * 10, player.vx)
    elseif collisionDir == 'right' then
      --print('right')
      player.x = platform.x - player.width
      player.vx = math.min(MINIMUM_WALK_VELOCITY * 10, player.vx)
    end
  end

  -- Check for gem collection
  for _, gem in ipairs(gems) do
    if not gem.isCollected and entitiesOverlapping(player, gem) then
      gem.isCollected = true
      love.audio.play(gemSound:clone())
      score = score + 1
    end
  end

  -- Goal
  if entitiesOverlapping(player, goal) then
    level = level + 1
    resetGame()
  end

  -- enemies
  for _, enemy in ipairs(enemies) do
    if enemy.isActive then
      local collisionDir = checkForCollision(player, enemy)
      if collisionDir then
        -- testing
        -- print(collisionDir)
      end

      if collisionDir == 'bottom' then
        enemy.isActive = false
        player.vy = ENEMY_STOMP_SPEED

        -- online hit one enemy at a time
        break
      elseif collisionDir ~= nil then
        die()
        return
      end

      enemy.vy = enemy.vy + 0x00280

      if enemy.vy > 0x04000 then
        enemy.vy = 0x04000
      end

      enemy.x = enemy.x + TO_WORLD_UNITS(enemy.vx)
      enemy.y = enemy.y + TO_WORLD_UNITS(enemy.vy)

      local hasRightCollision = false
      local hasLeftCollision = false
      for _, platform in ipairs(platforms) do
        local collisionDir = checkForCollision(enemy, platform)
        if collisionDir == 'left' then
          enemy.vx = math.abs(enemy.vx)
        elseif collisionDir == 'right' then
          enemy.vx = -math.abs(enemy.vx)
        elseif collisionDir == 'bottom' then
          enemy.y = platform.y - enemy.height
          enemy.vy = math.min(0, enemy.vy)
        end

        enemy.x = enemy.x + BLOCK_SIZE
        enemy.y = enemy.y + 10
        local rightCollision = checkForCollision(enemy, platform)
        if rightCollision ~= nil then
          hasRightCollision = true
        end

        enemy.x = enemy.x - BLOCK_SIZE * 2
        local leftCollision = checkForCollision(enemy, platform)
        if leftCollision ~= nil then
          hasLeftCollision = true
        end

        enemy.x = enemy.x + BLOCK_SIZE
        enemy.y = enemy.y - 10
      end

      if hasLeftCollision == false then
        enemy.vx = math.abs(enemy.vx)
      end

      if hasRightCollision == false then
        enemy.vx = -math.abs(enemy.vx)
      end
    end
  end

  -- Keep the player in bounds
  if player.x < player.screenScrollX then
    player.x = player.screenScrollX
  end
  --[[elseif player.x > GAME_WIDTH - player.width then
    player.x = GAME_WIDTH - player.width
  end]]--
  if player.y > love.graphics.getHeight() / RENDER_SCALE + 50 then
    die()
    return
  end
end

function collisionSound()
  if player.elapsedTime - lastCollisionSoundTime > 0.1 then
    love.audio.play(landSound:clone())
    lastCollisionSoundTime = player.elapsedTime
  end
end

-- Renders the game
function love.draw()
  -- Scale and crop the screen
  --love.graphics.setScissor(0, 0, RENDER_SCALE * GAME_WIDTH, RENDER_SCALE * GAME_HEIGHT)

  love.graphics.push()
  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.clear(117 / 255, 218 / 255, 255 / 255)
  love.graphics.setColor(1, 1, 1, 1)

  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  if player.x > player.screenScrollX + (screenWidth / (RENDER_SCALE * 2.0) - BLOCK_SIZE / 2.0) then
    player.screenScrollX = player.x - (screenWidth / (RENDER_SCALE * 2.0) - BLOCK_SIZE / 2.0)
  end

  if player.x < player.screenScrollX + (0.3 * screenWidth / RENDER_SCALE - BLOCK_SIZE / 2.0) then
    player.screenScrollX = player.x - (0.3 * screenWidth / RENDER_SCALE - BLOCK_SIZE / 2.0)
  end

  if player.screenScrollX < 0 then
    player.screenScrollX = 0
  end

  if player.y > player.screenScrollY + (0.7 * screenHeight / RENDER_SCALE) then
    player.screenScrollY = player.y - (0.7 * screenHeight / RENDER_SCALE)
  end

  if player.y < player.screenScrollY + (0.2 * screenHeight / RENDER_SCALE) then
    player.screenScrollY = player.y - (0.2 * screenHeight / RENDER_SCALE)
  end

  love.graphics.translate(-player.screenScrollX, -player.screenScrollY)



  --[[
  for x=0, screenWidth, BLOCK_SIZE do
    love.graphics.line(x, 0, x, screenHeight)
  end

  for y=0, screenHeight, BLOCK_SIZE do
    love.graphics.line(0, y, screenWidth, y)
  end]]--

  -- Draw the platforms
  for _, platform in ipairs(platforms) do
    drawSprite(objectsImage, 16, 16, 3, platform.x, platform.y)
  end

  drawSprite(objectsImage, BLOCK_SIZE, BLOCK_SIZE, 1, goal.x, goal.y)
  drawSprite(objectsImage, BLOCK_SIZE, BLOCK_SIZE, 1, goal.x + BLOCK_SIZE, goal.y)
  drawSprite(objectsImage, BLOCK_SIZE, BLOCK_SIZE, 1, goal.x, goal.y + BLOCK_SIZE)
  drawSprite(objectsImage, BLOCK_SIZE, BLOCK_SIZE, 1, goal.x + BLOCK_SIZE, goal.y + BLOCK_SIZE)

  -- Draw the gems
  for _, gem in ipairs(gems) do
    if not gem.isCollected then
      drawSprite(objectsImage, 16, 16, 2, gem.x, gem.y)
    end
  end

  love.graphics.setColor(195 / 255, 124 / 255, 77 / 255, 1.0)
  for _, enemy in ipairs(enemies) do
    if enemy.isActive then
      drawSprite(playerImage, 16, 16, 1 + 7 * 4, enemy.x, enemy.y, enemy.vx < 0)
    end
  end
  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

  -- Draw the player
  local sprite
  if player.isGrounded then
    -- When standing
    local walkTimer = (player.walkTimer / 50.0) % 0.6

    if player.vx == 0 then
      if player.landingTimer > 0.00 then
        sprite = 7
      else
        sprite = 1
      end
    -- When running
    elseif walkTimer < 0.2 then
      sprite = 2
    elseif walkTimer < 0.3 then
      sprite = 3
    elseif walkTimer < 0.5 then
      sprite = 4
    else
      sprite = 3
    end
  -- When jumping
  elseif player.vy > 0 then
    sprite = 6
  else
    sprite = 5
  end
  drawSprite(playerImage, 16, 16, sprite + 14, player.x, player.y, player.lastDirection == -1)

  love.graphics.pop()
  love.graphics.setFont(BigFont)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Level " .. level .. "    Score " .. score, 20, 20)
  --renderButtons()
end

-- Draws a sprite from a sprite sheet, spriteNum=1 is the upper-leftmost sprite
function drawSprite(spriteSheetImage, spriteWidth, spriteHeight, sprite, x, y, flipHorizontal, flipVertical, rotation)
  local width, height = spriteSheetImage:getDimensions()
  local numColumns = math.floor(width / spriteWidth)
  local col, row = (sprite - 1) % numColumns, math.floor((sprite - 1) / numColumns)
  love.graphics.draw(spriteSheetImage,
    love.graphics.newQuad(spriteWidth * col, spriteHeight * row, spriteWidth, spriteHeight, width, height),
    x + spriteWidth / 2, y + spriteHeight / 2,
    rotation or 0,
    flipHorizontal and -1 or 1, flipVertical and -1 or 1,
    spriteWidth / 2, spriteHeight / 2)
end

-- Determine whether two rectangles are overlapping
function rectsOverlapping(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 + w1 > x2 and x2 + w2 > x1 and y1 + h1 > y2 and y2 + h2 > y1
end

-- Returns true if two entities are overlapping, by checking their bounding boxes
function entitiesOverlapping(a, b)
  return rectsOverlapping(a.x, a.y, a.width, a.height, b.x, b.y, b.width, b.height)
end

-- Checks to see if two entities are colliding, and if so from which side. This is
-- accomplished by checking the four quadrants of the axis-aligned bounding boxes
function checkForCollision(a, b)
  local indent = 5
  if rectsOverlapping(a.x + indent, a.y + a.height / 2, a.width - 2 * indent, a.height / 2, b.x, b.y, b.width, b.height) then
    return 'bottom'
  elseif rectsOverlapping(a.x + indent, a.y, a.width - 2 * indent, a.height / 2, b.x, b.y, b.width, b.height) then
    return 'top'
  elseif rectsOverlapping(a.x, a.y + indent, a.width / 2, a.height - 2 * indent, b.x, b.y, b.width, b.height) then
    return 'left'
  elseif rectsOverlapping(a.x + a.width / 2, a.y + indent, a.width / 2, a.height - 2 * indent, b.x, b.y, b.width, b.height) then
    return 'right'
  end
end
