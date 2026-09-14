@tool
extends Area2D

const FLOATING_TEXT = preload("uid://du2art0yggjax")

@export var num_collectable: int = -1:
	set(value):
		num_collectable = value
		update_configuration_warnings()

@onready var sfx: AudioStreamPlayer = $SFX


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return

	if Events.collectables[num_collectable]:
		queue_free()


func _physics_process(_delta: float) -> void:
	var time = Time.get_unix_time_from_system()
	position.y = position.y + sin(time * 2) / 6


func create_floating_text() -> void:
	var float_text = FLOATING_TEXT.instantiate()
	float_text.text = "You found note " + str(num_collectable + 1) + ".\nPress E to open notes."
	float_text.global_position = global_position
	add_sibling(float_text)


func _get_configuration_warnings() -> PackedStringArray:
	if num_collectable == -1:
		return ["Collectable number hasn't been set."]
	else:
		return []


func _on_body_entered(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	call_deferred("set_monitoring", false)
	call_deferred("set_visible", false)
	Events.picked_collectable(num_collectable)
	create_floating_text()

	sfx.play()
	await sfx.finished
	queue_free()
