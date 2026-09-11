extends Area2D

var player: MainCharacter = null

@onready var death_margin: Timer = $DeathMargin


func _physics_process(delta: float) -> void:
	if not player:
		return

	if not player.is_dashing and death_margin.is_stopped():
		death_margin.start()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	player = body
	set_physics_process(true)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	death_margin.stop()
	player = null
	set_physics_process(false)


func _on_death_margin_timeout() -> void:
	if player != null:
		player.take_player_control("fall_down")
		set_physics_process(false)
