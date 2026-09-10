extends CanvasLayer

var canvas_modulate: CanvasModulate
var current_desat: float = 0.0
var target_desat: float = 0.0

@export var is_night_mode: bool = false

func _ready() -> void:
	canvas_modulate = CanvasModulate.new()
	canvas_modulate.name = "WorldAtmosphereModulate"
	if is_night_mode:
		canvas_modulate.color = Color(0.22, 0.24, 0.38, 1.0)
	else:
		canvas_modulate.color = Color(1.0, 1.0, 1.0, 1.0)
	
	get_parent().call_deferred("add_child", canvas_modulate)

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.desaturation_updated.connect(_on_desaturation_updated)
		target_desat = inv_mgr.desaturation_level

func _process(delta: float) -> void:
	current_desat = move_toward(current_desat, target_desat, delta * 0.8)
	if is_instance_valid(canvas_modulate):
		if is_night_mode:
			# Rona malam detektif noir: dasar Color(0.22, 0.24, 0.38) dengan atmosfer misteri
			var r = lerpf(0.22, 0.16, current_desat)
			var g = lerpf(0.24, 0.17, current_desat)
			var b = lerpf(0.38, 0.26, current_desat)
			canvas_modulate.color = Color(r, g, b, 1.0)
		else:
			var r = lerpf(1.0, 0.72, current_desat)
			var g = lerpf(1.0, 0.76, current_desat)
			var b = lerpf(1.0, 0.88, current_desat)
			canvas_modulate.color = Color(r, g, b, 1.0)

func _on_desaturation_updated(amount: float) -> void:
	target_desat = amount

func set_desaturation_instant(amount: float) -> void:
	target_desat = amount
	current_desat = amount
	if is_instance_valid(canvas_modulate):
		if is_night_mode:
			var r = lerpf(0.22, 0.16, current_desat)
			var g = lerpf(0.24, 0.17, current_desat)
			var b = lerpf(0.38, 0.26, current_desat)
			canvas_modulate.color = Color(r, g, b, 1.0)
		else:
			var r = lerpf(1.0, 0.72, current_desat)
			var g = lerpf(1.0, 0.76, current_desat)
			var b = lerpf(1.0, 0.88, current_desat)
			canvas_modulate.color = Color(r, g, b, 1.0)
