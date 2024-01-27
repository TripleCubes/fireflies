-- title:   Fireflies
-- author:  TripleCubes
-- license: MIT License
-- version: 0.1
-- script:  moon

local vecnew
local veccopy
local vecadd
local player_create
local spring_create
local lamp_create
local lamp_door_create
local box_create
local entity_list_add
local tweenvec_create
local tweenvec_list_add
local get_draw_pos
local fireflies
local restart_room
local skip_room

WINDOW_W = 240
WINDOW_H = 136
WINDOW_WH = { x: 240, y: 136 }

NORMAL_GRAVITY_ADD = 0.15
NORMAL_JUMP_GRAVITY = -2.2

KNIFE_COOLDOWN = 0.1

LIST_ROOM = {}

list_entity = {}
list_tween_vec = {}
list_interval = {}
latest_interval_id = 1
player = {}
time_stopped = false
n_vbank = 0
prev_room = {}
t = 0
cam = {}
at_title = true
title_pos = {}
move_tut_pos = {}
showing_menu = false
menu_cooldown = 0

title_update = ->
	if not at_title then return
	if not btnp(4) then return
	
	at_title = false
	title_pos.tween(title_pos, vecnew(7, -30))
	move_tut_pos.tween(move_tut_pos, vecnew(19*8, 92*8))

ui_update = ->
	if at_title then return

	if btnp(7) then
		showing_menu = not showing_menu

	if not showing_menu then return
	
	if btnp(4) then 
		restart_room()
		showing_menu = false
		menu_cooldown = t + 30

	if btnp(5) then
		skip_room()
		showing_menu = false
		menu_cooldown = t + 30

ui_draw = ->
	print("Fireflies", title_pos.pos.x, title_pos.pos.y, 11, false, 3, true)
	print("Press z", title_pos.pos.x, title_pos.pos.y + 20, 12, false, 1, true)

	if showing_menu then
		pos = vecnew(WINDOW_W/2 - 33, WINDOW_H/2 - 15)
		print("MENU", pos.x, pos.y, 12, false, 1, true)
		print("Press S to exit menu", pos.x, pos.y + 8, 12, false, 1, true)
		print("Press Z to restart room", pos.x, pos.y + 16, 12, false, 1, true)
		print("Press X to skip room", pos.x, pos.y + 24, 12, false, 1, true)

bkg = ->
	lamp_draw_pos = get_draw_pos(vecnew(138 * 8, 27 * 8)) 
	spr(448, lamp_draw_pos.x, lamp_draw_pos.y, 0, 1, 0, 0, 2, 4)
	
	lamp_draw_pos_0 = get_draw_pos(vecnew(190 * 8, 94 * 8)) 
	spr(450, lamp_draw_pos_0.x, lamp_draw_pos_0.y, 0, 1, 0, 0, 2, 4)

	prt = (text, x, y) ->
		print_pos_0 = get_draw_pos(vecnew(x, y))
		print(text, print_pos_0.x, print_pos_0.y, 12, false, 1, true)

	prt("Arrows to move", move_tut_pos.pos.x, move_tut_pos.pos.y)
	prt("Z to jump", move_tut_pos.pos.x, move_tut_pos.pos.y + 8)

	prt("X to throw knife", 34*8, 90*8)
	prt("You can stand on knifes", 34*8, 90*8 + 8)

	prt("A to stop time", 68*8, 71*8)
	prt("Knife stop midair when time stopped", 68*8, 71*8 + 8)

	prt("S to open menu", 3*8, 54*8)
	prt("You can restart room or skip room there", 3*8, 54*8 + 8)


	prt("Art and codes by TripleCubes", 195*8, 87*8)
	prt("Thanks for playing", 195*8, 88*8)
	prt("The end", 195*8, 89*8)

boot = ->
	title_pos = tweenvec_create(vecnew(7, 12))
	tweenvec_list_add(title_pos)
	move_tut_pos = tweenvec_create(vecnew(19*8, 92*8 - 15*8))
	move_tut_pos.tween_time = 2
	tweenvec_list_add(move_tut_pos)

	LIST_ROOM = {
		{ -- 0
			pos: vecnew(0, 85),
			sz: vecnew(30, 17),
			restart: vecnew(7, 100),
		},
		{ -- 1
			pos: vecnew(30, 85),
			sz: vecnew(30, 17),
			restart: vecnew(37, 97),
		},
		{ -- 2
			pos: vecnew(60, 85),
			sz: vecnew(30, 17),
			restart: vecnew(65, 93),
		},
		{ -- 3
			pos: vecnew(60, 68),
			sz: vecnew(30, 17),
			restart: vecnew(80, 83),
		},
		{ -- 4
			pos: vecnew(30, 68),
			sz: vecnew(30, 17),
			restart: vecnew(58, 75),
		},
		{ -- 5
			pos: vecnew(0, 68),
			sz: vecnew(30, 17),
			restart: vecnew(28, 75),
		},
		{ -- 6
			pos: vecnew(0, 51),
			sz: vecnew(30, 17),
			restart: vecnew(13, 66),
		},
		{ -- 7
			pos: vecnew(30, 51),
			sz: vecnew(60, 17),
			restart: vecnew(32, 64),
		},
		{ -- 8
			pos: vecnew(60, 34),
			sz: vecnew(30, 17),
			restart: vecnew(83, 49),
		},
		{ -- 9
			pos: vecnew(60, 0),
			sz: vecnew(60, 34),
			restart: vecnew(67, 32),
		},
		{ -- 10
			pos: vecnew(120, 17),
			sz: vecnew(30, 17),
			restart: vecnew(122, 31),
		},
		{ -- 11
			pos: vecnew(120, 0),
			sz: vecnew(30, 17),
			restart: vecnew(123, 10),
		},
		{ -- 12
			pos: vecnew(150, 0),
			sz: vecnew(30, 17),
			restart: vecnew(153, 12),
		},
		{ -- 13
			pos: vecnew(180, 0),
			sz: vecnew(30, 17),
			restart: vecnew(183, 12),
		},
		{ -- 14
			pos: vecnew(180, 17),
			sz: vecnew(30, 17),
			restart: vecnew(207, 20),
		},
		{ -- 15
			pos: vecnew(180, 34),
			sz: vecnew(30, 17),
			restart: vecnew(183, 36),
		},
		{ -- 16
			pos: vecnew(150, 34),
			sz: vecnew(30, 17),
			restart: vecnew(176, 49),
		},
		{ -- 17
			pos: vecnew(120, 34),
			sz: vecnew(30, 17),
			restart: vecnew(147, 49),
		},
		{ -- 18
			pos: vecnew(120, 51),
			sz: vecnew(30, 17),
			restart: vecnew(131, 54),
		},
		{ -- 19
			pos: vecnew(90, 51),
			sz: vecnew(30, 17),
			restart: vecnew(117, 62),
		},
		{ -- 20
			pos: vecnew(90, 68),
			sz: vecnew(30, 17),
			restart: vecnew(92, 72),
		},
		{ -- 21
			pos: vecnew(120, 68),
			sz: vecnew(30, 34),
			restart: vecnew(122, 79),
		},
		{ -- 21
			pos: vecnew(150, 85),
			sz: vecnew(60, 17),
			restart: vecnew(153, 97),
		},
	}


	cam = {
		pos: tweenvec_create(vecnew(0, 85*8))
	}
	tweenvec_list_add(cam.pos)

	-- player = player_create(vecnew(58 * 8, 75 * 8 - 8))
	player = player_create(vecnew(6 * 8, 99 * 8))
	entity_list_add(player)


	spring = (x, y) ->
		spring_0 = spring_create(vecnew(x, y))
		entity_list_add(spring_0)
	lamp = (lamp_pos, door_pos, door_sz, door_dest) ->
		door_0 = lamp_door_create(door_pos, door_sz, door_dest)
		entity_list_add(door_0)
		lamp_0 = lamp_create(lamp_pos, door_0)
		entity_list_add(lamp_0)
	box = (x, y) ->
		box_0 = box_create(vecnew(x, y))
		entity_list_add(box_0)

	fireflies(false, vecadd(vecnew(68 * 8, 80 * 8), vecnew(0, 0)), 50, 10, 9)
	fireflies(false, vecadd(vecnew(44 * 8, 73 * 8), vecnew(0, 0)), 50, 10, 9)
	fireflies(false, vecadd(vecnew(72 * 8, 57 * 8), vecnew(0, 0)), 50, 10, 9)
	fireflies(false, vecadd(vecnew(164 * 8, 5 * 8), vecnew(0, 0)), 50, 10, 9)
	fireflies(false, vecadd(vecnew(198 * 8, 24 * 8), vecnew(0, 0)), 50, 10, 9)
	fireflies(false, vecadd(vecnew(134 * 8, 61 * 8), vecnew(0, 0)), 50, 10, 9)
	fireflies(false, vecadd(vecnew(125 * 8, 72 * 8), vecnew(0, 0)), 50, 10, 9)

	-- 7
	spring(36, 64)
	spring(47, 64)

	spring(58, 64)
	spring(59, 64)
	spring(60, 64)
	spring(61, 64)
	spring(62, 64)
	spring(63, 64)
	spring(64, 64)
	spring(65, 64)
	spring(66, 64)

	-- 8
	spring(72, 49)
	spring(79, 49)

	-- 9
	spring(79, 31)
	
	spring(84, 28)
	spring(85, 28)
	spring(86, 28)

	spring(84, 21)
	spring(85, 21)
	spring(86, 21)

	spring(101, 14)
	spring(102, 14)
	spring(107, 14)
	spring(108, 14)
	spring(113, 14)
	spring(114, 14)

	-- 10
	fireflies(false, vecadd(vecnew(138 * 8, 27 * 8), vecnew(3, -10)), 100, 30, 11)

	-- 11
	lamp(vecnew(141, 9), vecnew(148*8 + 5, 10*8), vecnew(3, 3*8), vecnew(148*8 + 5, 10*8 - 3*8))

	-- 12
	lamp(vecnew(171, 3), vecnew(174*8 + 5, 10*8), vecnew(3, 3*8), vecnew(174*8 + 5, 10*8 - 3*8))

	-- 13
	lamp(vecnew(187, 9), vecnew(197*8 + 5, 13*8), vecnew(3, 3*8), vecnew(197*8 + 5, 1*8))

	-- 14
	spring(206, 32)
	lamp(vecnew(183, 26), vecnew(191*8, 32*8 + 5), vecnew(3*8, 3), vecnew(191*8, 22*8 + 5))

	-- 15
	lamp(vecnew(197, 36), vecnew(183*8, 41*8 + 5), vecnew(2*8, 3), vecnew(181*8, 41*8 + 5))
	lamp(vecnew(206, 36), vecnew(205*8, 44*8 + 5), vecnew(2*8, 3), vecnew(207*8, 44*8 + 5))
	lamp(vecnew(200, 36), vecnew(194*8 + 5, 42*8), vecnew(3, 2*8), vecnew(194*8 + 5, 48*8))

	-- 16
	-- spring(162, 40)
	-- spring(163, 40)

	spring(166, 43)
	spring(167, 43)

	spring(170, 46)
	spring(171, 46)

	spring(174, 49)
	spring(175, 49)

	lamp(vecnew(154, 36), vecnew(150*8 + 5, 47*8), vecnew(3, 3*8), vecnew(150*8 + 5, 45*8))

	-- 17
	lamp(vecnew(124, 38), vecnew(130*8, 49*8 + 5), vecnew(4*8, 3), vecnew(121*8, 49*8 + 5))
	lamp(vecnew(122, 42), vecnew(136*8 + 5, 47*8), vecnew(3, 3*8), vecnew(136*8 + 5, 37*8))
	lamp(vecnew(140, 48), vecnew(126*8 + 5, 37*8), vecnew(3, 3*8), vecnew(126*8 + 5, 41*8))

	-- 18
	box(138*8, 53*8)

	-- 19
	lamp(vecnew(93, 61), vecnew(94*8 + 5, 63*8), vecnew(3, 3*8), vecnew(94*8 + 5, 60*8))
	box(99*8, 53*8)
	lamp(vecnew(110, 61), vecnew(91*8, 65*8 + 5), vecnew(2*8, 3), vecnew(102*8, 65*8 + 5))
	spring(108, 66)

	-- 20
	box(108 * 8, 71 * 8)

	-- 21
	lamp(vecnew(130, 78), vecnew(128*8, 85*8 + 5), vecnew(5*8, 3), vecnew(128*8, 99*8 + 5))
	box(135*8, 73*8)

	-- 22
	fireflies(false, vecadd(vecnew(190 * 8, 94 * 8), vecnew(3, -10)), 150, 40, 9)


-- vec
vecnew = (x, y) ->
	return {
		x: x,
		y: y,
	}

veccopy = (vec) ->
	return {
		x: vec.x,
		y: vec.y,
	}

vecequals = (vec1, vec2) ->
	return vec1.x == vec2.x and vec1.y == vec2.y

vecassign = (vec1, vec2) ->
	vec1.x = vec2.x
	vec1.y = vec2.y

vecadd = (vec1, vec2) ->
	return {
		x: vec1.x + vec2.x,
		y: vec1.y + vec2.y,
	}

vecsub = (vec1, vec2) ->
	return {
		x: vec1.x - vec2.x,
		y: vec1.y - vec2.y,
	}

vecmul = (vec, n) ->
	return {
		x: vec.x * n,
		y: vec.y * n,
	}

vecdiv = (vec, n) ->
	return {
		x: vec.x / n,
		y: vec.y / n,
	}

vecdivdiv = (vec, n) ->
	return {
		x: vec.x // n,
		y: vec.y // n,
	}

vecfloor = (vec) ->
	return {
		x: math.floor(vec.x),
		y: math.floor(vec.y),
	}

veclength = (vec) ->
	return math.sqrt(vec.x*vec.x + vec.y*vec.y)

vecdist = (vec1, vec2) ->
	return veclength(vecsub(vec1, vec2))

vecnormalized = (vec) ->
	if vecequals(vec, vecnew(0, 0)) then
		return vecnew(0, 0)
	return vecdiv(vec, veclength(vec))
	
vecshrink = (vec, n) ->
	length = veclength(vec)
	if length < 0.1 then return vecnew(0, 0)
	return vecmul(vecnormalized(vec), length - n)

vecrot = (vec, rad) ->
	newx = 0
	newy = 0
	newx = vec.x * math.cos(rad) - vec.y * math.sin(rad)
	newy = vec.x * math.sin(rad) + vec.y * math.cos(rad)
	return vecnew(newx, newy)

-- intervals
interval_list_update = ->
	for i, interval in ipairs(list_interval)
		if not interval.finished and t - interval.t_creation > (interval.looped + 1) * interval.delay*60 then
			interval.looped += 1
			interval.func()
			if interval.looped >= interval.number_of_loop then
				interval.finished = true

set_interval = (delay, number_of_loop, func) ->
	index = -1
	for i, interval in ipairs(list_interval)
		if interval.finished then
			index = i
			break

	interval = {
		t_creation: t,
		delay: delay,
		func: func,
		id: latest_interval_id,
		number_of_loop: number_of_loop,
		looped: 0,
		finished: false,
	}
	latest_interval_id += 1
	if latest_interval_id > 1000000 then
		trace("interval id pass 1000000")

	if index != -1 then list_interval[index] = interval
	else table.insert(list_interval, interval)

	return interval.id

stop_interval = (id) ->
    for i, interval in ipairs(list_interval)
        if interval.id == id
            interval.finished = true

wait = (delay, func) ->
	return set_interval(delay, 1, func)

stop_wait = (id) ->
	stop_interval(id)

-- math
floor = (n, f) ->
	return (n // f) * f

sqr = (n) ->
	return n*n

rndf = (a, b) ->
	return math.random() * (b - a) + a

rndi = (a, b) ->
	return math.random(a, b)

sign = (n) ->
	if n == 0 then return 0
	if n < 0 then return -1
	return 1

rectcollide = (pos1, sz1, pos2, sz2) ->
	if pos1.x + sz1.x <= pos2.x then return false
	if pos1.x >= pos2.x + sz2.x then return false
	if pos1.y + sz1.y <= pos2.y then return false
	if pos1.y >= pos2.y + sz2.y then return false
	return true

is_in_rect = (pos, rect_pos, rect_sz) ->
	if pos.x < rect_pos.x then return false
	if pos.x >= rect_pos.x + rect_sz.x then return false
	if pos.y < rect_pos.y then return false
	if pos.y >= rect_pos.y + rect_sz.y then return false
	return true

-- From https://easings.net/#easeInOutSine
ease = (n) ->
	return -(math.cos(math.pi * n) - 1) / 2

-- utils
find_in_list = (list, val) ->
	for i, val_comp in ipairs(list)
		if val_comp == val then return i
	return -1

-- tween
tweenvec_create = (pos) ->
	return {
		prev_pos: veccopy(pos),
		pos: veccopy(pos),
		dest: veccopy(pos),
		tween_time: 0.7,
		t_start_tween: 0,
		sine: true,
		tween: (self, dest) ->
			self.prev_pos = veccopy(self.pos)
			self.dest = veccopy(dest)
			self.t_start_tween = t
		set_pos: (self, pos) ->
			self.prev_pos = veccopy(pos)
			self.dest = veccopy(pos)
			self.pos = veccopy(pos)
			self.t_start_tween = t - self.tween_time*60
		tweening: (self) ->
			return t <= self.t_start_tween + self.tween_time*60
	}

tweenvec_list_add = (tweenvec) ->
	table.insert(list_tween_vec, tweenvec)

tweenvec_list_update = () ->
	for i, tweenvec in ipairs(list_tween_vec)
		t_percent = (t - tweenvec.t_start_tween) / (tweenvec.tween_time * 60)
		if t_percent >= 1 then
			tweenvec.pos = veccopy(tweenvec.dest)
			continue
		if tweenvec.sine then
			t_percent = ease(t_percent)
		dir = vecsub(tweenvec.dest, tweenvec.prev_pos)
		dir = vecmul(dir, t_percent)
		tweenvec.pos = vecadd(tweenvec.prev_pos, dir)

-- map
map_solid = (pos) ->
	m = mget(pos.x // 8, pos.y // 8)
	return m >= 1 and m <= 47

map_only_down = (pos) ->
	m = mget(pos.x // 8, pos.y // 8)
	return m >= 48 and m <= 79

map_only_down_half = (pos) ->
	m = mget(pos.x // 8, pos.y // 8)
	return pos.y % 8 <= 1 and m >= 48 and m <= 79

map_spike = (pos) ->
	m = mget(pos.x // 8, pos.y // 8)
	return m >= 80 and m <= 95

-- room
local explode
local restart_room_create
local entity_create
local player_pop
local set_time_stop

get_room = (pos) ->
	map_pos = vecdivdiv(pos, 8)
	for i, room in ipairs(LIST_ROOM)
		if is_in_rect(map_pos, room.pos, room.sz) then return room
	return -1

get_next_room_index = (pos) ->
	map_pos = vecdivdiv(pos, 8)
	for i, room in ipairs(LIST_ROOM)
		if is_in_rect(map_pos, room.pos, room.sz) then 
			if i+1 == 11 then return 12
			if i+1 > #LIST_ROOM then return #LIST_ROOM
			return i+1
	return -1

restart_entities = ->
	for i = #list_entity, 1, -1
		if list_entity[i].type == "knife" then
			table.remove(list_entity, i)
		if list_entity[i].type == "lamp" then
			list_entity[i].broken = false
		if list_entity[i].type == "lamp_door" then
			list_entity[i].close(list_entity[i])
		if list_entity[i].type == "firefly_reset" then
			table.remove(list_entity, i)
		if list_entity[i].type == "box" then
			list_entity[i].pos = veccopy(list_entity[i].origin)

restart_room = () ->
	wait(0.5, () -> entity_list_add(restart_room_create()))
	wait(0.9, () -> 
		player.visible = true
		player.pos = vecadd(vecmul(prev_room.restart, 8), vecnew(0, -16))

		restart_entities()

		set_time_stop(false)
	)

skip_room = () ->
	index = get_next_room_index(vecadd(player.pos, vecnew(4, 12)))
	if index > #LIST_ROOM then return

	player.fvec = vecnew(0, 0)
	player.gravity = 0
	wait(0.5, () -> entity_list_add(restart_room_create()))
	wait(0.9, () -> 
		cam.pos.set_pos(cam.pos, vecmul(LIST_ROOM[index].pos, 8))
		player.pos = vecadd(vecmul(LIST_ROOM[index].restart, 8), vecnew(0, -16))

		restart_entities()

		set_time_stop(false)
	)
	
room_update = ->
	room = get_room(vecadd(player.pos, vecnew(4, 12)))
	if room != -1 then
		prev_room = room
		return

	if room == -1 and player.visible then 
		player_pop()
	
-- restart room = ->
restart_room_draw = (e) ->
	t_diff = t - e.t_creation
	rect(0, WINDOW_H - t_diff * 6, WINDOW_W, WINDOW_H + 100, 0)

restart_room_chkremove = (i, e) ->
	t_diff = t - e.t_creation
	if WINDOW_H - t_diff * 2 < -(WINDOW_H + 100) then
		table.remove(list_entity, i)
	
restart_room_create = ->
	rr = entity_create("restart_room", vecnew(0, 0), vecnew(0, 0))
	rr.t_creation = t

	rr.draw = restart_room_draw
	rr.chkremove = restart_room_chkremove
	
	return rr

-- camera
get_draw_pos = (pos) ->
	return vecsub(pos, vecfloor(cam.pos.pos))

cam_update = () ->
	room = get_room(vecadd(player.pos, vecnew(4, 12)))
	if room == -1 then
		return

	cam_follow_pos = vecsub(player.pos, vecdiv(WINDOW_WH, 2))
	cam_follow_pos = vecadd(cam_follow_pos, vecdiv(player.sz, 2))

	if cam_follow_pos.x//8 < room.pos.x then cam_follow_pos.x = room.pos.x*8
	if (cam_follow_pos.x + WINDOW_W)//8 >= room.pos.x + room.sz.x then
		cam_follow_pos.x = (room.pos.x + room.sz.x)*8 - WINDOW_W
	if cam_follow_pos.y//8 < room.pos.y then cam_follow_pos.y = room.pos.y*8
	if (cam_follow_pos.y + WINDOW_H)//8 >= room.pos.y + room.sz.y then
		cam_follow_pos.y = (room.pos.y + room.sz.y)*8 - WINDOW_H

	follow_dist = vecdist(cam_follow_pos, cam.pos.pos)
	if not cam.pos.tweening(cam.pos) and follow_dist > 50 then
		cam.pos.tween(cam.pos, cam_follow_pos)
		return

	if cam.pos.tweening(cam.pos) then
		return

	cam_follow_spd = vecdist(cam.pos.pos, cam_follow_pos) * 0.06
	cam_follow_dir = vecnormalized(vecsub(cam_follow_pos, cam.pos.pos))
	cam.pos.set_pos(cam.pos, vecadd(cam.pos.pos, vecmul(cam_follow_dir, cam_follow_spd)))

-- entity
COLLISION_COLLISION = 0
COLLISION_ONLY_DOWN = 1
COLLISION_NONE = 2

entity_list_add = (e) ->
	table.insert(list_entity, e)

entity_list_update = ->
	for i, e in ipairs(list_entity)
		if e.update != nil then e.update(e)

entity_list_chkremove = ->
	for i = #list_entity, 1, -1
		e = list_entity[i]
		if e.chkremove != nil then e.chkremove(i, e)

entity_list_draw = ->
	for i, e in ipairs(list_entity)
		if e.draw != nil then e.draw(e)

entity_create = (type, pos, sz) ->
	return {
		type: type,
		pos: veccopy(pos),
		sz: veccopy(sz),
		fvec: vecnew(0, 0),
		gravity: 0,
		gravity_add: 0,
		jump_gravity: 0,
		collision_weight: 999999,
		collision_type: COLLISION_COLLISION,
		ignore_collision: {},
	}

entity_physic_point_list = (pos, e) ->
	list = {}

	for ix = 0, (e.sz.x - 1)//8
		for iy = 0, (e.sz.y - 1)//8
			table.insert(list, vecnew(pos.x + 8*ix, pos.y + 8*iy))

	for ix = 0, (e.sz.x - 1)//8
		table.insert(list, vecnew(pos.x + 8*ix, pos.y + e.sz.y-1))

	for iy = 0, (e.sz.y - 1)//8
		table.insert(list, vecnew(pos.x + e.sz.x-1, pos.y + 8*iy))

	table.insert(list, vecnew(pos.x + e.sz.x-1, pos.y + e.sz.y-1))

	return list

entity_physic_point_list_only_down = (pos, e) ->
	list = {}

	for ix = 0, (e.sz.x - 1)//8
		table.insert(list, vecnew(pos.x + 8*ix, pos.y + e.sz.y-1))

	table.insert(list, vecnew(pos.x + e.sz.x-1, pos.y + e.sz.y-1))

	return list

entity_movex = (e) ->
	mx = e.fvec.x
	if mx == 0 then return
		
	newpos = vecnew(e.pos.x + mx, e.pos.y)
	
	list_physic_point = entity_physic_point_list(newpos, e)

	for i, physic_point in ipairs(list_physic_point)
		if map_solid(physic_point) then
			if mx < 0 then e.pos.x = floor(e.pos.x, 8)
			else e.pos.x = floor(newpos.x + e.sz.x, 8) - e.sz.x
			return

	for i, e_comp in ipairs(list_entity)
		if e_comp == e then continue
		if find_in_list(e.ignore_collision, e_comp) != -1 then continue
		if e_comp.collision_type == COLLISION_NONE then continue
		if e_comp.collision_type == COLLISION_ONLY_DOWN then continue
		if rectcollide(newpos, e.sz, e_comp.pos, e_comp.sz) then
			if mx < 0 then e.pos.x = e_comp.pos.x + e_comp.sz.x
			else e.pos.x = e_comp.pos.x - e.sz.x
			return

	e.pos.x = newpos.x

entity_movey = (e) ->
	my = e.fvec.y
	if my == 0 then return
			
	newpos = vecnew(e.pos.x, e.pos.y + my)
	
	list_physic_point = entity_physic_point_list(newpos, e)

	for i, physic_point in ipairs(list_physic_point)
		if map_solid(physic_point) then
			if my < 0 then e.pos.y = floor(e.pos.y, 8)
			else e.pos.y = floor(newpos.y + e.sz.y, 8) - e.sz.y
			return

	list_physic_point_only_down = entity_physic_point_list_only_down(newpos, e)
	for i, physic_point in ipairs(list_physic_point_only_down)
		if my > 0 and map_only_down(physic_point) then
			dest = floor(newpos.y + e.sz.y, 8) - e.sz.y
			if e.pos.y <= dest then 
				e.pos.y = dest
				return

	for i, e_comp in ipairs(list_entity)
		if e_comp == e then continue
		if find_in_list(e.ignore_collision, e_comp) != -1 then continue
		if e_comp.collision_type == COLLISION_NONE then continue
		if e_comp.collision_type == COLLISION_ONLY_DOWN and my < 0 then continue
		if rectcollide(newpos, e.sz, e_comp.pos, e_comp.sz) then
			if my < 0 then 
				e.pos.y = e_comp.pos.y + e_comp.sz.y
				return
			else
				dest = e_comp.pos.y - e.sz.y
				if e.pos.y <= dest then 
					e.pos.y = dest
					return

	e.pos.y = newpos.y

entity_move = (e) ->
	entity_movex(e)
	entity_movey(e)

_entity_collision_pt_chk = (list) ->
	for i, pos in ipairs(list)
		if map_solid(pos) then
			return true

	return false

_entity_collision_pt_chk_down = (list) ->
	for i, pos in ipairs(list)
		if map_solid(pos) or map_only_down_half(pos) then
			return true

	return false

entity_collision_up = (e) ->
	list = {
		vecnew(e.pos.x, e.pos.y - 1),
		vecnew(e.pos.x + e.sz.x-1, e.pos.y - 1),
	}
	if _entity_collision_pt_chk(list) then
		return true

	newpos = vecnew(e.pos.x, e.pos.y - 1)
	for i, e_comp in ipairs(list_entity)
		if e == e_comp then continue
		if e_comp.collision_type == COLLISION_NONE then continue
		if e_comp.collision_type == COLLISION_ONLY_DOWN then continue
		if rectcollide(newpos, e.sz, e_comp.pos, e_comp.sz) then return true
			
	return false

entity_ground = (e) ->
	list = {
		vecnew(e.pos.x, e.pos.y + e.sz.y),
		vecnew(e.pos.x + e.sz.x-1, e.pos.y + e.sz.y),
	}
	if _entity_collision_pt_chk_down(list) then
		return true

	return false

entity_collision_down = (e) ->
	list = {
		vecnew(e.pos.x, e.pos.y + e.sz.y),
		vecnew(e.pos.x + e.sz.x-1, e.pos.y + e.sz.y),
	}
	if _entity_collision_pt_chk_down(list) then
		return true

	newpos = vecnew(e.pos.x, e.pos.y + 1)
	for i, e_comp in ipairs(list_entity)
		if e == e_comp then continue
		if e_comp.collision_type == COLLISION_NONE then continue
		if e_comp.collision_type == COLLISION_ONLY_DOWN then
			if rectcollide(vecnew(newpos.x, newpos.y + e.sz.y-1), vecnew(e.sz.x, 1), e_comp.pos, e_comp.sz) then return true
			continue
		if rectcollide(newpos, e.sz, e_comp.pos, e_comp.sz) then return true

	return false

entity_collision_left = (e) ->
	list = {
		vecnew(e.pos.x - 1, e.pos.y),
		vecnew(e.pos.x - 1, e.pos.y + e.sz.y - 1),
	}
	if _entity_collision_pt_chk(list) then
		return true

	newpos = vecnew(e.pos.x - 1, e.pos.y)
	for i, e_comp in ipairs(list_entity)
		if e == e_comp then continue
		if e_comp.collision_type == COLLISION_NONE then continue
		if e_comp.collision_type == COLLISION_ONLY_DOWN then continue
		if rectcollide(newpos, e.sz, e_comp.pos, e_comp.sz) then return true

	return false

entity_collision_right = (e) ->
	list = {
		vecnew(e.pos.x + e.sz.x, e.pos.y),
		vecnew(e.pos.x + e.sz.x, e.pos.y + e.sz.y - 1),
	}
	if _entity_collision_pt_chk(list) then
		return true

	newpos = vecnew(e.pos.x + 1, e.pos.y)
	for i, e_comp in ipairs(list_entity)
		if e == e_comp then continue
		if e_comp.collision_type == COLLISION_NONE then continue
		if e_comp.collision_type == COLLISION_ONLY_DOWN then continue
		if rectcollide(newpos, e.sz, e_comp.pos, e_comp.sz) then return true

	return false

entity_gravity = (e, gravity_add, jump, jump_gravity) ->
	e.gravity += gravity_add

	if e.fvec.y > 0 and entity_collision_down(e) then
		e.gravity = 1
		if jump then e.gravity = jump_gravity

	if entity_collision_up(e, true) then
		e.gravity = 1

-- player
local knife_create
_player_looking_right = true
_knife_cooldown = 0

player_pop = ->
	player.visible = false
	player.fvec = vecnew(0, 0)
	player.gravity = 0
	explode(vecadd(player.pos, vecnew(4, 8)), 1.7, math.pi/2/3, 40, 5, 11)
	restart_room()

set_time_stop = (b) ->
	time_stopped = b
	if time_stopped then n_vbank = 1 else n_vbank = 0

player_update = (e) ->
	if at_title or showing_menu then return
	if t < menu_cooldown then return
	if not player.visible then return

	e.fvec.x = 0
	if btn(2) then e.fvec.x = -1
	if btn(3) then e.fvec.x = 1

	entity_gravity(e, e.gravity_add, btnp(4), e.jump_gravity)
	e.fvec.y = math.floor(e.gravity)

	entity_move(e)


	if btnp(5) and _knife_cooldown <= 0 then
		_knife_cooldown = KNIFE_COOLDOWN * 60
		knife_pos = vecnew(e.pos.x + e.sz.x, e.pos.y + 6)
		if not _player_looking_right then knife_pos.x = e.pos.x - 8
		entity_list_add(knife_create(knife_pos, _player_looking_right))
	_knife_cooldown -= 1

	
	if btnp(6) then
		set_time_stop(not time_stopped)


	list_physic_point = entity_physic_point_list(player.pos, player)
	for i, point in ipairs(list_physic_point)
		if map_spike(point) then 
			player_pop()
			break

_PLAYER_SPR = {
	run: {
		257,
		259,
		263,
		261,
	},
	idle: {
		256,
		288,
	},
	air: {
		257,
	},
}

_t_player_stop_move = 0

player_draw = (e) ->
	if not player.visible then return
		
	draw_pos = get_draw_pos(e.pos)

	if not at_title and not showing_menu and t >= menu_cooldown and btn(2) then _player_looking_right = false
	if not at_title and not showing_menu and t >= menu_cooldown and btn(3) then _player_looking_right = true

	if e.fvec.y < 0 or not entity_collision_down(e) then
		if not _player_looking_right then
			spr(_PLAYER_SPR.air[1], draw_pos.x-4, draw_pos.y, 0, 1, 0, 0, 2, 2)
		else
			spr(_PLAYER_SPR.air[1], draw_pos.x-4, draw_pos.y, 0, 1, 1, 0, 2, 2)
		return

	if not at_title and not showing_menu and t >= menu_cooldown and btn(2) then
		spr(_PLAYER_SPR.run[(t//6)%4+1], draw_pos.x-4, draw_pos.y, 0, 1, 0, 0, 2, 2)
		_t_player_stop_move = t
		return

	if not at_title and not showing_menu and t >= menu_cooldown and btn(3) then
		spr(_PLAYER_SPR.run[(t//6)%4+1], draw_pos.x-4, draw_pos.y, 0, 1, 1, 0, 2, 2)
		_t_player_stop_move = t
		return

	if not _player_looking_right then
		spr(_PLAYER_SPR.idle[(t-_t_player_stop_move)//40%2 + 1], draw_pos.x, draw_pos.y, 0, 1, 0, 0, 1, 2)
		return
	
	spr(_PLAYER_SPR.idle[(t-_t_player_stop_move)//40%2 + 1], draw_pos.x, draw_pos.y, 0, 1, 1, 0, 1, 2)

player_create = (pos) ->
	player = entity_create("player", pos, vecnew(8, 16))
	player.collision_weight = 10

	player.gravity_add = NORMAL_GRAVITY_ADD
	player.jump_gravity = NORMAL_JUMP_GRAVITY

	player.visible = true

	player.draw = player_draw
	player.update = player_update

	return player

-- Knife
knife_update = (e) ->
	if time_stopped then return
	entity_move(e)

knife_draw = (e) ->
	draw_pos = vecnew(0, 0)
	if e.fvec.x < 0 then draw_pos.x = e.pos.x - 1
	else draw_pos.x = e.pos.x - 7
	draw_pos.y = e.pos.y

	draw_pos = get_draw_pos(draw_pos)

	flip = 0
	if e.fvec.x > 0 then flip = 1

	spr(320, draw_pos.x, draw_pos.y, 0, 1, flip, 0, 2, 1)

knife_create = (pos, right_dir) ->
	knife = entity_create("knife", pos, vecnew(8, 2))
	if not right_dir then
		knife.fvec.x = -2
	else
		knife.fvec.x = 2

	knife.update = knife_update
	knife.draw = knife_draw

	knife.collision_type = COLLISION_ONLY_DOWN
	knife.ignore_collision = { player }

	return knife

-- explode
explode_particle_update = (par) ->
	par.pos = vecadd(par.pos, par.fvec)

explode_particle_chkremove = (i, par) ->
	dist = vecdist(par.pos, par.origin)
	if dist > par.max_dist + par.line_dist then table.remove(list_entity, i)

explode_particle_draw = (par) ->
	p1 = veccopy(par.pos)
	dist = vecdist(p1, par.origin)

	dir = vecnormalized(par.fvec)
	p0 = veccopy(par.origin)
	if dist > par.line_dist then p0 = vecsub(p1, vecmul(dir, par.line_dist))

	if dist > par.max_dist then p1 = vecadd(par.origin, vecmul(dir, par.max_dist))
	
	drawp0 = get_draw_pos(p0)
	drawp1 = get_draw_pos(p1)
	line(drawp0.x, drawp0.y, drawp1.x, drawp1.y, par.color)

explode_particle_create = (pos, fvec, max_dist, line_dist, color) ->
	par = entity_create("explode_particle", pos, vecnew(0, 0))
	par.collision_type = COLLISION_NONE
	par.fvec = veccopy(fvec)
	par.max_dist = max_dist
	par.color = color
	par.origin = veccopy(pos)
	par.line_dist = line_dist
	
	par.update = explode_particle_update
	par.chkremove = explode_particle_chkremove
	par.draw = explode_particle_draw
	return par

explode = (pos, spd, step, max_dist, line_dist, color) ->
	for i = 0, (math.pi*2) // step
		fvec = vecrot(vecnew(0, spd), i*step)
		entity_list_add(explode_particle_create(pos, fvec, max_dist, line_dist, color))

-- spring
spring_update = (e) ->
	if time_stopped then
		e.t_spring_start += 1
		return

	t_diff = (t - e.t_spring_start) / 60
	if rectcollide(player.pos, player.sz, e.pos, e.sz) and t_diff > 0.5 then
		e.t_spring_start = t
		player.gravity = -3.5
		player.pos = vecsub(player.pos, vecnew(0, 1))

_SPRING_SPR = {
	337, 338, 337, 336,
}
spring_draw = (e) ->
	draw_pos = get_draw_pos(e.pos)
	t_diff = (t - e.t_spring_start) / 60
	i = t_diff // 0.1 + 1
	if i > #_SPRING_SPR then i = #_SPRING_SPR
	spr(_SPRING_SPR[i], draw_pos.x, draw_pos.y - 6, 0)

spring_create = (map_pos) ->
	spring = entity_create("spring", vecnew(map_pos.x*8, map_pos.y*8 + 6), vecnew(8, 2))
	spring.t_spring_start = 0
	spring.update = spring_update
	spring.draw = spring_draw
	spring.collision_type = COLLISION_NONE
	return spring

-- lamp
lamp_update = (e) ->
	if e.broken then return

	for i, e_comp in ipairs(list_entity)
		if e_comp.type != "knife" then continue
		if rectcollide(e_comp.pos, e_comp.sz, e.pos, e.sz) then
			e.broken = true

			explode(vecadd(e.pos, vecnew(3, 4)), 1, math.pi/4, 15, 2, 9)
			-- fireflies(true, vecadd(e.pos, vecnew(3, -10)), 50, 15, 9)

			e.connect_to.move(e.connect_to)

lamp_draw = (e) ->
	if e.broken then
		return

	draw_pos = get_draw_pos(e.pos)
	spr(352, draw_pos.x, draw_pos.y, 0)

lamp_create = (map_pos, connect_to) ->
	lamp = entity_create("lamp", vecnew(map_pos.x*8, map_pos.y*8), vecnew(8, 8))
	lamp.connect_to = connect_to
	lamp.collision_type = COLLISION_NONE
	lamp.broken = false

	lamp.draw = lamp_draw
	lamp.update = lamp_update
	return lamp

-- lamp door
lamp_door_update = (e) ->
	if time_stopped then
		e.tween_pos.t_start_tween += 1

	for i, knife in ipairs(list_entity)
		if knife.type != "knife" then continue
		if rectcollide(vecadd(e.pos, vecnew(-1, 0)), vecadd(e.sz, vecnew(2, 0)), knife.pos, knife.sz) then
			knife.pos = vecadd(knife.pos, vecsub(e.tween_pos.pos, e.pos))

	if rectcollide(vecadd(e.pos, vecnew(0, -1)), vecadd(e.sz, vecnew(0, 2)), player.pos, player.sz) then
		player.pos = vecadd(player.pos, vecsub(e.tween_pos.pos, e.pos))

	vecassign(e.pos, e.tween_pos.pos)

lamp_door_draw = (e) ->
	draw_pos = get_draw_pos(e.pos)
	rect(draw_pos.x, draw_pos.y, e.sz.x, e.sz.y, 4)
	
	pix(draw_pos.x + e.sz.x - 1, draw_pos.y, 3)
	pix(draw_pos.x + e.sz.x - 2, draw_pos.y, 3)
	pix(draw_pos.x + e.sz.x - 1, draw_pos.y + 1, 3)

	-- pix(draw_pos.x, draw_pos.y + e.sz.y - 1, 4)
	-- pix(draw_pos.x, draw_pos.y + e.sz.y - 2, 4)
	-- pix(draw_pos.x + 1, draw_pos.y + e.sz.y - 1, 4)

lamp_door_create = (pos, sz, dest) ->
	lamp_door = entity_create("lamp_door", pos, sz)
	lamp_door.tween_pos = tweenvec_create(pos)
	lamp_door.tween_pos.tween_time = 2
	tweenvec_list_add(lamp_door.tween_pos)
	lamp_door.dest = veccopy(dest)
	lamp_door.origin = veccopy(pos)
	lamp_door.move = (e) ->
		e.tween_pos.tween(e.tween_pos, e.dest)
	lamp_door.close = (e) ->
		e.tween_pos.set_pos(e.tween_pos, e.origin)

	lamp_door.update = lamp_door_update
	lamp_door.draw = lamp_door_draw

	return lamp_door

-- firefly
firefly_update = (e) ->
	if time_stopped then
		e.rnd -= 1

firefly_draw = (e) ->
	draw_pos = get_draw_pos(e.pos)
	offsety = math.sin((t+e.rnd)/60) * 3
	pix(draw_pos.x, draw_pos.y + offsety, e.color)

firefly_create = (reset, pos, color) ->
	type = ""
	if reset then type = "firefly_reset" else type = "firefly"
	firefly = entity_create(type, pos, vecnew(1, 1))
	firefly.color = color
	firefly.collision_type = COLLISION_NONE
	firefly.rnd = rndi(0, 1000)

	firefly.draw = firefly_draw
	firefly.update = firefly_update
	return firefly

-- fireflies
fireflies = (reset, pos, radius, num, color) ->
	for i = 1, num
		vec = vecnew(rndf(-1, 1), rndf(-1, 1))
		vec = vecmul(vecnormalized(vec), rndf(0, radius))
		wait(i*rndf(0.1, 0.2), ->
			entity_list_add(firefly_create(reset, vecadd(pos, vec), color))
		)

export BOOT = ->
	boot()

-- box
box_update = (e) ->
	if time_stopped then return
		
	prev_pos = veccopy(e.pos)
	e.fvec.x = 0

	if rectcollide(vecadd(e.pos, vecnew(-1, 0)), vecadd(e.sz, vecnew(2, 0)), player.pos, player.sz) then
		if sign(player.fvec.x) == sign(e.pos.x - player.pos.x) and entity_ground(player) then
			e.fvec.x = player.fvec.x/3

	entity_gravity(e, e.gravity_add, false, 0)
	e.fvec.y = math.floor(e.gravity)
	entity_move(e)

	for i, knife in ipairs(list_entity)
		if knife.type != "knife" then continue
		if rectcollide(vecadd(e.pos, vecnew(-1, 0)), vecadd(e.sz, vecnew(2, 0)), knife.pos, knife.sz) then
			knife.pos = vecadd(knife.pos, vecsub(e.pos, prev_pos))

box_draw = (e) ->
	draw_pos = get_draw_pos(e.pos)
	spr(368, draw_pos.x, draw_pos.y, 0, 1, 0, 0, 2, 2)

box_create = (pos) ->
	box = entity_create("box", pos, vecnew(16, 16))
	box.origin = veccopy(pos)
	box.collision_weight = 10
	box.gravity_add = NORMAL_GRAVITY_ADD

	box.draw = box_draw
	box.update = box_update
	return box

export TIC = ->
	cls(0)
	vbank(n_vbank)

	title_update()
	ui_update()
	cam_update()
	cam_pos = vecfloor(cam.pos.pos)
	map(cam_pos.x//8-1, cam_pos.y//8-1, 32, 19, 8 - cam_pos.x%8 - 16, 8 - cam_pos.y%8 - 16)

	tweenvec_list_update()
	interval_list_update()
	room_update()
	entity_list_update()
	entity_list_chkremove()

	bkg()
	entity_list_draw()
	ui_draw()

	t += 1

-- <TILES>
-- 001:eeeeeeeee000000ee000000ee000000ee000000ee000000ee000000eeeeeeeee
-- 002:ffefeeee0ffffffe0ffffffe000ffffeeeee0feefffe0ffffffe0fffffff00f0
-- 003:ffeeeeee0ffffffe0ffffffe000ffffeeeee0feefffe0ffffffe0fffffff0000
-- 004:ffefeeee0ffffffe0ffffffe000ffffeefee0feefffe0ffffffe0fffffff00ff
-- 006:dddddddd000ddd000ff0dffe000ffffeeeee0feefffe0ffffffe0fffffff00f0
-- 007:dddddddd0dddd00000dddffe000ffffeeeee0feefffe0ffffffe0fffffff0000
-- 008:ddddddddddddd0000dddfffe000ffffeeeee0feefffe0ffffffe0fffffff00f0
-- 009:dddddddd0000dddd0ffff0de000ffffeeeee0feefffe0ffffffe0fffffff0000
-- 048:3333333344000000400000000000000000000000000000000000000000000000
-- 049:3333333300000000000000000000000000000000000000000000000000000000
-- 050:3333333300000044000000040000000000000000000000000000000000000000
-- 080:ee00e00efeeeeeee0efddde00efffde0ee8fffee0e88ffe00eeeeee0ff00e00e
-- 096:00ff000000f0f00000f0f000000f000000f0f00000f0f00000f0f000000f0000
-- 097:000000000000000000000000000dd000000dd000000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:00bbbb000bbbbbb00bcbbbb00bcccbb00bccccb00bdccdb0008dd80008fddf80
-- 001:000000bb00000bbb00000bcb00000bcc00000bcc00000bdc0000008d000008fd
-- 002:bb000000bbb00000bbb00000cbb00000ccb00000cdb00000d8000000df800000
-- 003:00000000000000bb00000bbb00000bcb00000bcc00000bcc00000bdc0000008d
-- 004:00000000bb000000bbb00000bbb00000cbb00000ccb00000cdb00000d8000000
-- 005:000000bb00000bbb00000bcb00000bcc00000bcc00000bdc0000008d000008fd
-- 006:bb000000bbb00000bbb00000cbb00000ccb00000cdb00000d8000000df800000
-- 007:00000000000000bb00000bbb00000bcb00000bcc00000bcc00000bdc0000008d
-- 008:00000000bb000000bbb00000bbb00000cbb00000ccb00000cdb00000d8000000
-- 016:08fddf800ffddff0fff88ffffff88ffffff88fff08f88f8000c00c0000f00f00
-- 017:00008ffd000ffffd00fffff8000f8ff800000ff800000ff8000000c0000000f0
-- 018:dff80000dffff0008fffff008ff8f0008ff000008ff000000c0000000f000000
-- 019:000008fd00008ffd000ffffd00fffff8000f8ff800000ff80000000c0000000f
-- 020:df800000dff80000dffff0008fffff008ff8f0008ff00000c00000000f000000
-- 021:00008ffd000ffffd00fffff8000f8ff800000ff800000ff800000c0000000f00
-- 022:dff80000dffff0008fffff008ff8f0008ff000008ff0000000c0000000f00000
-- 023:000008fd00008ffd000ffffd00fffff8000f8ff800000ff8000000c0000000f0
-- 024:df800000dff80000dffff0008fffff008ff8f0008ff000000c0000000f000000
-- 032:0000000000bbbb000bbbbbb00bcbbbb00bcccbb00bccccb00bdccdb0008dd800
-- 048:08fddf8008fddf800ffddff0fff88ffffff88fff08f88f8000c00c0000f00f00
-- 064:eedeeeee0eedee00000000000000000000000000000000000000000000000000
-- 065:ee00000000000000000000000000000000000000000000000000000000000000
-- 080:0000000000000000000000000000000000000000000000004333c3cc4433333c
-- 081:0000000000000000000000004333c3cc4433333c044003300003300003300330
-- 082:4333c3cc4433333c040000300030030000033000000330000030030003000030
-- 096:000f00000feeef000eecee000e99ce000e99ce000e499e000eeeee0000000000
-- 112:3333333333777777373444443473444434473444344473443444473434444473
-- 113:33c3cccc7777773c444443724444377344437473443744734374447337444473
-- 128:3444444334444437344443743444374434437444343744443374444433333333
-- 129:3444447373444473473444734473447344473473444473734444473333333333
-- 192:000000000000000000000000000000000000efff0000f0000000f00000feeef0
-- 193:00000000000000000000000000ef0000ffff000000ef000000ef000000ef0000
-- 194:000000000000000000000000000000000000efff0000f0000000f00000feeef0
-- 195:00000000000000000000000000ef0000ffff000000ef000000ef000000ef0000
-- 208:00eecee000ebbce000ebbce000edbbe000eeeee0000000000000000000000000
-- 209:00ef000000ef000000ef000000ef000000ef000000ef000000ef000000ef0000
-- 210:00eecee000e99ce000e99ce000e499e000eeeee0000000000000000000000000
-- 211:00ef000000ef000000ef000000ef000000ef000000ef000000ef000000ef0000
-- 225:00ef000000ef000000ef000000ef000000ef000000ef000000ef000000ef0000
-- 227:00ef000000ef000000ef000000ef000000ef000000ef000000ef000000ef0000
-- 241:00ef000000ef000000ef000000ef000000ef000000ef000000ef000000ef0000
-- 243:00ef000000ef000000ef000000ef000000ef000000ef000000ef000000ef0000
-- </SPRITES>

-- <MAP>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000
-- 001:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000060000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 002:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000060000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 003:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 004:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000160000000000000020200000000000000000000000000020031323202020202020202000000020000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202020031300000000000000000000000000000000160000000000000020200000000000000000000000000000000000000020202020202000000020000000000000000000000000000000000000000000000000000000000000
-- 006:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000202020202020202020200000000000000000000000000000000000000000160000000000000020200000000000000000000000000000000000000000002020202000000020000000000000000000000000000000000000000000000000000000000000
-- 007:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000060000202020000020200000000000132320000000000000000000000000160000000000202020202020202020202020202000000000000000000000000000202000000020000000000000000000000000000000000000000000000000000000000000
-- 008:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000002020000020200000000000000000000000000000000000000000160000002020202020200000000000000600202000000000000000000000000000002000000020000000000000000000000000000000000000000000000000000000000000
-- 009:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000160000002020202020200000000000000000002000000000000000000000000000002000000020000000000000000000000000000000000000000000000000000000000000
-- 010:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000132320000000000000000000000000160000000000000000000000000000001616162020161616161616161616160000002000000020000000000000000000000000000000000000000000000000000000000000
-- 011:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000132320202020202020202020202020000000000000000000161616161616161600000000000000000000000000000000000000000000161616160000000000000000000000000000002020200000000000000000160000002000000020000000000000000000000000000000000000000000000000000000000000
-- 012:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020000000160000002000000020000000000000000000000000000000000000000000000000000000000000
-- 013:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000161616160000002000000020000000000000000000000000000000000000000000000000000000000000
-- 014:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020031300000020202020202020202020200000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000002000000020000000000000000000000000000000000000000000000000000000000000
-- 015:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000020200505050520200505050520200505050520202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000002000000020000000000000000000000000000000000000000000000000000000000000
-- 016:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000000020000000000000000000000000000000000000000000000000000000000000
-- 017:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202000000020000000000000000000000000000000000000000000000000000000000000
-- 018:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000202000060000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 019:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 020:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020000000000000000000202020202020202020202020202020202020202020202020202003132320200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 021:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000000000000000000000000000000000020132320000000000000000000000000000000000000000000000000000000000000
-- 022:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202000000000000000000000000000000000202020000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 023:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020200000000000000000000000000000000000000000050505000000000000000000000000000000000000000000000000000000000000132320200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000500000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 024:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000500000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 025:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000060000000000000500000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 026:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000013232020202000000000000000000000132320200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000001616161600000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 027:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000001600000500000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 028:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202005050505050505050505050520200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000001600000500000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 029:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000050500202020000023202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000001616160516160000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 030:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000050500000000000000202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000000000000500160000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 031:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000050500000000000000202020202020202020000000000000000000000000000000000000000000000000000000002020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000500160000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 032:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000202020202020202020202005050505050505202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000500000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 033:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000202000000020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000
-- 034:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200313000020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000000020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000
-- 035:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000600200000000000000000002000000000000000000000000020200000000600000000000000000000000000000000000000000000000020202000000000000000000000000000000006000006000000000006000020000000000000000000000000000000000000000000000000000000000000
-- 036:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000600200000000050000000002000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202000000000001616161616161616161600000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 037:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200313000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000600000000000000000000000000000000000000000000000020200000001600000000000000000000000000000000000000000000000020202020200000001600000000000000000000000016000000000016000020000000000000000000000000000000000000000000000000000000000000
-- 038:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000001616161616161616161616161616161600000000000020200000001600000000000000000000000000000000000000000000000020202020202020202020202020000000000000000016000000000016000020000000000000000000000000000000000000000000000000000000000000
-- 039:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000001600000000000000000000000000000000001600000000000020200000001600000000000000000000000000000000000000000000000020200000000000001600000000000000000000000016000000000016000020000000000000000000000000000000000000000000000000000000000000
-- 040:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202000002020031313132320200000001600000000000000000000000000000000000000000000000020200000001616161600000000000000000000000016000000000016000020000000000000000000000000000000000000000000000000000000000000
-- 041:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202000000000000000002020202000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200006001616161616161616000000000000000000001600000000000020200000001600000000001323202005050000000000000000000000000020200000202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000
-- 042:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000002020200000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000000000000016000000000000000000001600000000000020200000001600000000000000202005050000000000000000000000000020200000000000000000000000000000000000000016000000000016000020000000000000000000000000000000000000000000000000000000000000
-- 043:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000002000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200016161616161616000016000000000000000000001600000000002020200000001600000000000000202005050000000000000000000000000020200000000000000000000000000000161616161616000000000016000020000000000000000000000000000000000000000000000000000000000000
-- 044:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200323200000000000000000002000000000000500000000000000000020000000000000000000000000000000000000000000000000000000000000200505050505202020202020202020202020202020202000002003232020200000001600000000001323202005052020050500000000000000000020202020202020202020202020202020202020202020202020202020000020000000000000000000000000000000000000000000000000000000000000
-- 045:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000002000000000000500000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000200016000016000000002000000006001600000000000020200000001600000000000000202005052020050500000000000000000020200000000000000000000000000020000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 046:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000002000000000000500000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000200016000016000000002000000006001600000000000020200000001600000000000000202005052020050500000000000000000020200000000000000000000000000020000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 047:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200323200000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000200016000016000000000000000006001600002003132320200000001600000000001323202005052020050520200505000000000000000000000000000000000000000020000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 048:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000200016161616161616160000000000161600000000000000001616161600000000000000202005052020050520200505000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 049:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000200000000000200000000016000000000000000000000000000000000000000000000000000000000000202005052020050520200505000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000
-- 050:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020200000000020000000000000000000000000000000000000000000000000000000000000202020202020202020200000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000
-- 051:202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000132320202020202020202020202020202020202020202020202020202020202020202020202020202020200000000020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 052:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000200000000000000000002000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 053:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000200000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 054:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020200000000000000000000000000000000000000000000000000000000020200000000000000000200000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 055:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202005050505202020202020202020202020202020202003130020200000000000000000200313232020202020202000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 056:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020200000062000000000000000000000000000000006000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 057:200000000000000000000020202020202020000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020200000062000000000000000000000000000000006000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 058:200000000000000000000020000020202020202000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020201616062016161616160000000000000000000006000000000000132320200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 059:200000000000000000000000000000002020202000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020201600062000000000160000000000000000000006000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 060:202020000000000000000020000000002020202000000000000000000020200000000000000000000000000000000000000000000000000000000505050505050505050000000000000000000000202020202020202020202020201600060000000000160000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 061:200000000000000000000020031300000020202000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020201600000000000000161616161616161616161600000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 062:200000000000000000000000000000000000202000000000000000000000000000000000000005050000000000000000000505000000000000000000000000000000000000000000000000002020202020202020202020202020201600160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 063:200000000000000000000020000000000000202000000000000000000000000000000000000005050000000000000000000505000000000000000000000000000000000000000000000000202020202020202020202020202020201600160020202020000000000000000000000000000020202020202020202020202000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 064:200000000000000000000020031300000000202000000000000000000000000000000000000005050000000000000000000505000000000000000000000000000000000000000000002020202020202020202020202020202020201600161620202020200000000000050500000000000020202020202020202020202000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 065:200000000000000000000000000000000000202000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020201600000020202020200000000000050500000000002020202020202020202020202000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 066:200000000000000000000000000000000000202000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000202020202020200500000000050500000000202020202020202020202020202000000000000000000000000000000000000000000000202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 067:202020202020202020202020202020000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000202020202020200505050505202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 068:202020202020202020202020202020001323202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 069:200000000000000000000000000000000000200000000000000000000020200000000000000000000000000000000000000000200000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 070:200000000000000000000000000000000000200000000000000000000020200000000000000000000000000000000000000000200000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 071:200000000000000000000000000000001323200000000000000000000020200000000000000000000000000000000000000000200000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 072:200000000000000000000000000000000000200000000000000000000020200000000000000000000000000000000000000000200000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 073:200000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202000000020202020202020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 074:200000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 075:200000000000000000000000000000002020200000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000020202020000000000000000000000000000000000000000000000000000020200000000000000000000000202020202000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 076:200000000000000000202020202020202020000000000000000000202020202020000000000000000000000000000000000000200000000000132320202020202020202020202020000000000000000020202020200000000020202000000000000000000000000000000000000000000000000000000020200000000000000000202020000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 077:200000000000000000000000000000000000000000000000002020202020200000000000000000002020000000000000000000000000000000000020202020202020000000000000000000000000000000000000000000132320200000000000000000000000000000000000000000000000000000000000000000000000000020000600000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 078:200313000000000000000000000000000000000000000000202020202020200000000000000000002020202000000000000000000000000000132320202020200000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 079:200000000000000000000000000000000000000000000000202020202020200000000000000000002020202020200000000000000000000000000020202020000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000002020200000001600000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 080:200000002020202020202000000000000000000000002020202020202020200000000000000000000000202020202020031300000000000000132320202000000000000000000000000000000000000000000000002020202020200000000000000000000000000000000000000000000000001323202020202020200000000000001600000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 081:200000000000000000000000000000000000000000202020202020202020200000000000000000000000000000000000000000000000000000000020202000000000000000000000000000000000000000000000202020202020200505050505050505050505050505050505050505050505050505050520200000000000000000001600000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 082:200000000000000000000000000000000000000020202020202020202020200000000000000000000000000000000000000000000000000000132320200000000000000000000000000000000000000000000020202020202020202020202020202020202000000000000000000000000000000000000020200000000000000000001600000000050505050505050505050505050520200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 083:200000000000000000000000000000000000202020202020202020202020200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000002020202020202020202020202020202020000000000000000000000000000000000000000020200000000000000000001600000000000000000000000000050505050520200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 084:202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000001600000000000000000000000000000000050520200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 085:202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000001323202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000001600000000000000000000000000000000000520200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 086:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202020202020202020202020202000000000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 087:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202020202020202020202020202003130000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 088:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202020202020202020202020202000000000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 089:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202020202020202020202020202000000000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 090:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000020202020202020202020202020202000000000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 091:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001323202020202020202020202020000000000000000000000000000000000000000000000000000000000000200505050505050505050505050505000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 092:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200505050505000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 093:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020000000000000000000000000000000000000000000000000000000000000200505000000000000000000000000000000000000000000002020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 094:200000000000000000000000000000000000000000000000000000000020200000000000000000000000000000000000000000002020202003132320202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200500000000000000000000000000000000000000202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 095:200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200500000000000000000000000000132320202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 096:200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 097:200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000
-- 098:200000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200505000000000000000000000000000000000000000000000000007070609080809070607070807060909080707060606090909070809090909090909080706060906090909070706060907080707080908060607070708060200000000000000000000000000000000000000000000000000000000000
-- 099:200000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200505050500000000000000000000000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000
-- 100:200000000000000000000000000000002020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000200505050505050505050505050505050000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000
-- 101:202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2cedededfffbedf3dea4f5c16da7f07038b764ad8a53262c3fffea66d98effbaf5fffffff694b0c2566c86333c57
-- 001:1a1c2cedededfffbeddededec7c7c7a7f07038b7648e8e8e2c2c2ce1e1e1d98effe4e4e4fffff6aaaaaa6868683c3c3c
-- </PALETTE>
