extends Node2D

# ── Referensi Node ────────────────────────────────────────────────────────
@onready var player: CharacterBody2D = $Player
@onready var hud_speed_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var hud_pos_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/PosLabel

func _ready() -> void:
	print("Game IPB - Top-Down Movement Playground Siap!")

func _process(_delta: float) -> void:
	# Update telemetry HUD jika ada player
	if is_instance_valid(player) and is_instance_valid(hud_speed_label) and is_instance_valid(hud_pos_label):
		var spd = player.velocity.length()
		hud_speed_label.text = "Kecepatan: %.0f px/s" % spd
		hud_pos_label.text = "Posisi: (X: %.0f, Y: %.0f)" % [player.global_position.x, player.global_position.y]

func _on_reset_btn_pressed() -> void:
	if is_instance_valid(player):
		player.global_position = Vector2(640, 360)
		player.velocity = Vector2.ZERO
