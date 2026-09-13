class_name UserInterface
extends CanvasLayer

var time_tween: Tween
var current_coins: int = 0
var max_coins: int = 0

@onready var alarm_popup: RichTextLabel = $AlarmPopUp
@onready var black_fade: ColorRect = $BlackFade
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var death_label: RichTextLabel = $DeathLabel

@onready var coins_label: Label = $MarginContainer/HBoxContainer/CoinsLabel


func _ready() -> void:
	black_fade.modulate = Color.TRANSPARENT
	black_fade.visible = true
	alarm_popup.modulate = Color.TRANSPARENT
	alarm_popup.visible = true
	death_label.modulate = Color.TRANSPARENT
	death_label.visible = true

	Events.connect("updating_alarm", _updating_alarm)
	Events.connect("stopping_alarm", _stopping_alarm)
	Events.connect("fading_out", _fading_out)
	Events.connect("fading_in", _fading_in)


func update_coins() -> void:
	coins_label.text = str(current_coins) + "/" + str(max_coins)


func initialize_coins(new_max: int) -> void:
	current_coins = 0
	max_coins = new_max
	update_coins()


func add_coin() -> void:
	current_coins += 1
	update_coins()


func get_current_coins() -> int:
	return current_coins


func game_over_popup() -> void:
	alarm_popup.visible = false
	var tween = create_tween()
	tween.tween_property(black_fade, "modulate", Color(1, 1, 1, 0.6), 0.5)
	tween.tween_property(death_label, "modulate", Color.WHITE, 1)
	await get_tree().create_timer(2.5).timeout


func _fading_out() -> void:
	anim_player.play("fade_out")


func _fading_in() -> void:
	anim_player.play("fade_in")


func _updating_alarm(value: float) -> void:
	if time_tween:
		time_tween.kill()
	alarm_popup.modulate = Color.WHITE
	alarm_popup.text = "Alarm triggers in " + str(snapped(value, 0.1)) + " seconds."


func _stopping_alarm() -> void:
	alarm_popup.text = "The alarm went down."
	time_tween = create_tween()
	time_tween.tween_property(alarm_popup, "modulate", Color.TRANSPARENT, 1.0)
