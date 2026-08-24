extends CanvasLayer

# ── Mini Game 1: Tailgating Marcus (Sesuai GDD) ─────────────────────────────
# Benedict harus menguntit Inspektur Marcus tanpa terlalu dekat (<80px)
# dan tidak boleh terlalu jauh (>320px) sembari menghindari kerumunan warga.

signal minigame_completed(success: bool)

var is_active: bool = false
var follow_progress: float = 0.0
var suspicion_meter: float = 0.0
var lost_trail_timer: float = 0.0

var hud_panel: PanelContainer
var dist_label: Label
var dist_progress: ProgressBar
var suspicion_progress: ProgressBar
var follow_progress_bar: ProgressBar
var status_hint: Label

# Target distance
const MIN_SAFE_DIST = 90.0
const MAX_SAFE_DIST = 260.0
const MAX_TRAIL_DIST = 380.0

var player_ref: CharacterBody2D
var marcus_ref: Node2D

func _ready() -> void:
	layer = 12
	_build_ui()
	visible = false

func start_minigame(p: CharacterBody2D, m: Node2D) -> void:
	player_ref = p
	marcus_ref = m
	is_active = true
	visible = true
	follow_progress = 0.0
	suspicion_meter = 0.0
	lost_trail_timer = 0.0

func _process(delta: float) -> void:
	if not is_active or not is_instance_valid(player_ref) or not is_instance_valid(marcus_ref):
		return

	var dist = player_ref.global_position.distance_to(marcus_ref.global_position)
	
	# Update Distance Meter UI
	if is_instance_valid(dist_progress):
		dist_progress.value = clampf(dist, 0.0, MAX_TRAIL_DIST)
	
	if dist < MIN_SAFE_DIST:
		# Terlalu Dekat! Marcus curiga
		suspicion_meter += delta * 35.0
		status_hint.text = "⚠️ TERLALU DEKAT! Marcus mulai curiga!"
		status_hint.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	elif dist > MAX_SAFE_DIST and dist <= MAX_TRAIL_DIST:
		# Agak Jauh
		status_hint.text = "⚡ Jarak mulai merenggang... Dekati Marcus!"
		status_hint.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	elif dist > MAX_TRAIL_DIST:
		# Terlalu Jauh! Jejak hilang
		lost_trail_timer += delta
		status_hint.text = "🚨 TERLALU JAUH! Kehilangan jejak dalam %.1fs!" % (5.0 - lost_trail_timer)
		status_hint.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		if lost_trail_timer >= 5.0:
			_fail_minigame("Kehilangan jejak Inspektur Marcus!")
			return
	else:
		# Zona Aman! Progress naik
		lost_trail_timer = move_toward(lost_trail_timer, 0.0, delta * 2.0)
		suspicion_meter = move_toward(suspicion_meter, 0.0, delta * 15.0)
		follow_progress += delta * 6.5 # ~15 detik untuk selesai
		status_hint.text = "✔ JARAK AMAN — Menguping rute Marcus..."
		status_hint.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))

	if is_instance_valid(dist_label):
		dist_label.text = "Jarak ke Marcus: %.0f px" % dist
	if is_instance_valid(suspicion_progress):
		suspicion_progress.value = suspicion_meter
	if is_instance_valid(follow_progress_bar):
		follow_progress_bar.value = follow_progress

	# Cek Kalah / Menang
	if suspicion_meter >= 100.0:
		_fail_minigame("Marcus memergokimu! Kepanikan terjadi!")
	elif follow_progress >= 100.0:
		_complete_minigame()

func _complete_minigame() -> void:
	is_active = false
	visible = false
	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("police_eavesdrop")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_2_STATION)
	minigame_completed.emit(true)

func _fail_minigame(reason: String) -> void:
	is_active = false
	status_hint.text = "❌ GAGAL: " + reason
	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.notification_displayed.emit("❌ GAGAL: " + reason + " — Mengulang dari checkpoint!")
	await get_tree().create_timer(1.5).timeout
	follow_progress = 0.0
	suspicion_meter = 0.0
	lost_trail_timer = 0.0
	is_active = true

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.add_theme_constant_override("margin_left", 300)
	margin.add_theme_constant_override("margin_right", 300)
	margin.add_theme_constant_override("margin_top", 20)
	add_child(margin)

	hud_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.92)
	style.border_color = Color(0.3, 0.7, 1.0, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	hud_panel.add_theme_stylebox_override("panel", style)
	margin.add_child(hud_panel)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	hud_panel.add_child(vb)

	var title = Label.new()
	title.text = "🕵️ MINI GAME: MENGUNTIT INSPEKTUR MARCUS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 14)
	vb.add_child(title)

	status_hint = Label.new()
	status_hint.text = "Jaga jarak di zona hijau (100px - 260px)"
	status_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_hint.add_theme_font_size_override("font_size", 12)
	vb.add_child(status_hint)

	var hb = HBoxContainer.new()
	vb.add_child(hb)

	dist_label = Label.new()
	dist_label.text = "Jarak: 0 px"
	dist_label.add_theme_font_size_override("font_size", 12)
	dist_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(dist_label)

	dist_progress = ProgressBar.new()
	dist_progress.max_value = MAX_TRAIL_DIST
	dist_progress.custom_minimum_size = Vector2(160, 16)
	hb.add_child(dist_progress)

	var hb2 = HBoxContainer.new()
	vb.add_child(hb2)

	var sus_lbl = Label.new()
	sus_lbl.text = "Kecurigaan Marcus:"
	sus_lbl.add_theme_font_size_override("font_size", 12)
	sus_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb2.add_child(sus_lbl)

	suspicion_progress = ProgressBar.new()
	suspicion_progress.max_value = 100
	suspicion_progress.custom_minimum_size = Vector2(160, 16)
	hb2.add_child(suspicion_progress)

	var hb3 = HBoxContainer.new()
	vb.add_child(hb3)

	var prog_lbl = Label.new()
	prog_lbl.text = "Progres Menguntit:"
	prog_lbl.add_theme_font_size_override("font_size", 12)
	prog_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb3.add_child(prog_lbl)

	follow_progress_bar = ProgressBar.new()
	follow_progress_bar.max_value = 100
	follow_progress_bar.custom_minimum_size = Vector2(160, 16)
	hb3.add_child(follow_progress_bar)
