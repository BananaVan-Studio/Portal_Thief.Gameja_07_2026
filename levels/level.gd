@tool
extends Node2D

## Attach this to the root of every level scene. It's the single place a
## level declares "my house, my rules": just tick the two checkboxes in the
## inspector. The player reads these through the Game autoload.

@export var allow_sprint := true
@export var allow_dash := true
@export var next_level: int = -1:
	set(value):
		next_level = value
		update_configuration_warnings()
## Optional short line shown to the player when the house loads,
## e.g. "This house forbids sprinting."
@export var rule_announcement := ""
@export var intro_enabled := true
@export var swap_to_player_camera := true

@onready var player: MainCharacter = $Player
@onready var player_cam: Camera2D = $Player/PlayerCam
@onready var global_cam: Camera2D = $Base/GlobalCam
@onready var starting_pos: Area2D = $StartingPosition
@onready var finish_area: Area2D = $FinishArea
@onready var initial: Order = $ThiefActions/Initial
@onready var thief: Thief = $Thief
@onready var atrezzo: Node2D = $Atrezzo
@onready var obstacles: Node2D = $Obstacles


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	global_cam.enabled = true
	player_cam.enabled = false
	finish_area.set_visible(false)
	thief.global_position = initial.global_position
	player.global_position = starting_pos.global_position

	if not intro_enabled or SceneManager.consume_intro_skip():
		thief.queue_free()
		finish_transition()
		atrezzo.queue_free()
		finish_area.set_visible(true)

		if obstacles:
			for i in obstacles.get_children():
				i.set_visible(true)

		return

	Game.set_rules(allow_sprint, allow_dash)
	SceneManager.enter_level(scene_file_path)

	var text := rule_announcement
	if text == "":
		text = _auto_rule_text()
	SceneManager.show_toast(text)

	await thief.execute_orders_queue()
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


func _get_configuration_warnings():
	if next_level == 0:
		return ["Next level hasn't been set."]
	else:
		return []


func _auto_rule_text() -> String:
	if not allow_sprint and not allow_dash:
		return "My house, my rules: no sprinting, no dashing."
	if not allow_sprint:
		return "My house, my rules: no sprinting."
	if not allow_dash:
		return "My house, my rules: no dashing."
	return ""


func _on_finish_area_body_entered(body: Node2D) -> void:
	print("Body: ", body.name)
	if not body.is_in_group("Player"):
		return

	AudioManager.portal()
	SceneManager.go_to_level(next_level)
