extends Node2D

signal interaction_triggered

# ── Status Interaksi ───────────────────────────────────────────────────────
var player_in_range: bool = false
var anim_timer: float = 0.0

# ── Node References ────────────────────────────────────────────────────────
@onready var prompt_node: Node2D = $PromptBadge
@onready var prompt_label: Label = $PromptBadge/Panel/PromptLabel
@onready var god_figure: Node2D = $Visuals/GodFigure
@onready var ritual_floor: Node2D = $Visuals/RitualFloor

func _ready() -> void:
	y_sort_enabled = true
	prompt_node.visible = false
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	anim_timer += delta * 2.5
	
	# Animasi melayang (hovering) Dewa Kematian
	if is_instance_valid(god_figure):
		god_figure.position.y = -90.0 + sin(anim_timer) * 6.0
	
	# Animasi berdenyut ritual floor
	if is_instance_valid(ritual_floor):
		var scale_factor = 1.0 + sin(anim_timer * 1.5) * 0.04
		ritual_floor.scale = Vector2(scale_factor, scale_factor)

	# Animasi bounce pada prompt badge
	if player_in_range and is_instance_valid(prompt_node):
		prompt_node.position.y = -165.0 + sin(anim_timer * 3.0) * 4.0

func _input(event: InputEvent) -> void:
	if not player_in_range:
		return

	# Deteksi tombol E atau Enter
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_E or event.keycode == KEY_ENTER:
			print("[DeathGodShrine] Tombol interaksi ditekan!")
			interaction_triggered.emit()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		print("[DeathGodShrine] Action ui_accept diterima!")
		interaction_triggered.emit()
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		print("[DeathGodShrine] Pemain masuk area kuil!")
		player_in_range = true
		prompt_node.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		print("[DeathGodShrine] Pemain keluar area kuil.")
		player_in_range = false
		prompt_node.visible = false
