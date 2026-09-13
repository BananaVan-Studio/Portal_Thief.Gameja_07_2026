extends Node

signal updating_alarm(value: float)
signal stopping_alarm
signal fading_out
signal fading_in
signal switch_alarms

var collectables: Array[bool] = [
	false,
	false,
	false,
	false,
]


func trigger_switch() -> void:
	switch_alarms.emit()


func update_alarm(value: float) -> void:
	updating_alarm.emit(value)


func stop_alarm() -> void:
	stopping_alarm.emit()


func fade_in() -> void:
	fading_in.emit()


func fade_out() -> void:
	fading_out.emit()
