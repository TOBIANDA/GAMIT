extends Node2D

# ── Referensi Node ────────────────────────────────────────────────────────
@onready var player: CharacterBody2D = $Player
@onready var shrine: Node2D = $DeathGodShrine
@onready var dialog_box: CanvasLayer = $DialogBox
@onready var hud_speed_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var hud_pos_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/PosLabel

func _ready() -> void:
	print("Game IPB - Top-Down 3/4 View & Death God Shrine Siap!")

	# Fallback pencarian shrine jika berada di child lain
	if not is_instance_valid(shrine):
		shrine = get_node_or_null("Environment/DeathGodShrine")
	if not is_instance_valid(shrine):
		shrine = find_child("DeathGodShrine", true, false)

	# Hubungkan sinyal interaksi kuil dan dialog box
	if is_instance_valid(shrine):
		if not shrine.interaction_triggered.is_connected(_on_shrine_interacted):
			shrine.interaction_triggered.connect(_on_shrine_interacted)
			print("[Main] Sinyal DeathGodShrine terhubung!")
	else:
		printerr("[Main] ERROR: DeathGodShrine tidak ditemukan!")

	if is_instance_valid(dialog_box):
		if not dialog_box.dialog_opened.is_connected(_on_dialog_opened):
			dialog_box.dialog_opened.connect(_on_dialog_opened)
		if not dialog_box.dialog_closed.is_connected(_on_dialog_closed):
			dialog_box.dialog_closed.connect(_on_dialog_closed)

func _process(_delta: float) -> void:
	# Update telemetry HUD jika ada player
	if is_instance_valid(player) and is_instance_valid(hud_speed_label) and is_instance_valid(hud_pos_label):
		var spd = player.velocity.length()
		hud_speed_label.text = "Kecepatan: %.0f px/s" % spd
		hud_pos_label.text = "Posisi: (X: %.0f, Y: %.0f)" % [player.global_position.x, player.global_position.y]

func _on_shrine_interacted() -> void:
	print("[Main] Percakapan dengan Dewa Kematian dimulai...")
	if is_instance_valid(dialog_box):
		dialog_box.open_dialog()

func _on_dialog_opened() -> void:
	if is_instance_valid(player):
		player.can_move = false

func _on_dialog_closed() -> void:
	if is_instance_valid(player):
		player.can_move = true

func _on_reset_btn_pressed() -> void:
	if is_instance_valid(player):
		player.global_position = Vector2(640, 500)
		player.velocity = Vector2.ZERO
