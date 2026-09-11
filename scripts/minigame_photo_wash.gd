extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var current_step: int = 0

var soak_progress: float = 0.0
var is_mouse_holding: bool = false

# --- QTE SISTEM MANCING (MLBB FISHING TIMING BAR) ---
const QTE_TARGET_GOAL = 4   # 4 Foto total yang dicuci
const ZONE_SIZES: Array[float] = [0.42, 0.30, 0.20, 0.12] # Area makin kecil: klik 1 (42%), 2 (30%), 3 (20%), 4 (12%)
const SLIDER_SPEED: float = 1.25 # Kecepatan jarum bolak-balik
const SOAK_DURATION: float = 1.3

var current_photo_idx: int = 0 # 0..3 (Foto 1, 2, 3, 4)
var photo_sub_click: int = 0   # 0..4 (Pencetan 1, 2, 3, 4 per foto)

var slider_val: float = 0.0    # 0.0 .. 1.0 posisi jarum bergerak
var slider_dir: float = 1.0    # 1.0 (ke kanan) atau -1.0 (ke kiri)
var hit_flash_timer: float = 0.0
var miss_flash_timer: float = 0.0

var workbench_box: VBoxContainer
var status_label: Label
var action_hint: Label
var baskom_box: Control
var baskom_texture_rect: TextureRect
var photo_preview_rect: TextureRect
var photo_step_badge: Label
var soak_container: VBoxContainer
var soak_progress_bar: ProgressBar
var qte_box: PanelContainer
var qte_label: Label
var qte_pips_label: Label
var qte_meter_control: Control
var result_panel: PanelContainer
var result_title: Label
var result_label: Label
var close_btn: Button
var splash_player: AudioStreamPlayer
var suspense_player: AudioStreamPlayer

# Aset Tekstur Polaroid Lengkap: 1 Sebelum Dicuci + 4 Pose Hasil Cuci
var tex_baskom: Texture2D
var tex_polaroid_dark: Texture2D # 1 foto sebelum dicuci
var tex_pose1: Texture2D         # Pose 1
var tex_pose2: Texture2D         # Pose 2
var tex_pose3: Texture2D         # Pose 3
var tex_pose4: Texture2D         # Pose 4 (Wajah Benedict!)

var gallery_card_rects: Array[TextureRect] = []
var gallery_card_labels: Array[Label] = []
var selected_photo_idx: int = 3 # Default highlight foto 4 yang paling mengejutkan

# Ukuran Bak dan Foto yang Disesuaikan Sempurna (Foto 100% di dalam bak & cairan kimia)
const BASKOM_W := 580.0
const BASKOM_H := 430.0
const PHOTO_W := 156.0
const PHOTO_H := 176.0
const PHOTO_IDLE_Y := 10.0
const PHOTO_SOAK_Y := 114.0

func _ready() -> void:
	layer = 14
	_load_assets()
	_setup_audio()
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

func _setup_audio() -> void:
	if not is_instance_valid(splash_player):
		splash_player = AudioStreamPlayer.new()
		splash_player.name = "WaterSplashPlayer"
		var w_stream = load("res://sound/Water Splash.mp3")
		if w_stream:
			splash_player.stream = w_stream
			splash_player.volume_db = -3.0
		add_child(splash_player)

	if not is_instance_valid(suspense_player):
		suspense_player = AudioStreamPlayer.new()
		suspense_player.name = "SuspensePlayer"
		var s_stream = load("res://sound/Suspense.mp3")
		if s_stream:
			suspense_player.stream = s_stream
			suspense_player.volume_db = -2.0
		add_child(suspense_player)

func _play_splash() -> void:
	if is_instance_valid(splash_player) and splash_player.is_inside_tree() and splash_player.stream:
		splash_player.play()

func start_minigame() -> void:
	if not is_instance_valid(status_label):
		_load_assets()
		_setup_audio()
		_build_scene_ui()
	is_active = true
	visible = true
	current_step = 0
	soak_progress = 0.0
	is_mouse_holding = false
	current_photo_idx = 0
	photo_sub_click = 0
	slider_val = 0.0
	slider_dir = 1.0
	hit_flash_timer = 0.0
	miss_flash_timer = 0.0
	selected_photo_idx = 3
	_setup_soak_step()

func _setup_soak_step() -> void:
	current_step = 0
	soak_progress = 0.0
	is_mouse_holding = false
	status_label.text = "LANGKAH 1: MERENDAM KLISE FOTO (SEBELUM DICUCI)"
	action_hint.text = "TAHAN KLIK KIRI MOUSE atau [SPASI] untuk mencelupkan klise gelap ke cairan pengembang..."
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))

	if is_instance_valid(photo_step_badge):
		photo_step_badge.text = "[ KLISE SEBELUM DICUCI ]"
		photo_step_badge.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))

	if is_instance_valid(photo_preview_rect) and is_instance_valid(tex_polaroid_dark):
		photo_preview_rect.texture = tex_polaroid_dark
		photo_preview_rect.modulate = Color(0.5, 0.5, 0.55, 0.9)
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
	current_photo_idx = 0
	photo_sub_click = 0
	slider_val = 0.0
	slider_dir = 1.0
	hit_flash_timer = 0.0
	miss_flash_timer = 0.0

	status_label.text = "LANGKAH 2: MEMBILAS & MENGEMBANGKAN 4 FOTO POSE (TIMING BAR)"
	action_hint.text = "TEKAN [ SPASI ] / [ A ] / KLIK TEPAT SAAT JARUM BERADA DI ZONA HIJAU!"
	action_hint.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))

	if is_instance_valid(photo_preview_rect):
		photo_preview_rect.position = Vector2((BASKOM_W - PHOTO_W) * 0.5, PHOTO_SOAK_Y)
		photo_preview_rect.rotation_degrees = -1.5

	if is_instance_valid(workbench_box):
		workbench_box.visible = true
	if is_instance_valid(soak_container):
		soak_container.visible = false
	if is_instance_valid(qte_box):
		qte_box.visible = true
	if is_instance_valid(result_panel):
		result_panel.visible = false

	_update_step_ui()
	_update_photo_visual()

func _update_step_ui() -> void:
	var titles = [
		"FOTO 1/4: PERON STASIUN",
		"FOTO 2/4: PENGINTAIAN DI BALIK PILAR",
		"FOTO 3/4: KORBAN LEMAH DI BANGKU TUNGGU",
		"FOTO 4/4: WAJAH KORBAN PEMBUNUHAN?!"
	]
	var pct_names = ["Zona 42% (Paling Lebar)", "Zona 30%", "Zona 20%", "Zona 12% (Paling Sempit!)"]

	var pips = ""
	for i in range(4):
		pips += " ●" if i < photo_sub_click else " ○"

	var cur_title = titles[clamp(current_photo_idx, 0, 3)]
	if is_instance_valid(photo_step_badge):
		photo_step_badge.text = "[ %s ]" % cur_title
		photo_step_badge.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))

	if is_instance_valid(qte_pips_label):
		qte_pips_label.text = "BILASAN FOTO: [%s ] — Klik ke-%d/4 (%s)" % [
			pips,
			photo_sub_click + 1,
			pct_names[clamp(photo_sub_click, 0, 3)]
		]

func _update_photo_visual() -> void:
	var photo_textures = [tex_pose1, tex_pose2, tex_pose3, tex_pose4]
	if current_photo_idx >= 0 and current_photo_idx < photo_textures.size() and is_instance_valid(photo_textures[current_photo_idx]):
		photo_preview_rect.texture = photo_textures[current_photo_idx]

	# Tingkat kecerahan bertahap (setiap klik makin terang)
	match photo_sub_click:
		0:
			# Belum ada klik: siluet gelap/samar
			photo_preview_rect.modulate = Color(0.18, 0.18, 0.22, 0.65)
		1:
			# Klik 1: mulai muncul bayangan gambar
			photo_preview_rect.modulate = Color(0.42, 0.42, 0.48, 0.80)
		2:
			# Klik 2: detail dan warna mulai tampak
			photo_preview_rect.modulate = Color(0.68, 0.68, 0.74, 0.90)
		3:
			# Klik 3: hampir jelas sempurna
			photo_preview_rect.modulate = Color(0.88, 0.88, 0.92, 0.96)
		4:
			# Klik 4: terang sempurna 100%
			photo_preview_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _process(delta: float) -> void:
	if not is_active:
		return

	if current_step == 0:
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

			soak_progress += delta * (100.0 / SOAK_DURATION)
			soak_progress_bar.value = soak_progress

			if is_instance_valid(photo_preview_rect):
				photo_preview_rect.position.y = move_toward(photo_preview_rect.position.y, PHOTO_SOAK_Y, delta * 550.0)
				photo_preview_rect.rotation_degrees = -2.0 + sin(Time.get_ticks_msec() * 0.008) * 1.5
				var r_factor = clampf(soak_progress / 100.0, 0.0, 1.0)
				photo_preview_rect.modulate = Color(0.5 + r_factor * 0.45, 0.5 + r_factor * 0.45, 0.55 + r_factor * 0.45, 0.9 + r_factor * 0.1)

			if is_instance_valid(action_hint):
				action_hint.text = "Merendam klise polaroid dalam cairan pengembang... %d%%" % int(clampf(soak_progress, 0.0, 100.0))
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
				action_hint.text = "TAHAN KLIK KIRI MOUSE atau [SPASI] untuk mencelupkan klise foto ke cairan kimia..."
				action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))

	elif current_step == 1:
		# Gerakan jarum bolak-balik (slider ping-pong)
		slider_val += slider_dir * delta * SLIDER_SPEED
		if slider_val >= 1.0:
			slider_val = 1.0
			slider_dir = -1.0
		elif slider_val <= 0.0:
			slider_val = 0.0
			slider_dir = 1.0

		if hit_flash_timer > 0.0:
			hit_flash_timer -= delta
		if miss_flash_timer > 0.0:
			miss_flash_timer -= delta

		# Kembalikan posisi X foto ke tengah secara mulus jika sebelumnya bergetar saat gagal
		if is_instance_valid(photo_preview_rect):
			var target_x = (BASKOM_W - PHOTO_W) * 0.5
			photo_preview_rect.position.x = move_toward(photo_preview_rect.position.x, target_x, delta * 90.0)

		if is_instance_valid(qte_meter_control):
			qte_meter_control.queue_redraw()

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
			if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_A, KEY_S, KEY_D, KEY_F, KEY_E, KEY_Q, KEY_W, KEY_R]:
				_try_qte_hit()
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
		elif current_step == 1 and event.pressed:
			_try_qte_hit()
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	_input(event)

func _try_qte_hit() -> void:
	if current_step != 1 or not is_active:
		return

	var zone_ratio = ZONE_SIZES[clamp(photo_sub_click, 0, 3)]
	var zone_start = (1.0 - zone_ratio) * 0.5
	var zone_end = (1.0 + zone_ratio) * 0.5

	# Toleransi margin 0.015 agar respon terasa adil dan presisi
	if slider_val >= (zone_start - 0.015) and slider_val <= (zone_end + 0.015):
		_on_qte_sub_hit()
	else:
		_on_qte_sub_miss()

func _on_qte_sub_hit() -> void:
	_play_splash()
	hit_flash_timer = 0.25
	miss_flash_timer = 0.0
	photo_sub_click += 1

	_update_photo_visual()

	if photo_sub_click >= 4:
		# Foto ini selesai dibilas sempurna (4/4 klik berhasil)!
		current_photo_idx += 1
		photo_sub_click = 0 # Balik ke default klik pertama untuk foto berikutnya!

		if current_photo_idx >= QTE_TARGET_GOAL:
			# Keempat foto selesai dibilas!
			_show_photo_revelation()
			return
		else:
			action_hint.text = "FOTO %d/4 TERCUCI SEMPURNA! Lanjut membilas foto berikutnya (Zona kembali lebar)..." % current_photo_idx
			action_hint.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))
			_update_step_ui()
			_update_photo_visual()
	else:
		var pct_list = ["42%", "30%", "20%", "12%"]
		action_hint.text = "KLIK %d/4 BERHASIL! Foto makin terang, area mengecil (%s) — Tekan lagi di zona hijau!" % [
			photo_sub_click,
			pct_list[clamp(photo_sub_click, 0, 3)]
		]
		action_hint.add_theme_color_override("font_color", Color(0.4, 0.95, 0.5))
		_update_step_ui()

func _on_qte_sub_miss() -> void:
	miss_flash_timer = 0.35
	hit_flash_timer = 0.0

	# Getaran visual foto saat gagal bilas
	if is_instance_valid(photo_preview_rect):
		photo_preview_rect.position.x = (BASKOM_W - PHOTO_W) * 0.5 + randf_range(-10.0, 10.0)

	# Sesuai aturan: jika miss, mengulang ke saat klik pertama foto ini (sub_click = 0)
	# Foto kembali redup dan area klik kembali default paling lebar
	photo_sub_click = 0
	_update_photo_visual()
	_update_step_ui()

	action_hint.text = "MELESET! Bilasan gagal dan mengulang dari klik pertama foto ini (Zona kembali lebar)!"
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))

func _show_photo_revelation() -> void:
	current_step = 2
	if is_instance_valid(workbench_box):
		workbench_box.visible = false
	if is_instance_valid(result_panel):
		result_panel.visible = true

	if is_instance_valid(suspense_player) and suspense_player.is_inside_tree() and suspense_player.stream:
		suspense_player.play()

	_select_photo_card(3)

	var inv_mgr = null
	if is_inside_tree():
		inv_mgr = get_node_or_null("/root/InvestigationManager")
		if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
			inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("developed_photos")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_4_HOSPITAL)

func _select_photo_card(idx: int) -> void:
	selected_photo_idx = idx
	for i in range(gallery_card_rects.size()):
		var card = gallery_card_rects[i]
		if not is_instance_valid(card):
			continue
		var p_parent = card.get_parent()
		if p_parent is PanelContainer:
			var border_col = Color(1.0, 0.3, 0.3, 1.0) if i == 3 else Color(0.4, 0.7, 1.0, 0.8)
			if i == idx:
				var sb = p_parent.get_theme_stylebox("panel")
				if sb is StyleBoxFlat:
					sb.border_color = Color(1.0, 0.95, 0.3, 1.0)
					sb.set_border_width_all(3)
			else:
				var sb = p_parent.get_theme_stylebox("panel")
				if sb is StyleBoxFlat:
					sb.border_color = border_col
					sb.set_border_width_all(1)

	var desc_texts = [
		"FOTO 1: Korban terlihat berjalan tergesa-gesa menyusuri peron stasiun kereta api.",
		"FOTO 2: Seseorang berdiri membuntuti di seberang pilar stasiun, mengawasi gerak-gerik korban.",
		"FOTO 3: Korban terduduk lemas di bangku tunggu stasiun sambil mendekap amplop dan tasnya.",
		"FOTO 4 (FAKTA MENGERIKAN):\nJasad korban terbaring kaku... Kemeja, dasi, dan wajah korban di foto adalah WAJAH BENEDICT SENDIRI!\n\nBenedict: 'Mustahil... Bagaimana mungkin korban yang tewas adalah diriku sendiri?! Aku harus segera menyelinap ke Kamar Jenazah Rumah Sakit untuk membuktikannya!'"
	]

	if is_instance_valid(result_label):
		result_label.text = desc_texts[clamp(idx, 0, desc_texts.size() - 1)]

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
				"Dari keempat lembar foto yang kucuci tadi...",
				"Wajah korban di foto terakhir... itu... wajahku sendiri?!",
				"Tidak... ini tidak masuk akal! Aku harus segera pergi ke Rumah Sakit untuk melihat langsung jasad di kamar mayat!"
			]
			dlg.start_monologue(shocked_lines, "Detektif Benedict", "[ Terkejut & Curiga ]", "res://karakter/MC_Kaget.png")

func _build_scene_ui() -> void:
	if is_instance_valid(status_label):
		return

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.015, 0.02, 1.0)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 6)
	margin.add_child(main_vbox)

	# Header
	var header = HBoxContainer.new()
	main_vbox.add_child(header)

	var title = Label.new()
	title.text = "KAMAR GELAP FORENSIK — PENCUCIAN 4 FOTO POLAROID STASIUN"
	title.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.22, 0.08, 0.10, 0.9)
	close_style.border_color = Color(0.85, 0.35, 0.35, 1.0)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.pressed.connect(func(): _finish_and_close(false))
	header.add_child(close_btn)

	var center_wrapper = CenterContainer.new()
	center_wrapper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(center_wrapper)

	# --- WORKBENCH STEP 1 & 2 ---
	workbench_box = VBoxContainer.new()
	workbench_box.add_theme_constant_override("separation", 8)
	workbench_box.alignment = BoxContainer.ALIGNMENT_CENTER
	center_wrapper.add_child(workbench_box)

	status_label = Label.new()
	status_label.text = "LANGKAH 1: MERENDAM KLISE FOTO (SEBELUM DICUCI)"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.85))
	workbench_box.add_child(status_label)

	photo_step_badge = Label.new()
	photo_step_badge.text = "[ KLISE SEBELUM DICUCI ]"
	photo_step_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	photo_step_badge.add_theme_font_size_override("font_size", 14)
	photo_step_badge.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	workbench_box.add_child(photo_step_badge)

	action_hint = Label.new()
	action_hint.text = "TAHAN KLIK KIRI MOUSE atau [SPASI] untuk mencelupkan klise foto ke cairan kimia..."
	action_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_hint.add_theme_font_size_override("font_size", 14)
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	workbench_box.add_child(action_hint)

	var tray_center = CenterContainer.new()
	workbench_box.add_child(tray_center)

	baskom_box = Control.new()
	baskom_box.custom_minimum_size = Vector2(BASKOM_W, BASKOM_H)
	baskom_box.size = Vector2(BASKOM_W, BASKOM_H)
	tray_center.add_child(baskom_box)

	baskom_texture_rect = TextureRect.new()
	if is_instance_valid(tex_baskom):
		baskom_texture_rect.texture = tex_baskom
	baskom_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	baskom_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	baskom_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
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
	baskom_box.add_child(photo_preview_rect)

	# Progress Bar Langkah 1 (Merendam)
	soak_container = VBoxContainer.new()
	soak_container.add_theme_constant_override("separation", 6)
	workbench_box.add_child(soak_container)

	soak_progress_bar = ProgressBar.new()
	soak_progress_bar.custom_minimum_size = Vector2(480, 24)
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

	# --- QTE BOX: TIMING METER DENGAN ZONA KLIK & JARUM BERGERAK (SEPERTI MANCING MLBB) ---
	qte_box = PanelContainer.new()
	var qte_style = StyleBoxFlat.new()
	qte_style.bg_color = Color(0.14, 0.04, 0.06, 0.95)
	qte_style.border_color = Color(0.9, 0.45, 0.45, 1.0)
	qte_style.set_border_width_all(2)
	qte_style.set_corner_radius_all(10)
	qte_style.content_margin_left = 18
	qte_style.content_margin_right = 18
	qte_style.content_margin_top = 8
	qte_style.content_margin_bottom = 10
	qte_box.add_theme_stylebox_override("panel", qte_style)
	qte_box.custom_minimum_size = Vector2(520, 95)
	qte_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	workbench_box.add_child(qte_box)

	var qte_vb = VBoxContainer.new()
	qte_vb.add_theme_constant_override("separation", 6)
	qte_box.add_child(qte_vb)

	# Header Instruksi & Tombol
	var qte_header_hb = HBoxContainer.new()
	qte_header_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	qte_vb.add_child(qte_header_hb)

	qte_label = Label.new()
	qte_label.text = "[ SPASI / A / KLIK MOUSE ]"
	qte_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.3))
	qte_label.add_theme_font_size_override("font_size", 16)
	qte_header_hb.add_child(qte_label)

	qte_pips_label = Label.new()
	qte_pips_label.text = "BILASAN FOTO: [ ○ ○ ○ ○ ] — Klik ke-1/4 (Zona 42% Default)"
	qte_pips_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_pips_label.add_theme_color_override("font_color", Color(0.6, 0.95, 0.8))
	qte_pips_label.add_theme_font_size_override("font_size", 13)
	qte_vb.add_child(qte_pips_label)

	# Timing Meter Bar
	qte_meter_control = Control.new()
	qte_meter_control.custom_minimum_size = Vector2(480, 32)
	qte_meter_control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	qte_meter_control.draw.connect(_draw_qte_meter)
	qte_vb.add_child(qte_meter_control)

	# --- HASIL AKHIR: GALERI 4 FOTO POSE LENGKAP + 1 KLISE SEBELUM DICUCI ---
	result_panel = PanelContainer.new()
	var res_style = StyleBoxFlat.new()
	res_style.bg_color = Color(0.08, 0.02, 0.04, 0.98)
	res_style.border_color = Color(0.9, 0.3, 0.3, 1.0)
	res_style.set_border_width_all(2)
	res_style.set_corner_radius_all(10)
	res_style.content_margin_left = 20
	res_style.content_margin_right = 20
	res_style.content_margin_top = 14
	res_style.content_margin_bottom = 14
	result_panel.add_theme_stylebox_override("panel", res_style)
	result_panel.custom_minimum_size = Vector2(1040, 520)
	center_wrapper.add_child(result_panel)

	var res_main_vb = VBoxContainer.new()
	res_main_vb.add_theme_constant_override("separation", 10)
	result_panel.add_child(res_main_vb)

	result_title = Label.new()
	result_title.text = "HASIL REKONSTRUKSI FOTO FORENSIK (4 FOTO SELESAI DICUCI)"
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.add_theme_font_size_override("font_size", 18)
	result_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	res_main_vb.add_child(result_title)

	var gallery_hb = HBoxContainer.new()
	gallery_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	gallery_hb.add_theme_constant_override("separation", 14)
	res_main_vb.add_child(gallery_hb)

	# 1 Klise Sebelum Dicuci
	var unwashed_box = _create_photo_card_box("Sebelum Dicuci", tex_polaroid_dark, -1, false)
	gallery_hb.add_child(unwashed_box)

	# 4 Foto Pose Hasil Cuci
	var poses_tex = [tex_pose1, tex_pose2, tex_pose3, tex_pose4]
	var poses_title = ["Pose 1: Stasiun", "Pose 2: Diintai", "Pose 3: Lemas", "Pose 4: KORBAN!"]
	gallery_card_rects.clear()

	for i in range(4):
		var is_twist = (i == 3)
		var p_box = _create_photo_card_box(poses_title[i], poses_tex[i], i, is_twist)
		gallery_hb.add_child(p_box)

	# Label Keterangan Dinamis
	result_label = Label.new()
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.92))
	result_label.add_theme_font_size_override("font_size", 15)
	result_label.custom_minimum_size = Vector2(0, 70)
	res_main_vb.add_child(result_label)

	var continue_btn = Button.new()
	continue_btn.text = "Lanjutkan Menyelidiki ke Rumah Sakit (Kamar Mayat) [SPASI / ENTER]"
	continue_btn.custom_minimum_size = Vector2(0, 44)
	continue_btn.focus_mode = Control.FOCUS_NONE
	continue_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var cbtn_style = StyleBoxFlat.new()
	cbtn_style.bg_color = Color(0.72, 0.15, 0.18, 1.0)
	cbtn_style.border_color = Color(1.0, 0.45, 0.45, 1.0)
	cbtn_style.set_border_width_all(2)
	cbtn_style.set_corner_radius_all(8)
	continue_btn.add_theme_stylebox_override("normal", cbtn_style)
	continue_btn.pressed.connect(func(): _finish_and_close(true))
	res_main_vb.add_child(continue_btn)

func _draw_qte_meter() -> void:
	if not is_instance_valid(qte_meter_control):
		return
	var w = qte_meter_control.size.x
	var h = qte_meter_control.size.y
	if w <= 0 or h <= 0:
		w = 480.0
		h = 32.0

	# 1. Background Track (Rel Meteran Gelap)
	var track_rect = Rect2(0, 0, w, h)
	qte_meter_control.draw_rect(track_rect, Color(0.08, 0.03, 0.05, 0.95), true)
	qte_meter_control.draw_rect(track_rect, Color(0.40, 0.16, 0.22, 1.0), false, 1.5)

	# 2. Target Zone (Zona Klik Hijau / Luminous Green)
	var zone_ratio = ZONE_SIZES[clamp(photo_sub_click, 0, 3)]
	var zone_w = w * zone_ratio
	var zone_x = (w - zone_w) * 0.5 # Posisi Simetris di Tengah

	var zone_rect = Rect2(zone_x, 2, zone_w, h - 4)
	var z_col = Color(0.15, 0.85, 0.45, 0.65)
	var z_border = Color(0.45, 1.0, 0.70, 1.0)
	if hit_flash_timer > 0.0:
		z_col = Color(0.35, 1.0, 0.65, 0.95)
	elif miss_flash_timer > 0.0:
		z_col = Color(0.9, 0.2, 0.2, 0.75)
		z_border = Color(1.0, 0.35, 0.35, 1.0)

	qte_meter_control.draw_rect(zone_rect, z_col, true)
	qte_meter_control.draw_rect(zone_rect, z_border, false, 2.0)

	# 3. Moving Needle / Slider (Jarum Meluncur Bolak-Balik)
	var needle_x = clampf(slider_val * (w - 6) + 3, 3, w - 3)
	var needle_col = Color(1.0, 0.95, 0.2, 1.0)
	if miss_flash_timer > 0.0:
		needle_col = Color(1.0, 0.25, 0.25, 1.0)
	elif hit_flash_timer > 0.0:
		needle_col = Color(0.4, 1.0, 0.5, 1.0)

	# Garis jarum tengah
	qte_meter_control.draw_line(Vector2(needle_x, 1), Vector2(needle_x, h - 1), needle_col, 4.0)

	# Panah segitiga atas & bawah jarum (cursor pointer)
	var poly_top = PackedVector2Array([
		Vector2(needle_x - 6, 0),
		Vector2(needle_x + 6, 0),
		Vector2(needle_x, 8)
	])
	var poly_bottom = PackedVector2Array([
		Vector2(needle_x - 6, h),
		Vector2(needle_x + 6, h),
		Vector2(needle_x, h - 8)
	])
	qte_meter_control.draw_colored_polygon(poly_top, needle_col)
	qte_meter_control.draw_colored_polygon(poly_bottom, needle_col)

func _create_photo_card_box(card_title: String, tex: Texture2D, idx: int, is_twist: bool) -> PanelContainer:
	var pc = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.05, 0.07, 0.95)
	style.border_color = Color(1.0, 0.3, 0.3, 1.0) if is_twist else Color(0.4, 0.7, 1.0, 0.75)
	style.set_border_width_all(2 if is_twist else 1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	pc.add_theme_stylebox_override("panel", style)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	pc.add_child(vb)

	var t_rect = TextureRect.new()
	if is_instance_valid(tex):
		t_rect.texture = tex
	t_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t_rect.custom_minimum_size = Vector2(170, 170)
	t_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	t_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	vb.add_child(t_rect)

	if idx >= 0:
		gallery_card_rects.append(t_rect)
		t_rect.gui_input.connect(func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_select_photo_card(idx)
		)

	var lbl = Label.new()
	lbl.text = card_title
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4) if is_twist else Color(0.85, 0.9, 1.0))
	vb.add_child(lbl)

	return pc
