extends CanvasLayer

# ── Mini Game 3: Forensic Cleaning & Cuci Foto Kamar Gelap (Sesuai GDD) ─────
# Kontrol:
# - Merendam foto: Klik dan TAHAN tombol kiri mouse (Hold Left Click)
# - Membilas foto: QTE (Tekan tombol keyboard yang muncul dalam batas waktu singkat)

signal minigame_completed(success: bool)

var is_active: bool = false
var current_step: int = 0 # 0: Rendam Foto, 1: Bilas QTE Foto, 2: Hasil Foto Terungkap

var soak_progress: float = 0.0
var is_mouse_holding: bool = false
var qte_target_key: Key = KEY_NONE
var qte_key_name: String = ""
var qte_timer: float = 0.0
var qte_success_count: int = 0
const QTE_TARGET_GOAL = 4

var status_label: Label
var action_hint: Label
var soak_progress_bar: ProgressBar
var qte_box: PanelContainer
var qte_label: Label
var qte_timer_bar: ProgressBar
var result_panel: PanelContainer
var result_label: Label
var photo_display: ColorRect
var close_btn: Button

func _ready() -> void:
	layer = 14
	_build_scene_ui()
	visible = false

func start_minigame() -> void:
	is_active = true
	visible = true
	current_step = 0
	soak_progress = 0.0
	is_mouse_holding = false
	qte_success_count = 0
	_setup_soak_step()

func _setup_soak_step() -> void:
	current_step = 0
	soak_progress = 0.0
	status_label.text = "🧪 LANGKAH 1: MERENDAM FOTO KE CAIRAN PENGEMBANG"
	action_hint.text = "👉 TAHAN KLIK KIRI MOUSE untuk merendam foto dalam bak kimia..."
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	soak_progress_bar.visible = true
	qte_box.visible = false
	result_panel.visible = false

func _setup_qte_step() -> void:
	current_step = 1
	qte_success_count = 0
	status_label.text = "💧 LANGKAH 2: MEMBILAS FOTO DENGAN CEPAT (QTE)"
	action_hint.text = "👉 TEKAN TOMBOL KEYBOARD YANG MUNCUL DENGAN TEPAT!"
	action_hint.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	soak_progress_bar.visible = false
	qte_box.visible = true
	_pick_next_qte_key()

func _pick_next_qte_key() -> void:
	var keys = [KEY_Q, KEY_W, KEY_E, KEY_R, KEY_A, KEY_S, KEY_D, KEY_F, KEY_SPACE]
	var names = ["Q", "W", "E", "R", "A", "S", "D", "F", "SPACE"]
	var idx = randi() % keys.size()
	qte_target_key = keys[idx]
	qte_key_name = names[idx]
	qte_timer = 2.0 # 2 detik per tombol
	qte_label.text = "[ " + qte_key_name + " ]"

func _process(delta: float) -> void:
	if not is_active:
		return

	# Step 0: Merendam Foto
	if current_step == 0:
		if is_mouse_holding:
			soak_progress += delta * 35.0
			soak_progress_bar.value = soak_progress
			if soak_progress >= 100.0:
				_setup_qte_step()
		else:
			soak_progress = move_toward(soak_progress, 0.0, delta * 20.0)
			soak_progress_bar.value = soak_progress

	# Step 1: Bilas QTE
	elif current_step == 1:
		qte_timer -= delta
		if is_instance_valid(qte_timer_bar):
			qte_timer_bar.value = (qte_timer / 2.0) * 100.0

		if qte_timer <= 0.0:
			# Gagal QTE
			action_hint.text = "⚠️ Terlalu lambat membilas! Mengulang bilasan..."
			action_hint.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
			qte_success_count = max(0, qte_success_count - 1)
			_pick_next_qte_key()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	# Deteksi Tahan Klik Kiri
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if current_step == 0:
			is_mouse_holding = event.pressed
			get_viewport().set_input_as_handled()

	# Deteksi Tekan Key QTE
	if event is InputEventKey and event.pressed and not event.is_echo() and current_step == 1:
		if event.keycode == qte_target_key:
			qte_success_count += 1
			action_hint.text = "✨ Bilasan sempurna! (%d/%d)" % [qte_success_count, QTE_TARGET_GOAL]
			action_hint.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
			
			if qte_success_count >= QTE_TARGET_GOAL:
				_show_photo_revelation()
			else:
				_pick_next_qte_key()
			get_viewport().set_input_as_handled()
		else:
			action_hint.text = "❌ Salah tombol! Tekan tombol yang sesuai!"
			action_hint.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

# ── Penyingkapan Hasil Foto Forensik (Plot Twist) ───────────────────────────
func _show_photo_revelation() -> void:
	current_step = 2
	qte_box.visible = false
	result_panel.visible = true
	status_label.text = "📷 HASIL CUCI FOTO FORENSIK TERUNGKAP"
	action_hint.text = "⚠️ KEJANGGALAN MUTLAK TERUNGKAP!"
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

	result_label.text = "Di bawah cahaya lampu merah kamar gelap, detail foto terakhir muncul dengan sangat jelas...\n\nJasad korban yang tergeletak mengenakan setelan kemeja putih detektif... dan wajah korban adalah:\n👉 WAJAH BENEDICT SENDIRI!\n\nBenedict: 'Tidak mungkin... Kenapa wajah korban di foto ini... adalah wajahku sendiri?! Aku harus segera ke Rumah Sakit untuk memeriksa jasad itu!'"

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("developed_photos")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_4_HOSPITAL)

func _finish_and_close() -> void:
	is_active = false
	visible = false
	minigame_completed.emit(true)

# ── Membangun UI Kamar Gelap Cuci Foto ──────────────────────────────────────
func _build_scene_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.01, 0.02, 0.95) # Nuansa Red Darkroom
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	margin.add_child(main_vbox)

	# Header
	var header = HBoxContainer.new()
	main_vbox.add_child(header)

	var title = Label.new()
	title.text = "🔴 KAMAR GELAP FORENSIK — PENCUCIAN ROL FOTO TKP"
	title.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "✖ Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func(): is_active = false; visible = false)
	header.add_child(close_btn)

	status_label = Label.new()
	status_label.text = "🧪 LANGKAH 1: MERENDAM FOTO"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	main_vbox.add_child(status_label)

	action_hint = Label.new()
	action_hint.text = "TAHAN KLIK KIRI MOUSE..."
	action_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_hint.add_theme_font_size_override("font_size", 14)
	main_vbox.add_child(action_hint)

	# Progress Bar Rendam
	soak_progress_bar = ProgressBar.new()
	soak_progress_bar.custom_minimum_size = Vector2(0, 32)
	soak_progress_bar.max_value = 100
	main_vbox.add_child(soak_progress_bar)

	# Box QTE
	qte_box = PanelContainer.new()
	var qte_style = StyleBoxFlat.new()
	qte_style.bg_color = Color(0.18, 0.05, 0.08, 0.95)
	qte_style.border_color = Color(1.0, 0.5, 0.5, 1.0)
	qte_style.set_border_width_all(2)
	qte_style.set_corner_radius_all(10)
	qte_style.content_margin_top = 20
	qte_style.content_margin_bottom = 20
	qte_box.add_theme_stylebox_override("panel", qte_style)
	main_vbox.add_child(qte_box)

	var qte_vb = VBoxContainer.new()
	qte_vb.add_theme_constant_override("separation", 10)
	qte_box.add_child(qte_vb)

	qte_label = Label.new()
	qte_label.text = "[ SPACE ]"
	qte_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	qte_label.add_theme_font_size_override("font_size", 36)
	qte_vb.add_child(qte_label)

	qte_timer_bar = ProgressBar.new()
	qte_timer_bar.custom_minimum_size = Vector2(240, 16)
	qte_timer_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	qte_timer_bar.max_value = 100
	qte_vb.add_child(qte_timer_bar)

	# Result Panel (Foto Terungkap)
	result_panel = PanelContainer.new()
	var res_style = StyleBoxFlat.new()
	res_style.bg_color = Color(0.12, 0.03, 0.05, 0.95)
	res_style.border_color = Color(1.0, 0.2, 0.2, 1.0)
	res_style.set_border_width_all(2)
	res_style.set_corner_radius_all(10)
	res_style.content_margin_left = 20
	res_style.content_margin_right = 20
	res_style.content_margin_top = 16
	res_style.content_margin_bottom = 16
	result_panel.add_theme_stylebox_override("panel", res_style)
	main_vbox.add_child(result_panel)

	var res_vb = VBoxContainer.new()
	res_vb.add_theme_constant_override("separation", 12)
	result_panel.add_child(res_vb)

	result_label = Label.new()
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.9))
	result_label.add_theme_font_size_override("font_size", 15)
	res_vb.add_child(result_label)

	var continue_btn = Button.new()
	continue_btn.text = "🚨 Lanjutkan ke Rumah Sakit (Kamar Mayat)"
	continue_btn.custom_minimum_size = Vector2(0, 40)
	continue_btn.focus_mode = Control.FOCUS_NONE
	continue_btn.pressed.connect(_finish_and_close)
	res_vb.add_child(continue_btn)
