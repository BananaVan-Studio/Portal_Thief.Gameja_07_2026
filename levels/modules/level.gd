@tool
extends Node2D

## Attach this to the root of every level scene. It's the single place a
## level declares "my house, my rules": just tick the two checkboxes in the
## inspector. The player reads these through the Game autoload.

@export var allow_sprint := true
@export var allow_dash := true
@export var next_level: int = 0:
	set(value):
		next_level = value
		update_configuration_warnings()
## Optional short line shown to the player when the house loads,
## e.g. "This house forbids sprinting."
@export var rule_announcement := ""


func _ready() -> void:
	Game.set_rules(allow_sprint, allow_dash)
	SceneManager.enter_level(scene_file_path)

	var text := rule_announcement
	if text == "":
		text = _auto_rule_text()
	SceneManager.show_toast(text)


func _get_configuration_warnings():
	if next_level == 0:
		return ["Next level hasn't been set."]
	else:
		return []


func _auto_rule_text() -> String:
	if not allow_sprint and not allow_dash:
		return "My house, my rules: no sprinting, no dashing."
	if not allow_sprint:
		return "My house, my rules: no sprinting."
	if not allow_dash:
		return "My house, my rules: no dashing."
	return ""


func _on_finish_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	AudioManager.portal()
	SceneManager.go_to_level(next_level)
