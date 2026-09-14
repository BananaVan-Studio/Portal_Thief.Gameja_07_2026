extends Area2D

const FLOATING_TEXT = preload("uid://du2art0yggjax")

var current_time: float

@onready var sfx: AudioStreamPlayer = $SFX
@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	current_time = Time.get_unix_time_from_system()
	scale.x = sin(current_time * 2)


func create_floating_text() -> void:
	var float_text = FLOATING_TEXT.instantiate()
	float_text.text = "+1"
	float_text.life_time = 1
	float_text.global_position = global_position
	add_sibling(float_text)


func _on_body_entered(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	sprite.call_deferred("set_visible", false)
	call_deferred("set_monitoring", false)
	body.add_coin_UI()
	create_floating_text()

	sfx.play()
	await sfx.finished
	queue_free()
