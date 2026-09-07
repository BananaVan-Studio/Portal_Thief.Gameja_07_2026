extends Control

## Controls screen, opened as an overlay from the main menu. Emits `closed`
## when the player backs out.

signal closed


func _ready() -> void:
	var back: Button = $Center/VBox/BackButton
	back.pressed.connect(_on_back)

	UiStyle.paint_dim($Dim)
	UiStyle.title($Center/VBox/Title, 56)
	UiStyle.plain($Center/VBox/Move, 32)
	UiStyle.plain($Center/VBox/Run, 32)
	UiStyle.plain($Center/VBox/Dash, 32)
	UiStyle.subtitle($Center/VBox/Extra, 22)
	UiStyle.button(back)
	back.grab_focus()


func _on_back() -> void:
	AudioManager.back()
	closed.emit()
