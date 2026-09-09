extends Node2D

## Boss fight. A small red square (styled like the player) sits at the top; the
## player climbs from the bottom to reach it. The boss throws two kinds of
## hazards down the arena:
##   - WALLS: solid red bars with one gap. Miss the gap and they shove you down
##     toward the precipice along the bottom. Fall in and you lose.
##   - PITS: full-width dark bands. You must be DASHING as one passes over you,
##     or you fall. Pits only appear while dashing is allowed, so they're always
##     survivable.
## The movement rules rotate (no sprint -> no dash -> neither -> ...), so the
## fight keeps changing. The camera holds a fixed wide view of the whole arena
## after a short presentation of the boss. Reaching the boss wins the game.

const NEXT_AFTER_BOSS := 5

# Arena geometry (world coordinates). Must match the scene's walls/zones.
@export var arena_left := 40.0
@export var arena_right := 560.0
@export var spawn_y := 130.0
@export var despawn_y := 1000.0

# Hazard behaviour (tuned harder than the first pass).
@export var wall_thickness := 28.0
@export var gap_width := 105.0
@export var wall_speed := 175.0
## Downward shove while touching a wall's solid part. Kept ABOVE the dash speed
## (700) on purpose: a dash can't punch through a wall — only pits are dashable.
## Walls must be walked around (through the gap).
@export var wall_push := 760.0
@export var pit_thickness := 34.0
@export var pit_speed := 190.0
@export var spawn_interval := 1.0
## Dash-allowed phases spawn denser (dash is strong, so it needs the pressure).
@export var dash_phase_spawn_scale := 0.72
## Never more than this many pits falling at once (keeps it survivable).
@export var max_active_pits := 2
@export var pit_chance := 0.6

# Rule rotation.
@export var rule_interval := 5.0

# Fixed wide view of the arena once the fight starts.
@export var fight_zoom := Vector2(0.55, 0.55)
@export var arena_center := Vector2(300, 500)

var _phases := [
	{"sprint": false, "dash": true, "text": "Boss rule: no sprinting"},
	{"sprint": true, "dash": false, "text": "Boss rule: no dashing"},
	{"sprint": false, "dash": false, "text": "Boss rule: no sprinting, no dashing"},
]
var _phase_index := 0
var _ended := false
var _falling := false
var _fight_started := false
var _player = null

@onready var walls: Node2D = $Walls
@onready var boss_core: Area2D = $BossCore
@onready var fall_zone: Area2D = $FallZone
@onready var spawn_timer: Timer = $SpawnTimer
@onready var rule_timer: Timer = $RuleTimer
@onready var arena_cam: Camera2D = $Camera2D


func _ready() -> void:
	randomize()
	SceneManager.consume_intro_skip()
	SceneManager.enter_level(scene_file_path)

	_player = get_tree().get_first_node_in_group("Player")

	boss_core.body_entered.connect(_on_boss_reached)
	fall_zone.body_entered.connect(_on_fell)

	spawn_timer.wait_time = spawn_interval
	rule_timer.wait_time = rule_interval
	spawn_timer.timeout.connect(_spawn_hazard)
	rule_timer.timeout.connect(_next_phase)

	_set_phase(0, false)  # apply rules quietly; announced when the fight starts
	_present_boss()


func _physics_process(delta: float) -> void:
	if _ended:
		return

	# Hold the player still through the whole presentation. The spawn animation
	# would otherwise hand back control partway through, letting them climb
	# before the fight begins.
	if not _fight_started:
		if _player == null or not is_instance_valid(_player):
			_player = get_tree().get_first_node_in_group("Player")
		if is_instance_valid(_player):
			_player.set_physics_process(false)
			_player.velocity = Vector2.ZERO
		return

	var pushed := false
	for hazard in walls.get_children():
		var speed: float = hazard.get_meta("speed", wall_speed)
		hazard.position.y += speed * delta
		if hazard.position.y > despawn_y:
			hazard.queue_free()
			continue
		# Walls are non-solid shove-zones: while you're in the solid part they
		# push you down toward the precipice (a steady move, no bounce, no
		# accumulation), but never block or trap you.
		if not hazard.get_meta("is_pit", false):
			if is_instance_valid(_player) and hazard.overlaps_body(_player):
				pushed = true
	if is_instance_valid(_player):
		_player.external_push = Vector2(0, wall_push) if pushed else Vector2.ZERO


# --- Intro presentation -------------------------------------------------
func _present_boss() -> void:
	# Zoom in on the boss at the top.
	arena_cam.enabled = true
	arena_cam.global_position = boss_core.global_position + Vector2(0, 50)
	arena_cam.zoom = Vector2(1.1, 1.1)
	await get_tree().create_timer(0.4).timeout

	# The red square "runs" side to side.
	var bx := boss_core.position.x
	var run := create_tween()
	run.tween_property(boss_core, "position:x", bx - 110, 0.3).set_trans(Tween.TRANS_SINE)
	run.tween_property(boss_core, "position:x", bx + 110, 0.45).set_trans(Tween.TRANS_SINE)
	run.tween_property(boss_core, "position:x", bx, 0.3).set_trans(Tween.TRANS_SINE)
	await run.finished

	# Pull back to the fixed wide arena view.
	var pull := create_tween()
	pull.set_parallel(true)
	pull.tween_property(arena_cam, "global_position", arena_center, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pull.tween_property(arena_cam, "zoom", fight_zoom, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await pull.finished

	_start_fight()


func _start_fight() -> void:
	if _ended or not is_inside_tree():
		return
	_fight_started = true
	if is_instance_valid(_player) and _player.has_method("give_player_control"):
		_player.give_player_control()
	SceneManager.show_toast(_phases[_phase_index]["text"], 1.6)
	spawn_timer.start()
	rule_timer.start()


# --- Rules --------------------------------------------------------------
func _set_phase(index: int, announce: bool) -> void:
	_phase_index = index
	var phase: Dictionary = _phases[index]
	Game.set_rules(phase["sprint"], phase["dash"])

	if phase["dash"]:
		# Dash is strong, so lean on the player harder during these phases.
		spawn_timer.wait_time = spawn_interval * dash_phase_spawn_scale
	else:
		spawn_timer.wait_time = spawn_interval
		# Any pit still falling can't be dashed now — remove it so the phase
		# stays possible.
		_clear_pits()

	if announce:
		SceneManager.show_toast(phase["text"], 1.6)


func _clear_pits() -> void:
	for hazard in walls.get_children():
		if hazard.get_meta("is_pit", false):
			hazard.queue_free()


func _active_pit_count() -> int:
	var count := 0
	for hazard in walls.get_children():
		if hazard.get_meta("is_pit", false):
			count += 1
	return count


func _next_phase() -> void:
	_set_phase((_phase_index + 1) % _phases.size(), true)


# --- Hazards ------------------------------------------------------------
func _spawn_hazard() -> void:
	# Pits only when dashing is allowed, capped so they never pile up.
	if Game.allow_dash and _active_pit_count() < max_active_pits and randf() < pit_chance:
		_spawn_pit()
	else:
		_spawn_wall()


func _spawn_wall() -> void:
	var wall := Area2D.new()
	wall.position = Vector2(0, spawn_y)
	wall.set_meta("speed", wall_speed)
	wall.set_meta("is_pit", false)

	var half_gap := gap_width / 2.0
	var gap_center := randf_range(arena_left + half_gap + 20.0, arena_right - half_gap - 20.0)
	_add_wall_segment(wall, arena_left, gap_center - half_gap)
	_add_wall_segment(wall, gap_center + half_gap, arena_right)

	walls.add_child(wall)


func _add_wall_segment(wall: Area2D, x_from: float, x_to: float) -> void:
	var width := x_to - x_from
	if width <= 0.0:
		return

	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, wall_thickness)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2((x_from + x_to) / 2.0, 0.0)
	wall.add_child(col)

	var rect := ColorRect.new()
	rect.color = Color(0.85, 0.12, 0.12)
	rect.size = Vector2(width, wall_thickness)
	rect.position = Vector2(x_from, -wall_thickness / 2.0)
	wall.add_child(rect)


func _spawn_pit() -> void:
	var width := arena_right - arena_left
	var pit := Area2D.new()
	pit.position = Vector2(0, spawn_y)
	pit.set_meta("speed", pit_speed)
	pit.set_meta("is_pit", true)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, pit_thickness)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2((arena_left + arena_right) / 2.0, 0.0)
	pit.add_child(col)

	var rect := ColorRect.new()
	rect.color = Color(0.05, 0.05, 0.07)
	rect.size = Vector2(width, pit_thickness)
	rect.position = Vector2(arena_left, -pit_thickness / 2.0)
	pit.add_child(rect)

	pit.body_entered.connect(_on_pit_entered.bind(pit))
	walls.add_child(pit)


func _on_pit_entered(body: Node2D, pit: Area2D) -> void:
	if _ended or _falling or not body.is_in_group("Player"):
		return
	if body.is_dashing:
		return
	# Short grace, then confirm they're still on it and still not dashing.
	await get_tree().create_timer(0.07).timeout
	if _ended or _falling:
		return
	if is_instance_valid(pit) and is_instance_valid(body) and pit.overlaps_body(body) and not body.is_dashing:
		_player_falls(body)


# --- Win / lose ---------------------------------------------------------
func _on_boss_reached(body: Node2D) -> void:
	if _ended or not body.is_in_group("Player"):
		return
	_ended = true
	spawn_timer.stop()
	rule_timer.stop()
	AudioManager.portal()
	Game.set_rules(true, true)
	if is_instance_valid(_player):
		_player.external_push = Vector2.ZERO
	await get_tree().create_timer(0.9).timeout
	SceneManager.go_to_level(NEXT_AFTER_BOSS)  # no such level -> win screen


func _on_fell(body: Node2D) -> void:
	if _ended or not body.is_in_group("Player"):
		return
	_player_falls(body)


func _player_falls(body: Node2D) -> void:
	if _falling:
		return
	_falling = true
	if body.has_method("take_player_control"):
		body.take_player_control("fall_down")  # -> game_over -> reload
