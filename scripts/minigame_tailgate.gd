extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var follow_progress: float = 0.0
var suspicion_meter: float = 0.0
var lost_trail_timer: float = 0.0
var grace_period: float = 0.0

var hud_panel: PanelContainer
var dist_label: Label
var direction_label: Label
var dist_progress: ProgressBar
var suspicion_progress: ProgressBar
var follow_progress_bar: ProgressBar
var status_hint: Label
var close_btn: Button

const MIN_SAFE_DIST = 90.0
const MAX_SAFE_DIST = 260.0
const MAX_TRAIL_DIST = 380.0

var player_ref: CharacterBody2D
var marcus_ref: Node2D
var chatter_player: AudioStreamPlayer

func _ready() -> void:
	layer = 12
	_setup_chatter_audio()
	_build_ui()
	visible = false

func _setup_chatter_audio() -> void:
	if is_instance_valid(chatter_player):
		return
	chatter_player = AudioStreamPlayer.new()
	chatter_player.name = "ChatterPlayer"
	var c_stream = load("res://sound/TALKING (Bg).mp3")
	if c_stream:
		chatter_player.stream = c_stream
		chatter_player.volume_db = -3.0
	add_child(chatter_player)

func start_minigame(p: CharacterBody2D, m: Node2D) -> void:
	if not is_instance_valid(hud_panel):
		_build_ui()
	_setup_chatter_audio()
	if is_instance_valid(chatter_player) and chatter_player.stream and not chatter_player.playing:
		chatter_player.play()
	player_ref = p
	marcus_ref = m
	is_active = true
	visible = true
	follow_progress = 0.0
	suspicion_meter = 0.0
	lost_trail_timer = 0.0
	grace_period = 2.0
	
	if is_instance_valid(player_ref) and "can_move" in player_ref:
		player_ref.can_move = true
	if is_instance_valid(marcus_ref) and marcus_ref.has_method("start_patrol"):
		marcus_ref.start_patrol()

func cancel_minigame() -> void:
	is_active = false
	visible = false
	if is_instance_valid(chatter_player) and chatter_player.playing:
		chatter_player.stop()
	if is_instance_valid(player_ref) and "can_move" in player_ref:
		player_ref.can_move = true
	minigame_completed.emit(false)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		cancel_minigame()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not is_active or not is_instance_valid(player_ref) or not is_instance_valid(marcus_ref):
		return

	var dist = player_ref.global_position.distance_to(marcus_ref.global_position)
	var diff = marcus_ref.global_position - player_ref.global_position
	var angle_deg = rad_to_deg(diff.angle())

	var dir_text = "DEPAN"
	if angle_deg >= -22.5 and angle_deg < 22.5:
		dir_text = "KANAN (Timur)"
	elif angle_deg >= 22.5 and angle_deg < 67.5:
		dir_text = "BAWAH-KANAN (Tenggara)"
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		dir_text = "BAWAH (Selatan)"
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		dir_text = "BAWAH-KIRI (Barat Daya)"
	elif angle_deg >= 157.5 or angle_deg < -157.5:
		dir_text = "KIRI (Barat)"
	elif angle_deg >= -157.5 and angle_deg < -112.5:
		dir_text = "ATAS-KIRI (Barat Laut)"
	elif angle_deg >= -112.5 and angle_deg < -67.5:
		dir_text = "ATAS (Utara)"
	elif angle_deg >= -67.5 and angle_deg < -22.5:
		dir_text = "ATAS-KANAN (Timur Laut)"

	if is_instance_valid(direction_label):
		direction_label.text = "Posisi Marcus: %s" % dir_text

	if is_instance_valid(dist_progress):
		dist_progress.value = clampf(dist, 0.0, MAX_TRAIL_DIST)

	if is_instance_valid(dist_label):
		dist_label.text = "Jarak: %.0f px" % dist

	if dist < MIN_SAFE_DIST:
		if grace_period <= 0.0:
			suspicion_meter += delta * 35.0
		status_hint.text = "TERLALU DEKAT! Marcus mulai menoleh curiga!"
		status_hint.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	elif dist > MAX_SAFE_DIST and dist <= MAX_TRAIL_DIST:
		status_hint.text = "Jarak mulai merenggang... Kejar Marcus!"
		status_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	elif dist > MAX_TRAIL_DIST:
		if grace_period <= 0.0:
			lost_trail_timer += delta
			status_hint.text = "TERLALU JAUH! Kehilangan jejak dalam %.1fs!" % max(0.0, 5.0 - lost_trail_timer)
			status_hint.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
			if lost_trail_timer >= 5.0:
				_fail_minigame("Kehilangan jejak Inspektur Marcus!")
				return
		else:
			status_hint.text = "Mulai menguntit! Dekati posisi Marcus..."
			status_hint.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	else:
		lost_trail_timer = move_toward(lost_trail_timer, 0.0, delta * 2.0)
		suspicion_meter = move_toward(suspicion_meter, 0.0, delta * 15.0)
		follow_progress += delta * 7.5
		status_hint.text = "JARAK AMAN — Menguping obrolan Marcus dan rekannya menuju stasiun..."
		status_hint.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))

	if grace_period > 0.0:
		grace_period -= delta

	if is_instance_valid(suspicion_progress):
		suspicion_progress.value = suspicion_meter
	if is_instance_valid(follow_progress_bar):
		follow_progress_bar.value = follow_progress

	if suspicion_meter >= 100.0:
		_fail_minigame("Marcus memergokimu! Kepanikan terjadi!")
	elif follow_progress >= 100.0:
		_complete_minigame()

func _complete_minigame() -> void:
	is_active = false
	if is_instance_valid(chatter_player) and chatter_player.playing:
		chatter_player.stop()
	status_hint.text = "SUKSES! Obrolan Marcus: 'Korban terakhir menuju Stasiun Kereta Api... periksa peron!'"
	status_hint.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
		inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("police_eavesdrop")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_2_STATION)

	if is_inside_tree() and get_tree():
		await get_tree().create_timer(2.0).timeout
	visible = false
	if is_instance_valid(player_ref) and "can_move" in player_ref:
		player_ref.can_move = true
	minigame_completed.emit(true)

func _fail_minigame(reason: String) -> void:
	is_active = false
	status_hint.text = "GAGAL: " + reason
	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr) and is_inside_tree() and get_tree() and get_tree().root:
		inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.notification_displayed.emit("GAGAL: " + reason + " — Mengulang dari checkpoint!")
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(1.6).timeout
	
	if is_instance_valid(player_ref) and is_instance_valid(marcus_ref):
		# Reposisi pemain di jarak aman di belakang Marcus agar tidak langsung gagal lagi
		player_ref.global_position = marcus_ref.global_position + Vector2(-130, 0)
		if "can_move" in player_ref:
			player_ref.can_move = true

	follow_progress = 0.0
	suspicion_meter = 0.0
	lost_trail_timer = 0.0
	grace_period = 2.5
	is_active = true

func _build_ui() -> void:
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.add_theme_constant_override("margin_left", 260)
	margin.add_theme_constant_override("margin_right", 260)
	margin.add_theme_constant_override("margin_top", 16)
	add_child(margin)

	hud_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.94)
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

	var top_header = HBoxContainer.new()
	vb.add_child(top_header)

	var title = Label.new()
	title.text = "MINI GAME: MENGUNTIT INSPEKTUR MARCUS"
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 14)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "[ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(cancel_minigame)
	top_header.add_child(close_btn)

	var info_hb = HBoxContainer.new()
	vb.add_child(info_hb)

	direction_label = Label.new()
	direction_label.text = "Posisi Marcus: Menghitung..."
	direction_label.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	direction_label.add_theme_font_size_override("font_size", 12)
	direction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_hb.add_child(direction_label)

	status_hint = Label.new()
	status_hint.text = "Jaga jarak di zona hijau (90px - 260px)"
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
	dist_progress.custom_minimum_size = Vector2(180, 16)
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
	suspicion_progress.custom_minimum_size = Vector2(180, 16)
	var sus_fill = StyleBoxFlat.new()
	sus_fill.bg_color = Color(0.9, 0.25, 0.25, 0.9)
	sus_fill.set_corner_radius_all(4)
	suspicion_progress.add_theme_stylebox_override("fill", sus_fill)
	hb2.add_child(suspicion_progress)

	var hb3 = HBoxContainer.new()
	vb.add_child(hb3)

	var prog_lbl = Label.new()
	prog_lbl.text = "Progres Menguping:"
	prog_lbl.add_theme_font_size_override("font_size", 12)
	prog_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb3.add_child(prog_lbl)

	follow_progress_bar = ProgressBar.new()
	follow_progress_bar.max_value = 100
	follow_progress_bar.custom_minimum_size = Vector2(180, 16)
	var prog_fill = StyleBoxFlat.new()
	prog_fill.bg_color = Color(0.2, 0.85, 0.5, 0.9)
	prog_fill.set_corner_radius_all(4)
	follow_progress_bar.add_theme_stylebox_override("fill", prog_fill)
	hb3.add_child(follow_progress_bar)
