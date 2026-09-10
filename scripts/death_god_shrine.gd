extends Node2D

signal interaction_triggered

const CHIBI_TEXTURES = {
	"depan": preload("res://grimChibi/depan.png"),
	"belakang": preload("res://grimChibi/belakang.png"),
	"kiri": preload("res://grimChibi/kiri.png"),
	"kanan": preload("res://grimChibi/kanan.png"),
}

var player_in_range: bool = false
var is_dialog_active: bool = false
var anim_timer: float = 0.0

@onready var prompt_node: Node2D = $PromptBadge
@onready var prompt_label: Label = $PromptBadge/Panel/PromptLabel
@onready var god_figure: Node2D = $Visuals/GodFigure
@onready var ritual_floor: Node2D = $Visuals/RitualFloor
@onready var chibi_sprite: Sprite2D = get_node_or_null("Visuals/GodFigure/ChibiSprite")

func _ready() -> void:
	y_sort_enabled = true
	prompt_node.visible = false
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	anim_timer += delta * 2.5
	
	if is_instance_valid(god_figure):
		god_figure.position.y = -90.0 + sin(anim_timer) * 6.0
	
	if is_instance_valid(ritual_floor):
		var scale_factor = 1.0 + sin(anim_timer * 1.5) * 0.04
		ritual_floor.scale = Vector2(scale_factor, scale_factor)

	# Arahkan pandangan Dewa Kematian chibi menghadap pemain
	_update_chibi_facing()

	if player_in_range and not is_dialog_active and is_instance_valid(prompt_node):
		prompt_node.visible = true
		prompt_node.position.y = -165.0 + sin(anim_timer * 3.0) * 4.0
	else:
		prompt_node.visible = false

func _get_chibi_sprite() -> Sprite2D:
	if not is_instance_valid(chibi_sprite):
		chibi_sprite = get_node_or_null("Visuals/GodFigure/ChibiSprite")
	return chibi_sprite

func _update_chibi_facing() -> void:
	var sprite = _get_chibi_sprite()
	if not is_instance_valid(sprite):
		return
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		var diff = player.global_position - global_position
		if diff.length_squared() < 250000.0: # Dalam jarak 500px
			set_facing_direction(diff)
		else:
			sprite.texture = CHIBI_TEXTURES["depan"]

func set_facing_direction(dir: Vector2) -> void:
	var sprite = _get_chibi_sprite()
	if not is_instance_valid(sprite):
		return
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.texture = CHIBI_TEXTURES["kanan"]
		else:
			sprite.texture = CHIBI_TEXTURES["kiri"]
	else:
		if dir.y > 0:
			sprite.texture = CHIBI_TEXTURES["depan"]
		else:
			sprite.texture = CHIBI_TEXTURES["belakang"]

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
	if is_instance_valid(prompt_node):
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
