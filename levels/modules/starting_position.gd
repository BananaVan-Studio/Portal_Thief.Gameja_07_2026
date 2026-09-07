extends Marker2D

## Intro director for a level:
##   1. Hold on a wide shot of the whole house.
##   2. The "bad guy" (a black square) runs from the bottom entrance up to the
##      top gate, tracing the escape route the player is about to follow.
##   3. Sweep the camera down to the player and spawn them in.
##
## On a level RESTART (the "R" key or dying) the intro is skipped: the player
## just spawns straight away. Set intro_enabled = false to disable it always.

@export var intro_enabled := true

## When false, spawning the player does NOT switch to the player's camera —
## the level keeps whatever camera is active (used by the boss fight, which
## wants a fixed wide view of the whole arena).
@export var swap_to_player_camera := true

@onready var player: MainCharacter = $Player
@onready var global_cam: Camera2D = $"../Camera2D"
@onready var player_cam: Camera2D = $Player/Camera2D
@onready var teleporter: ColorRect = $Teleporter


func _ready() -> void:
	global_cam.enabled = true
	player_cam.enabled = false

	# Skip the whole show on a restart, or if disabled for this level.
	if not intro_enabled or SceneManager.consume_intro_skip():
		finish_transition()
		return

	_play_intro()


func _process(delta: float) -> void:
	teleporter.rotation += delta * 10


func _play_intro() -> void:
	# 1. Wide establishing shot of the full level. The level's Camera2D is
	#    authored to frame the whole house, so we just hold on it.
	await get_tree().create_timer(0.9).timeout

	# 2. The bad guy runs from the bottom entrance up to the top gate.
	var finish := get_node_or_null("../FinishArea")
	var start_pos: Vector2 = global_position
	var end_pos: Vector2 = finish.global_position if finish else start_pos - Vector2(0, 640)

	var thief := ColorRect.new()
	thief.color = Color(0.85, 0.12, 0.12)
	thief.size = Vector2(24, 24)
	thief.global_position = start_pos - thief.size / 2.0
	get_parent().add_child(thief)

	var run := create_tween()
	run.tween_property(
		thief, "global_position", end_pos - thief.size / 2.0, 1.7
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await run.finished

	# Slip through the top gate and vanish.
	var vanish := create_tween()
	vanish.set_parallel(true)
	vanish.tween_property(thief, "global_position:y", thief.global_position.y - 70, 0.5)
	vanish.tween_property(thief, "modulate:a", 0.0, 0.5)
	await vanish.finished
	thief.queue_free()

	await get_tree().create_timer(0.3).timeout

	# 3. Sweep down to the player and spawn.
	start_camera_transition()


func start_camera_transition() -> void:
	var destino: Vector2 = player.global_position
	var zoom_final: Vector2 = player_cam.zoom

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		global_cam,
		"global_position",
		destino,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		global_cam,
		"zoom",
		zoom_final,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.chain().tween_callback(finish_transition)


func finish_transition() -> void:
	AudioManager.portal()
	player.exec_spawn_player()
	if swap_to_player_camera:
		global_cam.enabled = false
		player_cam.enabled = true
