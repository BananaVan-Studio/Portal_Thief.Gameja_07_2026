@tool
extends BaseLevel


func _on_boss_thief_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	Game.add_coins(player.UI.get_current_coins())
	SceneManager.go_to_level(next_level)


func _on_rot_cloud_body_entered(body: Node2D) -> void:
	if not body is MainCharacter:
		return

	body.take_player_control("get_sick")
