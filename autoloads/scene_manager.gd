extends CanvasLayer

## Handles everything that lives "above" individual scenes:
##   - fade-to-black transitions between screens (menu <-> levels)
##   - going to a level by number / reloading the current level ("R")
##   - the pause menu overlay (Esc)
##   - a small on-screen toast used to announce each house's rules
##
## Because this is an autoload it persists across scene changes, so the fade
## overlay covers the gap while the next scene loads (the classic pattern from
## the tutorial you linked).

const MAIN_MENU := "res://menu/main_menu.tscn"
const WIN_SCREEN := "res://menu/win_screen.tscn"
const LEVEL_PATH := "res://levels/level_%d.tscn"
const PAUSE_MENU := preload("res://menu/pause_menu.tscn")

const FADE_TIME := 0.4

# True while a real gameplay level is active (so "R" / Esc only work in-game).
var in_level := false
var current_scene_path := ""

# Set true right before a reload so the level's intro (camera sweep + the
# escaping thief) is skipped on restart. Consumed once by the level.
var skip_next_intro := false

var _fade: ColorRect
var _toast: Label
var _pause_instance: Control = null

var _transitioning := false


func _ready() -> void:
	# Keep working even while the tree is paused (for the pause menu / reset).
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 128 # draw above every level UI

	_build_overlay()


func _unhandled_input(event: InputEvent) -> void:
	if not in_level:
		return
	if event.is_action_pressed("Reset"):
		reload_level()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func change_scene(path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	_clear_pause()
	AudioManager.reset_music_speed()
	await _fade_to_black()
	get_tree().change_scene_to_file(path)
	# Let the new scene run its _ready before we reveal it.
	await get_tree().process_frame
	current_scene_path = path
	await _fade_from_black()
	_transitioning = false


func reload_level() -> void:
	if _transitioning:
		return
	_transitioning = true
	skip_next_intro = true
	_clear_pause()
	AudioManager.reset_music_speed()
	await _fade_to_black()
	get_tree().reload_current_scene()
	await get_tree().process_frame
	await _fade_from_black()
	_transitioning = false


## Returns true (once) if the upcoming level should skip its intro.
func consume_intro_skip() -> bool:
	var skip := skip_next_intro
	skip_next_intro = false
	return skip


func go_to_level(number: int) -> void:
	var path := LEVEL_PATH % number
	if ResourceLoader.exists(path):
		change_scene(path)
	else:
		# No such level -> the player escaped the last house.
		in_level = false
		change_scene(WIN_SCREEN)


func go_to_main_menu() -> void:
	in_level = false
	change_scene(MAIN_MENU)


func start_game() -> void:
	go_to_level(0)


# Called by each level's root script (levels/level.gd) on _ready.
func enter_level(scene_path: String) -> void:
	in_level = true
	current_scene_path = scene_path


# --- Pause --------------------------------------------------------------
func toggle_pause() -> void:
	if _pause_instance:
		_clear_pause()
	else:
		_pause_instance = PAUSE_MENU.instantiate()
		add_child(_pause_instance)
		get_tree().paused = true


# --- Toast (rule announcements) ----------------------------------------
func show_toast(text: String, duration := 2.0) -> void:
	if _toast == null:
		return
	_toast.text = text
	var tween := create_tween()
	tween.tween_property(_toast, "modulate:a", 1.0, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.6)


func _build_overlay() -> void:
	# Full-screen black rectangle used for fades.
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.modulate.a = 0.0
	add_child(_fade)

	# Centered toast label near the top for rule announcements.
	_toast = Label.new()
	_toast.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 42)
	_toast.offset_top = 40
	_toast.offset_bottom = 140
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.modulate.a = 0.0
	add_child(_toast)


# --- Transitions --------------------------------------------------------
func _fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
	await tween.finished


func _fade_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 0.0, FADE_TIME)
	await tween.finished


func _clear_pause() -> void:
	if _pause_instance:
		_pause_instance.queue_free()
		_pause_instance = null
	get_tree().paused = false
