extends Control

@onready var completion: Label = $Center/VBox/Completion


func _ready() -> void:
	SceneManager.in_level = false
	get_tree().paused = false

	var menu: Button = $Center/VBox/MenuButton
	menu.pressed.connect(_on_menu)

	UiStyle.paint_bg($BG)
	UiStyle.title($Center/VBox/Title, 80)
	UiStyle.subtitle($Center/VBox/Subtitle)
	UiStyle.subtitle($Center/VBox/Completion)
	UiStyle.button(menu)

	print("Current coins: ", Game.current_coins)
	var percentage: float = snapped(Game.current_coins / 42.0 * 100, 0.01)
	completion.text = "You completed the game picking " + str(percentage) + "% of the coins!"
	menu.grab_focus()


func _on_menu() -> void:
	AudioManager.back()
	SceneManager.go_to_main_menu()
