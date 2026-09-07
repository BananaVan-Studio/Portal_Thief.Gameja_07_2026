extends Area2D

@onready var teleporter: ColorRect = $Teleporter


func _process(delta: float) -> void:
	teleporter.rotation += delta * 10
