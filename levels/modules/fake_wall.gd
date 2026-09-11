extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)


func _on_body_exited(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
