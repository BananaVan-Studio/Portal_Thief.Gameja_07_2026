@tool
extends Area2D

## Values starting from 1 onwards. 0 is the base level, so it shouldn't be used.
@export var next_level: int = 0:
	set(value):
		next_level = value
		update_configuration_warnings()

@onready var teleporter: ColorRect = $Teleporter


func _process(delta: float) -> void:
	teleporter.rotation += delta * 10


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	AudioManager.portal()
	SceneManager.go_to_level(next_level)


func _get_configuration_warnings():
	if next_level == 0:
		return ["Next level hasn't been set."]
	else:
		return []
