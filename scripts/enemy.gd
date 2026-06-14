extends CharacterBody3D

## 敵キャラクター
## プレイヤーを検知して接近し、近づくと攻撃してくる簡易AI。

signal died

@export var move_speed: float = 3.0
@export var max_health: float = 50.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 1.8
@export var detect_range: float = 9.0
@export var attack_cooldown_time: float = 1.2
@export var rotation_speed: float = 8.0

@onready var model: Node3D = $Model
@onready var hit_flash_mesh: MeshInstance3D = $Model/Body

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_health: float
var is_dead: bool = false
var _attack_cooldown: float = 0.0
var _player: Node3D = null

var _base_material_color: Color
var _flash_timer: float = 0.0


func _ready() -> void:
	current_health = max_health
	_player = get_tree().get_first_node_in_group("player")

	var mat: StandardMaterial3D = hit_flash_mesh.get_surface_override_material(0)
	if mat != null:
		_base_material_color = mat.albedo_color


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta

	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_set_flash(false)

	if _player == null or not is_instance_valid(_player):
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var to_player: Vector3 = _player.global_position - global_position
	to_player.y = 0.0
	var dist: float = to_player.length()

	if dist <= attack_range:
		velocity.x = 0.0
		velocity.z = 0.0
		_face_direction(to_player, delta)
		_try_attack()
	elif dist <= detect_range:
		var dir: Vector3 = to_player.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		_face_direction(to_player, delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 4.0 * delta)

	move_and_slide()


func _face_direction(to_player: Vector3, delta: float) -> void:
	if to_player.length() < 0.01:
		return
	var target_angle: float = atan2(to_player.x, to_player.z)
	model.rotation.y = lerp_angle(model.rotation.y, target_angle, rotation_speed * delta)


func _try_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = attack_cooldown_time
	if _player != null and _player.has_method("take_damage"):
		_player.take_damage(attack_damage)


func take_damage(amount: float) -> void:
	if is_dead:
		return

	current_health = max(current_health - amount, 0.0)
	_set_flash(true)
	_flash_timer = 0.15

	if current_health <= 0.0:
		_die()


func _set_flash(enabled: bool) -> void:
	var mat: StandardMaterial3D = hit_flash_mesh.get_surface_override_material(0)
	if mat == null:
		return
	if enabled:
		mat.albedo_color = Color(1.0, 1.0, 1.0)
	else:
		mat.albedo_color = _base_material_color


func _die() -> void:
	is_dead = true
	died.emit()
	queue_free()
