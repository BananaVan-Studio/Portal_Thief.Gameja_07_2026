extends Area2D

@onready var button: Polygon2D = $Button
@onready var sfx: AudioStreamPlayer = $SFX


func _on_body_entered(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	button.position.x = 1
	sfx.play()
	Events.trigger_switch()
