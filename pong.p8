pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- constants

local screen_height = 128
local screen_width =
	screen_height
local border_height = 2
local bat_sz = 24
local bat_width = 8
local ball_sz = 8
local map_up_limit =
	8 + border_height
local map_down_limit =
	screen_height - border_height
local map_sz =
	map_down_limit - map_up_limit

-- state

function _init()
	-- bats
	bat_x = {8, 112}
	bat_y = {
		round(
			map_up_limit +
			map_sz / 2 -
			bat_sz / 2
		),
		round(
			map_up_limit +
			map_sz / 2 -
			bat_sz / 2
		)
	}
	bat_speed = {2, 2}
	scores = {0, 0}
	score_len = {1, 1}
	inputs = {
		{
			up = false,
			down = false,
			launch = false
		},
		{
			up = false,
			down = false,
			launch = false
		}
	}

	-- ball
	ball_x = 60
	ball_y = 65
	ball_mvx = 0
	ball_mvy = 0
	ball_speed = 2
	ball_attached = 1
end

-- game methods

function _update60()
	inputs[1].up = btn(⬆️);
	inputs[1].down = btn(⬇️);
	inputs[1].launch = btn(🅾️);

	-- move bat

	if inputs[1].up
	then
		bat_y[1] -= bat_speed[1]
	end
	if inputs[1].down
	then
		bat_y[1] += bat_speed[1]
	end

	-- launch ball

	if (
		inputs[1].launch and
		ball_attached == 1
	)
	then
		sfx(0)
		local modifier = (
			bat_y[1] +
			bat_sz / 2 -
			map_up_limit
		) / map_sz - 0.5
		ball_mvx = ball_speed *
			(1 - abs(modifier))
		ball_mvy = ball_speed *
			modifier
		ball_attached = 0
	end

	-- bat - wall collision

	if bat_y[1] < map_up_limit
	then
		bat_y[1] = map_up_limit
	elseif (
		bat_y[1] >=
		map_down_limit - bat_sz
	)
	then
		bat_y[1] =
			map_down_limit - bat_sz
	end

	-- move ball

	if ball_attached == 0
	then
		ball_x += ball_mvx
		ball_y += ball_mvy
	elseif ball_attached == 1
	then
		ball_x = bat_x[1] + 8
		ball_y = bat_y[1] + 8
	else
		ball_x = bat_x[2] - 8
		ball_y = bat_y[2] + 8
	end

	-- ball - bat collisions
	
	if collide(
		ball_x, ball_y,
		ball_sz, ball_sz,
		bat_x[2], bat_y[2],
		bat_width, bat_sz
	)
	then
		local modifier =
			(
				ball_y +
				ball_sz / 2 -
				bat_y[2]
			) / bat_sz - 0.5
		ball_mvx =
			ball_speed *
			-(1 - abs(modifier))
		ball_mvy =
			ball_speed * modifier
		ball_x += ball_mvx
		ball_y += ball_mvy
	elseif collide(
		ball_x, ball_y,
		ball_sz, ball_sz,
		bat_x[1], bat_y[1],
		bat_width, bat_sz
	)
	then
		local modifier = (
			ball_y +
			ball_sz / 2 -
			bat_y[1]
		) / bat_sz - 0.5
		ball_mvx =
			ball_speed *
			(1 - abs(modifier))
		ball_mvy =
			ball_speed * modifier
		ball_x += ball_mvx
		ball_y += ball_mvy
	end

	-- ball - wall collisions

	local ball_bottom_y =
		ball_y + ball_sz
	if ball_x < 0
	then
		inc_score(2)
		ball_attached = 1
	elseif (
		ball_x + ball_sz >=
		screen_width
	)
	then
		inc_score(1)
		ball_attached = 2
	elseif ball_y < map_up_limit
	then
		ball_y =
			ball_y +
			(map_up_limit - ball_y)
		ball_mvy = -ball_mvy
	elseif (
		ball_bottom_y >=
		map_down_limit
	)
	then
		ball_y =
			map_down_limit +
			(
				map_down_limit -
				ball_bottom_y
			) - ball_sz
		ball_mvy = -ball_mvy
	end
end

function _draw()
	cls(0)
	map(0, 0, 0, 0, 16, 16)
	print_score(
		scores[1],
		scores[2],
		score_len[1]
	)
	draw_bat(bat_x[1], bat_y[1])
	draw_bat(bat_x[2], bat_y[2])
	draw_ball(ball_x, ball_y)
end

-- functions

function draw_bat(x, y)
	sspr(0, 0, 8, bat_sz, x, y)
end

function draw_ball(x, y)
	spr(4, round(x), round(y))
end

function print_score(
	score1,
	score2,
	score1_len
)
	print("--", 60, 0)
	print(
		score1,
		60 - score1_len * 4,
		0
	)
	print(score2, 68, 0)
end

function inc_score(player)
	scores[player] += 1
	score_len[player] =
		#tostring(scores[player])
end

function round(x)
	if x % 1 < 0.5 then
		return flr(x)
	else
		return ceil(x)
	end
end

function collide(
	x1, y1, w1, h1,
	x2, y2, w2, h2
)
	return (
		x1 < x2 + w2 and
		x1 + w1 > x2 and
		y1 < y2 + h2 and
		y1 + h1 > y2
	)
end

__gfx__
0077770066666666cd000000000000e8000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0766667077777777dc0000000000008e076556700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7655556700000000cd000000000000e8065005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7650056700000000dc0000000000008e750000570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7650056700000000cd000000000000e8750000570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7650056700000000dc0000000000008e065005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7650056700000000cd000000000000e8076556700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7650056700000000dc0000000000008e000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76500567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76555567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07666670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1919191919191919191919191919191900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0211111111111111111111111111110300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000006050110601a070300703007028050180400b0300302001010000000b0002e0003000025000190000d000050000400004000000000000001000010000200002000020000200000000010000000000000
