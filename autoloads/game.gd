extends Node

const NOTES = preload("uid://c4ryf1iguxsr4")

var allow_sprint := true
var allow_dash := true

var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0
var fullscreen := false
var in_level: bool = false

var current_coins: int = 0
var notes: Notes
var open_notes: bool = false


func _ready() -> void:
	set_master_volume(master_volume) # Master bus always exists
	set_fullscreen(fullscreen)
	process_mode = Node.PROCESS_MODE_ALWAYS
	notes = NOTES.instantiate()
	add_child(notes)


func _unhandled_input(event: InputEvent) -> void:
	if not in_level:
		return

	if SceneManager._pause_instance:
		return

	if event.is_action_pressed("Action"):
		get_tree().paused = !get_tree().paused
		notes.call_deferred("set_visible", get_tree().paused)
		open_notes = get_tree().paused


func hide_notes() -> void:
	notes.call_deferred("set_visible", false)


func reset_notes() -> void:
	notes.reset_buttons()


func reset_coins() -> void:
	current_coins = 0


func add_coins(new_qtt: int) -> void:
	current_coins += new_qtt


func set_rules(sprint: bool, dash: bool) -> void:
	allow_sprint = sprint
	allow_dash = dash


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_bus("Master", master_volume)


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_bus("Music", music_volume)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_bus("SFX", sfx_volume)


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_bus(bus_name: String, value: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	if bus == -1:
		return # bus not created yet (AudioManager will re-apply)
	if value <= 0.0:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))
