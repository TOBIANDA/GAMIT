extends Node2D

signal interaction_triggered

# ── Status Interaksi ───────────────────────────────────────────────────────
var player_in_range: bool = false
var is_dialog_active: bool = false
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

	# Animasi bounce pada prompt badge (hanya jika dialog sedang tidak aktif)
	if player_in_range and not is_dialog_active and is_instance_valid(prompt_node):
		prompt_node.visible = true
		prompt_node.position.y = -165.0 + sin(anim_timer * 3.0) * 4.0
	else:
		prompt_node.visible = false

# Gunakan _unhandled_input agar tombol E yang diketik di LineEdit TIDAK ditangkap di sini
func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or is_dialog_active:
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_E:
			print("[DeathGodShrine] Tombol E ditekan di dunia game!")
			interaction_triggered.emit()
			get_viewport().set_input_as_handled()

func set_dialog_active(active: bool) -> void:
	is_dialog_active = active
	if is_dialog_active:
		prompt_node.visible = false
	elif player_in_range:
		prompt_node.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		player_in_range = true
		if not is_dialog_active:
			prompt_node.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		player_in_range = false
		prompt_node.visible = false
