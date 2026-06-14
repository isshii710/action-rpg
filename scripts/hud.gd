extends CanvasLayer

## ゲーム画面のUI全体を管理する。
## 仮想スティック / カメラ操作 / 攻撃ボタン / HPバー / リザルト表示。

signal joystick_moved(value: Vector2)
signal look_drag(delta: Vector2)
signal attack_pressed
signal retry_pressed

@onready var root: Control = $Root
@onready var joystick: Control = $Root/VirtualJoystick
@onready var attack_button: Button = $Root/AttackButton
@onready var health_bar: ProgressBar = $Root/HealthBarContainer/HealthBar
@onready var message_layer: Control = $Root/MessageLayer
@onready var message_label: Label = $Root/MessageLayer/Panel/VBoxContainer/MessageLabel
@onready var retry_button: Button = $Root/MessageLayer/Panel/VBoxContainer/RetryButton


func _ready() -> void:
	joystick.joystick_moved.connect(func(value: Vector2) -> void: joystick_moved.emit(value))
	root.look_drag.connect(func(delta: Vector2) -> void: look_drag.emit(delta))
	attack_button.pressed.connect(func() -> void: attack_pressed.emit())
	retry_button.pressed.connect(func() -> void: retry_pressed.emit())
	message_layer.visible = false


func update_health(current: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current


func show_message(text: String) -> void:
	message_label.text = text
	message_layer.visible = true
