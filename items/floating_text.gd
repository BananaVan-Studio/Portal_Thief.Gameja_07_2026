extends Label

var life_time: float = 3


func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "position:y", position.y - 30, life_time)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, life_time)
	tween.tween_callback(queue_free).set_delay(life_time)
