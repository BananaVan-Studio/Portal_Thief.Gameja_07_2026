class_name Order
extends Marker2D

enum Command {
	NONE,
	MOVE,
	STAY,
	ROTATE,
}

@export var index: int = -1
@export var action: Command = Command.NONE
@export var execution_time: float = -1
@export var time_until_next_order: float = -1
@export var rotation_deg: float = -1
