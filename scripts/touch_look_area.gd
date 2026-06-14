extends Control

## 画面のドラッグでカメラを回転させるための入力エリア。
## 仮想スティックや各ボタンに重なっていない領域のドラッグを検出する。

signal look_drag(delta: Vector2)

var _touch_index: int = -1
var _last_position: Vector2


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1:
				_touch_index = event.index
				_last_position = event.position
		else:
			if event.index == _touch_index:
				_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			var delta: Vector2 = event.position - _last_position
			_last_position = event.position
			look_drag.emit(delta)
