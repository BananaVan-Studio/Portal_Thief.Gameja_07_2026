extends Node

## Global game state: the movement "rules" for the current house and the
## user's persistent settings. Each level pushes its own rules here on _ready
## (see levels/level.gd), and the player reads them every physics frame.

# --- Rules ("my house, my rules") ---------------------------------------
var allow_sprint := true
var allow_dash := true

# --- Settings -----------------------------------------------------------
## Master = overall volume. Music and SFX are sub-buses that feed into Master,
## so Master scales both; Music/SFX let the player balance them independently.
var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0
var fullscreen := false


func _ready() -> void:
	set_master_volume(master_volume) # Master bus always exists
	set_fullscreen(fullscreen)

	# Music/SFX buses are created by AudioManager; it applies those once ready.


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
