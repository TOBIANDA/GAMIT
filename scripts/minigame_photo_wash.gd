extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var current_step: int = 0

var soak_progress: float = 0.0
var is_mouse_holding: bool = false
var qte_target_key: Key = KEY_NONE
var qte_key_name: String = ""
var qte_timer: float = 0.0
var qte_success_count: int = 0
const QTE_TARGET_GOAL = 3
const QTE_TIME_LIMIT = 1.3
const SOAK_DURATION = 1.3

var workbench_box: VBoxContainer
var status_label: Label
var action_hint: Label
var baskom_box: Control
var baskom_texture_rect: TextureRect
var photo_preview_rect: TextureRect
var soak_container: VBoxContainer
var soak_progress_bar: ProgressBar
var qte_box: PanelContainer
var qte_label: Label
var qte_timer_bar: ProgressBar
var result_panel: PanelContainer
var result_label: Label
var result_photo_rect: TextureRect
var close_btn: Button
var splash_player: AudioStreamPlayer

# Aset Tekstur
var tex_baskom: Texture2D
var tex_polaroid_dark: Texture2D
var tex_pose1: Texture2D
var tex_pose2: Texture2D
var tex_pose3: Texture2D
var tex_pose4: Texture2D

const BASKOM_W := 500.0
const BASKOM_H := 340.0
const PHOTO_W := 200.0
const PHOTO_H := 220.0
const PHOTO_IDLE_Y := 20.0
const PHOTO_SOAK_Y := 105.0

func _ready() -> void:
	layer = 14
	_load_assets()
	_setup_splash_audio()
	_build_scene_ui()
	visible = false

func _load_assets() -> void:
	if tex_baskom == null:
		tex_baskom = load("res://Environment/interactable assets/baskom cetak photo.png")
	if tex_polaroid_dark == null:
		tex_polaroid_dark = load("res://UI/Polaroid/polaroidSebelumDiCuci.png")
	if tex_pose1 == null:
		tex_pose1 = load("res://UI/Polaroid/pose1.png")
	if tex_pose2 == null:
		tex_pose2 = load("res://UI/Polaroid/pose2.png")
	if tex_pose3 == null:
		tex_pose3 = load("res://UI/Polaroid/pose3.png")
	if tex_pose4 == null:
		tex_pose4 = load("res://UI/Polaroid/pose4.png")

func _setup_splash_audio() -> void:
	if is_instance_valid(splash_player):
		return
	splash_player = AudioStreamPlayer.new()
	splash_player.name = "WaterSplashPlayer"
	var w_stream = load("res://sound/Water Splash.mp3")
	if w_stream:
		splash_player.stream = w_stream
		splash_player.volume_db = -4.0
	add_child(splash_player)

func _play_splash() -> void:
	if is_instance_valid(splash_player) and splash_player.stream:
		splash_player.play()

func start_minigame() -> void:
	if not is_instance_valid(status_label):
		_load_assets()
		_setup_splash_audio()
		_build_scene_ui()
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
	is_mouse_holding = false
	status_label.text = "LANGKAH 1: MERENDAM FOTO KE CAIRAN PENGEMBANG"
	action_hint.text = "TAHAN KLIK KIRI MOUSE atau [SPASI] untuk mencelupkan foto ke cairan kimia..."
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	
	if is_instance_valid(photo_preview_rect) and is_instance_valid(tex_polaroid_dark):
		photo_preview_rect.texture = tex_polaroid_dark
		photo_preview_rect.modulate = Color(0.4, 0.4, 0.45, 0.85)
		photo_preview_rect.position = Vector2((BASKOM_W - PHOTO_W) * 0.5, PHOTO_IDLE_Y)
		photo_preview_rect.rotation_degrees = -2.0

	if is_instance_valid(workbench_box):
		workbench_box.visible = true
	if is_instance_valid(soak_container):
		soak_container.visible = true
	if is_instance_valid(qte_box):
		qte_box.visible = false
	if is_instance_valid(result_panel):
		result_panel.visible = false

func _setup_qte_step() -> void:
	current_step = 1
	qte_success_count = 0
	status_label.text = "LANGKAH 2: MEMBILAS FOTO DENGAN CEPAT (QTE)"
	action_hint.text = "TEKAN TOMBOL KEYBOARD YANG MUNCUL DENGAN CEPAT!"
	action_hint.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	
	if is_instance_valid(photo_preview_rect) and is_instance_valid(tex_pose1):
		photo_preview_rect.texture = tex_pose1
		photo_preview_rect.modulate = Color(0.75, 0.75, 0.85, 0.95)
		photo_preview_rect.position = Vector2((BASKOM_W - PHOTO_W) * 0.5, PHOTO_SOAK_Y)

	if is_instance_valid(workbench_box):
		workbench_box.visible = true
	if is_instance_valid(soak_container):
		soak_container.visible = false
	if is_instance_valid(qte_box):
		qte_box.visible = true
	if is_instance_valid(result_panel):
		result_panel.visible = false
	_pick_next_qte_key()

func _pick_next_qte_key() -> void:
	var keys = [KEY_Q, KEY_W, KEY_E, KEY_R, KEY_A, KEY_S, KEY_D, KEY_F, KEY_SPACE]
	var names = ["Q", "W", "E", "R", "A", "S", "D", "F", "SPACE"]
	var idx = randi() % keys.size()
	qte_target_key = keys[idx]
	qte_key_name = names[idx]
	qte_timer = QTE_TIME_LIMIT
	if is_instance_valid(qte_label):
		qte_label.text = "[ " + qte_key_name + " ]"
	if is_instance_valid(action_hint):
		action_hint.text = "TEKAN TOMBOL [ %s ] SEGERA UNTUK MEMBILAS!" % qte_key_name

func _process(delta: float) -> void:
	if not is_active:
		return

	if current_step == 0:
		# Deteksi input ganda (mouse hold, space, enter, E, F) agar tidak pernah macet
		var is_mouse_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		if is_mouse_down and is_instance_valid(close_btn) and close_btn.get_global_rect().has_point(get_viewport().get_mouse_position()):
			is_mouse_down = false

		var holding_active = is_mouse_holding \
			or is_mouse_down \
			or Input.is_key_pressed(KEY_SPACE) \
			or Input.is_key_pressed(KEY_ENTER) \
			or Input.is_key_pressed(KEY_E) \
			or Input.is_key_pressed(KEY_F)

		if holding_active:
			if not is_mouse_holding:
				is_mouse_holding = true
				_play_splash()

			# Timing perendaman: selesai tepat dalam 1.3 detik
			soak_progress += delta * (100.0 / SOAK_DURATION)
			soak_progress_bar.value = soak_progress

			# Animasi tenggelam cepat & mulus masuk ke dalam cairan baskom
			if is_instance_valid(photo_preview_rect):
				photo_preview_rect.position.y = move_toward(photo_preview_rect.position.y, PHOTO_SOAK_Y, delta * 550.0)
				photo_preview_rect.rotation_degrees = -2.0 + sin(Time.get_ticks_msec() * 0.008) * 1.5
				var r_factor = clampf(soak_progress / 100.0, 0.0, 1.0)
				photo_preview_rect.modulate = Color(0.4 + r_factor * 0.5, 0.45 + r_factor * 0.5, 0.5 + r_factor * 0.5, 0.88 + r_factor * 0.12)

			if is_instance_valid(action_hint):
				action_hint.text = "Merendam klise dalam cairan pengembang... %d%%" % int(clampf(soak_progress, 0.0, 100.0))
				action_hint.add_theme_color_override("font_color", Color(0.3, 0.95, 0.95))

			if soak_progress >= 100.0:
				_play_splash()
				_setup_qte_step()
		else:
			is_mouse_holding = false
			soak_progress = move_toward(soak_progress, 0.0, delta * 35.0)
			soak_progress_bar.value = soak_progress

			if is_instance_valid(photo_preview_rect):
				photo_preview_rect.position.y = move_toward(photo_preview_rect.position.y, PHOTO_IDLE_Y, delta * 350.0)
				photo_preview_rect.rotation_degrees = move_toward(photo_preview_rect.rotation_degrees, -2.0, delta * 15.0)

			if is_instance_valid(action_hint):
				action_hint.text = "TAHAN KLIK KIRI MOUSE atau [SPASI] untuk mencelupkan foto ke cairan kimia..."
				action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))

	elif current_step == 1:
		qte_timer -= delta
		if is_instance_valid(qte_timer_bar):
			qte_timer_bar.value = (qte_timer / QTE_TIME_LIMIT) * 100.0

		if qte_timer <= 0.0:
			action_hint.text = "Terlalu lambat membilas! Mengulang bilasan..."
			action_hint.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
			qte_success_count = max(0, qte_success_count - 1)
			_pick_next_qte_key()

func _input(event: InputEvent) -> void:
	if not is_active or not visible:
		return

	if event is InputEventKey and not event.is_echo():
		if event.keycode == KEY_ESCAPE and event.pressed:
			_finish_and_close(false)
			get_viewport().set_input_as_handled()
			return

		if current_step == 0:
			if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_F]:
				if event.pressed != is_mouse_holding:
					is_mouse_holding = event.pressed
					if event.pressed:
						_play_splash()
				get_viewport().set_input_as_handled()
				return

		if current_step == 1 and event.pressed:
			if event.keycode == qte_target_key:
				_on_qte_success()
			else:
				_on_qte_fail()
			get_viewport().set_input_as_handled()
			return

		if current_step == 2 and event.pressed:
			if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_F]:
				_finish_and_close(true)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(close_btn) and close_btn.get_global_rect().has_point(event.global_position):
			return
		if current_step == 0:
			if event.pressed != is_mouse_holding:
				is_mouse_holding = event.pressed
				if event.pressed:
					_play_splash()
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	_input(event)

func _on_bg_gui_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if current_step == 0:
			if event.pressed != is_mouse_holding:
				is_mouse_holding = event.pressed
				if event.pressed:
					_play_splash()

func _on_qte_success() -> void:
	qte_success_count += 1
	_play_splash()
	action_hint.text = "Bilasan sempurna! (%d/%d)" % [qte_success_count, QTE_TARGET_GOAL]
	action_hint.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))

	if is_instance_valid(photo_preview_rect):
		if qte_success_count == 1 and is_instance_valid(tex_pose1):
			photo_preview_rect.texture = tex_pose1
		elif qte_success_count == 2 and is_instance_valid(tex_pose2):
			photo_preview_rect.texture = tex_pose2
		elif qte_success_count >= 3 and is_instance_valid(tex_pose3):
			photo_preview_rect.texture = tex_pose3
		photo_preview_rect.modulate = Color.WHITE

	if qte_success_count >= QTE_TARGET_GOAL:
		_show_photo_revelation()
	else:
		_pick_next_qte_key()

func _on_qte_fail() -> void:
	action_hint.text = "Salah tombol! Tekan tombol yang sesuai!"
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

var suspense_player: AudioStreamPlayer

func _show_photo_revelation() -> void:
	current_step = 2
	if is_instance_valid(workbench_box):
		workbench_box.visible = false
	if is_instance_valid(result_panel):
		result_panel.visible = true

	if not is_instance_valid(suspense_player):
		suspense_player = AudioStreamPlayer.new()
		suspense_player.name = "SuspensePlayer"
		var s_stream = load("res://sound/Suspense.mp3")
		if s_stream:
			suspense_player.stream = s_stream
			suspense_player.volume_db = -2.0
		add_child(suspense_player)
	if is_instance_valid(suspense_player) and suspense_player.stream:
		suspense_player.play()

	if is_instance_valid(result_photo_rect) and is_instance_valid(tex_pose4):
		result_photo_rect.texture = tex_pose4

	result_label.text = "Di bawah cahaya lampu merah kamar gelap, detail foto terakhir muncul dengan sangat jelas...\n\nJasad korban yang tergeletak mengenakan kemeja putih dan dasi detektif... dan wajah korban di foto adalah:\nWAJAH BENEDICT SENDIRI!\n\nBenedict: 'Tidak mungkin... Kenapa wajah korban di foto ini... adalah wajahku sendiri?! Aku harus segera menyelinap ke Rumah Sakit untuk membuktikannya!'"

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
		inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("developed_photos")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_4_HOSPITAL)

func _finish_and_close(success: bool = true) -> void:
	is_active = false
	visible = false
	if is_instance_valid(suspense_player) and suspense_player.playing:
		suspense_player.stop()
	minigame_completed.emit(success)

	if success and get_tree() and get_tree().root:
		var dlg = get_tree().root.find_child("DialogBox", true, false)
		if is_instance_valid(dlg):
			var shocked_lines: Array[String] = [
				"A-apa yang baru saja kulihat...",
				"Di foto terakhir tadi... wajah korban yang tewas itu...",
				"Itu... wajahku sendiri?!",
				"Tidak, ini pasti ada kekeliruan besar! Aku harus segera ke Rumah Sakit untuk melihat langsung jasad di kamar mayat!"
			]
			dlg.start_monologue(shocked_lines, "Detektif Benedict", "[ Terkejut & Curiga ]", "res://karakter/MC_Kaget.png")

func _build_scene_ui() -> void:
	if is_instance_valid(status_label):
		return

	# 1. Background Kamar Gelap 100% Solid Gelap (Mencegah Tembus/Bocor Cahaya Luar)
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.04, 0.015, 0.02, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.gui_input.connect(_on_bg_gui_input)
	add_child(bg)

	# 2. Margin Utama yang Pas dengan Resolusi Viewport
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(main_vbox)

	# 3. Header Kamar Gelap
	var header = HBoxContainer.new()
	main_vbox.add_child(header)

	var title = Label.new()
	title.text = "KAMAR GELAP FORENSIK — PENCUCIAN ROL FOTO TKP"
	title.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.22, 0.08, 0.10, 0.9)
	close_style.border_color = Color(0.85, 0.35, 0.35, 1.0)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(6)
	close_style.content_margin_left = 14
	close_style.content_margin_right = 14
	close_style.content_margin_top = 4
	close_style.content_margin_bottom = 4
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.pressed.connect(func(): _finish_and_close(false))
	header.add_child(close_btn)

	# 4. Central Workstation Container (Menjaga semua elemen di tengah secara proporsional)
	var center_wrapper = CenterContainer.new()
	center_wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(center_wrapper)

	# Workbench Box untuk Step 1 & Step 2
	workbench_box = VBoxContainer.new()
	workbench_box.add_theme_constant_override("separation", 12)
	workbench_box.alignment = BoxContainer.ALIGNMENT_CENTER
	center_wrapper.add_child(workbench_box)

	status_label = Label.new()
	status_label.text = "LANGKAH 1: MERENDAM FOTO KE CAIRAN PENGEMBANG"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 17)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.85))
	workbench_box.add_child(status_label)

	action_hint = Label.new()
	action_hint.text = "TAHAN KLIK KIRI MOUSE atau [SPASI] untuk mencelupkan foto ke cairan kimia..."
	action_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_hint.add_theme_font_size_override("font_size", 14)
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	workbench_box.add_child(action_hint)

	# Meja Baskom
	var tray_center = CenterContainer.new()
	workbench_box.add_child(tray_center)

	baskom_box = Control.new()
	baskom_box.custom_minimum_size = Vector2(BASKOM_W, BASKOM_H)
	baskom_box.size = Vector2(BASKOM_W, BASKOM_H)
	baskom_box.mouse_filter = Control.MOUSE_FILTER_STOP
	baskom_box.gui_input.connect(_on_bg_gui_input)
	tray_center.add_child(baskom_box)

	baskom_texture_rect = TextureRect.new()
	if is_instance_valid(tex_baskom):
		baskom_texture_rect.texture = tex_baskom
	baskom_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	baskom_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	baskom_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	baskom_texture_rect.anchor_right = 1.0
	baskom_texture_rect.anchor_bottom = 1.0
	baskom_box.add_child(baskom_texture_rect)

	photo_preview_rect = TextureRect.new()
	if is_instance_valid(tex_polaroid_dark):
		photo_preview_rect.texture = tex_polaroid_dark
	photo_preview_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo_preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	photo_preview_rect.custom_minimum_size = Vector2(PHOTO_W, PHOTO_H)
	photo_preview_rect.size = Vector2(PHOTO_W, PHOTO_H)
	photo_preview_rect.position = Vector2((BASKOM_W - PHOTO_W) * 0.5, PHOTO_IDLE_Y)
	photo_preview_rect.pivot_offset = Vector2(PHOTO_W * 0.5, PHOTO_H * 0.5)
	photo_preview_rect.rotation_degrees = -2.0
	photo_preview_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	photo_preview_rect.gui_input.connect(_on_bg_gui_input)
	baskom_box.add_child(photo_preview_rect)

	# Progress Bar (Step 1)
	soak_container = VBoxContainer.new()
	soak_container.add_theme_constant_override("separation", 6)
	workbench_box.add_child(soak_container)

	soak_progress_bar = ProgressBar.new()
	soak_progress_bar.custom_minimum_size = Vector2(480, 26)
	soak_progress_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	soak_progress_bar.max_value = 100
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.12, 0.04, 0.06, 0.9)
	bar_bg.border_color = Color(0.4, 0.2, 0.25, 1.0)
	bar_bg.set_border_width_all(1)
	bar_bg.set_corner_radius_all(6)
	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.2, 0.85, 0.75, 0.9)
	bar_fill.set_corner_radius_all(6)
	soak_progress_bar.add_theme_stylebox_override("background", bar_bg)
	soak_progress_bar.add_theme_stylebox_override("fill", bar_fill)
	soak_container.add_child(soak_progress_bar)

	# Box QTE (Step 2)
	qte_box = PanelContainer.new()
	var qte_style = StyleBoxFlat.new()
	qte_style.bg_color = Color(0.18, 0.05, 0.08, 0.95)
	qte_style.border_color = Color(1.0, 0.5, 0.5, 1.0)
	qte_style.set_border_width_all(2)
	qte_style.set_corner_radius_all(10)
	qte_style.content_margin_top = 10
	qte_style.content_margin_bottom = 10
	qte_box.add_theme_stylebox_override("panel", qte_style)
	qte_box.custom_minimum_size = Vector2(480, 80)
	qte_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	workbench_box.add_child(qte_box)

	var qte_vb = VBoxContainer.new()
	qte_vb.add_theme_constant_override("separation", 6)
	qte_box.add_child(qte_vb)

	qte_label = Label.new()
	qte_label.text = "[ SPACE ]"
	qte_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	qte_label.add_theme_font_size_override("font_size", 28)
	qte_vb.add_child(qte_label)

	qte_timer_bar = ProgressBar.new()
	qte_timer_bar.custom_minimum_size = Vector2(280, 12)
	qte_timer_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	qte_timer_bar.max_value = 100
	var timer_fill = StyleBoxFlat.new()
	timer_fill.bg_color = Color(0.3, 0.85, 1.0, 0.9)
	timer_fill.set_corner_radius_all(4)
	qte_timer_bar.add_theme_stylebox_override("background", bar_bg)
	qte_timer_bar.add_theme_stylebox_override("fill", timer_fill)
	qte_vb.add_child(qte_timer_bar)

	# 5. Panel Hasil Akhir (Step 3)
	result_panel = PanelContainer.new()
	var res_style = StyleBoxFlat.new()
	res_style.bg_color = Color(0.12, 0.03, 0.05, 0.98)
	res_style.border_color = Color(1.0, 0.25, 0.25, 1.0)
	res_style.set_border_width_all(2)
	res_style.set_corner_radius_all(12)
	res_style.content_margin_left = 32
	res_style.content_margin_right = 32
	res_style.content_margin_top = 24
	res_style.content_margin_bottom = 24
	result_panel.add_theme_stylebox_override("panel", res_style)
	result_panel.custom_minimum_size = Vector2(980, 480)
	center_wrapper.add_child(result_panel)

	var res_hb = HBoxContainer.new()
	res_hb.add_theme_constant_override("separation", 36)
	res_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	result_panel.add_child(res_hb)

	result_photo_rect = TextureRect.new()
	result_photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_photo_rect.custom_minimum_size = Vector2(300, 360)
	result_photo_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	res_hb.add_child(result_photo_rect)

	var res_vb = VBoxContainer.new()
	res_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	res_vb.add_theme_constant_override("separation", 20)
	res_hb.add_child(res_vb)

	var res_title = Label.new()
	res_title.text = "HASIL CUCI FOTO FORENSIK TERUNGKAP"
	res_title.add_theme_font_size_override("font_size", 20)
	res_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	res_vb.add_child(res_title)

	result_label = Label.new()
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.92))
	result_label.add_theme_font_size_override("font_size", 16)
	res_vb.add_child(result_label)

	var continue_btn = Button.new()
	continue_btn.text = "Lanjutkan Menyelidiki ke Rumah Sakit (Kamar Mayat)"
	continue_btn.custom_minimum_size = Vector2(0, 48)
	continue_btn.focus_mode = Control.FOCUS_NONE
	var cbtn_style = StyleBoxFlat.new()
	cbtn_style.bg_color = Color(0.7, 0.15, 0.18, 1.0)
	cbtn_style.border_color = Color(1.0, 0.4, 0.4, 1.0)
	cbtn_style.set_border_width_all(2)
	cbtn_style.set_corner_radius_all(8)
	continue_btn.add_theme_stylebox_override("normal", cbtn_style)
	continue_btn.pressed.connect(func(): _finish_and_close(true))
	res_vb.add_child(continue_btn)
