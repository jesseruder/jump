-- Render constants
local RENDER_SCALE = 3

-- Game constants
local LEVEL_DATA = {{type = 'block', x = 0, y = 2, width = 1, height = 1}}
for i=0,200 do
  table.insert(LEVEL_DATA, {type = 'block', x = i, y = 8, width = 1, height = 1})
end

table.insert(LEVEL_DATA, {type = 'block', x = 11, y = 4, width = 1, height = 1})
table.insert(LEVEL_DATA, {type = 'block', x = 12, y = 3, width = 1, height = 1})
table.insert(LEVEL_DATA, {type = 'block', x = 13, y = 3, width = 1, height = 1})
table.insert(LEVEL_DATA, {type = 'block', x = 14, y = 3, width = 1, height = 1})

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

-- Game variables
local player
local platforms
local gems

-- Assets
local playerImage
local objectsImage
local walkSounds
local jumpSound
local landSound
local gemSound

function resetGame()
  -- Create platforms and game objects from the level data
  platforms = {}
  gems = {}

  -- Create the player
  player = {
    x = 1,
    y = 1,
    vx = 0,
    vy = 0,
    holdingAGravity = 0x00280,
    fallingGravity = 0x00280,
    elapsedTime = 0,
    runUntilTime = 0,
    width = BLOCK_SIZE,
    height = BLOCK_SIZE,
    isGrounded = false,
    isHoldingA = false,
    startJumpVx = 0,
    screenScroll = 0,
  }

  for _, obj in ipairs(LEVEL_DATA) do
    if obj.type == 'block' then
      table.insert(platforms, {
        x = obj.x * BLOCK_SIZE,
        y = obj.y * BLOCK_SIZE,
        width = obj.width * BLOCK_SIZE,
        height = obj.height * BLOCK_SIZE
      })
    end
  end
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

-- Updates the game state
function love.update(dt)
  player.elapsedTime = player.elapsedTime + dt

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

    if moveX > 0 and player.vx <= 0 then
      if player.vx < -0x01900 then
        player.vx = player.vx + 0x000E4
      else

      end
    end


    local maxJumpVx = math.abs(player.startJumpVx) <= 0x01900 and 0x01900 or 0x02900
    if player.vx > maxJumpVx then
      player.vx = maxJumpVx
    elseif player.vx < -maxJumpVx then
      player.vx = -maxJumpVx
    end
  end

  -- Accelerate downward (a la gravity)
  player.vy = player.vy + gravity

  if player.vy > 0x04000 then
    player.vy = 0x04000
  end

  -- Apply the player's velocity to her position
  player.x = player.x + TO_WORLD_UNITS(player.vx)
  player.y = player.y + TO_WORLD_UNITS(player.vy)

  -- Check for collisions with platforms
  local wasGrounded = player.isGrounded
  player.isGrounded = false
  for _, platform in ipairs(platforms) do
    local collisionDir = checkForCollision(player, platform)
    if collisionDir == 'top' then
      player.y = platform.y + platform.height
      player.vy = math.max(0, player.vy)
    elseif collisionDir == 'bottom' then
      player.y = platform.y - player.height
      player.vy = math.min(0, player.vy)
      player.isGrounded = true
      if not wasGrounded then
        love.audio.play(landSound:clone())
      end
    elseif collisionDir == 'left' then
      player.x = platform.x + platform.width
      --player.vx = math.max(0, player.vx)
    elseif collisionDir == 'right' then
      player.x = platform.x - player.width
      --player.vx = math.min(0, player.vx)
    end
  end

  -- Check for gem collection
  for _, gem in ipairs(gems) do
    if not gem.isCollected and entitiesOverlapping(player, gem) then
      gem.isCollected = true
      love.audio.play(gemSound:clone())
    end
  end

  -- Keep the player in bounds
  if player.x < player.screenScroll then
    player.x = player.screenScroll
  end
  --[[elseif player.x > GAME_WIDTH - player.width then
    player.x = GAME_WIDTH - player.width
  end]]--
  if player.y > love.graphics.getHeight() / RENDER_SCALE + 50 then
    player.y = -10
  end
end

-- Renders the game
function love.draw()
  -- Scale and crop the screen
  --love.graphics.setScissor(0, 0, RENDER_SCALE * GAME_WIDTH, RENDER_SCALE * GAME_HEIGHT)

  love.graphics.scale(RENDER_SCALE, RENDER_SCALE)
  love.graphics.clear(251 / 255, 134 / 255, 199 / 255)
  love.graphics.setColor(1, 1, 1, 1)

  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()

  if player.x > player.screenScroll + (screenWidth / (RENDER_SCALE * 2.0) - BLOCK_SIZE / 2.0) then
    player.screenScroll = player.x - (screenWidth / (RENDER_SCALE * 2.0) - BLOCK_SIZE / 2.0)
  end

  love.graphics.translate(-player.screenScroll, 0)



  --[[
  for x=0, screenWidth, BLOCK_SIZE do
    love.graphics.line(x, 0, x, screenHeight)
  end

  for y=0, screenHeight, BLOCK_SIZE do
    love.graphics.line(0, y, screenWidth, y)
  end]]--

  -- Draw the platforms
  for _, platform in ipairs(platforms) do
    drawSprite(objectsImage, 16, 16, 1, platform.x, platform.y)
  end

  -- Draw the gems
  for _, gem in ipairs(gems) do
    if not gem.isCollected then
      drawSprite(objectsImage, 16, 16, 2, gem.x, gem.y)
    end
  end

  -- Draw the player
  local sprite
  if player.isGrounded then
    sprite = 1
  -- When jumping
  elseif player.vy > 0 then
    sprite = 6
  else
    sprite = 5
  end
  drawSprite(playerImage, 16, 16, sprite, player.x, player.y, player.isFacingLeft)

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
  local indent = 3
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
