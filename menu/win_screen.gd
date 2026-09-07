extends Control


func _ready() -> void:
	SceneManager.in_level = false
	get_tree().paused = false

	var menu: Button = $Center/VBox/MenuButton
	menu.pressed.connect(_on_menu)

	UiStyle.paint_bg($BG)
	UiStyle.title($Center/VBox/Title, 80)
	UiStyle.subtitle($Center/VBox/Subtitle)
	UiStyle.button(menu)

	menu.grab_focus()


func _on_menu() -> void:
	AudioManager.back()
	SceneManager.go_to_main_menu()
