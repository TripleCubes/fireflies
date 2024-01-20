-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  moon

WINDOW_W = 240
WINDOW_H = 136
WINDOW_WH = { x: 240, y: 136 }

NORMAL_GRAVITY_ADD = 0.15
NORMAL_JUMP_GRAVITY = -2.2

t = 0
list_entity = {}
cam = {
	pos: { x: 0, y: 0 },
}

-- vec
vec = (x, y) ->
	return {
		x: x,
		y: y,
	}

vecassign = (vec1, vec2) ->
	vec1.x = vec2.x
	vec1.y = vec2.y

veccp = (vec) ->
	return {
		x: vec.x,
		y: vec.y,
	}

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
	return vecdiv(vec, veclength(vec))
	
vecshrink = (vec, n) ->
	length = veclength(vec)
	if length < 0.1 then return vec(0, 0)
	return vecmul(vecnormalized(vec), length - n)

-- math
floor = (n, f) ->
	return (n // f) * f

-- map
map_solid = (pos) ->
	return mget(pos.x // 8, pos.y // 8) != 0

-- entity
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

entity_create = (pos, sz) ->
	return {
		pos: veccp(pos),
		sz: veccp(sz),
		fvec: vec(0, 0),
		gravity: 0,
		gravity_add: 0,
		jump_gravity: 0
	}

entity_physic_point_list = (pos, e) ->
	list = {}

	for ix = 0, (e.sz.x - 1)//8
		for iy = 0, (e.sz.y - 1)//8
			table.insert(list, vec(pos.x + 8*ix, pos.y + 8*iy))

	for ix = 0, (e.sz.x - 1)//8
		table.insert(list, vec(pos.x + 8*ix, pos.y + e.sz.y-1))

	for iy = 0, (e.sz.y - 1)//8
		table.insert(list, vec(pos.x + e.sz.x-1, pos.y + 8*iy))

	table.insert(list, vec(pos.x + e.sz.x-1, pos.y + e.sz.y-1))

	return list

entity_movex = (e) ->
	mx = e.fvec.x
	if mx == 0 then return
		
	newpos = vec(e.pos.x + mx, e.pos.y)
	list_physic_point = entity_physic_point_list(newpos, e)

	for i, physic_point in ipairs(list_physic_point)
		if map_solid(physic_point) then
			if mx < 0 then e.pos.x = floor(e.pos.x, 8)
			else e.pos.x = floor(newpos.x + e.sz.x, 8) - e.sz.x
			return

	e.pos.x = newpos.x

entity_movey = (e) ->
	my = e.fvec.y
	if my == 0 then return
			
	newpos = vec(e.pos.x, e.pos.y + my)
	list_physic_point = entity_physic_point_list(newpos, e)

	for i, physic_point in ipairs(list_physic_point)
		if map_solid(physic_point) then
			if my < 0 then e.pos.y = floor(e.pos.y, 8)
			else e.pos.y = floor(newpos.y + e.sz.y, 8) - e.sz.y
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

entity_collision_up = (e, count_fvec) ->
	if count_fvec and e.fvec.y >= 0 then return false

	list = {
		vec(e.pos.x , e.pos.y - 1),
		vec(e.pos.x + e.sz.x-1 , e.pos.y - 1),
	}

	if _entity_collision_pt_chk(list) then
		return true
			
	return false

entity_collision_down = (e, count_fvec) ->
	if count_fvec and e.fvec.y <= 0 then return false

	list = {
		vec(e.pos.x , e.pos.y + e.sz.y),
		vec(e.pos.x + e.sz.x-1 , e.pos.y + e.sz.y),
	}

	if _entity_collision_pt_chk(list) then
		return true

	return false

entity_collision_left = (e, count_fvec) ->
	if count_fvec and e.fvec.x >= 0 then return false

	list = {
		vec(e.pos.x - 1, e.pos.y),
		vec(e.pos.x - 1, e.pos.y + e.sz.y - 1),
	}

	if _entity_collision_pt_chk(list) then
		return true

	return false

entity_collision_right = (e, count_fvec) ->
	if count_fvec and e.fvec.x <= 0 then return false

	list = {
		vec(e.pos.x + e.sz.x, e.pos.y),
		vec(e.pos.x + e.sz.x, e.pos.y + e.sz.y - 1),
	}

	if _entity_collision_pt_chk(list) then
		return true

	return false

entity_gravity = (e, gravity_add, jump, jump_gravity) ->
	e.gravity += gravity_add

	if entity_collision_down(e, true) then
		e.gravity = 0
		if jump then e.gravity = jump_gravity

	if entity_collision_up(e, true) then
		e.gravity = 0

-- player
player_create = (pos, hp) ->
	player = entity_create(pos, vec(8, 16))
	player.hp = hp
	return player

player_update = (e) ->
	e.fvec.x = 0
	if btn(2) then e.fvec.x = -1
	if btn(3) then e.fvec.x = 1

	if e.fvec.y == 0 then e.fvec.y = 1
	entity_gravity(e, e.gravity_add, btnp(4), e.jump_gravity)
	e.fvec.y = math.floor(e.gravity)

	entity_move(e)
	
	cam_follow_pos = vecsub(e.pos, vecdiv(WINDOW_WH, 2))
	cam_follow_pos = vecadd(cam_follow_pos, vecdiv(e.sz, 2))
	cam_follow_spd = vecdist(cam.pos, cam_follow_pos) * 0.1
	cam_follow_dir = vecnormalized(vecsub(cam_follow_pos, cam.pos))
	cam.pos = vecadd(cam.pos, vecmul(cam_follow_dir, cam_follow_spd))

player_chkremove = (i, e) ->
	if e.hp == 0 then table.remove(list_entity, i)

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

_player_looking_right = false
_t_player_stop_move = 0

player_draw = (e) ->
	draw_pos = vecsub(e.pos, vecfloor(cam.pos))

	if btn(2) then _player_looking_right = false
	if btn(3) then _player_looking_right = true

	if not entity_collision_down(e, false) then
		if not _player_looking_right then
			spr(_PLAYER_SPR.air[1], draw_pos.x-5, draw_pos.y, 0, 1, 0, 0, 2, 2)
		else
			spr(_PLAYER_SPR.air[1], draw_pos.x-5, draw_pos.y, 0, 1, 1, 0, 2, 2)
		return

	if btn(2) then
		spr(_PLAYER_SPR.run[(t//6)%4+1], draw_pos.x-5, draw_pos.y, 0, 1, 0, 0, 2, 2)
		_t_player_stop_move = t
		return

	if btn(3) then
		spr(_PLAYER_SPR.run[(t//6)%4+1], draw_pos.x-5, draw_pos.y, 0, 1, 1, 0, 2, 2)
		_t_player_stop_move = t
		return

	if not _player_looking_right then
		spr(_PLAYER_SPR.idle[(t-_t_player_stop_move)//40%2 + 1], draw_pos.x, draw_pos.y, 0, 1, 0, 0, 1, 2)
		return
	
	spr(_PLAYER_SPR.idle[(t-_t_player_stop_move)//40%2 + 1], draw_pos.x, draw_pos.y, 0, 1, 1, 0, 1, 2)

export BOOT = ->
	player = entity_create(vec(50, 50), vec(8, 16))
	player.draw = player_draw
	player.update = player_update
	player.chkremove = player_chkremove
	player.gravity_add = NORMAL_GRAVITY_ADD
	player.jump_gravity = NORMAL_JUMP_GRAVITY
	entity_list_add(player)

export TIC = ->
	cls(0)

	cam_pos = vecfloor(cam.pos)
	map(cam_pos.x//8-1, cam_pos.y//8-1, 32, 19, 8 - cam_pos.x%8 - 16, 8 - cam_pos.y%8 - 16)

	entity_list_update()
	entity_list_chkremove()
	entity_list_draw()

	t += 1

-- <TILES>
-- 000:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 001:eeeeeeeee000000ee000000ee000000ee000000ee000000ee000000eeeeeeeee
-- </TILES>

-- <SPRITES>
-- 000:00bbbb000bbbbbb00b2bbbb00b222bb00b2222b00bd22db000811f0008f11ff0
-- 001:000000bb00000bbb00000b2b00000b2200000b2200000bd200000081000008f1
-- 002:bb000000bbb00000bbb000002bb0000022b000002db000001f0000001ff00000
-- 003:00000000000000bb00000bbb00000b2b00000b2200000b2200000bd200000081
-- 004:00000000bb000000bbb00000bbb000002bb0000022b000002db000001f000000
-- 005:000000bb00000bbb00000b2b00000b2200000b2200000bd200000081000008f1
-- 006:bb000000bbb00000bbb000002bb0000022b000002db000001f0000001ff00000
-- 007:00000000000000bb00000bbb00000b2b00000b2200000b2200000bd200000081
-- 008:00000000bb000000bbb00000bbb000002bb0000022b000002db000001f000000
-- 016:08f11ff008f11ff08ff88fff8ff88fff8ff88fff08f88ff00020020000800800
-- 017:00008ff10008fff1008ffff8000ffff800000ff800000ff80000002000000080
-- 018:1fff00001ffff0008fffff008ff8f0008ff000008ff000000200000008000000
-- 019:000008f100008ff10008fff1008ffff8000ffff800000ff80000000200000008
-- 020:1ff000001fff00001ffff0008fffff008ff8f0008ff000002000000008000000
-- 021:00008ff10008fff1008ffff8000ffff800000ff800000ff80000020000000800
-- 022:1fff00001ffff0008fffff008ff8f0008ff000008ff000000020000000800000
-- 023:000008f100008ff10008fff1008ffff8000ffff800000ff80000002000000080
-- 024:1ff000001fff00001ffff0008fffff008ff8f0008ff000000200000008000000
-- 032:0000000000bbbb000bbbbbb00b2bbbb00b222bb00b2222b00bd22db000811f00
-- 048:08f11ff008f11ff008f11ff08ff88fff8ff88fff08f88ff00020020000800800
-- </SPRITES>

-- <MAP>
-- 006:101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:101000000000000010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:100000001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
-- 000:1a1c2cedededfffbedf3dea4f5c16da7f07038b764ad8a53262c3fffea66d98effdefbfffffff694b0c2566c86333c57
-- </PALETTE>

