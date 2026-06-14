extends Control

## 仮想スティック
## タッチ/ドラッグした位置に応じて -1.0 ~ 1.0 のVector2を発行する。

signal joystick_moved(value: Vector2)

@export var max_distance: float = 60.0

@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob

var _touch_index: int = -1
var _center: Vector2
var _knob_rest_position: Vector2


func _ready() -> void:
	_center = base.size * 0.5
	_knob_rest_position = knob.position


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1:
				_touch_index = event.index
				_update_knob(event.position)
		else:
			if event.index == _touch_index:
				_touch_index = -1
				_reset_knob()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_knob(event.position)


func _update_knob(local_pos: Vector2) -> void:
	var offset: Vector2 = local_pos - _center
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance

	knob.position = _knob_rest_position + offset

	var value: Vector2 = offset / max_distance
	joystick_moved.emit(value)


func _reset_knob() -> void:
	knob.position = _knob_rest_position
	joystick_moved.emit(Vector2.ZERO)
