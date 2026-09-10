class_name Thief
extends StaticBody2D

const PORTAL = preload("uid://sd4adlodp52g")
const STEAL = preload("uid://dwf2vlvn4qio0")
const FALLING_FURNITURE = preload("uid://c8bwma6ffgsyi")

var orders: Array[Node]

@onready var thief_actions: Node2D = $"../ThiefActions"
@onready var sfx: AudioStreamPlayer = $SFX


func _ready() -> void:
	orders = thief_actions.get_children()


func execute_orders_queue() -> void:
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
	var order: Order = orders[idx]
	if order.action == Order.Command.NONE:
		push_error("Order not initialized.")
		return

	match order.action:
		Order.Command.MOVE:
			var tween = create_tween()
			tween.tween_property(self, "global_position", order.global_position, order.execution_time)
			await tween.finished

		Order.Command.WAIT:
			await get_tree().create_timer(order.execution_time).timeout

		Order.Command.ROTATE:
			var tween = create_tween()
			tween.tween_property(self, "rotation_degrees", order.rotation_deg, order.execution_time)
			await tween.finished

		Order.Command.PICK:
			sfx.volume_db = 0
			sfx.stream = STEAL
			sfx.play()
			order.picked_item.queue_free()

		Order.Command.THROW:
			sfx.volume_db = -5
			sfx.stream = FALLING_FURNITURE
			sfx.play()
			order.picked_item.queue_free()
			order.thrown_item.call_deferred("set_visible", true)

		Order.Command.SPAWN:
			order.spawn.call_deferred("set_visible", true)
