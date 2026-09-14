@tool
extends BaseLevel

@onready var initial: Order = $ThiefActions/Initial
@onready var thief: Thief = $Thief
@onready var atrezzo: Node2D = $Atrezzo
@onready var obstacles: Node2D = $Obstacles


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	Game.in_level = true
	global_cam.enabled = true
	player_cam.enabled = false
	finish_area.set_visible(false)
	thief.global_position = initial.global_position
	player.global_position = starting_pos.global_position
	player.initialize_coins_UI(coins.get_child_count())

	if not intro_enabled or SceneManager.consume_intro_skip():
		thief.queue_free()
		finish_area.set_visible(true)
		finish_transition()
		atrezzo.queue_free()

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


func _on_finish_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	AudioManager.portal()
	Game.in_level = false
	Game.add_coins(player.UI.get_current_coins())
	if next_level == 4:
		SceneManager.go_to_boss_level()
		return

	SceneManager.go_to_level(next_level)
