extends CharacterBody3D

## プレイヤーキャラクター
## 仮想スティックとカメラドラッグで移動・視点操作を行い、
## 3Dワールド内をTPS視点で動き回る2.5Dアクションのコア。

signal health_changed(current: float, max_health: float)
signal died

@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var jump_velocity: float = 4.5

@export var max_health: float = 100.0
@export var attack_damage: float = 20.0
@export var attack_duration: float = 0.25
@export var attack_cooldown_time: float = 0.5

@export var look_sensitivity: float = 0.005
@export var min_pitch_deg: float = 5.0
@export var max_pitch_deg: float = 65.0

@onready var model: Node3D = $Model
@onready var weapon: MeshInstance3D = $Model/Weapon
@onready var attack_area: Area3D = $Model/AttackArea
@onready var camera_rig: Node3D = $CameraRig
@onready var spring_arm: SpringArm3D = $CameraRig/SpringArm3D
@onready var camera: Camera3D = $CameraRig/SpringArm3D/Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_input: Vector2 = Vector2.ZERO

var is_attacking: bool = false
var _attack_timer: float = 0.0
var _attack_cooldown: float = 0.0

var current_health: float
var is_dead: bool = false

var _weapon_rest_rotation: Vector3


func _ready() -> void:
	current_health = max_health
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	_weapon_rest_rotation = weapon.rotation
	health_changed.emit(current_health, max_health)

	# カメラリグの初期角度をコードから設定する（俯瞰の三人称視点）
	spring_arm.rotation_degrees = Vector3(20.0, 180.0, 0.0)
	camera.rotation_degrees = Vector3(0.0, 180.0, 0.0)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 重力
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	_update_movement(delta)
	move_and_slide()
	_update_attack(delta)


func _update_movement(delta: float) -> void:
	# カメラの向きを基準にした移動方向を計算する
	var cam_basis: Basis = camera.global_transform.basis
	var forward: Vector3 = -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right: Vector3 = cam_basis.x
	right.y = 0.0
	right = right.normalized()

	var direction: Vector3 = forward * (-move_input.y) + right * move_input.x

	if direction.length() > 0.05:
		direction = direction.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

		var target_angle: float = atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 4.0 * delta)


func _update_attack(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta

	if is_attacking:
		_attack_timer -= delta
		var t: float = clamp(1.0 - (_attack_timer / attack_duration), 0.0, 1.0)
		weapon.rotation.x = _weapon_rest_rotation.x + sin(t * PI) * 1.8

		if _attack_timer <= 0.0:
			is_attacking = false
			attack_area.monitoring = false
			weapon.rotation = _weapon_rest_rotation


## 仮想スティックから呼ばれる移動入力 (-1.0 ~ 1.0 の範囲のVector2)
func set_move_input(value: Vector2) -> void:
	move_input = value


## 画面ドラッグによるカメラ操作 (ドラッグの差分ベクトル)
func rotate_camera(delta: Vector2) -> void:
	camera_rig.rotation.y -= delta.x * look_sensitivity

	var pitch: float = spring_arm.rotation.x - delta.y * look_sensitivity
	pitch = clamp(pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
	spring_arm.rotation.x = pitch


## 攻撃ボタンから呼ばれる
func attack() -> void:
	if is_dead or is_attacking or _attack_cooldown > 0.0:
		return

	is_attacking = true
	_attack_timer = attack_duration
	_attack_cooldown = attack_cooldown_time
	attack_area.monitoring = true


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body == self:
		return
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)


func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		_die()


func _die() -> void:
	is_dead = true
	move_input = Vector2.ZERO
	velocity = Vector3.ZERO
	died.emit()
