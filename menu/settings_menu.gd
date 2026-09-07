extends Control

## Reusable settings panel. Opened as an overlay by the main menu and the
## pause menu. Emits `closed` when the user backs out.

signal closed


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep working while paused

	var master: HSlider = $Center/VBox/MasterRow/MasterSlider
	var music: HSlider = $Center/VBox/MusicRow/MusicSlider
	var sfx: HSlider = $Center/VBox/SfxRow/SfxSlider
	var fullscreen: CheckButton = $Center/VBox/FullscreenRow/FullscreenCheck
	var back: Button = $Center/VBox/BackButton

	master.value = Game.master_volume
	music.value = Game.music_volume
	sfx.value = Game.sfx_volume
	fullscreen.button_pressed = Game.fullscreen

	master.value_changed.connect(func(v: float) -> void: Game.set_master_volume(v))
	music.value_changed.connect(func(v: float) -> void: Game.set_music_volume(v))
	sfx.value_changed.connect(func(v: float) -> void: Game.set_sfx_volume(v))
	sfx.drag_ended.connect(_on_sfx_drag_ended)
	fullscreen.toggled.connect(func(p: bool) -> void: Game.set_fullscreen(p))
	back.pressed.connect(_on_back)

	UiStyle.paint_dim($Dim)
	UiStyle.title($Center/VBox/Title, 60)
	UiStyle.plain($Center/VBox/MasterRow/Label)
	UiStyle.plain($Center/VBox/MusicRow/Label)
	UiStyle.plain($Center/VBox/SfxRow/Label)
	UiStyle.plain($Center/VBox/FullscreenRow/Label)
	UiStyle.button(back)
	back.grab_focus()


func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.advance()  # short blip so you can hear the new SFX level


func _on_back() -> void:
	AudioManager.back()
	closed.emit()
