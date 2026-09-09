@tool
class_name Order
extends Marker2D

enum Command {
	NONE,
	MOVE,
	STAY,
	ROTATE,
}

@export var index: int = -1:
	set(value):
		index = value
		update_configuration_warnings()
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
@export var previous_order: Order = null:
	set(value):
		previous_order = value
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if action == Command.NONE or execution_time == -1 or index == -1:
		warnings.append("Order not initialized. Some core data is missing.")

	if action == Command.ROTATE and rotation_deg == -1:
		warnings.append("Received rotation order, but rotation_deg was not introduced.")

	if action == Command.STAY:
		if previous_order == null:
			return warnings 

		if previous_order.global_position != global_position:
			warnings.append("Received stay order, but marker is not in the same position as previous order.")

	return warnings
