extends CanvasLayer

# ── Progressive World Desaturation & Atmosphere Controller (Safe Mode) ──────
# Mengatur saturasi dan atmosfer warna dunia secara dinamis menggunakan modulasi
# warna yang 100% aman untuk semua GPU (Compatibility / Forward+ / WebGL).

var canvas_modulate: CanvasModulate
var current_desat: float = 0.0
var target_desat: float = 0.0

func _ready() -> void:
	# CanvasModulate mempengaruhi seluruh render Node2D di dalam map secara aman
	canvas_modulate = CanvasModulate.new()
	canvas_modulate.name = "WorldAtmosphereModulate"
	canvas_modulate.color = Color(1.0, 1.0, 1.0, 1.0)
	
	# Tambahkan ke parent (Main Scene)
	get_parent().call_deferred("add_child", canvas_modulate)

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.desaturation_updated.connect(_on_desaturation_updated)
		target_desat = inv_mgr.desaturation_level

func _process(delta: float) -> void:
	current_desat = move_toward(current_desat, target_desat, delta * 0.8)
	if is_instance_valid(canvas_modulate):
		# Berpindah dari warna terang normal (1.0, 1.0, 1.0) ke dingin monokromatik (0.75, 0.78, 0.90)
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
		var r = lerpf(1.0, 0.72, current_desat)
		var g = lerpf(1.0, 0.76, current_desat)
		var b = lerpf(1.0, 0.88, current_desat)
		canvas_modulate.color = Color(r, g, b, 1.0)
