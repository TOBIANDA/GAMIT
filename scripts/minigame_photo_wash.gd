extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var current_step: int = 0

var soak_progress: float = 0.0
var is_mouse_holding: bool = false

# --- QTE SISTEM MANCING (MLBB FISHING TIMING BAR) ---
const QTE_TARGET_GOAL = 4   # 4 Foto total yang dicuci
# Area makin mengecil pada klik 1 (36%), klik 2 (26%), klik 3 (18%), klik 4 (11%)
const ZONE_SIZES: Array[float] = [0.36, 0.26, 0.18, 0.11]
# Kecepatan jarum dipercepat dan semakin dinamis pada setiap klik
const SLIDER_SPEEDS: Array[float] = [2.2, 2.45, 2.7, 3.0]
const SOAK_DURATION: float = 1.3

var current_photo_idx: int = 0 # 0..3 (Foto 1, 2, 3, 4)
var photo_sub_click: int = 0   # 0..4 (Pencetan 1, 2, 3, 4 per foto)

var slider_val: float = 0.0    # 0.0 .. 1.0 posisi jarum bergerak
var slider_dir: float = 1.0    # 1.0 (ke kanan) atau -1.0 (ke kiri)
var hit_flash_timer: float = 0.0
var miss_flash_timer: float = 0.0

# Posisi sweet spot / target zone yang bergeser-geser (diacak)
var target_zone_center: float = 0.5

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

# Rak jemuran / tempat foto selesai di kanan bak
var drying_rack_panel: PanelContainer
var rack_card_panels: Array[PanelContainer] = []
var rack_card_rects: Array[TextureRect] = []
var rack_card_labels: Array[Label] = []
var rack_count_label: Label
var rack_finding_desc: Label

var gallery_card_rects: Array[TextureRect] = []
var gallery_card_labels: Array[Label] = []
var selected_photo_idx: int = 3 # Default highlight foto 4 yang paling mengejutkan

# Ukuran Bak dan Foto yang Disesuaikan Sempurna (Foto 100% di dalam bak & cairan kimia)
const BASKOM_W := 540.0
const BASKOM_H := 400.0
const PHOTO_W := 154.0
const PHOTO_H := 174.0
const PHOTO_IDLE_Y := 10.0
const PHOTO_SOAK_Y := 105.0

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
	target_zone_center = 0.5
	selected_photo_idx = 3
	_reset_drying_rack()
	_setup_soak_step()

func _reset_drying_rack() -> void:
	for i in range(rack_card_rects.size()):
		var t_rect = rack_card_rects[i]
		if is_instance_valid(t_rect):
			t_rect.texture = tex_polaroid_dark
			t_rect.modulate = Color(0.25, 0.25, 0.3, 0.45)
		if i < rack_card_labels.size() and is_instance_valid(rack_card_labels[i]):
			rack_card_labels[i].text = "[ Menunggu ]"
			rack_card_labels[i].add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.6))
		if i < rack_card_panels.size() and is_instance_valid(rack_card_panels[i]):
			var sb = rack_card_panels[i].get_theme_stylebox("panel")
			if sb is StyleBoxFlat:
				sb.border_color = Color(0.35, 0.20, 0.25, 0.6)
				sb.set_border_width_all(1)

	if is_instance_valid(rack_count_label):
		rack_count_label.text = "Foto Selesai: 0 / 4"
	if is_instance_valid(rack_finding_desc):
		rack_finding_desc.text = "Rendam klise foto terlebih dahulu di bak air, lalu bilas tepat pada indikator timing bar..."
		rack_finding_desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))

func _reveal_drying_rack_photo(idx: int) -> void:
	if idx < 0 or idx >= 4:
		return

	var textures = [tex_pose1, tex_pose2, tex_pose3, tex_pose4]
	var titles = ["Pose 1: Stasiun", "Pose 2: Diintai", "Pose 3: Lemas", "Pose 4: KORBAN!"]
	var findings = [
		"FOTO 1: Korban terlihat berjalan tergesa-gesa menyusuri peron stasiun kereta api.",
		"FOTO 2: Seseorang berdiri mengintai di balik pilar stasiun, mengawasi korban secara intens.",
		"FOTO 3: Korban terduduk lemas di bangku peron sambil mendekap amplop dan tasnya.",
		"FOTO 4 (FAKTA MENGERIKAN): Korban terkapar kaku... dan wajahnya adalah DETEKTIF BENEDICT SENDIRI?!"
	]

	if idx < rack_card_rects.size() and is_instance_valid(rack_card_rects[idx]):
		rack_card_rects[idx].texture = textures[idx]
		rack_card_rects[idx].modulate = Color.WHITE

	if idx < rack_card_labels.size() and is_instance_valid(rack_card_labels[idx]):
		rack_card_labels[idx].text = titles[idx]
		var col = Color(1.0, 0.35, 0.35) if idx == 3 else Color(0.4, 0.95, 0.7)
		rack_card_labels[idx].add_theme_color_override("font_color", col)

	if idx < rack_card_panels.size() and is_instance_valid(rack_card_panels[idx]):
		var sb = rack_card_panels[idx].get_theme_stylebox("panel")
		if sb is StyleBoxFlat:
			sb.border_color = Color(1.0, 0.3, 0.3, 1.0) if idx == 3 else Color(0.3, 0.9, 0.6, 1.0)
			sb.set_border_width_all(2)

	if is_instance_valid(rack_count_label):
		rack_count_label.text = "Foto Selesai: %d / 4 (Dijejerkan di Rak Kanan)" % (idx + 1)

	if is_instance_valid(rack_finding_desc):
		rack_finding_desc.text = findings[idx]
		var f_col = Color(1.0, 0.45, 0.45) if idx == 3 else Color(0.9, 0.95, 1.0)
		rack_finding_desc.add_theme_color_override("font_color", f_col)

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

	status_label.text = "LANGKAH 2: MEMBILAS & MENGEMBANGKAN 4 FOTO POSE (TIMING BAR CEPAT)"
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

	_randomize_qte_zone()
	_update_step_ui()
	_update_photo_visual()

func _randomize_qte_zone() -> void:
	var ratio = ZONE_SIZES[clamp(photo_sub_click, 0, 3)]
	var half = ratio * 0.5
	var min_c = half + 0.06
	var max_c = 1.0 - half - 0.06
	if max_c <= min_c:
		target_zone_center = 0.5
	else:
		var new_c = randf_range(min_c, max_c)
		for _attempt in range(5):
			if absf(new_c - target_zone_center) >= 0.18:
				break
			new_c = randf_range(min_c, max_c)
		target_zone_center = new_c

	if is_instance_valid(qte_meter_control):
		qte_meter_control.queue_redraw()

func _get_current_speed() -> float:
	return SLIDER_SPEEDS[clamp(photo_sub_click, 0, 3)]

func _update_step_ui() -> void:
	var titles = [
		"FOTO 1/4: PERON STASIUN",
		"FOTO 2/4: PENGINTAIAN DI BALIK PILAR",
		"FOTO 3/4: KORBAN LEMAH DI BANGKU TUNGGU",
		"FOTO 4/4: WAJAH KORBAN PEMBUNUHAN?!"
	]
	var pct_names = [
		"Zona 36% (Awal)",
		"Zona 26% (Mengecil & Geser)",
		"Zona 18% (Cepat & Sempit)",
		"Zona 11% (Krusial Tercepat!)"
	]

	var pips = ""
	for i in range(4):
		pips += " ●" if i < photo_sub_click else " ○"

	var cur_title = titles[clamp(current_photo_idx, 0, 3)]
	if is_instance_valid(photo_step_badge):
		photo_step_badge.text = "[ %s ]" % cur_title
		photo_step_badge.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0))

	if is_instance_valid(qte_pips_label):
		var spd = _get_current_speed()
		qte_pips_label.text = "BILASAN FOTO: [%s ] — Klik %d/4 | %s | Kecepatan: %.1fx" % [
			pips,
			photo_sub_click + 1,
			pct_names[clamp(photo_sub_click, 0, 3)],
			spd
		]

func _update_photo_visual() -> void:
	var photo_textures = [tex_pose1, tex_pose2, tex_pose3, tex_pose4]
	if current_photo_idx >= 0 and current_photo_idx < photo_textures.size() and is_instance_valid(photo_textures[current_photo_idx]):
		photo_preview_rect.texture = photo_textures[current_photo_idx]

	# Tingkat kecerahan bertahap di dalam bak air (setiap klik makin terang)
	match photo_sub_click:
		0:
			photo_preview_rect.modulate = Color(0.18, 0.18, 0.22, 0.65)
		1:
			photo_preview_rect.modulate = Color(0.42, 0.42, 0.48, 0.80)
		2:
			photo_preview_rect.modulate = Color(0.68, 0.68, 0.74, 0.90)
		3:
			photo_preview_rect.modulate = Color(0.88, 0.88, 0.92, 0.96)
		4:
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
		# Gerakan jarum bolak-balik berkecepatan tinggi & dinamis
		var cur_speed = _get_current_speed()
		slider_val += slider_dir * delta * cur_speed
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
	var zone_start = target_zone_center - (zone_ratio * 0.5)
	var zone_end = target_zone_center + (zone_ratio * 0.5)

	# Toleransi margin 0.020 agar tetap adil pada kecepatan tinggi
	if slider_val >= (zone_start - 0.020) and slider_val <= (zone_end + 0.020):
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
		# Jejerkan foto ini ke rak jemuran di kanan bak air
		_reveal_drying_rack_photo(current_photo_idx)

		current_photo_idx += 1
		photo_sub_click = 0 # Balik ke default klik pertama untuk foto berikutnya!

		if current_photo_idx >= QTE_TARGET_GOAL:
			# Keempat foto selesai dibilas!
			_show_photo_revelation()
			return
		else:
			action_hint.text = "FOTO %d/4 SELESAI & DITARUH DI RAK KANAN! Membilas foto berikutnya..." % current_photo_idx
			action_hint.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))
			_randomize_qte_zone()
			_update_step_ui()
			_update_photo_visual()
	else:
		var pct_list = ["36%", "26%", "18%", "11%"]
		action_hint.text = "KLIK %d/4 TEPAT! Kotak bergeser (%s) & jarum makin cepat — Tekan tepat di zona hijau!" % [
			photo_sub_click,
			pct_list[clamp(photo_sub_click, 0, 3)]
		]
		action_hint.add_theme_color_override("font_color", Color(0.4, 0.95, 0.5))
		_randomize_qte_zone()
		_update_step_ui()

func _on_qte_sub_miss() -> void:
	miss_flash_timer = 0.35
	hit_flash_timer = 0.0

	# Getaran visual foto saat gagal bilas
	if is_instance_valid(photo_preview_rect):
		photo_preview_rect.position.x = (BASKOM_W - PHOTO_W) * 0.5 + randf_range(-12.0, 12.0)

	# Jika miss, mengulang ke saat klik pertama foto ini (sub_click = 0)
	photo_sub_click = 0
	_randomize_qte_zone()
	_update_photo_visual()
	_update_step_ui()

	action_hint.text = "MELESET! Bilasan gagal dan mengulang dari klik pertama foto ini (Zona kembali lebar & bergeser)!"
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
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
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
	workbench_box.add_theme_constant_override("separation", 6)
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
	action_hint.add_theme_font_size_override("font_size", 13)
	action_hint.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	workbench_box.add_child(action_hint)

	# TRAY & DRYING RACK SIDE-BY-SIDE (Bak di Kiri, Rak Jemuran Foto di Kanan)
	var work_row = HBoxContainer.new()
	work_row.alignment = BoxContainer.ALIGNMENT_CENTER
	work_row.add_theme_constant_override("separation", 18)
	workbench_box.add_child(work_row)

	# KIRI: BAK AIR CUCI FOTO
	baskom_box = Control.new()
	baskom_box.custom_minimum_size = Vector2(BASKOM_W, BASKOM_H)
	baskom_box.size = Vector2(BASKOM_W, BASKOM_H)
	work_row.add_child(baskom_box)

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

	# KANAN: RAK PENGERINGAN / FOTO SELESAI DIJEJERKAN
	drying_rack_panel = PanelContainer.new()
	var rack_style = StyleBoxFlat.new()
	rack_style.bg_color = Color(0.09, 0.03, 0.05, 0.95)
	rack_style.border_color = Color(0.7, 0.28, 0.32, 1.0)
	rack_style.set_border_width_all(2)
	rack_style.set_corner_radius_all(10)
	rack_style.content_margin_left = 14
	rack_style.content_margin_right = 14
	rack_style.content_margin_top = 10
	rack_style.content_margin_bottom = 10
	drying_rack_panel.add_theme_stylebox_override("panel", rack_style)
	drying_rack_panel.custom_minimum_size = Vector2(490, BASKOM_H)
	work_row.add_child(drying_rack_panel)

	var rack_vb = VBoxContainer.new()
	rack_vb.add_theme_constant_override("separation", 8)
	drying_rack_panel.add_child(rack_vb)

	# Judul Rak
	var rack_header_hb = HBoxContainer.new()
	rack_vb.add_child(rack_header_hb)

	var rack_title = Label.new()
	rack_title.text = "FOTO SELESAI DICUCI (JEMURAN)"
	rack_title.add_theme_font_size_override("font_size", 14)
	rack_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	rack_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rack_header_hb.add_child(rack_title)

	rack_count_label = Label.new()
	rack_count_label.text = "Foto Selesai: 0 / 4"
	rack_count_label.add_theme_font_size_override("font_size", 13)
	rack_count_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	rack_header_hb.add_child(rack_count_label)

	# Garis Jemuran Visual
	var rack_line = ColorRect.new()
	rack_line.custom_minimum_size = Vector2(0, 3)
	rack_line.color = Color(0.6, 0.45, 0.35, 0.9)
	rack_vb.add_child(rack_line)

	# Baris 4 Foto Dijejerkan
	var rack_cards_hb = HBoxContainer.new()
	rack_cards_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	rack_cards_hb.add_theme_constant_override("separation", 8)
	rack_vb.add_child(rack_cards_hb)

	rack_card_panels.clear()
	rack_card_rects.clear()
	rack_card_labels.clear()

	for i in range(4):
		var slot_card = PanelContainer.new()
		var s_style = StyleBoxFlat.new()
		s_style.bg_color = Color(0.06, 0.02, 0.03, 0.9)
		s_style.border_color = Color(0.35, 0.20, 0.25, 0.6)
		s_style.set_border_width_all(1)
		s_style.set_corner_radius_all(6)
		s_style.content_margin_left = 4
		s_style.content_margin_right = 4
		s_style.content_margin_top = 4
		s_style.content_margin_bottom = 4
		slot_card.add_theme_stylebox_override("panel", s_style)
		slot_card.custom_minimum_size = Vector2(104, 155)
		rack_cards_hb.add_child(slot_card)
		rack_card_panels.append(slot_card)

		var slot_vb = VBoxContainer.new()
		slot_vb.add_theme_constant_override("separation", 4)
		slot_card.add_child(slot_vb)

		# Jepitan jemuran kecil
		var clip_rect = ColorRect.new()
		clip_rect.custom_minimum_size = Vector2(16, 5)
		clip_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		clip_rect.color = Color(0.9, 0.75, 0.3, 0.95)
		slot_vb.add_child(clip_rect)

		var slot_tex = TextureRect.new()
		slot_tex.texture = tex_polaroid_dark
		slot_tex.modulate = Color(0.25, 0.25, 0.3, 0.45)
		slot_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot_tex.custom_minimum_size = Vector2(96, 108)
		slot_vb.add_child(slot_tex)
		rack_card_rects.append(slot_tex)

		var slot_lbl = Label.new()
		slot_lbl.text = "[ Menunggu ]"
		slot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_lbl.add_theme_font_size_override("font_size", 11)
		slot_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.6))
		slot_vb.add_child(slot_lbl)
		rack_card_labels.append(slot_lbl)

	# Box Temuan Bukti dari Foto
	var finding_panel = PanelContainer.new()
	var fp_style = StyleBoxFlat.new()
	fp_style.bg_color = Color(0.05, 0.02, 0.03, 0.85)
	fp_style.border_color = Color(0.4, 0.2, 0.25, 0.8)
	fp_style.set_border_width_all(1)
	fp_style.set_corner_radius_all(6)
	fp_style.content_margin_left = 10
	fp_style.content_margin_right = 10
	fp_style.content_margin_top = 8
	fp_style.content_margin_bottom = 8
	finding_panel.add_theme_stylebox_override("panel", fp_style)
	finding_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rack_vb.add_child(finding_panel)

	var fp_vb = VBoxContainer.new()
	fp_vb.add_theme_constant_override("separation", 3)
	finding_panel.add_child(fp_vb)

	var fp_head = Label.new()
	fp_head.text = "BUKTI DARI HASIL CUCI FOTO:"
	fp_head.add_theme_font_size_override("font_size", 11)
	fp_head.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
	fp_vb.add_child(fp_head)

	rack_finding_desc = Label.new()
	rack_finding_desc.text = "Rendam klise foto terlebih dahulu di bak air, lalu bilas tepat pada indikator timing bar..."
	rack_finding_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rack_finding_desc.add_theme_font_size_override("font_size", 12)
	rack_finding_desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	fp_vb.add_child(rack_finding_desc)

	# Progress Bar Langkah 1 (Merendam)
	soak_container = VBoxContainer.new()
	soak_container.add_theme_constant_override("separation", 6)
	workbench_box.add_child(soak_container)

	soak_progress_bar = ProgressBar.new()
	soak_progress_bar.custom_minimum_size = Vector2(520, 24)
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

	# --- QTE BOX: TIMING METER DENGAN ZONA KLIK BERGESER & JARUM CEPAT ---
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
	qte_box.custom_minimum_size = Vector2(560, 95)
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
	qte_pips_label.text = "BILASAN FOTO: [ ○ ○ ○ ○ ] — Klik ke-1/4 | Zona 36% (Awal) | Kecepatan: 2.2x"
	qte_pips_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_pips_label.add_theme_color_override("font_color", Color(0.6, 0.95, 0.8))
	qte_pips_label.add_theme_font_size_override("font_size", 13)
	qte_vb.add_child(qte_pips_label)

	# Timing Meter Bar
	qte_meter_control = Control.new()
	qte_meter_control.custom_minimum_size = Vector2(520, 32)
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

	var unwashed_box = _create_photo_card_box("Sebelum Dicuci", tex_polaroid_dark, -1, false)
	gallery_hb.add_child(unwashed_box)

	var poses_tex = [tex_pose1, tex_pose2, tex_pose3, tex_pose4]
	var poses_title = ["Pose 1: Stasiun", "Pose 2: Diintai", "Pose 3: Lemas", "Pose 4: KORBAN!"]
	gallery_card_rects.clear()

	for i in range(4):
		var is_twist = (i == 3)
		var p_box = _create_photo_card_box(poses_title[i], poses_tex[i], i, is_twist)
		gallery_hb.add_child(p_box)

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
		w = 520.0
		h = 32.0

	# 1. Background Track (Rel Meteran Gelap)
	var track_rect = Rect2(0, 0, w, h)
	qte_meter_control.draw_rect(track_rect, Color(0.08, 0.03, 0.05, 0.95), true)
	qte_meter_control.draw_rect(track_rect, Color(0.40, 0.16, 0.22, 1.0), false, 1.5)

	# 2. Target Zone (Zona Klik Hijau / Luminous Green Yang Bergeser & Mengecil)
	var zone_ratio = ZONE_SIZES[clamp(photo_sub_click, 0, 3)]
	var zone_w = w * zone_ratio
	var zone_x = (target_zone_center - (zone_ratio * 0.5)) * w
	zone_x = clampf(zone_x, 2.0, w - zone_w - 2.0)

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

	# 3. Moving Needle / Slider (Jarum Cepat Meluncur Bolak-Balik)
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
