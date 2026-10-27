BALL_SIZE = 20
PADDLE_HEIGHT = 100
PADDLE_THICKNESS = BALL_SIZE
PADDLE_PADDING = BALL_SIZE
BALL_SPEED = 1000*0.4


score_right = 0 
score_left = 0


digits = {
   [0] = {{1,1,1}, {1,0,1}, {1,0,1}, {1,0,1}, {1,1,1}},
   [1] = {{0,1,0}, {0,1,0}, {0,1,0}, {0,1,0}, {0,1,0}},
   [2] = {{1,1,1}, {0,0,1}, {1,1,1}, {1,0,0}, {1,1,1}},
   [3] = {{1,1,1}, {0,0,1}, {1,1,1}, {0,0,1}, {1,1,1}},
   [4] = {{1,0,1}, {1,0,1}, {1,1,1}, {0,0,1}, {0,0,1}},
   [5] = {{1,1,1}, {1,0,0}, {1,1,1}, {0,0,1}, {1,1,1}},
   [6] = {{1,1,1}, {1,0,0}, {1,1,1}, {1,0,1}, {1,1,1}},
   [7] = {{1,1,1}, {0,0,1}, {0,0,1}, {0,0,1}, {0,0,1}},
   [8] = {{1,1,1}, {1,0,1}, {1,1,1}, {1,0,1}, {1,1,1}},
   [9] = {{1,1,1}, {1,0,1}, {1,1,1}, {0,0,1}, {1,1,1}},
}

function count_digits(n)
    assert(n >= 0)
    if n == 0 then
        return 1
    end
    local count = 0

    while n > 0 do
        count = count + 1
        n = math.floor(n / 10)
    end

    return count
end

function number_width(n)
    local count = count_digits(n)
    return count*3*DIGIT_SIZE + (count - 1)*DIGIT_SIZE
end

function render_number(n, x, y)
    assert(n >= 0)
    if n == 0 then
        render_digit(digits[n], x, y)
        return 1
    end
    local count = count_digits(n)
    x = x + (count - 1)*4*DIGIT_SIZE

    while n > 0 do
        local digit = n%10
        render_digit(digits[digit], x, y)
        n = math.floor(n / 10)
        x = x - 4*DIGIT_SIZE
    end

    return count
end

function render_digit(digit, x, y)
    for cell_y, row in ipairs(digit) do
        for cell_x, col in ipairs(row) do
            if col ~= 0 then
                love.graphics.rectangle("fill", x + (cell_x-1)*DIGIT_SIZE, y + (cell_y-1)*DIGIT_SIZE, DIGIT_SIZE, DIGIT_SIZE)
            end
        end
    end
end

function love.load()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    PADDLE_SPEED = BALL_SPEED*1.2

    ball_x = 0.0
    ball_y = 0.0
    ball_dx = -1.0 --speed
    ball_dy = 1.0 --speed

    NET_GIRTH = 3 
    NET_COUNT = 51

    paddle_left_y = 0
    paddle_right_y = 0
    paddle_left_x = PADDLE_PADDING
    paddle_right_x = w - PADDLE_PADDING - PADDLE_THICKNESS

    DIGIT_SIZE = BALL_SIZE
end

function love.draw()
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    love.graphics.clear(0x20/255, 0x1e/255, 0x29/255, 1)
    local segment_length = h/NET_COUNT
    for i=0,NET_COUNT-1 do
        if i % 2 == 0 then
            local width = love.graphics.setLineWidth(NET_GIRTH)
            love.graphics.line(w/2, i*segment_length, w/2, (i+1)*segment_length)
        end
    end
    love.graphics.rectangle("fill", ball_x, ball_y, BALL_SIZE, BALL_SIZE)
    local score_left_width = number_width(score_left)
    render_number(score_left, w/2 - score_left_width - 2*DIGIT_SIZE, 2*DIGIT_SIZE)
    render_number(score_right, w/2 + 2*DIGIT_SIZE, 2*DIGIT_SIZE)
    love.graphics.rectangle("fill", paddle_left_x, paddle_left_y, PADDLE_THICKNESS, PADDLE_HEIGHT)

    local paddle_right_x = w - PADDLE_PADDING - PADDLE_THICKNESS
    love.graphics.rectangle("fill", paddle_right_x, paddle_right_y, PADDLE_THICKNESS, PADDLE_HEIGHT)
end

function love.update(dt)
    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    local ball_nx = ball_x + ball_dx * dt * BALL_SPEED
    if (paddle_left_y <= ball_y
        and ball_y < paddle_left_y + PADDLE_HEIGHT
        and ball_nx < paddle_left_x  + PADDLE_THICKNESS)
        or (paddle_right_y <= ball_y
        and ball_y < paddle_right_y + PADDLE_HEIGHT
        and ball_nx + BALL_SIZE >= paddle_right_x)
        then
        ball_dx = -ball_dx
    elseif (ball_nx < 0) then
        score_right = score_right + 1
        ball_x = w/2 - BALL_SIZE/2
        ball_y = h/2 - BALL_SIZE/2
        ball_dx = 1
        ball_dy = 1
    elseif (ball_nx + BALL_SIZE >= w) then
        score_left = score_left + 1
        ball_x = w/2 - BALL_SIZE/2
        ball_y = h/2 - BALL_SIZE/2
        ball_dx = -1
        ball_dy = 1
    else
        ball_x = ball_nx
    end

    local ball_ny = ball_y + ball_dy * dt * BALL_SPEED
    if ball_ny < 0 or ball_ny + BALL_SIZE >= h then
        ball_dy = -ball_dy
    else
        ball_y = ball_ny
    end

    if love.keyboard.isDown("s") then
        local paddle_left_ny = paddle_left_y + PADDLE_SPEED*dt
        if paddle_left_ny + PADDLE_HEIGHT < h then
            paddle_left_y = paddle_left_ny
        end
    end

    if love.keyboard.isDown("w") then
        local paddle_left_ny = paddle_left_y - PADDLE_SPEED*dt
        if paddle_left_ny > 0 then
            paddle_left_y = paddle_left_ny
        end
    end

    if love.keyboard.isDown("down") then
        local paddle_right_ny = paddle_right_y + PADDLE_SPEED*dt
        if paddle_right_ny + PADDLE_HEIGHT < h then
            paddle_right_y = paddle_right_ny
        end
    end
    if love.keyboard.isDown("up") then
        local paddle_right_ny = paddle_right_y - PADDLE_SPEED*dt
        if paddle_right_ny > 0 then
            paddle_right_y = paddle_right_ny
        end
    end
end
