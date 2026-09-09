class_name Thief
extends StaticBody2D

var orders: Array[Node]

@onready var thief_actions: Node2D = $"../ThiefActions"
@onready var sfx: AudioStreamPlayer = $SFX
const PORTAL = preload("uid://sd4adlodp52g")
const STEAL = preload("uid://dwf2vlvn4qio0")


func _ready() -> void:
	orders = thief_actions.get_children()


func execute_orders_queue() -> void:
	sfx.volume_db = 10
	sfx.stream = PORTAL
	sfx.play()
	if not orders.size():
		push_error("Orders not initialized.")
		return

	for idx in range(orders.size()):
		await execute_order(idx)
	await vanish_animation()


func vanish_animation() -> void:
	var vanish := create_tween()
	vanish.set_parallel(true)
	vanish.tween_property(self, "global_position:y", global_position.y - 70, 0.5)
	vanish.tween_property(self, "modulate:a", 0.0, 0.5)
	sfx.volume_db = 10
	sfx.stream = PORTAL
	sfx.play()
	await sfx.finished
	queue_free()


func execute_order(idx: int) -> void:
	if orders[idx].action == Order.Command.NONE:
		push_error("Order not initialized.")
		return

	match orders[idx].action:
		Order.Command.MOVE:
			var tween = create_tween()
			tween.tween_property(self, "global_position", orders[idx].global_position, orders[idx].execution_time)
			await tween.finished

		Order.Command.WAIT:
			await get_tree().create_timer(orders[idx].execution_time).timeout

		Order.Command.ROTATE:
			var tween = create_tween()
			tween.tween_property(self, "rotation_degrees", orders[idx].rotation_deg, orders[idx].execution_time)
			await tween.finished

		Order.Command.PICK:
			sfx.volume_db = 0
			sfx.stream = STEAL
			sfx.play()
			orders[idx].picked_item.queue_free()

		Order.Command.SPAWN:
			orders[idx].thrown_item.set_visible(true)
