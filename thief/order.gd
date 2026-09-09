@tool
class_name Order
extends Marker2D

enum Command {
	NONE,
	MOVE,
	WAIT,
	ROTATE,
	PICK,
	SPAWN,
}

@export var action: Command = Command.NONE:
	set(value):
		action = value
		update_configuration_warnings()
@export var execution_time: float = -1:
	set(value):
		execution_time = value
		update_configuration_warnings()
@export var rotation_deg: float = -1:
	set(value):
		rotation_deg = value
		update_configuration_warnings()
@export var picked_item: Sprite2D = null:
	set(value):
		picked_item = value
		update_configuration_warnings()
@export var thrown_item: Node2D = null:
	set(value):
		thrown_item = value
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	match action:
		Command.ROTATE:
			if rotation_deg == -1:
				warnings.append("Received rotation order, but rotation_deg was not introduced.")
			if execution_time == -1:
				warnings.append("Order duration not initialized.")
		Command.MOVE:
			if execution_time == -1:
				warnings.append("Order duration not initialized.")
		Command.WAIT:
			if execution_time == -1:
				warnings.append("Order duration not initialized.")
		Command.PICK:
			if not picked_item:
				warnings.append("Received pick item order, but item was not selected.")
		Command.SPAWN:
			if not thrown_item:
				warnings.append("Received throw item order, but item was not selected.")
		_:
			warnings.append("Order not initialized. Some core data is missing.")

	return warnings
