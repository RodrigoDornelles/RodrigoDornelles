local b245c = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local r245c = function(i, f)
return function()
local c = f()
b245c[i] = function() return c end
return c
end
end
local function m245c()
local mapgen = b245c[1]('game_src_data_mapgen')
local actor = b245c[2]('game_src_logic_actor')
local critter_ai = b245c[3]('game_src_logic_ai_critter')
local perk_manager = b245c[4]('game_src_perks_manager')
local view = b245c[5]('game_src_view_render')
local effects = b245c[6]('game_src_view_effects')
local C = b245c[7]('game_src_const')
local G = {
state = C.S_MENU,
level = 1,
grid = {},
w = 0, h = 0,
dots = 0,
dots_x = {},
dots_y = {},
dots_count = 0,
dots_active = {},
player = nil,
critter = nil,
upgrade_options = {},
upgrade_cursor = 1,
menu_cursor = 1,
pause_cursor = 1,
shake = 0,
capture_timer = 0,
ability_cooldown = 0,
shotgun_cooldown = 0,
player_idle_time = 0,
last_player_x = 0,
last_player_y = 0,
dot_fade_timer = 0,
fade_active = false,
time_elapsed = 0,
anim_time = 0,
death_reason = nil,
last_input_time = 0,
frame_count = 0,
saved_state = nil
}
local _triggers = { false, false, false }
local _ai_context = { brave = false, dread_tiles = nil, player_idle = 0 }
local function grid_get(x, y)
if x < 1 or x > G.w or y < 1 or y > G.h then return C.T_WALL end
return G.grid[(y - 1) * G.w + x]
end
local function grid_set(x, y, v)
if x >= 1 and x <= G.w and y >= 1 and y <= G.h then
G.grid[(y - 1) * G.w + x] = v
end
end
local function can_input(std)
if std.milis > G.last_input_time + C.input.cooldown then
G.last_input_time = std.milis
return true
end
return false
end
local function check_input(std, key)
return std.key.press[key] and can_input(std)
end
local function fade_random_dot(std)
if not G.critter or G.dots_count < 1 then return end
local c = G.critter
local best_idx = nil
local best_dist = 0
for i = 1, G.dots_count do
if G.dots_active[i] then
local dx = G.dots_x[i] - c.x
local dy = G.dots_y[i] - c.y
local dist = dx * dx + dy * dy
if dist > 9 and dist > best_dist then
best_dist = dist
best_idx = i
end
end
end
if best_idx then
local x, y = G.dots_x[best_idx], G.dots_y[best_idx]
if grid_get(x, y) == C.T_DOT then
grid_set(x, y, C.T_FADING)
effects.dot_fade(std, x, y)
G.dots_active[best_idx] = false
end
end
end
local function remove_fading_dots()
for y = 1, G.h do
for x = 1, G.w do
if grid_get(x, y) == C.T_FADING then
grid_set(x, y, C.T_EMPTY)
G.dots = G.dots - 1
end
end
end
end
local function new_level(std)
local size = 19 + math.min(G.level, 5) * 2
local map = mapgen.generate(size, size, std)
G.grid = map.grid
G.dots = map.dots
G.w, G.h = map.w, map.h
G.dots_x = map.dots_x
G.dots_y = map.dots_y
G.dots_count = map.dots_count
for i = 1, G.dots_count do
G.dots_active[i] = true
end
local old = G.player or {}
local stats = {
speed_mod = old.speed_mod or 0,
wall_hack = old.wall_hack or false,
has_fear_aura = old.has_fear_aura or false,
fear_radius = old.fear_radius or 3,
zoom_out = old.zoom_out or false,
has_shotgun = old.has_shotgun or false,
has_dash = old.has_dash or false,
has_mark = old.has_mark or false,
has_chains = old.has_chains or false,
has_dread = old.has_dread or false,
actives = old.actives or {}
}
G.player = actor.create(map.spawn_player.x, map.spawn_player.y, true)
local p = G.player
for k, v in pairs(stats) do p[k] = v end
if p.has_dread then p.dread_tiles = {} end
G.critter = actor.create(map.spawn_critter.x, map.spawn_critter.y, false)
G.critter.base_speed = C.balance.base_critter_speed - (G.level * C.balance.speed_per_level)
G.player_idle_time = 0
G.last_player_x = p.x
G.last_player_y = p.y
G.dot_fade_timer = 0
G.fade_active = false
G.time_elapsed = 0
G.ability_cooldown = 0
G.state = C.S_PLAY
G.shake = 0
G.death_reason = nil
G.frame_count = 0
G.last_input_time = std.milis
std.app.title("ghostman - level " .. G.level)
end
local function capture_sequence(std)
if not G.critter then return end
G.state = C.S_CAPTURE
G.capture_timer = 1200
G.shake = 25
effects.explode(std, G.critter.real_x, G.critter.real_y)
local num = G.time_elapsed < 10000 and 3 or 2
G.upgrade_options = perk_manager.get_options(std, num, G.player)
G.upgrade_cursor = 1
end
local function death_sequence(std, reason)
G.state = C.S_GAMEOVER
G.death_reason = reason
G.shake = 30
if G.player then
effects.explode(std, G.player.real_x, G.player.real_y)
end
end
local function init(self, std)
if not std.math.dis then
std.math.dis = function(x1, y1, x2, y2)
local dx, dy = x2 - x1, y2 - y1
return math.sqrt(dx * dx + dy * dy)
end
end
local sys_random = math.random
std.math.random = function(a, b)
if not a then return sys_random() end
if not b then return sys_random(math.floor(a)) end
return sys_random(math.floor(a), math.floor(b))
end
G.level = 1
G.player = nil
G.anim_time = 0
effects.reset()
G.state = C.S_MENU
G.menu_cursor = 1
G.pause_cursor = 1
G.last_input_time = 0
end
local function loop(self, std)
local dt = std.delta
G.anim_time = G.anim_time + dt
G.frame_count = G.frame_count + 1
local s = G.state
if s == C.S_PLAY or s == C.S_UPGRADE or s == C.S_CAPTURE then
if check_input(std, "p") or check_input(std, "menu") then
G.saved_state = s
G.state = C.S_PAUSE
G.pause_cursor = 1
return
end
end
if G.state ~= C.S_PAUSE then
if G.shake > 0 then
local decay = (1 - C.smooth.shake_decay) ^ (dt / 16.666)
G.shake = G.shake * decay
if G.shake < 0.1 then G.shake = 0 end
end
if G.shotgun_cooldown > 0 then G.shotgun_cooldown = G.shotgun_cooldown - dt end
if G.ability_cooldown > 0 then G.ability_cooldown = G.ability_cooldown - dt end
effects.update(std, G)
end
s = G.state
if s == C.S_PAUSE then
if check_input(std, "up") then G.pause_cursor = G.pause_cursor == 1 and 3 or G.pause_cursor - 1 end
if check_input(std, "down") then G.pause_cursor = G.pause_cursor == 3 and 1 or G.pause_cursor + 1 end
if check_input(std, "a") then
if G.pause_cursor == 1 then
G.state = G.saved_state or C.S_PLAY
G.last_input_time = std.milis
elseif G.pause_cursor == 2 then
G.state = C.S_MENU
G.menu_cursor = 1
G.player = nil
G.critter = nil
effects.reset()
elseif G.pause_cursor == 3 then
std.app.exit()
end
end
if check_input(std, "p") or check_input(std, "menu") then
G.state = G.saved_state or C.S_PLAY
G.last_input_time = std.milis
end
elseif s == C.S_MENU then
if check_input(std, "up") then G.menu_cursor = G.menu_cursor == 1 and 4 or G.menu_cursor - 1 end
if check_input(std, "down") then G.menu_cursor = G.menu_cursor == 4 and 1 or G.menu_cursor + 1 end
if check_input(std, "menu") then
std.app.exit()
end
if check_input(std, "a") then
if G.menu_cursor == 1 then
G.level = 1
new_level(std)
elseif G.menu_cursor == 2 then
G.state = C.S_EVOLUTION
elseif G.menu_cursor == 3 then
G.state = C.S_CREDITS
elseif G.menu_cursor == 4 then
std.app.exit()
end
end
elseif s == C.S_GAMEOVER then
if check_input(std, "a") then
G.level = 1
effects.reset()
new_level(std)
end
if check_input(std, "menu") then
G.state = C.S_MENU
G.menu_cursor = 1
G.player = nil
G.critter = nil
effects.reset()
end
elseif s == C.S_PLAY then
G.time_elapsed = G.time_elapsed + dt
local p, c = G.player, G.critter
if not p or not c then return end
if p.x == G.last_player_x and p.y == G.last_player_y then
G.player_idle_time = G.player_idle_time + dt
else
G.player_idle_time = 0
G.last_player_x = p.x
G.last_player_y = p.y
end
c.brave = G.player_idle_time > C.balance.idle_threshold
if G.time_elapsed > C.balance.dot_fade_start then G.fade_active = true end
if G.fade_active then
G.dot_fade_timer = G.dot_fade_timer + dt
if G.dot_fade_timer > C.balance.dot_fade_interval then
G.dot_fade_timer = 0
remove_fading_dots()
if G.dots > 3 then fade_random_dot(std) end
end
end
if p.actives then
_triggers[1] = std.key.press.a or false
_triggers[2] = std.key.press.b or false
_triggers[3] = std.key.press.c or false
for i = 1, #p.actives do
local perk = p.actives[i]
if perk.update then
if perk.update(p, std, G, _triggers[i]) == "capture" then
capture_sequence(std)
return
end
end
end
end
if not (p.aiming or p.dashing) then
if std.key.press.left then p.next_dir = C.D_LEFT end
if std.key.press.right then p.next_dir = C.D_RIGHT end
if std.key.press.up then p.next_dir = C.D_UP end
if std.key.press.down then p.next_dir = C.D_DOWN end
end
actor.update(p, G, std)
if c.chained then
c.chain_timer = (c.chain_timer or 0) - dt
if c.chain_timer <= 0 then
c.chained = false
c.speed_mod = 0
end
end
if G.frame_count % C.balance.ai_think_interval == 0 then
_ai_context.brave = c.brave
_ai_context.dread_tiles = p.has_dread and p.dread_tiles or nil
_ai_context.player_idle = G.player_idle_time
critter_ai.think(c, p, G, std, _ai_context)
end
local dist = std.math.dis(p.x, p.y, c.x, c.y)
c.scared = dist < 5 and not c.brave
local fear_radius = p.fear_radius or 3
local frozen = p.has_fear_aura and dist < fear_radius and not c.brave
if not frozen then
local brave_bonus = c.brave and C.balance.courage_speed_bonus or 0
local orig_mod = c.speed_mod
c.speed_mod = c.speed_mod - brave_bonus
local moved = actor.update(c, G, std)
c.speed_mod = orig_mod
if moved then
local tile = grid_get(c.x, c.y)
if tile == C.T_DOT or tile == C.T_FADING then
grid_set(c.x, c.y, C.T_EMPTY)
G.dots = G.dots - 1
for i = 1, G.dots_count do
if G.dots_x[i] == c.x and G.dots_y[i] == c.y then
G.dots_active[i] = false
break
end
end
end
end
end
local pdist = std.math.dis(p.real_x, p.real_y, c.real_x, c.real_y)
if pdist < 0.75 then
if c.brave then
death_sequence(std, "eaten")
else
capture_sequence(std)
end
return
end
if G.dots <= 0 then
G.state = C.S_GAMEOVER
G.death_reason = "starved"
end
elseif s == C.S_CAPTURE then
G.capture_timer = G.capture_timer - dt
if G.capture_timer <= 0 then
if #G.upgrade_options == 0 then
G.level = G.level + 1
new_level(std)
else
G.state = C.S_UPGRADE
end
end
elseif s == C.S_UPGRADE then
local num = #G.upgrade_options
if num == 0 then
G.level = G.level + 1
new_level(std)
return
end
if check_input(std, "left") then
G.upgrade_cursor = G.upgrade_cursor == 1 and num or G.upgrade_cursor - 1
end
if check_input(std, "right") then
G.upgrade_cursor = G.upgrade_cursor == num and 1 or G.upgrade_cursor + 1
end
if check_input(std, "a") then
perk_manager.apply(G.upgrade_options[G.upgrade_cursor], G.player)
G.level = G.level + 1
new_level(std)
end
if check_input(std, "b") then
G.state = C.S_MENU
end
elseif s == C.S_CREDITS or s == C.S_EVOLUTION then
if check_input(std, "a") or check_input(std, "menu") then
G.state = C.S_MENU
end
end
end
local function draw(self, std)
std.draw.clear(C.pal.bg)
view.draw(std, G)
end
local function on_error(self, std, msg)
print("crash: " .. tostring(msg))
print(debug.traceback())
return false
end
return {
meta = { title = "ghostman", version = "2.6.2", author = "guily" },
config = { require = "math math.random" },
callbacks = { init = init, loop = loop, draw = draw, error = on_error }
}
end
b245c[1] = r245c(1, function()
local C = b245c[7]('game_src_const')
local function xy_to_idx(x, y, w)
return (y - 1) * w + x
end
local function generate(w, h, std)
local grid = {}
local size = w * h
for i = 1, size do
grid[i] = C.T_WALL
end
local function get(x, y)
if x < 1 or x > w or y < 1 or y > h then return C.T_WALL end
return grid[(y - 1) * w + x]
end
local function set(x, y, v)
if x >= 1 and x <= w and y >= 1 and y <= h then
grid[(y - 1) * w + x] = v
end
end
local stack = {}
local stack_top = 0
local start_x, start_y = 3, 3
set(start_x, start_y, C.T_EMPTY)
stack_top = stack_top + 1
stack[stack_top] = start_x + start_y * 1000
local dirs = { { 0, -2 }, { 0, 2 }, { -2, 0 }, { 2, 0 } }
local neighbors = {}
while stack_top > 0 do
local packed = stack[stack_top]
local cx = packed % 1000
local cy = math.floor(packed / 1000)
local n_count = 0
for i = 1, 4 do
local dx, dy = dirs[i][1], dirs[i][2]
local nx, ny = cx + dx, cy + dy
if nx > 1 and nx < w and ny > 1 and ny < h and get(nx, ny) == C.T_WALL then
n_count = n_count + 1
neighbors[n_count] = i
end
end
if n_count > 0 then
local pick = neighbors[std.math.random(1, n_count)]
local dx, dy = dirs[pick][1], dirs[pick][2]
local nx, ny = cx + dx, cy + dy
set(cx + dx / 2, cy + dy / 2, C.T_EMPTY)
set(nx, ny, C.T_EMPTY)
stack_top = stack_top + 1
stack[stack_top] = nx + ny * 1000
else
stack_top = stack_top - 1
end
end
local loops = math.floor(size / 10)
for _ = 1, loops do
local rx = std.math.random(2, w - 1)
local ry = std.math.random(2, h - 1)
if get(rx, ry) == C.T_WALL then
local open = 0
if get(rx, ry - 1) == C.T_EMPTY then open = open + 1 end
if get(rx, ry + 1) == C.T_EMPTY then open = open + 1 end
if get(rx - 1, ry) == C.T_EMPTY then open = open + 1 end
if get(rx + 1, ry) == C.T_EMPTY then open = open + 1 end
if open == 2 then set(rx, ry, C.T_EMPTY) end
end
end
local dots = 0
local dots_x = {}
local dots_y = {}
local dots_count = 0
for y = 1, h do
for x = 1, w do
if get(x, y) == C.T_EMPTY then
if std.math.random(1, 100) > 20 then
set(x, y, C.T_DOT)
dots = dots + 1
dots_count = dots_count + 1
dots_x[dots_count] = x
dots_y[dots_count] = y
end
end
end
end
local function find_empty()
for _ = 1, 1000 do
local rx = std.math.random(2, w - 1)
local ry = std.math.random(2, h - 1)
if get(rx, ry) == C.T_EMPTY then
return rx, ry
end
end
return 2, 2
end
local sp_x, sp_y = find_empty()
local sc_x, sc_y = find_empty()
set(sp_x, sp_y, C.T_EMPTY)
set(sc_x, sc_y, C.T_EMPTY)
return {
grid = grid,
dots = dots,
dots_x = dots_x,
dots_y = dots_y,
dots_count = dots_count,
w = w,
h = h,
spawn_player = { x = sp_x, y = sp_y },
spawn_critter = { x = sc_x, y = sc_y }
}
end
return { generate = generate }
end)
b245c[2] = r245c(2, function()
local C = b245c[7]('game_src_const')
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local math_sin = math.sin
local math_sqrt = math.sqrt
local function smooth_lerp(current, target, speed, dt)
local norm = dt / 16.666
local factor = 1 - (1 - speed) ^ norm
if factor > 1 then factor = 1 end
if factor < 0 then factor = 0 end
return current + (target - current) * factor
end
local function create(x, y, is_player)
return {
x = x,
y = y,
real_x = x,
real_y = y,
vel_x = 0,
vel_y = 0,
next_dir = 1,
curr_dir = 1,
prev_dir = 1,
move_timer = 0,
base_speed = is_player and 140 or 170,
speed_mod = 0,
frame = 0,
anim_time = 0,
wall_hack = false,
is_moving = false,
just_moved = false,
dashing = false,
aiming = false,
aim_angle = 0,
bob_offset = 0,
bob_phase = 0,
squash = 0,
target_squash = 0,
_cached_speed = 0,
_last_update = 0
}
end
local function grid_get(G, x, y)
if x < 1 or x > G.w or y < 1 or y > G.h then return C.T_WALL end
return G.grid[(y - 1) * G.w + x]
end
local function is_valid(G, x, y, wall_hack)
local tile = grid_get(G, x, y)
if wall_hack then return tile ~= nil end
return tile ~= C.T_WALL
end
local function update(a, G, std)
local dt = std.delta
local milis = std.milis
local smooth = C.smooth
if a._last_update ~= milis then
a._cached_speed = math_max(20, a.base_speed + a.speed_mod)
a._last_update = milis
end
local lerp_speed = smooth.actor_lerp
local dx = a.x - a.real_x
local dy = a.y - a.real_y
local dist = dx * dx + dy * dy
if dist > 9 or a.dashing then
lerp_speed = smooth.actor_lerp_fast
end
local old_rx, old_ry = a.real_x, a.real_y
a.real_x = smooth_lerp(a.real_x, a.x, lerp_speed, dt)
a.real_y = smooth_lerp(a.real_y, a.y, lerp_speed, dt)
local dt_s = dt / 1000 + 0.001
a.vel_x = (a.real_x - old_rx) / dt_s
a.vel_y = (a.real_y - old_ry) / dt_s
a.bob_phase = a.bob_phase + dt * smooth.bob_speed
if a.bob_phase > 6.28318 then
a.bob_phase = a.bob_phase - 6.28318
end
a.bob_offset = math_sin(a.bob_phase) * smooth.bob_amplitude
a.squash = smooth_lerp(a.squash, a.target_squash, 0.15, dt)
if math_abs(a.squash) < 0.01 then a.squash = 0 end
a.target_squash = smooth_lerp(a.target_squash, 0, 0.1, dt)
a.anim_time = a.anim_time + dt
a.just_moved = false
if milis > a.move_timer then
local moved = false
local vn = C.vectors[a.next_dir]
local vc = C.vectors[a.curr_dir]
if a.next_dir ~= 1 and is_valid(G, a.x + vn.x, a.y + vn.y, a.wall_hack) then
a.prev_dir = a.curr_dir
a.curr_dir = a.next_dir
vc = vn
end
local tx, ty = a.x + vc.x, a.y + vc.y
if is_valid(G, tx, ty, a.wall_hack) then
a.x = tx
a.y = ty
moved = true
a.just_moved = true
a.frame = (a.frame + 1) % 10000
a.target_squash = 0.3
end
a.is_moving = moved
a.move_timer = milis + a._cached_speed
return moved
end
return false
end
return {
create = create,
update = update,
smooth_lerp = smooth_lerp
}
end)
b245c[3] = r245c(3, function()
local C = b245c[7]('game_src_const')
local _queue = {}
local _visited = {}
local _neighbors = {}
local function grid_get(G, x, y)
if x < 1 or x > G.w or y < 1 or y > G.h then return C.T_WALL end
return G.grid[(y - 1) * G.w + x]
end
local function bfs_path(sx, sy, tx, ty, G)
for k in pairs(_visited) do _visited[k] = nil end
local w, h = G.w, G.h
local dirs = { C.D_UP, C.D_DOWN, C.D_LEFT, C.D_RIGHT }
local head, tail = 1, 0
for i = 1, 4 do
local v = C.vectors[dirs[i]]
local nx, ny = sx + v.x, sy + v.y
local key = ny * 1000 + nx
if nx >= 1 and nx <= w and ny >= 1 and ny <= h then
if grid_get(G, nx, ny) ~= C.T_WALL and not _visited[key] then
_visited[key] = true
tail = tail + 1
_queue[tail] = { x = nx, y = ny, d = dirs[i], s = 1 }
end
end
end
while head <= tail do
local cur = _queue[head]
head = head + 1
if cur.x == tx and cur.y == ty then
return cur.d
end
if cur.s > 80 then goto continue end
for i = 1, 4 do
local v = C.vectors[dirs[i]]
local nx, ny = cur.x + v.x, cur.y + v.y
local key = ny * 1000 + nx
if nx >= 1 and nx <= w and ny >= 1 and ny <= h then
if grid_get(G, nx, ny) ~= C.T_WALL and not _visited[key] then
_visited[key] = true
tail = tail + 1
_queue[tail] = { x = nx, y = ny, d = cur.d, s = cur.s + 1 }
end
end
end
::continue::
end
return nil
end
local function think(me, ghost, G, std, ctx)
ctx = ctx or {}
local brave = ctx.brave or false
local dread = ctx.dread_tiles
if brave then
local d = bfs_path(me.x, me.y, ghost.x, ghost.y, G)
if d then
me.next_dir = d
return
end
end
local best_score = -999999
local best_dir = me.curr_dir
local dirs = { C.D_UP, C.D_DOWN, C.D_LEFT, C.D_RIGHT }
for i = 1, 4 do
local d = dirs[i]
local v = C.vectors[d]
local tx, ty = me.x + v.x, me.y + v.y
local tile = grid_get(G, tx, ty)
if tile ~= C.T_WALL then
local score = 0
local gdx, gdy = tx - ghost.x, ty - ghost.y
local gdist = math.abs(gdx) + math.abs(gdy)
if gdist < 8 then
score = score - (10 - gdist) * 20
else
score = score + 10
end
if dread then
local key = tx .. "," .. ty
if dread[key] then
score = score - 200
end
end
if tile == C.T_DOT then
local danger = 0
if gdist < 3 then danger = 100
elseif gdist < 5 then danger = 50 end
score = score + (100 - danger)
elseif tile == C.T_FADING then
score = score + 150
end
if d == me.curr_dir then
score = score + 12
end
local opp = { [C.D_UP] = C.D_DOWN, [C.D_DOWN] = C.D_UP, [C.D_LEFT] = C.D_RIGHT, [C.D_RIGHT] = C.D_LEFT }
if d == opp[me.curr_dir] then
score = score - 25
end
local t2 = grid_get(G, tx + v.x, ty + v.y)
if t2 == C.T_DOT then
score = score + 20
end
score = score + std.math.random(0, 15)
if score > best_score then
best_score = score
best_dir = d
end
end
end
me.next_dir = best_dir
end
return { think = think }
end)
b245c[4] = r245c(4, function()
local collection = {
b245c[8]('src/perks/collection/speed'), 
b245c[9]('src/perks/collection/ethereal'), 
b245c[10]('src/perks/collection/fear'), 
b245c[11]('src/perks/collection/vision'), 
b245c[12]('src/perks/collection/boomstick'), 
b245c[13]('src/perks/collection/dash'), 
b245c[14]('src/perks/collection/mark'), 
b245c[15]('src/perks/collection/chains'), 
b245c[16]('src/perks/collection/dread') 
}
local _pool = {}
local _options = {}
local function get_options(std, count, player)
for i = 1, #_pool do _pool[i] = nil end
for i = 1, #_options do _options[i] = nil end
local pool_count = 0
for _, p in ipairs(collection) do
local skip = false
if player then
if p.type == "active" and player.actives then
for _, a in ipairs(player.actives) do
if a.id == p.id then skip = true; break end
end
end
if p.id == "speed" and player.speed_mod <= -60 then skip = true end
if p.id == "wall" and player.wall_hack then skip = true end
if p.id == "fear" and player.has_fear_aura then skip = true end
if p.id == "vision" and player.zoom_out then skip = true end
if p.id == "mark" and player.has_mark then skip = true end
if p.id == "dread" and player.has_dread then skip = true end
if p.id == "speed" and player.speed_mod < 0 and player.speed_mod > -60 then
skip = false
end
end
if not skip then
pool_count = pool_count + 1
_pool[pool_count] = p
end
end
for i = 1, count do
if pool_count == 0 then break end
local idx = std.math.random(1, pool_count)
local perk = _pool[idx]
if perk then
_options[#_options + 1] = perk
_pool[idx] = _pool[pool_count]
_pool[pool_count] = nil
pool_count = pool_count - 1
end
end
return _options
end
local function apply(perk, player)
if perk.apply then
perk.apply(player)
end
if perk.type == "active" then
player.actives = player.actives or {}
if #player.actives < 3 then
player.actives[#player.actives + 1] = perk
else
player.actives[1] = player.actives[2]
player.actives[2] = player.actives[3]
player.actives[3] = perk
end
end
end
return {
get_options = get_options,
apply = apply,
collection = collection
}
end)
b245c[5] = r245c(5, function()
local C = b245c[7]('game_src_const')
local skins = b245c[17]('game_src_view_skins_init')
local effects = b245c[6]('game_src_view_effects')
local ui = b245c[18]('game_src_view_ui_init')
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_sin = math.sin
local cam = { x = 0, y = 0, zoom = 1 }
local function grid_get(G, x, y)
if x < 1 or x > G.w or y < 1 or y > G.h then return C.T_WALL end
return G.grid[(y - 1) * G.w + x]
end
local function draw_game(std, G)
if G.state == C.S_MENU or G.state == C.S_CREDITS or G.state == C.S_EVOLUTION then
ui.draw(std, G)
return
end
local p = G.player
if not p then
ui.draw(std, G)
return
end
local dt = std.delta
local sw, sh = std.app.width, std.app.height
if G.state ~= C.S_PAUSE then
local target_zoom = p.zoom_out and 0.55 or 1.15
local zoom_speed = p.zoom_out and 0.04 or 0.08
cam.zoom = cam.zoom + (target_zoom - cam.zoom) * zoom_speed
end
local cs = math_max(8, math_floor(math_min(sw, sh) / 20 * cam.zoom))
if G.state ~= C.S_PAUSE then
cam.x = cam.x + (p.real_x - cam.x) * C.smooth.camera_lerp
cam.y = cam.y + (p.real_y - cam.y) * C.smooth.camera_lerp
end
local ox = math_floor(sw / 2 - cam.x * cs)
local oy = math_floor(sh / 2 - cam.y * cs)
if G.shake > 0 then
ox = ox + math_sin(std.milis * 0.05) * G.shake * 0.5
oy = oy + math.cos(std.milis * 0.065) * G.shake * 0.5
end
local vl = math_floor(-ox / cs)
local vt = math_floor(-oy / cs)
local vr = vl + math_floor(sw / cs) + 2
local vb = vt + math_floor(sh / cs) + 2
vl = math_max(1, vl)
vt = math_max(1, vt)
vr = math_min(G.w, vr)
vb = math_min(G.h, vb)
local light_max = p.zoom_out and 1200 or 144
for y = vt, vb do
for x = vl, vr do
local tile = grid_get(G, x, y)
local dx = x - p.real_x
local dy = y - p.real_y
local d2 = dx * dx + dy * dy
local light = d2 > light_max and 0.2 or math_max(0.2, 1.0 - d2 / light_max)
local px = ox + (x - 1) * cs
local py = oy + (y - 1) * cs
if tile == C.T_WALL then
skins.draw(std, "wall", x, y, px, py, cs, light, std.milis, nil)
elseif tile == C.T_EMPTY then
local dread = p.has_dread and p.dread_tiles and p.dread_tiles[x .. "," .. y]
skins.draw(std, "floor", x, y, px, py, cs, light, std.milis, dread)
elseif tile == C.T_DOT then
skins.draw(std, "dot", x, y, px, py, cs, light, std.milis, nil)
elseif tile == C.T_FADING then
skins.draw(std, "dot_fading", x, y, px, py, cs, light, std.milis, nil)
end
end
end
effects.draw(std, cs, ox, oy, G)
local c = G.critter
if c and G.state ~= C.S_CAPTURE then
local cx = ox + (c.real_x - 1) * cs
local cy = oy + (c.real_y - 1) * cs
skins.draw_critter(std, cx, cy, cs, c, std.milis)
end
local px = ox + (p.real_x - 1) * cs
local py = oy + (p.real_y - 1) * cs
skins.draw_player(std, px, py, cs, p, std.milis)
ui.draw(std, G, false)
end
return { draw = draw_game }
end)
b245c[6] = r245c(6, function()
local C = b245c[7]('game_src_const')
local math_floor = math.floor
local math_sin = math.sin
local math_cos = math.cos
local MAX_PARTICLES = 128
local MAX_MARKERS = 32
local particles = {}
local particles_count = 0
local fade_markers = {}
local markers_count = 0
for i = 1, MAX_PARTICLES do
particles[i] = {
x = 0, y = 0, vx = 0, vy = 0,
life = 0, max_life = 0, size = 0,
type = 0, color = 0, alpha = 0,
gravity = 0, friction = 0, active = false
}
end
for i = 1, MAX_MARKERS do
fade_markers[i] = { x = 0, y = 0, life = 0, max_life = 0, phase = 0, active = false }
end
local function reset()
for i = 1, MAX_PARTICLES do
particles[i].active = false
end
particles_count = 0
for i = 1, MAX_MARKERS do
fade_markers[i].active = false
end
markers_count = 0
end
local function get_free_particle()
for i = 1, MAX_PARTICLES do
if not particles[i].active then
return particles[i]
end
end
return particles[1]
end
local function explode(std, x, y)
for i = 1, 15 do
local p = get_free_particle()
local angle = std.math.random(0, 628) / 100
local speed = std.math.random(60, 200) / 100
p.x = x
p.y = y
p.vx = math_cos(angle) * speed
p.vy = math_sin(angle) * speed - 0.5
p.life = std.math.random(40, 90)
p.max_life = 90
p.size = std.math.random(25, 55) / 100
p.type = 1
p.alpha = 1
p.gravity = 0.012
p.friction = 0.985
p.active = true
particles_count = particles_count + 1
end
end
local function pellet(std, x, y, dx, dy)
local p = get_free_particle()
p.x = x
p.y = y
p.vx = dx * 0.9
p.vy = dy * 0.9
p.life = 15
p.max_life = 15
p.size = 0.3
p.type = 2
p.alpha = 1
p.gravity = 0
p.friction = 0.98
p.active = true
particles_count = particles_count + 1
end
local function magic_spark(std, x, y, color)
for i = 1, 10 do
local p = get_free_particle()
local angle = std.math.random(0, 628) / 100
local speed = std.math.random(30, 80) / 100
p.x = x
p.y = y
p.vx = math_cos(angle) * speed
p.vy = math_sin(angle) * speed
p.life = std.math.random(15, 30)
p.max_life = 30
p.size = std.math.random(15, 35) / 100
p.type = 3
p.color = color
p.alpha = 1
p.gravity = -0.005
p.friction = 0.92
p.active = true
particles_count = particles_count + 1
end
end
local function dot_fade(std, x, y)
for i = 1, MAX_MARKERS do
if not fade_markers[i].active then
local m = fade_markers[i]
m.x = x
m.y = y
m.life = 60
m.max_life = 60
m.phase = std.math.random(0, 628) / 100
m.active = true
markers_count = markers_count + 1
return
end
end
end
local function update(std, G)
local dt = std.delta / 16.666
for i = 1, MAX_PARTICLES do
local p = particles[i]
if p.active then
p.vy = p.vy + p.gravity * dt
p.vx = p.vx * p.friction
p.vy = p.vy * p.friction
p.x = p.x + p.vx * dt
p.y = p.y + p.vy * dt
p.life = p.life - dt
p.alpha = p.life / p.max_life
if p.life <= 0 then
p.active = false
particles_count = particles_count - 1
end
end
end
for i = 1, MAX_MARKERS do
local m = fade_markers[i]
if m.active then
m.life = m.life - dt
if m.life <= 0 then
m.active = false
markers_count = markers_count - 1
end
end
end
end
local function draw(std, cs, ox, oy, G)
for i = 1, MAX_MARKERS do
local m = fade_markers[i]
if m.active then
local s = cs * 0.6 * (math_sin(m.phase) * 0.3 + 0.7) * (m.life / m.max_life)
std.draw.color(C.pal.dot_fading)
std.draw.rect(0, ox + (m.x - 1) * cs + cs * 0.2, oy + (m.y - 1) * cs + cs * 0.2, s, s)
end
end
for i = 1, MAX_PARTICLES do
local p = particles[i]
if p.active and p.alpha > 0.05 then
local color
if p.type == 1 then
color = C.pal.blood
elseif p.type == 2 then
color = 0xffffccFF
else
color = p.color
end
local s = p.size * cs
std.draw.color(color)
std.draw.rect(0, ox + (p.x - 1) * cs + cs / 2 - s / 2, oy + (p.y - 1) * cs + cs / 2 - s / 2, s, s)
end
end
end
return {
reset = reset,
explode = explode,
pellet = pellet,
magic_spark = magic_spark,
dot_fade = dot_fade,
update = update,
draw = draw
}
end)
b245c[7] = r245c(7, function()
local P = {
input = { cooldown = 100 },
smooth = {
actor_lerp = 0.18,
actor_lerp_fast = 0.28,
camera_lerp = 0.08,
bob_speed = 0.008,
bob_amplitude = 2.5,
shake_decay = 0.06
},
balance = {
dot_fade_start = 15000,
dot_fade_interval = 2000,
idle_threshold = 2000,
base_critter_speed = 155,
speed_per_level = 6,
courage_speed_bonus = 25,
ai_think_interval = 4
},
S_MENU = 0,
S_PLAY = 1,
S_GAMEOVER = 2,
S_UPGRADE = 3,
S_CAPTURE = 4,
S_EVOLUTION = 5,
S_CREDITS = 6,
S_PAUSE = 7,
T_EMPTY = 0,
T_WALL = 1,
T_DOT = 2,
T_FADING = 3,
D_NONE = 1,
D_UP = 2,
D_DOWN = 3,
D_LEFT = 4,
D_RIGHT = 5,
vectors = {
{ x = 0, y = 0 },
{ x = 0, y = -1 },
{ x = 0, y = 1 },
{ x = -1, y = 0 },
{ x = 1, y = 0 }
},
pal = {
bg = 0x0a0a1aFF,
bg_alt = 0x0f0f24FF,
wall_top = 0x4a4a6aFF,
wall_side = 0x2a2a40FF,
blood = 0xFFD700FF,
blood_stain = 0x886600FF,
blood_splat = 0xFFD700AA,
ghost = 0x88eeffFF,
ghost_glow = 0x88eeff44,
ghost_eye = 0x1a1a2eFF,
ghost_pupil = 0x000000FF,
ghost_angry = 0xff6688FF,
critter = 0xff6666FF,
critter_dark = 0xcc3333FF,
critter_belly = 0xffaaaaFF,
critter_eye = 0xffffffFF,
critter_pupil = 0x000000FF,
critter_brave = 0xffaa44FF,
dot = 0xffd700FF,
dot_glow = 0xffd70066,
dot_fading = 0xff880088,
ui_bg = 0x1a1a2aEE,
ui_panel = 0x252540FF,
ui_border = 0xaa88ffFF,
ui_select = 0xff66aaFF,
ui_dim = 0x000000AA,
ui_shadow = 0x00000066,
ui_warning = 0xff4444FF,
ui_success = 0x44ff88FF,
text = 0xf0f0f0FF,
text_dim = 0x7080a0FF,
text_highlight = 0xffffaaFF,
perk_chains = 0x8888ffFF
}
}
return P
end)
b245c[8] = r245c(8, function()
return {
id = "speed",
name = "SPECTRAL HASTE",
desc = "movement +25%. stacks twice!",
icon = ">>>",
type = "passive",
color = 0x44ddffFF,
apply = function(p)
p.speed_mod = (p.speed_mod or 0) - 30
end
}
end)
b245c[9] = r245c(9, function()
return {
id = "wall",
name = "ETHEREAL FORM",
desc = "phase through walls freely. ultimate mobility.",
icon = "[#]",
type = "passive",
color = 0xaa66ffFF,
apply = function(p)
p.wall_hack = true
end
}
end)
b245c[10] = r245c(10, function()
return {
id = "fear",
name = "TERROR VISAGE",
desc = "freezes prey nearby. useless if they're brave!",
icon = "(@)",
type = "passive",
color = 0xff4488FF,
apply = function(p)
p.has_fear_aura = true
p.fear_radius = (p.fear_radius or 0) + 3
end
}
end)
b245c[11] = r245c(11, function()
local const = b245c[19]('src/const')
return {
id = "vision",
name = "ALL-SEEYING EYE",
desc = "camera zoom-out. see the whole maze!",
icon = "[o]",
type = "passive",
color = 0x88ff88FF,
apply = function(p)
p.zoom_out = true
end
}
end)
b245c[12] = r245c(12, function()
local effects = b245c[20]('src/view/effects')
local const = b245c[19]('src/const')
local function get_angle(y, x)
if math.atan2 then return math.atan2(y, x) end
return math.atan(y, x)
end
local function fire(std, p, G)
if G.shotgun_cooldown > 0 then return false end
G.shotgun_cooldown = 1000
G.shake = 15
local base_angle = p.aim_angle
p.real_x = p.real_x - math.cos(base_angle) * 0.4
p.real_y = p.real_y - math.sin(base_angle) * 0.4
p.target_squash = -0.4
for i = 1, 10 do
local spread = (std.math.random() - 0.5) * 0.5
local final_angle = base_angle + spread
local speed = 0.5 + std.math.random() * 0.6
local vx = math.cos(final_angle) * speed
local vy = math.sin(final_angle) * speed
effects.pellet(std, p.real_x, p.real_y, vx, vy)
end
local cx, cy = G.critter.real_x, G.critter.real_y
local dist = std.math.dis(p.real_x, p.real_y, cx, cy)
if dist < 8 then
local angle_critter = get_angle(cy - p.real_y, cx - p.real_x)
local diff = math.abs(angle_critter - base_angle)
if diff > math.pi then diff = math.abs(diff - 2 * math.pi) end
if diff < 0.7 then
return "capture"
end
end
return false
end
return {
id = "shotgun",
name = "SHOTGUN",
desc = "hold to aim, release to shoot.",
icon = "}-",
type = "active",
color = 0xffaa44FF,
apply = function(p)
p.has_shotgun = true
p.aim_angle = 0
end,
update = function(p, std, G, triggered)
if triggered then
if not p.aiming then
p.aiming = true
local vec = const.vectors[p.curr_dir]
if vec.x == 0 and vec.y == 0 then
vec = const.vectors[p.prev_dir or 5]
end
p.aim_angle = get_angle(vec.y, vec.x)
end
local rotation_speed = 0.008 * std.delta
if std.key.press.left then
p.aim_angle = p.aim_angle - rotation_speed
if math.cos(p.aim_angle) < -0.5 then
p.curr_dir = 4
elseif math.cos(p.aim_angle) > 0.5 then
p.curr_dir = 5
elseif math.sin(p.aim_angle) < -0.5 then
p.curr_dir = 2
else
p.curr_dir = 3
end
end
if std.key.press.right then
p.aim_angle = p.aim_angle + rotation_speed
if math.cos(p.aim_angle) < -0.5 then
p.curr_dir = 4
elseif math.cos(p.aim_angle) > 0.5 then
p.curr_dir = 5
elseif math.sin(p.aim_angle) < -0.5 then
p.curr_dir = 2
else
p.curr_dir = 3
end
end
p.move_timer = std.milis + 100
else
if p.aiming then
p.aiming = false
return fire(std, p, G)
end
end
return false
end
}
end)
b245c[13] = r245c(13, function()
local const = b245c[19]('src/const')
return {
id = "dash",
name = "PHANTOM DASH",
desc = "dash 3 tiles instantly. cooldown 2s.",
icon = "~>",
type = "active",
color = 0xff8844FF,
apply = function(p)
p.has_dash = true
end,
update = function(p, std, G, triggered)
if triggered and G.ability_cooldown <= 0 then
G.ability_cooldown = 2000
G.shake = 8
local vec = const.vectors[p.curr_dir]
local dash_dist = 3
local cx = math.floor(p.x + 0.5)
local cy = math.floor(p.y + 0.5)
local new_x = cx + vec.x * dash_dist
local new_y = cy + vec.y * dash_dist
new_x = math.max(2, math.min(G.w - 1, new_x))
new_y = math.max(2, math.min(G.h - 1, new_y))
local function is_wall(tx, ty)
if tx < 1 or tx > G.w or ty < 1 or ty > G.h then return true end
return G.grid[(ty - 1) * G.w + tx] == const.T_WALL
end
if not p.wall_hack and is_wall(new_x, new_y) then
for i = dash_dist - 1, 1, -1 do
local check_x = cx + vec.x * i
local check_y = cy + vec.y * i
if not is_wall(check_x, check_y) then
new_x = check_x
new_y = check_y
break
end
end
end
p.x = new_x
p.y = new_y
p.dash_timer = 200
p.dashing = true
local dist = std.math.dis(p.x, p.y, G.critter.x, G.critter.y)
if dist < 1.5 then
return "capture"
end
end
if p.dash_timer and p.dash_timer > 0 then
p.dash_timer = p.dash_timer - std.delta
if p.dash_timer <= 0 then
p.dashing = false
p.dash_timer = 0
end
else
p.dashing = false
end
return false
end
}
end)
b245c[14] = r245c(14, function()
return {
id = "mark",
name = "HUNTER'S MARK",
desc = "always see the critter, even through walls.",
icon = "{!}",
type = "passive",
color = 0xffff44FF,
apply = function(p)
p.has_mark = true
end
}
end)
b245c[15] = r245c(15, function()
local effects = b245c[20]('src/view/effects')
local const = b245c[19]('src/const')
return {
id = "chains",
name = "SPECTRAL CHAINS",
desc = "slows prey nearby. 5s cooldown.",
icon = "o-o",
type = "active",
color = 0x8888ffFF,
apply = function(p)
p.has_chains = true
end,
update = function(p, std, G, triggered)
if triggered and G.ability_cooldown <= 0 then
effects.magic_spark(std, p.real_x, p.real_y, 0x8888ffFF)
local dist = std.math.dis(p.x, p.y, G.critter.x, G.critter.y)
if dist < 8 then
G.ability_cooldown = 5000
G.shake = 5
G.critter.chained = true
G.critter.chain_timer = 3000
G.critter.speed_mod = 50
effects.magic_spark(std, G.critter.real_x, G.critter.real_y, 0xffffffff)
else
G.ability_cooldown = 1000
end
end
return false
end
}
end)
b245c[16] = r245c(16, function()
return {
id = "dread",
name = "LINGERING DREAD",
desc = "leave a trail of fear. prey avoids your path for 3s.",
icon = "~~~",
type = "passive",
color = 0x884488FF,
apply = function(p)
p.has_dread = true
p.dread_tiles = {}
end
}
end)
b245c[17] = r245c(17, function()
local painters = b245c[21]('game_src_view_skins_painters')
local C = b245c[7]('game_src_const')
local color_cache = {}
local cache_size = 0
local MAX_CACHE = 256
local last_clear = 0
local function quantize_light(light)
return math.floor(light * 10 + 0.5) / 10
end
local function apply_light(color, light, milis)
if milis and milis - last_clear > 15000 then
color_cache = {}
cache_size = 0
last_clear = milis
end
local q = quantize_light(light)
local key = color * 100 + math.floor(q * 100)
if color_cache[key] then
return color_cache[key]
end
local l = math.min(1.3, math.max(0, light))
local r = math.floor(color / 0x1000000)
local g = math.floor((color / 0x10000) % 0x100)
local b = math.floor((color / 0x100) % 0x100)
local a = color % 0x100
r = math.min(255, math.floor(r * l))
g = math.min(255, math.floor(g * l))
b = math.min(255, math.floor(b * l))
local result = r * 0x1000000 + g * 0x10000 + b * 0x100 + a
if cache_size < MAX_CACHE then
color_cache[key] = result
cache_size = cache_size + 1
end
return result
end
local WALL_TOP = C.pal.wall_top
local WALL_SIDE = C.pal.wall_side
local FLOOR_COL = 0x101020FF
local DOT_COL = C.pal.dot
local DOT_GLOW = C.pal.dot_glow
local GHOST_COL = C.pal.ghost
local CRITTER_COL = C.pal.critter
local function draw(std, skin_type, x, y, dx, dy, size, light, milis, dread)
if skin_type == "wall" then
local ct = apply_light(WALL_TOP, light, milis)
local cs = apply_light(WALL_SIDE, light, milis)
painters.wall_bricks(std, dx, dy, size, ct, cs, milis)
elseif skin_type == "floor" then
local c = apply_light(FLOOR_COL, light, milis)
painters.floor_tile(std, dx, dy, size, c, milis, dread)
elseif skin_type == "dot" then
local c = apply_light(DOT_COL, light, milis)
local g = apply_light(DOT_GLOW, light, milis)
painters.dot_pixel(std, dx, dy, size, c, g, milis)
elseif skin_type == "dot_fading" then
painters.dot_fading(std, dx, dy, size, milis)
end
end
local function draw_player(std, dx, dy, size, p, milis)
local c = apply_light(GHOST_COL, 1.0, milis)
painters.ghost_classic(std, dx, dy, size, c, milis, p)
painters.eyes_happy(std, dx, dy, size, p.curr_dir, p.aiming, milis, p.squash)
if p.has_shotgun then
local angle = p.aiming and p.aim_angle or
(p.curr_dir == C.D_UP and 4.71 or p.curr_dir == C.D_DOWN and 1.57 or p.curr_dir == C.D_LEFT and 3.14 or 0)
painters.gun_shotgun(std, dx, dy, size, angle, milis)
if p.aiming then
painters.aim_laser(std, dx, dy, size, angle, milis)
end
end
end
local function draw_critter(std, dx, dy, size, c, milis)
local col = apply_light(CRITTER_COL, 1.0, milis)
local body = { painters.critter_blob(std, dx, dy, size, col, milis, c) }
painters.critter_eyes(std, dx, dy, size, c.curr_dir, c.scared, c.brave, body, milis)
end
return {
draw = draw,
draw_player = draw_player,
draw_critter = draw_critter,
apply_light = apply_light
}
end)
b245c[18] = r245c(18, function()
local menu = b245c[22]('game_src_view_ui_menu')
local hud = b245c[23]('game_src_view_ui_hud')
local upgrade = b245c[24]('game_src_view_ui_upgrade')
local gameover = b245c[25]('game_src_view_ui_gameover')
local evolution = b245c[26]('game_src_view_ui_evolution')
local credits = b245c[27]('game_src_view_ui_credits')
local pause = b245c[28]('game_src_view_ui_pause')
local C = b245c[7]('game_src_const')
local function draw(std, G, fps)
local s = G.state
if s == C.S_MENU then
menu.draw(std, G.menu_cursor)
elseif s == C.S_PLAY then
hud.draw(std, G, fps)
elseif s == C.S_UPGRADE then
hud.draw(std, G, fps)
upgrade.draw(std, G.upgrade_options, G.upgrade_cursor)
elseif s == C.S_GAMEOVER then
gameover.draw(std, G)
elseif s == C.S_EVOLUTION then
evolution.draw(std, G.player)
elseif s == C.S_CREDITS then
credits.draw(std)
elseif s == C.S_PAUSE then
hud.draw(std, G, fps)
pause.draw(std, G)
end
end
return { draw = draw }
end)
b245c[19] = r245c(19, function()
local P = {
input = { cooldown = 100 },
smooth = {
actor_lerp = 0.18,
actor_lerp_fast = 0.28,
camera_lerp = 0.08,
bob_speed = 0.008,
bob_amplitude = 2.5,
shake_decay = 0.06
},
balance = {
dot_fade_start = 15000,
dot_fade_interval = 2000,
idle_threshold = 2000,
base_critter_speed = 155,
speed_per_level = 6,
courage_speed_bonus = 25,
ai_think_interval = 4
},
S_MENU = 0,
S_PLAY = 1,
S_GAMEOVER = 2,
S_UPGRADE = 3,
S_CAPTURE = 4,
S_EVOLUTION = 5,
S_CREDITS = 6,
S_PAUSE = 7,
T_EMPTY = 0,
T_WALL = 1,
T_DOT = 2,
T_FADING = 3,
D_NONE = 1,
D_UP = 2,
D_DOWN = 3,
D_LEFT = 4,
D_RIGHT = 5,
vectors = {
{ x = 0, y = 0 },
{ x = 0, y = -1 },
{ x = 0, y = 1 },
{ x = -1, y = 0 },
{ x = 1, y = 0 }
},
pal = {
bg = 0x0a0a1aFF,
bg_alt = 0x0f0f24FF,
wall_top = 0x4a4a6aFF,
wall_side = 0x2a2a40FF,
blood = 0xFFD700FF,
blood_stain = 0x886600FF,
blood_splat = 0xFFD700AA,
ghost = 0x88eeffFF,
ghost_glow = 0x88eeff44,
ghost_eye = 0x1a1a2eFF,
ghost_pupil = 0x000000FF,
ghost_angry = 0xff6688FF,
critter = 0xff6666FF,
critter_dark = 0xcc3333FF,
critter_belly = 0xffaaaaFF,
critter_eye = 0xffffffFF,
critter_pupil = 0x000000FF,
critter_brave = 0xffaa44FF,
dot = 0xffd700FF,
dot_glow = 0xffd70066,
dot_fading = 0xff880088,
ui_bg = 0x1a1a2aEE,
ui_panel = 0x252540FF,
ui_border = 0xaa88ffFF,
ui_select = 0xff66aaFF,
ui_dim = 0x000000AA,
ui_shadow = 0x00000066,
ui_warning = 0xff4444FF,
ui_success = 0x44ff88FF,
text = 0xf0f0f0FF,
text_dim = 0x7080a0FF,
text_highlight = 0xffffaaFF,
perk_chains = 0x8888ffFF
}
}
return P
end)
b245c[20] = r245c(20, function()
local C = b245c[19]('src/const')
local math_floor = math.floor
local math_sin = math.sin
local math_cos = math.cos
local MAX_PARTICLES = 128
local MAX_MARKERS = 32
local particles = {}
local particles_count = 0
local fade_markers = {}
local markers_count = 0
for i = 1, MAX_PARTICLES do
particles[i] = {
x = 0, y = 0, vx = 0, vy = 0,
life = 0, max_life = 0, size = 0,
type = 0, color = 0, alpha = 0,
gravity = 0, friction = 0, active = false
}
end
for i = 1, MAX_MARKERS do
fade_markers[i] = { x = 0, y = 0, life = 0, max_life = 0, phase = 0, active = false }
end
local function reset()
for i = 1, MAX_PARTICLES do
particles[i].active = false
end
particles_count = 0
for i = 1, MAX_MARKERS do
fade_markers[i].active = false
end
markers_count = 0
end
local function get_free_particle()
for i = 1, MAX_PARTICLES do
if not particles[i].active then
return particles[i]
end
end
return particles[1]
end
local function explode(std, x, y)
for i = 1, 15 do
local p = get_free_particle()
local angle = std.math.random(0, 628) / 100
local speed = std.math.random(60, 200) / 100
p.x = x
p.y = y
p.vx = math_cos(angle) * speed
p.vy = math_sin(angle) * speed - 0.5
p.life = std.math.random(40, 90)
p.max_life = 90
p.size = std.math.random(25, 55) / 100
p.type = 1
p.alpha = 1
p.gravity = 0.012
p.friction = 0.985
p.active = true
particles_count = particles_count + 1
end
end
local function pellet(std, x, y, dx, dy)
local p = get_free_particle()
p.x = x
p.y = y
p.vx = dx * 0.9
p.vy = dy * 0.9
p.life = 15
p.max_life = 15
p.size = 0.3
p.type = 2
p.alpha = 1
p.gravity = 0
p.friction = 0.98
p.active = true
particles_count = particles_count + 1
end
local function magic_spark(std, x, y, color)
for i = 1, 10 do
local p = get_free_particle()
local angle = std.math.random(0, 628) / 100
local speed = std.math.random(30, 80) / 100
p.x = x
p.y = y
p.vx = math_cos(angle) * speed
p.vy = math_sin(angle) * speed
p.life = std.math.random(15, 30)
p.max_life = 30
p.size = std.math.random(15, 35) / 100
p.type = 3
p.color = color
p.alpha = 1
p.gravity = -0.005
p.friction = 0.92
p.active = true
particles_count = particles_count + 1
end
end
local function dot_fade(std, x, y)
for i = 1, MAX_MARKERS do
if not fade_markers[i].active then
local m = fade_markers[i]
m.x = x
m.y = y
m.life = 60
m.max_life = 60
m.phase = std.math.random(0, 628) / 100
m.active = true
markers_count = markers_count + 1
return
end
end
end
local function update(std, G)
local dt = std.delta / 16.666
for i = 1, MAX_PARTICLES do
local p = particles[i]
if p.active then
p.vy = p.vy + p.gravity * dt
p.vx = p.vx * p.friction
p.vy = p.vy * p.friction
p.x = p.x + p.vx * dt
p.y = p.y + p.vy * dt
p.life = p.life - dt
p.alpha = p.life / p.max_life
if p.life <= 0 then
p.active = false
particles_count = particles_count - 1
end
end
end
for i = 1, MAX_MARKERS do
local m = fade_markers[i]
if m.active then
m.life = m.life - dt
if m.life <= 0 then
m.active = false
markers_count = markers_count - 1
end
end
end
end
local function draw(std, cs, ox, oy, G)
for i = 1, MAX_MARKERS do
local m = fade_markers[i]
if m.active then
local s = cs * 0.6 * (math_sin(m.phase) * 0.3 + 0.7) * (m.life / m.max_life)
std.draw.color(C.pal.dot_fading)
std.draw.rect(0, ox + (m.x - 1) * cs + cs * 0.2, oy + (m.y - 1) * cs + cs * 0.2, s, s)
end
end
for i = 1, MAX_PARTICLES do
local p = particles[i]
if p.active and p.alpha > 0.05 then
local color
if p.type == 1 then
color = C.pal.blood
elseif p.type == 2 then
color = 0xffffccFF
else
color = p.color
end
local s = p.size * cs
std.draw.color(color)
std.draw.rect(0, ox + (p.x - 1) * cs + cs / 2 - s / 2, oy + (p.y - 1) * cs + cs / 2 - s / 2, s, s)
end
end
end
return {
reset = reset,
explode = explode,
pellet = pellet,
magic_spark = magic_spark,
dot_fade = dot_fade,
update = update,
draw = draw
}
end)
b245c[21] = r245c(21, function()
local C = b245c[7]('game_src_const')
local sprites = b245c[29]('game_src_view_skins_sprites')
local math_ceil = math.ceil
local math_floor = math.floor
local math_sin = math.sin
local math_cos = math.cos
local compiled = {}
local function compile_sprite(name, matrix)
local stream = {}
local idx = 1
for py = 1, 8 do
local row = matrix[py]
if row then
local cur_c = nil
local run_start = 1
for px = 1, 8 do
local c = row[px]
if c ~= cur_c then
if cur_c and cur_c > 0 then
stream[idx] = run_start - 1
stream[idx + 1] = py - 1
stream[idx + 2] = px - run_start
stream[idx + 3] = cur_c
idx = idx + 4
end
cur_c = c
run_start = px
end
end
if cur_c and cur_c > 0 then
stream[idx] = run_start - 1
stream[idx + 1] = py - 1
stream[idx + 2] = 9 - run_start
stream[idx + 3] = cur_c
idx = idx + 4
end
end
end
compiled[name] = stream
end
compile_sprite("wall", sprites.wall)
compile_sprite("floor", sprites.floor)
compile_sprite("dot", sprites.dot)
local function draw_compiled(std, x, y, s, name, c1, c2, c3)
if s < 8 then
if c1 then
std.draw.color(c1)
std.draw.rect(0, x, y, s, s)
end
return
end
local stream = compiled[name]
if not stream then return end
local ps = s / 8
local i = 1
while i <= #stream do
local px, py, pw, ci = stream[i], stream[i + 1], stream[i + 2], stream[i + 3]
local col = (ci == 1 and c1) or (ci == 2 and c2) or (ci == 3 and c3)
if col then
std.draw.color(col)
std.draw.rect(0, x + px * ps, y + py * ps, pw * ps + 0.5, ps + 0.5)
end
i = i + 4
end
end
local function wall_bricks(std, x, y, s, c_top, c_side, milis)
std.draw.color(c_side)
std.draw.rect(0, x, y, s, s)
draw_compiled(std, x, y, s, "wall", c_top, 0x88888833, 0x00000044)
end
local function floor_tile(std, x, y, s, col, milis, dread)
std.draw.color(col)
std.draw.rect(0, x, y, s + 1, s + 1)
if dread then
std.draw.color(0x550055FF)
std.draw.rect(0, x + 2, y + 2, s - 4, s - 4)
else
draw_compiled(std, x, y, s, "floor", 0xFFFFFF0A, 0xFFFFFF15, nil)
end
end
local function dot_pixel(std, x, y, s, col, glow, milis)
local pulse = math_sin(milis * 0.004) * 0.15 + 0.85
local gs = s * 0.6 * pulse
std.draw.color(glow)
std.draw.rect(0, x + (s - gs) / 2, y + (s - gs) / 2, gs, gs)
draw_compiled(std, x, y, s, "dot", col, 0xFFFFFFAA, nil)
end
local function dot_fading(std, x, y, s, milis)
local pulse = math_sin(milis * 0.01) * 0.5 + 0.5
local sz = s * 0.4 * (0.5 + pulse * 0.5)
std.draw.color(C.pal.dot_fading)
std.draw.rect(0, x + (s - sz) / 2, y + (s - sz) / 2, sz, sz)
end
local function ghost_classic(std, x, y, s, col, milis, opts)
local sq = opts.squash or 0
local sx = 1 - sq * 0.15
local sy = 1 + sq * 0.1
if opts.dashing then
local vert = opts.curr_dir == 2 or opts.curr_dir == 3
sx = vert and 0.6 or 1.4
sy = vert and 1.4 or 0.6
end
local w = s * 0.85 * sx
local h = s * 0.9 * sy
local cx = x + (s - w) / 2
local cy = y + s - h
std.draw.color(C.pal.ghost_glow)
std.draw.rect(0, cx - 2, cy + h * 0.3, w + 4, h * 0.7)
local body_col = opts.aiming and C.pal.ghost_angry or col
std.draw.color(body_col)
std.draw.rect(0, cx + w * 0.1, cy, w * 0.8, h * 0.6)
std.draw.rect(0, cx, cy + h * 0.3, w, h * 0.5)
local wb = milis * 0.012
local tw = w / 3
local by = cy + h * 0.75
for i = 0, 2 do
std.draw.rect(0, cx + tw * i, by + math_sin(wb + i * 2) * 3, tw, h * 0.25)
end
end
local function eyes_happy(std, x, y, s, dir, aim, milis, squash)
squash = squash or 0
local sf = 1.0
if squash < 0 then sf = 1.0 + squash * 0.8 end
local ew = s * 0.18
local eh = (aim and s * 0.12 or s * 0.22) * sf
local ey = y + s * 0.32
if squash < 0 then ey = ey - squash * s * 0.1 end
local lx = (dir == 4 and -2) or (dir == 5 and 2) or 0
local ly = (dir == 2 and -2) or (dir == 3 and 2) or 0
local lex = x + s * 0.25 + lx
local rex = x + s * 0.55 + lx
local eyy = ey + ly
std.draw.color(C.pal.ghost_eye)
std.draw.rect(0, lex, eyy, ew, eh)
std.draw.rect(0, rex, eyy, ew, eh)
if not aim then
local p = ew * 0.6
std.draw.color(C.pal.ghost_pupil)
std.draw.rect(0, lex + ew * 0.2 + lx * 0.3, eyy + eh * 0.3, p, p)
std.draw.rect(0, rex + ew * 0.2 + lx * 0.3, eyy + eh * 0.3, p, p)
end
end
local function gun_shotgun(std, x, y, s, angle, milis)
local cx = x + s / 2
local cy = y + s / 2
local r = s * 0.6
local gx = cx + math_cos(angle) * r
local gy = cy + math_sin(angle) * r
local function draw_line(px, py, len, thick, col)
std.draw.color(col)
local steps = math_ceil(len / 2)
local dx = math_cos(angle) * (len / steps)
local dy = math_sin(angle) * (len / steps)
for i = 0, steps do
std.draw.rect(0, px + dx * i - thick / 2, py + dy * i - thick / 2, thick, thick)
end
end
draw_line(gx, gy, s * 0.24, 4, 0x8B4513FF)
draw_line(gx + math_cos(angle) * s * 0.24, gy + math_sin(angle) * s * 0.24, s * 0.36, 3, 0xAAAAAAFF)
end
local function aim_laser(std, x, y, s, angle, milis)
local cx = x + s / 2
local cy = y + s / 2
local p = math_sin(milis * 0.018) * 0.3 + 0.7
std.draw.color(C.pal.critter)
for i = 1, 10, 2 do
local dist = s * 0.6 + i * s * 0.25
local ds = 2 * p
std.draw.rect(0, cx + math_cos(angle) * dist - ds / 2, cy + math_sin(angle) * dist - ds / 2, ds, ds)
end
end
local function critter_blob(std, x, y, s, col, milis, opts)
local sq = opts.squash or 0
local sx = 1 + sq * 0.2
local sy = 1 - sq * 0.15
local w = s * 0.8 * sx
local h = s * 0.7 * sy
local cx = x + (s - w) / 2
local cy = y + s - h - 2
local bounce = opts.chained and 0 or math.abs(math_sin(milis * 0.012)) * 3
cy = cy - bounce
std.draw.color(0x00000033)
std.draw.rect(0, cx + 2, y + s - 4, w - 4, 4)
if opts.chained then
std.draw.color(C.pal.perk_chains)
std.draw.rect(0, cx - 3, cy + h * 0.3, w + 6, 3)
std.draw.rect(0, cx - 3, cy + h * 0.6, w + 6, 3)
end
local c = opts.brave and C.pal.critter_brave or col
std.draw.color(c)
std.draw.rect(0, cx + w * 0.1, cy, w * 0.8, h)
std.draw.rect(0, cx, cy + h * 0.15, w, h * 0.7)
std.draw.color(C.pal.critter_belly)
std.draw.rect(0, cx + w * 0.25, cy + h * 0.35, w * 0.5, h * 0.4)
std.draw.color(C.pal.critter_dark)
std.draw.rect(0, cx + w * 0.15, cy + h - 2, w * 0.2, h * 0.15)
std.draw.rect(0, cx + w * 0.65, cy + h - 2, w * 0.2, h * 0.15)
local aw = math_sin(milis * 0.012) * (opts.scared and 4 or 2)
std.draw.color(c)
std.draw.rect(0, cx + w * 0.3, cy - 6 + aw, 2, 8)
std.draw.rect(0, cx + w * 0.6, cy - 6 - aw, 2, 8)
return cx, cy, w, h
end
local function critter_eyes(std, x, y, s, dir, scared, brave, body, milis)
local cx, cy, w, h = body[1], body[2], body[3], body[4]
local es = scared and s * 0.24 or s * 0.18
local ey = cy + h * 0.28
local lx = (dir == 4 and -2) or (dir == 5 and 2) or 0
std.draw.color(C.pal.critter_eye)
std.draw.rect(0, cx + w * 0.18, ey, es, es)
std.draw.rect(0, cx + w * 0.54, ey, es, es)
local p = scared and es * 0.25 or es * 0.5
local po = (es - p) / 2
std.draw.color(C.pal.critter_pupil)
std.draw.rect(0, cx + w * 0.18 + po + lx, ey + po, p, p)
std.draw.rect(0, cx + w * 0.54 + po + lx, ey + po, p, p)
end
local function logo_pixel(std, cx, cy, s, color, shadow)
local gap = math_floor(s / 2)
local font = {
G = { 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1 },
H = { 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1 },
O = { 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1 },
S = { 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1 },
T = { 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0 },
M = { 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1 },
A = { 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1 },
N = { 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1 }
}
local text = "GHOSTMAN"
local start_x = cx - (#text * (3 * s + gap) - gap) / 2
for i = 1, #text do
local map = font[text:sub(i, i)]
local lx = start_x + (i - 1) * (3 * s + gap)
for idx = 0, 14 do
if map[idx + 1] == 1 then
local px = idx % 3
local py = math_floor(idx / 3)
if shadow then
std.draw.color(shadow)
std.draw.rect(0, lx + px * s + s, cy + py * s + s, s, s)
end
std.draw.color(color)
std.draw.rect(0, lx + px * s, cy + py * s, s, s)
end
end
end
end
return {
wall_bricks = wall_bricks,
floor_tile = floor_tile,
dot_pixel = dot_pixel,
dot_fading = dot_fading,
ghost_classic = ghost_classic,
eyes_happy = eyes_happy,
gun_shotgun = gun_shotgun,
aim_laser = aim_laser,
critter_blob = critter_blob,
critter_eyes = critter_eyes,
logo_pixel = logo_pixel
}
end)
b245c[22] = r245c(22, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local painters = b245c[21]('game_src_view_skins_painters')
local items = { "start", "evolution", "credits", "exit" }
local function draw(std, cursor)
local sw, sh = std.app.width, std.app.height
std.draw.clear(C.pal.bg)
for i = 1, 15 do
local t = std.milis / (2000 + i * 100)
local x = math.sin(i * 132 + t) * sw * 0.45 + sw / 2
local y = math.cos(i * 94 + t) * sh * 0.45 + sh / 2
local a = math.floor(math.abs(math.sin(t * 3)) * 100) + 50
std.draw.color(C.pal.ui_border - 0xFF + a)
std.draw.rect(0, x, y, 2, 2)
end
local bob = math.sin(std.milis / 400) * 4
local ps = math.max(4, math.floor(sw / 80))
painters.logo_pixel(std, sw / 2, sh / 4 + bob, ps, C.pal.ui_border, C.pal.ui_shadow)
local mw, mh = 220, 200
local mx = sw / 2 - mw / 2
local my = sh / 2
fw.panel(std, { x = mx, y = my, w = mw, h = mh, style = "fancy", border = C.pal.ui_select })
local bw, bh = 180, 32
local start_y = my + 25
local gap = 42
for i, item in ipairs(items) do
local y = start_y + (i - 1) * gap
fw.button(std, item, sw / 2 - bw / 2, y, bw, bh, cursor == i)
end
fw.separator(std, sw / 2 - 100, sh - 45, 200)
fw.text(std, "[z] select   [arrows] navigate", sw / 2, sh - 30, {
size = 10,
align = "center",
color = C.pal.text_dim
})
end
return { draw = draw }
end)
b245c[23] = r245c(23, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local fps_smooth = 60
local function update_fps(std)
local cur = 1000 / (std.delta + 0.001)
fps_smooth = fps_smooth + (cur - fps_smooth) * 0.1
return fps_smooth
end
local function draw(std, G, show_fps)
local sw, sh = std.app.width, std.app.height
local p = G.player
fw.panel(std, { x = 8, y = 8, w = 140, h = 50, style = "flat" })
fw.text(std, "level", 18, 14, { size = 11, color = C.pal.text_dim })
fw.text(std, tostring(G.level), 70, 11, { size = 18, color = C.pal.text })
fw.text(std, "dots: " .. G.dots, 18, 35, { size = 12, color = C.pal.dot, shadow = true })
if show_fps == 1 then
local fps = update_fps(std)
local col = fps > 50 and C.pal.ui_success or C.pal.ui_warning
fw.text(std, "fps: " .. math.floor(fps), sw - 40, 15, {
size = 10,
align = "right",
color = col,
shadow = true
})
end
if G.fade_active then
if math.floor(std.milis / 200) % 2 == 0 then
fw.text(std, "!", 100, 37, { size = 10, color = C.pal.ui_warning })
end
end
fw.text(std, "[p] pause", sw - 10, 8, {
size = 9,
align = "right",
color = C.pal.text_dim
})
local ss = 24
local gap = 8
local sx = sw / 2 - (ss * 3 + gap * 2) / 2
local sy = sh - 40
local keys = { "[z]", "[x]", "[c]" }
for i = 1, 3 do
local perk = p.actives and p.actives[i]
local cd = 0
if perk then
if perk.id == "shotgun" and G.shotgun_cooldown > 0 then
cd = G.shotgun_cooldown / 900
elseif (perk.id == "dash" or perk.id == "chains") and G.ability_cooldown > 0 then
local max = perk.id == "chains" and 5000 or 2000
cd = G.ability_cooldown / max
end
end
fw.skill_slot(std, sx + (i - 1) * (ss + gap), sy, ss, keys[i], perk, cd)
end
if p.aiming then
fw.text(std, "[ release to fire ]", sw / 2, sh - 60, {
size = 10,
align = "center",
color = C.pal.critter,
shadow = true
})
end
end
return { draw = draw, update_fps = update_fps }
end)
b245c[24] = r245c(24, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local function draw(std, options, cursor)
local sw, sh = std.app.width, std.app.height
local cx = sw / 2
local num = #options
std.draw.color(C.pal.ui_dim)
std.draw.rect(0, 0, 0, sw, sh)
local pw = math.max(200, 140 * num + 40)
local ph = 280
local py = sh / 2 - ph / 2
fw.panel(std, { x = cx - pw / 2, y = py, w = pw, h = ph, style = "fancy" })
fw.text(std, "evolution!", cx, py + 25, {
size = 24,
align = "center",
color = C.pal.text_highlight,
shadow = true
})
if num > 2 then
fw.text(std, "fast capture bonus!", cx, py + 52, {
size = 11,
align = "center",
color = C.pal.ui_success
})
end
if num == 0 then
fw.text(std, "maximum power!", cx, sh / 2, {
align = "center",
color = C.pal.text_dim
})
return
end
local cw, ch = 120, 170
local gap = 15
local tw = cw * num + gap * (num - 1)
local sx = cx - tw / 2
local cy = sh / 2 - 30
for i, opt in ipairs(options) do
if not opt then break end
local x = sx + (i - 1) * (cw + gap)
local sel = cursor == i
if sel then
std.draw.color(C.pal.ui_border)
std.draw.rect(0, x - 4, cy - 4, cw + 8, ch + 8)
end
fw.panel(std, {
x = x,
y = cy,
w = cw,
h = ch,
color = sel and C.pal.ui_select or C.pal.ui_panel,
border = sel and C.pal.text_highlight or C.pal.ui_border,
style = sel and "fancy" or "flat"
})
fw.text(std, opt.name or "?", x + cw / 2, cy + 18, {
size = 11,
align = "center",
color = sel and C.pal.bg or C.pal.text
})
std.text.font_size(32)
std.draw.color(opt.color or C.pal.ui_border)
local iw = std.text.mensure(opt.icon or "?")
std.text.print(x + cw / 2 - iw / 2, cy + 45, opt.icon or "?")
fw.separator(std, x + 10, cy + 85, cw - 20)
local desc = opt.desc or ""
local line_y = cy + 95
local pos = 1
while pos <= #desc and line_y < cy + ch - 25 do
local end_pos = math.min(pos + 17, #desc)
fw.text(std, desc:sub(pos, end_pos), x + cw / 2, line_y, {
size = 9,
align = "center",
color = sel and C.pal.bg or C.pal.text_dim
})
line_y = line_y + 11
pos = end_pos + 1
end
local tt = opt.type == "active" and "[active]" or "[passive]"
local tc = opt.type == "active" and C.pal.critter or C.pal.ui_success
if sel then tc = C.pal.bg end
fw.text(std, tt, x + cw / 2, cy + ch - 18, {
size = 8,
align = "center",
color = tc
})
end
end
return { draw = draw }
end)
b245c[25] = r245c(25, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local function get_msg(reason)
if reason == "eaten" then
return "you stood still..."
elseif reason == "starved" then
return "the critter survived..."
end
return "the hunt has ended..."
end
local function draw(std, G)
local sw, sh = std.app.width, std.app.height
std.draw.color(C.pal.ui_dim)
std.draw.rect(0, 0, 0, sw, sh)
fw.panel(std, { x = sw / 2 - 140, y = sh / 2 - 80, w = 280, h = 160 })
fw.text(std, "game over", sw / 2, sh / 2 - 50, {
size = 24,
align = "center",
color = C.pal.ui_select
})
fw.text(std, get_msg(G.death_reason), sw / 2, sh / 2 - 10, {
size = 14,
align = "center",
color = C.pal.text_dim
})
if math.floor(std.milis / 500) % 2 == 0 then
fw.text(std, "press z to restart", sw / 2, sh / 2 + 30, {
size = 12,
align = "center",
color = C.pal.ui_select
})
end
end
return { draw = draw }
end)
b245c[26] = r245c(26, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local function draw(std, player)
local sw, sh = std.app.width, std.app.height
fw.text(std, "evolution tree", sw / 2, 40, {
size = 24,
align = "center",
color = C.pal.ui_select
})
local cx, cy = sw / 2, sh / 2 + 30
local r = 120
local nodes = {
{ name = "start", x = 0, y = -r, check = nil },
{ name = "speed", x = r * 0.95, y = -r * 0.31, check = function(p) return p and p.speed_mod < 0 end },
{ name = "vision", x = r * 0.59, y = r * 0.81, check = function(p) return p and p.zoom_out end },
{ name = "fear", x = -r * 0.59, y = r * 0.81, check = function(p) return p and p.has_fear_aura end },
{ name = "ethereal", x = -r * 0.95, y = -r * 0.31, check = function(p) return p and p.wall_hack end },
{ name = "shotgun", x = 0, y = 0, check = function(p) return p and p.has_shotgun end }
}
local conns = { { 1, 3 }, { 3, 5 }, { 5, 2 }, { 2, 4 }, { 4, 1 }, { 1, 6 }, { 3, 6 }, { 5, 6 } }
std.draw.color(C.pal.ui_border)
for _, c in ipairs(conns) do
local a, b = nodes[c[1]], nodes[c[2]]
std.draw.line(cx + a.x, cy + a.y, cx + b.x, cy + b.y)
end
for _, n in ipairs(nodes) do
local nx, ny = cx + n.x, cy + n.y
local active = n.check and n.check(player)
local bg = active and C.pal.ui_success or C.pal.ui_panel
local txt = active and C.pal.bg or C.pal.text
if n.name == "start" then
bg = C.pal.ui_select
txt = C.pal.bg
end
std.draw.color(bg)
std.draw.rect(0, nx - 35, ny - 12, 70, 24)
std.draw.color(active and C.pal.text_highlight or C.pal.ui_border)
std.draw.rect(1, nx - 35, ny - 12, 70, 24)
std.text.font_size(10)
std.draw.color(txt)
local w = std.text.mensure(n.name)
std.text.print(nx - w / 2, ny - 5, n.name)
end
fw.text(std, "[z] back to menu", sw / 2, sh - 40, {
size = 12,
align = "center",
color = C.pal.text_dim
})
end
return { draw = draw }
end)
b245c[27] = r245c(27, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local function draw(std)
local sw, sh = std.app.width, std.app.height
fw.panel(std, { x = sw / 2 - 200, y = sh / 2 - 180, w = 400, h = 360 })
fw.text(std, "credits", sw / 2, sh / 2 - 140, {
size = 28,
align = "center",
color = C.pal.ui_border
})
std.draw.color(C.pal.ui_dim)
std.draw.rect(0, sw / 2 - 100, sh / 2 - 110, 200, 2)
fw.text(std, "developed by", sw / 2, sh / 2 - 80, {
size = 14,
align = "center",
color = C.pal.ui_select
})
fw.text(std, "guilhhotina", sw / 2, sh / 2 - 55, {
size = 20,
align = "center",
color = C.pal.text
})
fw.text(std, "v2.6.0", sw / 2, sh / 2 - 25, {
size = 12,
align = "center",
color = C.pal.text_dim
})
std.draw.color(C.pal.ui_dim)
std.draw.rect(0, sw / 2 - 80, sh / 2, 160, 2)
fw.text(std, "special thanks", sw / 2, sh / 2 + 20, {
size = 14,
align = "center",
color = C.pal.ui_border
})
fw.text(std, "you for playing!", sw / 2, sh / 2 + 45, {
size = 12,
align = "center",
color = C.pal.text_dim
})
fw.text(std, "donatello", sw / 2, sh / 2 + 65, {
size = 12,
align = "center",
color = C.pal.text_dim
})
fw.text(std, "[z] back to menu", sw / 2, sh / 2 + 130, {
size = 10,
align = "center",
color = C.pal.text_dim
})
end
return { draw = draw }
end)
b245c[28] = r245c(28, function()
local C = b245c[7]('game_src_const')
local fw = b245c[30]('game_src_view_ui_framework')
local items = { "resume", "quit to menu", "exit game" }
local function draw(std, G)
local sw, sh = std.app.width, std.app.height
std.draw.color(0x000000AA)
std.draw.rect(0, 0, 0, sw, sh)
local pw, ph = 240, 200
local px, py = sw / 2 - pw / 2, sh / 2 - ph / 2
fw.panel(std, {
x = px,
y = py,
w = pw,
h = ph,
style = "fancy",
border = C.pal.ui_select
})
fw.text(std, "paused", sw / 2, py + 25, {
size = 24,
align = "center",
color = C.pal.ui_border,
shadow = true
})
fw.separator(std, px + 20, py + 55, pw - 40)
local bw, bh = 180, 32
local start_y = py + 70
local gap = 40
for i, item in ipairs(items) do
local y = start_y + (i - 1) * gap
local sel = G.pause_cursor == i
fw.button(std, item, sw / 2 - bw / 2, y, bw, bh, sel)
end
fw.text(std, "[p] quick resume", sw / 2, py + ph - 20, {
size = 10,
align = "center",
color = C.pal.text_dim
})
end
return { draw = draw }
end)
b245c[29] = r245c(29, function()
return {
wall = {
{ 2, 2, 2, 2, 2, 2, 2, 0 },
{ 1, 1, 1, 1, 1, 1, 1, 0 },
{ 3, 3, 3, 3, 3, 3, 3, 0 },
{ 0, 0, 0, 0, 0, 0, 0, 0 },
{ 2, 2, 2, 0, 2, 2, 2, 2 },
{ 1, 1, 1, 0, 1, 1, 1, 1 },
{ 3, 3, 3, 0, 3, 3, 3, 3 },
{ 0, 0, 0, 0, 0, 0, 0, 0 }
},
floor = {
{ 1, 1, 1, 1, 1, 1, 1, 1 },
{ 1, 0, 0, 0, 0, 0, 0, 1 },
{ 1, 0, 2, 0, 0, 0, 0, 1 },
{ 1, 0, 0, 0, 0, 2, 0, 1 },
{ 1, 0, 0, 0, 0, 0, 0, 1 },
{ 1, 0, 0, 2, 0, 0, 0, 1 },
{ 1, 0, 0, 0, 0, 0, 0, 1 },
{ 1, 1, 1, 1, 1, 1, 1, 1 }
},
dot = {
{ 0, 0, 0, 0, 0, 0, 0, 0 },
{ 0, 0, 2, 2, 2, 2, 0, 0 },
{ 0, 2, 1, 1, 1, 1, 2, 0 },
{ 0, 2, 1, 1, 1, 1, 2, 0 },
{ 0, 2, 1, 1, 1, 1, 2, 0 },
{ 0, 2, 1, 1, 1, 1, 2, 0 },
{ 0, 0, 2, 2, 2, 2, 0, 0 },
{ 0, 0, 0, 0, 0, 0, 0, 0 }
}
}
end)
b245c[30] = r245c(30, function()
local C = b245c[7]('game_src_const')
local function dither(std, x, y, w, h, color)
std.draw.color(color)
for py = y, y + h - 1, 4 do
local off = ((py - y) / 4) % 2 == 0 and 0 or 2
for px = x + off, x + w - 1, 4 do
if px + 2 <= x + w and py + 2 <= y + h then
std.draw.rect(0, px, py, 2, 2)
end
end
end
end
local function panel(std, opts)
local x, y, w, h = opts.x, opts.y, opts.w, opts.h
local bg = opts.color or C.pal.ui_panel
local border = opts.border or C.pal.ui_border
std.draw.color(C.pal.ui_dim)
std.draw.rect(0, x + 4, y + 4, w, h)
std.draw.color(bg)
std.draw.rect(0, x, y, w, h)
dither(std, x + 2, y + 2, w - 4, h - 4, 0x00000033)
std.draw.color(opts.style == "fancy" and C.pal.ui_shadow or border)
std.draw.rect(1, x, y, w, h)
end
local function text(std, str, x, y, opts)
opts = opts or {}
std.text.font_size(opts.size or 12)
local w = std.text.mensure(str)
local fx = x
if opts.align == "center" then
fx = x - w / 2
elseif opts.align == "right" then
fx = x - w
end
if opts.shadow then
std.draw.color(C.pal.ui_shadow)
std.text.print(fx + 1, y + 1, str)
end
std.draw.color(opts.color or C.pal.text)
std.text.print(fx, y, str)
return w
end
local function button(std, txt, x, y, w, h, sel)
local bg = sel and C.pal.ui_select or C.pal.ui_panel
local oy = sel and math.sin(std.milis * 0.01) * 1.5 or 0
panel(std, {
x = x,
y = y + oy,
w = w,
h = h,
color = bg,
border = sel and C.pal.text_highlight or C.pal.ui_border,
style = sel and "fancy" or "flat"
})
text(std, txt, x + w / 2, y + h / 2 - 6 + oy, {
size = 12,
color = sel and C.pal.bg or C.pal.text,
align = "center",
shadow = not sel
})
end
local function separator(std, x, y, w)
std.draw.color(C.pal.ui_border)
std.draw.rect(0, x, y, w, 1)
std.draw.color(C.pal.ui_shadow)
std.draw.rect(0, x, y + 1, w, 1)
end
local function skill_slot(std, x, y, s, key, perk, cd)
std.draw.color(0x000000AA)
std.draw.rect(0, x, y, s, s)
std.draw.color(perk and perk.color or C.pal.ui_border)
std.draw.rect(1, x, y, s, s)
if perk then
text(std, perk.icon, x + s / 2, y + s / 2 - 6, {
size = 10,
align = "center",
color = perk.color
})
if cd > 0 then
std.draw.color(0x000000CC)
local ch = math.ceil(s * cd)
std.draw.rect(0, x + 1, y + s - ch, s - 2, ch)
end
end
text(std, key, x + s / 2, y + s + 4, {
size = 8,
align = "center",
color = C.pal.text_dim,
shadow = true
})
end
return {
panel = panel,
text = text,
button = button,
separator = separator,
skill_slot = skill_slot
}
end)
return m245c()
