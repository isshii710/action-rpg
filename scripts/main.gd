extends Node3D

## ステージ全体の管理。
## プレイヤーとHUD、敵を接続し、勝敗の判定を行う。

@onready var player: CharacterBody3D = $Player
@onready var hud: CanvasLayer = $HUD

var _enemy_count: int = 0


func _ready() -> void:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	_enemy_count = enemies.size()
	for enemy in enemies:
		enemy.died.connect(_on_enemy_died)

	player.health_changed.connect(hud.update_health)
	player.died.connect(_on_player_died)
	hud.update_health(player.current_health, player.max_health)

	hud.joystick_moved.connect(player.set_move_input)
	hud.look_drag.connect(player.rotate_camera)
	hud.attack_pressed.connect(player.attack)
	hud.retry_pressed.connect(_on_retry_pressed)


func _on_enemy_died() -> void:
	_enemy_count -= 1
	if _enemy_count <= 0:
		hud.show_message("VICTORY!\nすべての敵を倒した！")


func _on_player_died() -> void:
	hud.show_message("GAME OVER")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
