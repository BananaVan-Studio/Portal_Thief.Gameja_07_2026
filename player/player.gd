class_name MainCharacter
extends CharacterBody2D

@export var SPEED := 175.0
@export var SPRINT_SPEED := 350.0

@export var DASH_SPEED := 700.0
@export var DASH_DURATION := 0.15

var is_dashing := false
var dash_direction := Vector2.ZERO

## Extra velocity applied by outside forces (the boss walls). Set from outside
## each physics frame; added into the player's own velocity so the shove reads
## as smooth wind rather than a positional jolt.
var external_push := Vector2.ZERO

@onready var dash_timer: Timer = $DashTimer
@onready var dash_wait_time: Timer = $DashWaitTime
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $PlayerCam
@onready var UI: UserInterface = $UI
@onready var sprite: ColorRect = $ColorRect


func _ready() -> void:
	visible = false
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		# Wall shove still applies mid-dash, so a dash can't punch through a wall.
		if external_push != Vector2.ZERO:
			move_and_collide(external_push * delta)
		return

	var wants_sprint := Game.allow_sprint and Input.is_action_pressed("Sprint")
	var speed := SPRINT_SPEED if wants_sprint else SPEED

	if Game.allow_sprint and Input.is_action_just_pressed("Sprint"):
		AudioManager.run()

	var direction := Input.get_vector(
		"Left",
		"Right",
		"Up",
		"Down"
	)

	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed / 7.5)

	if direction.y <= -0.7:
		camera_2d.drag_vertical_offset = -1
	elif direction.y >= 0.7:
		camera_2d.drag_vertical_offset = 1

	if Game.allow_dash and Input.is_action_just_pressed("Dash") and dash_wait_time.is_stopped():
		dash_wait_time.start()
		start_dash(direction)

	move_and_slide()

	# Outside forces (boss walls) move the body directly, never through velocity,
	# so the shove can't build up frame over frame (that caused the fly-away).
	if external_push != Vector2.ZERO:
		move_and_collide(external_push * delta)


func start_dash(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	if direction.x:
		sprite.scale = Vector2(1.3, 0.7)
	else:
		sprite.scale = Vector2(0.7, 1.3)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1)

	dash_direction = direction.normalized()
	is_dashing = true
	AudioManager.dash()

	dash_timer.start()


func exec_spawn_player() -> void:
	anim_player.play("spawn_player")


func give_player_control() -> void:
	set_physics_process(true)


func take_player_control(animation: String) -> void:
	set_physics_process(false)
	anim_player.play(animation)
	await anim_player.animation_finished


func game_over() -> void:
	await UI.game_over_popup()
	SceneManager.reload_level()


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity = Vector2.ZERO
