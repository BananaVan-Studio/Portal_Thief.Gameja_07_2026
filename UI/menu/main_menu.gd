extends Control

const SETTINGS_MENU = preload("uid://bduoje8alkrc7")
const TUTORIAL = preload("uid://ctujr812lkrc7")


func _ready() -> void:
	SceneManager.in_level = false
	get_tree().paused = false

	var play: Button = $Menu/VBox/PlayButton
	var tutorial: Button = $Menu/VBox/TutorialButton
	var settings: Button = $Menu/VBox/SettingsButton
	var quit: Button = $Menu/VBox/QuitButton

	play.pressed.connect(_on_play)
	tutorial.pressed.connect(_on_tutorial)
	settings.pressed.connect(_on_settings)
	quit.pressed.connect(_on_quit)

	for b in [play, tutorial, settings, quit]:
		UiStyle.button(b)

	play.grab_focus()


func _on_play() -> void:
	Game.reset_coins()
	Game.reset_notes()
	Events.reset_collectables()
	AudioManager.advance()
	SceneManager.start_game()


func _on_tutorial() -> void:
	AudioManager.advance()
	var tutorial := TUTORIAL.instantiate()
	add_child(tutorial)
	tutorial.closed.connect(tutorial.queue_free)


func _on_settings() -> void:
	AudioManager.advance()
	var settings := SETTINGS_MENU.instantiate()
	add_child(settings)
	settings.closed.connect(settings.queue_free)


func _on_quit() -> void:
	AudioManager.back()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
