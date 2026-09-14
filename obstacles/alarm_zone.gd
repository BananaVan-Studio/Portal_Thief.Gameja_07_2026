@tool
extends Area2D

@export var caught_margin: float = 100:
	set(value):
		caught_margin = value
		if is_instance_valid(alarm_timer):
			alarm_timer.wait_time = value
		update_configuration_warnings()
@export var detect_sprint: bool = false

var player: MainCharacter = null

@onready var alarm_timer: Timer = $AlarmTimer
@onready var col_shape: CollisionPolygon2D = $CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $Polygon2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Events.switch_alarms.connect(_on_switch_alarms)
	polygon_2d.polygon = col_shape.polygon
	polygon_2d.position = col_shape.position
	if detect_sprint:
		polygon_2d.color = Color(Color.GOLD, 0.25)


func _process(_delta: float) -> void:
	if not player:
		return

	Events.update_alarm(alarm_timer.time_left)

	if player.is_dashing:
		player._on_dash_timer_timeout()
		alarm_triggered("caught_alarm")
		alarm_timer.stop()

	if not detect_sprint:
		return

	if player.is_sprinting:
		player.is_sprinting = false
		alarm_triggered("caught_alarm_slow")
		alarm_timer.stop()


func alarm_triggered(reason: String) -> void:
	AudioManager.alarm_siren()
	player.take_player_control(reason)


func _on_switch_alarms() -> void:
	detect_sprint = !detect_sprint
	if detect_sprint:
		polygon_2d.color = Color(Color.GOLD, 0.25)
	else:
		polygon_2d.color = Color(Color.RED, 0.25)


func _get_configuration_warnings() -> PackedStringArray:
	if caught_margin == 100:
		return ["Alarm time hasn't been set."]
	else:
		return []


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	alarm_timer.start()
	player = body
	AudioManager.alarm_enter()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	alarm_timer.stop()
	player = null
	Events.stop_alarm()
	AudioManager.alarm_exit()


func _on_alarm_timer_timeout() -> void:
	AudioManager.alarm_siren()
	player.take_player_control("alarm_time_off")
