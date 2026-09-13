extends Area2D

var current_time: float

@onready var sfx: AudioStreamPlayer = $SFX
@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	current_time = Time.get_unix_time_from_system()
	scale.x = sin(current_time * 2)


func _on_body_entered(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	body.add_coin_UI()
	sprite.call_deferred("set_visible", false)
	call_deferred("set_monitoring", false)
	sfx.play()
	await sfx.finished
	queue_free()
