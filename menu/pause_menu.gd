extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var resume: Button = $Center/VBox/ResumeButton
	var restart: Button = $Center/VBox/RestartButton
	var settings: Button = $Center/VBox/SettingsButton
	var menu: Button = $Center/VBox/MenuButton

	resume.pressed.connect(_on_resume)
	restart.pressed.connect(_on_restart)
	settings.pressed.connect(_on_settings)
	menu.pressed.connect(_on_menu)

	UiStyle.paint_dim($Dim)
	UiStyle.title($Center/VBox/Title, 60)
	for b in [resume, restart, settings, menu]:
		UiStyle.button(b)

	resume.grab_focus()


func _on_resume() -> void:
	AudioManager.back()
	SceneManager.toggle_pause()


func _on_restart() -> void:
	AudioManager.back()
	SceneManager.reload_level()


func _on_settings() -> void:
	AudioManager.advance()
	var settings := preload("res://menu/settings_menu.tscn").instantiate()
	add_child(settings)
	settings.closed.connect(settings.queue_free)


func _on_menu() -> void:
	AudioManager.back()
	SceneManager.go_to_main_menu()
