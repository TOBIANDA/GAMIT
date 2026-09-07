extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var shrine: Node2D = get_node_or_null("DeathGodShrine")
@onready var dialog_box: CanvasLayer = $DialogBox
@onready var hud_speed_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var hud_pos_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/PosLabel
@onready var hud_zoom_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/ZoomLabel
@onready var hud_objective_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/ObjectiveLabel

var server_pid: int = -1

var inv_mgr: Node
var world_shader: CanvasLayer
var clue_journal: CanvasLayer
var minigame_tailgate: CanvasLayer
var minigame_hidden_objects: CanvasLayer
var minigame_photo_wash: CanvasLayer
var minigame_safe: CanvasLayer
var death_god_layer: CanvasLayer

var interact_prompt: Button
var toast_banner: PanelContainer
var toast_label: Label
var toast_timer: float = 0.0

var active_poi_id: String = ""

var house_interior: Node2D
var is_inside_house: bool = false
var transition_overlay: ColorRect
var transition_layer: CanvasLayer

const POI_LOCATIONS = {
	"desk": {"name": "Masuk ke Rumah Benedict", "pos": Vector2(1170, 230), "radius": 150.0},
	"police": {"name": "Kantor Polisi & Marcus (Minigame Menguntit)", "pos": Vector2(350, 350), "radius": 220.0},
	"station": {"name": "Stasiun Kereta Api (Minigame Cari Bukti)", "pos": Vector2(2020, 930), "radius": 320.0},
	"hospital": {"name": "Rumah Sakit & Kamar Mayat", "pos": Vector2(750, 1095), "radius": 160.0},
	"phone": {"name": "Bilik Telepon Umum", "pos": Vector2(480, 240), "radius": 85.0}
}

var bgm_player: AudioStreamPlayer
var click_sfx_player: AudioStreamPlayer
var door_sfx_player: AudioStreamPlayer

func _ready() -> void:
	print("[Main] Menginisialisasi Sistem Lengkap Sesuai GDD...")

	_setup_audio_system()
	_setup_dialog_box()
	_setup_transition_overlay()
	_setup_house_interior()
	_setup_investigation_manager()
	_setup_world_shader()
	_setup_clue_journal()
	_setup_minigames()
	_setup_letter_viewer()
	_setup_hud_prompts()
	_start_ai_server()

	_update_hud_objective()

func _setup_dialog_box() -> void:
	if not is_instance_valid(dialog_box):
		dialog_box = get_node_or_null("DialogBox")
	if not is_instance_valid(dialog_box):
		var dlg_scene = load("res://scenes/dialog_box.tscn")
		if dlg_scene:
			dialog_box = dlg_scene.instantiate()
			dialog_box.name = "DialogBox"
			add_child(dialog_box)
	if is_instance_valid(dialog_box):
		if not dialog_box.dialog_opened.is_connected(_on_dialog_opened):
			dialog_box.dialog_opened.connect(_on_dialog_opened)
		if not dialog_box.dialog_closed.is_connected(_on_dialog_closed):
			dialog_box.dialog_closed.connect(_on_dialog_closed)

func _setup_audio_system() -> void:
	# 1. Background Music Player (BGM.mp3)
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	var bgm_stream = load("res://sound/BGM.mp3")
	if bgm_stream:
		bgm_player.stream = bgm_stream
		bgm_player.volume_db = -10.0
		bgm_player.finished.connect(func(): if is_instance_valid(bgm_player): bgm_player.play())
	add_child(bgm_player)
	if bgm_stream:
		bgm_player.play()

	# 2. Global Click SFX Player (Click sound.mp3)
	click_sfx_player = AudioStreamPlayer.new()
	click_sfx_player.name = "ClickSFXPlayer"
	var click_stream = load("res://sound/Click sound.mp3")
	if click_stream:
		click_sfx_player.stream = click_stream
		click_sfx_player.volume_db = -4.0
	add_child(click_sfx_player)

	# 3. Door SFX Player (Door Open.mp3)
	door_sfx_player = AudioStreamPlayer.new()
	door_sfx_player.name = "DoorSFXPlayer"
	var door_stream = load("res://sound/Door Open.mp3")
	if door_stream:
		door_sfx_player.stream = door_stream
		door_sfx_player.volume_db = -3.0
	add_child(door_sfx_player)

func play_click_sfx() -> void:
	if is_instance_valid(click_sfx_player) and click_sfx_player.stream:
		click_sfx_player.play()

func play_door_sfx() -> void:
	if is_instance_valid(door_sfx_player) and door_sfx_player.stream:
		door_sfx_player.play()

func _setup_transition_overlay() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.name = "TransitionLayer"
	transition_layer.layer = 25
	add_child(transition_layer)

	transition_overlay = ColorRect.new()
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color(0, 0, 0, 0.0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(transition_overlay)

func _setup_house_interior() -> void:
	var hi_script = load("res://scripts/house_interior.gd")
	if hi_script:
		house_interior = Node2D.new()
		house_interior.name = "HouseInterior"
		house_interior.set_script(hi_script)
		add_child(house_interior)

func _enter_house() -> void:
	if not is_instance_valid(player):
		return
	player.can_move = false
	play_door_sfx()

	var tw = create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.20)
	tw.tween_callback(func():
		is_inside_house = true
		player.global_position = Vector2(3600.0 + 270.0, 400.0 + 310.0)
		_show_toast("🏠 Masuk ke Dalam Rumah Benedict.")
	)
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		player.can_move = true
	)

func _exit_house() -> void:
	if not is_instance_valid(player):
		return
	player.can_move = false
	play_door_sfx()

	var tw = create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.20)
	tw.tween_callback(func():
		is_inside_house = false
		player.global_position = Vector2(1170.0, 250.0)
		_show_toast("🚪 Keluar ke Jalan Kota.")
	)
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		player.can_move = true
	)

func _trigger_indoor_letter_monologue() -> void:
	if not is_instance_valid(dialog_box):
		_open_letter_closeup()
		return

	var monologue_lines: Array[String] = [
		"hmmmmm.......",
		"dari mana ya aku harus memulai",
		"sepertinya aku harus menjumpai inspektur markus dulu"
	]
	if is_instance_valid(player):
		player.can_move = false

	dialog_box.start_monologue(monologue_lines, "Detektif Benedict", "[ Monolog Batin ]", "res://UI/mc_portrait.png")
	dialog_box.monologue_finished.connect(func():
		_open_letter_closeup()
	, CONNECT_ONE_SHOT)

func _setup_investigation_manager() -> void:
	inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr):
		var mgr_script = load("res://scripts/investigation_manager.gd")
		if mgr_script:
			inv_mgr = Node.new()
			inv_mgr.name = "InvestigationManager"
			inv_mgr.set_script(mgr_script)
			add_child(inv_mgr)
	if is_instance_valid(inv_mgr):
		if not inv_mgr.phase_changed.is_connected(_on_phase_changed):
			inv_mgr.phase_changed.connect(_on_phase_changed)
		if not inv_mgr.notification_displayed.is_connected(_show_toast):
			inv_mgr.notification_displayed.connect(_show_toast)

func _setup_world_shader() -> void:
	var ws_script = load("res://scripts/world_shader.gd")
	if ws_script:
		world_shader = CanvasLayer.new()
		world_shader.name = "WorldShader"
		world_shader.set_script(ws_script)
		add_child(world_shader)

func _setup_clue_journal() -> void:
	var cj_script = load("res://scripts/clue_journal.gd")
	if cj_script:
		clue_journal = CanvasLayer.new()
		clue_journal.name = "ClueJournal"
		clue_journal.set_script(cj_script)
		add_child(clue_journal)
		clue_journal.journal_opened.connect(func(): if is_instance_valid(player): player.can_move = false)
		clue_journal.journal_closed.connect(func(): if is_instance_valid(player): player.can_move = true)

func _setup_minigames() -> void:
	var mg1_script = load("res://scripts/minigame_tailgate.gd")
	if mg1_script:
		minigame_tailgate = CanvasLayer.new()
		minigame_tailgate.name = "MinigameTailgate"
		minigame_tailgate.set_script(mg1_script)
		add_child(minigame_tailgate)
		minigame_tailgate.minigame_completed.connect(func(_ok): _on_minigame_ended())

	var mg2_script = load("res://scripts/minigame_hidden_objects.gd")
	if mg2_script:
		minigame_hidden_objects = CanvasLayer.new()
		minigame_hidden_objects.name = "MinigameHiddenObjects"
		minigame_hidden_objects.set_script(mg2_script)
		add_child(minigame_hidden_objects)
		minigame_hidden_objects.minigame_completed.connect(func(_ok): _on_minigame_ended())

	var mg3_script = load("res://scripts/minigame_photo_wash.gd")
	if mg3_script:
		minigame_photo_wash = CanvasLayer.new()
		minigame_photo_wash.name = "MinigamePhotoWash"
		minigame_photo_wash.set_script(mg3_script)
		add_child(minigame_photo_wash)
		minigame_photo_wash.minigame_completed.connect(func(_ok): _on_minigame_ended())

	var safe_script = load("res://scripts/minigame_safe.gd")
	if safe_script:
		minigame_safe = CanvasLayer.new()
		minigame_safe.name = "MinigameSafe"
		minigame_safe.set_script(safe_script)
		add_child(minigame_safe)
		minigame_safe.safe_opened.connect(func(_ok): _on_minigame_ended())

	var dg_script = load("res://scripts/death_god.gd")
	if dg_script:
		death_god_layer = CanvasLayer.new()
		death_god_layer.name = "DeathGodLayer"
		death_god_layer.set_script(dg_script)
		add_child(death_god_layer)
		death_god_layer.death_god_closed.connect(func(): _on_minigame_ended())

func _on_minigame_ended() -> void:
	if is_instance_valid(player):
		player.can_move = true
	_update_hud_objective()

var letter_layer: CanvasLayer
var letter_root_control: Control
var letter_rect: TextureRect
var letter_close_btn: Button

func _setup_letter_viewer() -> void:
	letter_layer = CanvasLayer.new()
	letter_layer.name = "LetterViewer"
	letter_layer.layer = 15
	add_child(letter_layer)

	letter_root_control = Control.new()
	letter_root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter_layer.add_child(letter_root_control)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.03, 0.06, 0.88)
	bg.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_close_letter_viewer()
	)
	letter_root_control.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter_root_control.add_child(center)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	center.add_child(vb)

	# Container kertas surat dengan batasan ukuran agar pas di layar
	var letter_box = Control.new()
	letter_box.custom_minimum_size = Vector2(520, 540)
	vb.add_child(letter_box)

	letter_rect = TextureRect.new()
	var tex_close = load("res://Environment/interactable assets/surat close up.png")
	if is_instance_valid(tex_close):
		letter_rect.texture = tex_close
	letter_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	letter_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	letter_box.add_child(letter_rect)

	# Overlay teks surat otentik di atas kertas amplop
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 44)
	letter_box.add_child(margin)

	var text_vb = VBoxContainer.new()
	text_vb.add_theme_constant_override("separation", 8)
	margin.add_child(text_vb)

	var header_label = Label.new()
	header_label.text = "BERKAS PENYELIDIKAN #404"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.add_theme_color_override("font_color", Color(0.20, 0.14, 0.08))
	header_label.add_theme_font_size_override("font_size", 16)
	text_vb.add_child(header_label)

	var sub_label = Label.new()
	sub_label.text = "KASUS: KEMATIAN MISTERIUS DI JALUR REL STASIUN"
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_color_override("font_color", Color(0.60, 0.18, 0.18))
	sub_label.add_theme_font_size_override("font_size", 11)
	text_vb.add_child(sub_label)

	var hsep = HSeparator.new()
	var hsep_style = StyleBoxLine.new()
	hsep_style.color = Color(0.45, 0.35, 0.25, 0.5)
	hsep_style.thickness = 2
	hsep.add_theme_stylebox_override("separator", hsep_style)
	text_vb.add_child(hsep)

	var body_rtl = RichTextLabel.new()
	body_rtl.bbcode_enabled = true
	body_rtl.fit_content = true
	body_rtl.scroll_active = false
	body_rtl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_rtl.text = "[color=#261e16][b]Kepada Detektif Benedict,[/b]\n\nSebuah insiden kematian misterius dilaporkan terjadi di sekitar jalur rel peron [b]Stasiun Kereta Api Timur[/b]. Korban adalah seorang pria tanpa identitas resmi yang berencana naik kereta ke luar kota.\n\n[b]Petunjuk & Tugas:[/b]\n• Temui [b]Inspektur Marcus[/b] di Kantor Polisi untuk meminta keterangan saksi dan rincian olah TKP.\n• Telusuri peron stasiun untuk mencari petunjuk dan mengamankan amplop rol foto korban.\n• Cuci foto di bak kamar gelap rumah untuk mengungkap wajah dan identitas korban!\n\n[i]— Kepala Departemen Penyelidikan[/i][/color]"
	body_rtl.add_theme_font_size_override("normal_font_size", 13)
	body_rtl.add_theme_font_size_override("bold_font_size", 13)
	body_rtl.add_theme_font_size_override("italic_font_size", 12)
	text_vb.add_child(body_rtl)

	# Tombol silang kecil di pojok kanan atas surat
	var x_btn = Button.new()
	x_btn.text = "✕"
	x_btn.custom_minimum_size = Vector2(28, 28)
	x_btn.position = Vector2(520 - 36, 12)
	var x_style = StyleBoxFlat.new()
	x_style.bg_color = Color(0.4, 0.15, 0.15, 0.8)
	x_style.set_corner_radius_all(14)
	x_btn.add_theme_stylebox_override("normal", x_style)
	x_btn.pressed.connect(_close_letter_viewer)
	letter_box.add_child(x_btn)

	letter_close_btn = Button.new()
	letter_close_btn.text = "✔ Simpan ke Jurnal & Lanjutkan Investigasi [ESC / Spasi]"
	letter_close_btn.custom_minimum_size = Vector2(440, 42)
	letter_close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var lcb_style = StyleBoxFlat.new()
	lcb_style.bg_color = Color(0.12, 0.18, 0.30, 0.95)
	lcb_style.border_color = Color(0.9, 0.75, 0.3, 1.0)
	lcb_style.set_border_width_all(2)
	lcb_style.set_corner_radius_all(8)
	letter_close_btn.add_theme_stylebox_override("normal", lcb_style)
	letter_close_btn.pressed.connect(_close_letter_viewer)
	vb.add_child(letter_close_btn)

	var letter_photo_btn = Button.new()
	letter_photo_btn.text = "🧪 Langsung Buka Minigame Cuci Foto Polaroid"
	letter_photo_btn.custom_minimum_size = Vector2(440, 38)
	letter_photo_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var lpb_style = StyleBoxFlat.new()
	lpb_style.bg_color = Color(0.18, 0.38, 0.28, 0.95)
	lpb_style.border_color = Color(0.35, 0.85, 0.5, 1.0)
	lpb_style.set_border_width_all(1)
	lpb_style.set_corner_radius_all(6)
	letter_photo_btn.add_theme_stylebox_override("normal", lpb_style)
	letter_photo_btn.pressed.connect(func():
		_close_letter_viewer()
		if is_instance_valid(minigame_photo_wash):
			player.can_move = false
			minigame_photo_wash.start_minigame()
	)
	vb.add_child(letter_photo_btn)

	letter_root_control.visible = false

func _open_letter_closeup() -> void:
	if is_instance_valid(letter_root_control):
		letter_root_control.visible = true
		if is_instance_valid(player):
			player.can_move = false

func _close_letter_viewer() -> void:
	if is_instance_valid(letter_root_control):
		letter_root_control.visible = false
	if is_instance_valid(player):
		player.can_move = true
	if is_instance_valid(inv_mgr):
		if inv_mgr.current_phase == inv_mgr.Phase.PROLOGUE_HOME:
			_show_toast("✉️ Surat Tugas: Temui Inspektur Marcus di Kantor Polisi!")
			inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_1_POLICE)

func _setup_hud_prompts() -> void:
	var hud_layer = $HUD
	if not is_instance_valid(hud_layer):
		return

	interact_prompt = Button.new()
	interact_prompt.text = "👉 [ F / E / Spasi ] KLIK UNTUK INTERAKSI"
	interact_prompt.custom_minimum_size = Vector2(460, 52)
	interact_prompt.focus_mode = Control.FOCUS_NONE
	interact_prompt.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	interact_prompt.add_theme_font_size_override("font_size", 15)

	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.06, 0.08, 0.16, 0.92)
	btn_normal.border_color = Color(1.0, 0.85, 0.3, 1.0)
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(10)
	btn_normal.content_margin_left = 18
	btn_normal.content_margin_right = 18
	btn_normal.content_margin_top = 8
	btn_normal.content_margin_bottom = 8
	interact_prompt.add_theme_stylebox_override("normal", btn_normal)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.16, 0.22, 0.36, 0.96)
	btn_hover.border_color = Color(1.0, 1.0, 0.5, 1.0)
	interact_prompt.add_theme_stylebox_override("hover", btn_hover)
	interact_prompt.add_theme_stylebox_override("pressed", btn_hover)

	interact_prompt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.4))
	interact_prompt.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.8))

	interact_prompt.pressed.connect(func():
		play_click_sfx()
		if not active_poi_id.is_empty():
			_trigger_poi_interaction(active_poi_id)
	)
	interact_prompt.visible = false
	hud_layer.add_child(interact_prompt)

	toast_banner = PanelContainer.new()
	toast_banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	toast_banner.position = Vector2(0, 15)
	var t_style = StyleBoxFlat.new()
	t_style.bg_color = Color(0.06, 0.08, 0.14, 0.95)
	t_style.border_color = Color(0.9, 0.7, 0.3, 0.9)
	t_style.set_border_width_all(2)
	t_style.set_corner_radius_all(8)
	t_style.content_margin_left = 24
	t_style.content_margin_right = 24
	t_style.content_margin_top = 8
	t_style.content_margin_bottom = 8
	toast_banner.add_theme_stylebox_override("panel", t_style)
	toast_banner.visible = false
	hud_layer.add_child(toast_banner)

	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	toast_label.add_theme_font_size_override("font_size", 14)
	toast_banner.add_child(toast_label)

func _show_toast(msg: String) -> void:
	if is_instance_valid(toast_label) and is_instance_valid(toast_banner):
		toast_label.text = msg
		toast_banner.visible = true
		toast_timer = 3.5

func _process(delta: float) -> void:
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_banner.visible = false

	if is_instance_valid(player):
		if is_instance_valid(hud_speed_label):
			var spd = player.velocity.length()
			var mode_str = " (Lari/Shift)" if player.is_sprinting else " (Jalan)"
			hud_speed_label.text = "Kecepatan: %.0f px/s%s" % [spd, mode_str if spd > 10.0 else ""]
		if is_instance_valid(hud_pos_label):
			hud_pos_label.text = "Posisi: (X: %.0f, Y: %.0f)" % [player.global_position.x, player.global_position.y]
		if is_instance_valid(hud_zoom_label) and player.has_method("get_zoom_level"):
			hud_zoom_label.text = "Penglihatan (Zoom): %.1fx" % player.get_zoom_level()

		_check_poi_proximity()

func _check_poi_proximity() -> void:
	if not is_instance_valid(player):
		return

	var p_pos = player.global_position

	if is_inside_house:
		var desk_letter_pos = Vector2(3600.0 + 410.0, 400.0 + 250.0)
		var safe_pos = Vector2(3600.0 + 505.0, 400.0 + 215.0)
		var photo_basin_pos = Vector2(3600.0 + 335.0, 400.0 + 83.0)
		var exit_door_pos = Vector2(3600.0 + 270.0, 400.0 + 342.0)

		if p_pos.distance_to(desk_letter_pos) <= 52.0:
			active_poi_id = "indoor_letter"
		elif p_pos.distance_to(safe_pos) <= 42.0:
			active_poi_id = "indoor_safe"
		elif p_pos.distance_to(photo_basin_pos) <= 42.0:
			active_poi_id = "indoor_photo_basin"
		elif p_pos.distance_to(exit_door_pos) <= 38.0 or (p_pos.y >= (400.0 + 332.0) and abs(p_pos.x - (3600.0 + 270.0)) <= 38.0):
			active_poi_id = "indoor_exit"
		else:
			active_poi_id = ""

		if active_poi_id.is_empty():
			if is_instance_valid(interact_prompt):
				interact_prompt.visible = false
		else:
			if is_instance_valid(interact_prompt):
				match active_poi_id:
					"indoor_letter":
						interact_prompt.text = "👉 [ F / E / Spasi ] BACA SURAT DI ATAS MEJA"
					"indoor_safe":
						interact_prompt.text = "👉 [ F / E / Spasi ] BUKA BRANKAS BAJA KELUARGA"
					"indoor_photo_basin":
						interact_prompt.text = "👉 [ F / E / Spasi ] KAMAR GELAP: CUCI FOTO POLAROID"
					"indoor_exit":
						interact_prompt.text = "👉 [ F / E / Spasi ] KELUAR KE KOTA"
				var vp = get_viewport().get_visible_rect().size
				interact_prompt.position = Vector2(vp.x * 0.5 - 230, vp.y - 85)
				interact_prompt.visible = true
		return

	var closest_dist: float = 999999.0
	var best_poi: String = ""

	# Check bounding boxes for large complex areas first
	# 1. Stasiun Kereta Api (seluruh gedung, parkiran, peron, dan rel: x 1850..2350, y 670..1310)
	if p_pos.x >= 1850.0 and p_pos.x <= 2350.0 and p_pos.y >= 670.0 and p_pos.y <= 1310.0:
		best_poi = "station"
		closest_dist = 0.0
	# 2. Rumah Benedict (halaman, gerbang, dan jalan depan rumah: x 1050..1350, y 20..330)
	elif not is_inside_house and p_pos.x >= 1050.0 and p_pos.x <= 1350.0 and p_pos.y >= 20.0 and p_pos.y <= 330.0:
		best_poi = "desk"
		closest_dist = 0.0
	else:
		for poi_key in POI_LOCATIONS.keys():
			var poi = POI_LOCATIONS[poi_key]
			var dist = p_pos.distance_to(poi["pos"])
			if dist <= poi["radius"] and dist < closest_dist:
				closest_dist = dist
				best_poi = poi_key

	active_poi_id = best_poi

	if active_poi_id.is_empty():
		if is_instance_valid(interact_prompt):
			interact_prompt.visible = false
	else:
		if is_instance_valid(interact_prompt):
			var poi_info = POI_LOCATIONS[active_poi_id]
			interact_prompt.text = "👉 [ F / E / Spasi ] KLIK / TEKAN: " + poi_info["name"]
			var vp = get_viewport().get_visible_rect().size
			interact_prompt.position = Vector2(vp.x * 0.5 - 230, vp.y - 85)
			interact_prompt.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if is_instance_valid(letter_root_control) and letter_root_control.visible:
			if event.keycode in [KEY_ESCAPE, KEY_SPACE, KEY_ENTER, KEY_F, KEY_E]:
				_close_letter_viewer()
				get_viewport().set_input_as_handled()
				return

		if event.keycode == KEY_X:
			_trigger_death_god()
			get_viewport().set_input_as_handled()
			return

		# Pintasan cepat tombol angka untuk langsung uji coba semua minigame kapan saja:
		if event.keycode == KEY_1:
			_trigger_poi_interaction("police")
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_2:
			_trigger_poi_interaction("station")
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_3:
			if is_instance_valid(minigame_photo_wash):
				player.can_move = false
				minigame_photo_wash.start_minigame()
				_show_toast("🧪 Uji Coba: Minigame Cuci Foto Polaroid Dimulai!")
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_4:
			_trigger_poi_interaction("indoor_safe" if is_inside_house else "safe")
			get_viewport().set_input_as_handled()
			return

		if event.keycode in [KEY_F, KEY_E, KEY_SPACE, KEY_ENTER]:
			if not active_poi_id.is_empty():
				_trigger_poi_interaction(active_poi_id)
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_J:
			if is_instance_valid(clue_journal):
				clue_journal.toggle_journal()
				get_viewport().set_input_as_handled()
				return

func _trigger_poi_interaction(poi_id: String) -> void:
	if not is_instance_valid(inv_mgr):
		return

	match poi_id:
		"desk":
			_enter_house()

		"indoor_letter":
			_trigger_indoor_letter_monologue()

		"indoor_safe":
			if is_instance_valid(minigame_safe):
				player.can_move = false
				minigame_safe.start_minigame()
				_show_toast("🗝️ Membuka Brankas Baja Keluarga!")

		"indoor_photo_basin":
			if is_instance_valid(minigame_photo_wash):
				player.can_move = false
				minigame_photo_wash.start_minigame()
				_show_toast("🧪 Masuk ke Kamar Gelap: Cuci Foto Polaroid!")

		"indoor_exit":
			_exit_house()

		"police":
			var marcus_npc = find_child("NPC4", true, false)
			if not is_instance_valid(marcus_npc):
				marcus_npc = find_child("NPC1", true, false)
			if is_instance_valid(minigame_tailgate) and is_instance_valid(marcus_npc):
				player.can_move = false
				minigame_tailgate.start_minigame(player, marcus_npc)
				_show_toast("🕵️ Minigame Menguntit Marcus dimulai! Jaga jarak aman!")
			else:
				_show_toast("Kantor Polisi: 'Detektif, kami sedang menangani penyelidikan kasus 404.'")

		"station":
			if is_instance_valid(minigame_hidden_objects):
				player.can_move = false
				minigame_hidden_objects.start_minigame()
				_show_toast("🔍 Minigame Stasiun: Cari 3 Objek Bukti Tersembunyi!")
			else:
				_show_toast("Peron Stasiun Kereta Api Timur. Angin dingin berhembus sunyi.")

		"hospital":
			inv_mgr.unlock_clue("autopsy_corpse")
			inv_mgr.set_phase(inv_mgr.Phase.FINAL_DEATH_GOD)
			_show_toast("🩺 Rumah Sakit: Kamu melihat jasad dirimu sendiri... Tekan [X] untuk Dewa Kematian!")
			if is_instance_valid(dialog_box):
				dialog_box.open_dialog("...Detektif Benedict. Tataplah tubuh yang terbaring kaku itu. Kamu bukan lagi detektif yang bernafas... kamu adalah arwah yang mencari kebenaran tentang kematianmu sendiri. Tekan [X] kapan saja untuk memanggilku...")

		"safe":
			if is_instance_valid(minigame_safe):
				player.can_move = false
				minigame_safe.start_minigame()
				_show_toast("🗝️ Membuka Brankas Baja Rumah Ibu!")

		"phone":
			_show_toast("📞 Gagang telepon berdering hening... 'Waktu kematian tidak dapat diulang...'")

func _trigger_death_god() -> void:
	if is_instance_valid(player):
		player.can_move = false
	if is_instance_valid(death_god_layer) and death_god_layer.has_method("open_interface"):
		death_god_layer.open_interface()
	else:
		_summon_death_god()

func _summon_death_god() -> void:
	if is_instance_valid(dialog_box):
		var prompt = ""
		if is_instance_valid(inv_mgr):
			if inv_mgr.has_emotional_item() and inv_mgr.is_clue_unlocked("autopsy_corpse"):
				prompt = "✦ SANG DEWA KEMATIAN MUNCUL DI HADAPANMU ✦\n\nWahai jiwa Benedict... Kamu telah memanggilku. Di dalam genggaman jiwamu, tersimpan liontin kasih sayang Ibu Medeline yang belum tuntas.\n\nKatakan padaku apa yang kau rasakan sekarang untuk melangkah ke peristirahatan abadi..."
			elif inv_mgr.is_clue_unlocked("autopsy_corpse"):
				prompt = "✦ SANG DEWA KEMATIAN MUNCUL DI HADAPANMU ✦\n\nWahai Benedict... Kamu telah memanggilku dan mengetahui fakta bahwa kamu telah tiada. Katakan padaku apa yang telah kau pelajari tentang takdirmu..."
			else:
				prompt = "✦ SANG DEWA KEMATIAN MUNCUL DI HADAPANMU ✦\n\nWahai pengelana fana... Mengapa kamu memanggilku? Katakan padaku apa yang kau cari dalam keheningan ini..."
		
		dialog_box.open_dialog(prompt)

func _on_dialog_opened() -> void:
	if is_instance_valid(player):
		player.can_move = false
	if is_instance_valid(shrine) and shrine.has_method("set_dialog_active"):
		shrine.set_dialog_active(true)

func _on_dialog_closed() -> void:
	if is_instance_valid(player):
		player.can_move = true
	if is_instance_valid(shrine) and shrine.has_method("set_dialog_active"):
		shrine.set_dialog_active(false)

func _on_phase_changed(_p: int, _title: String) -> void:
	_update_hud_objective()

func _update_hud_objective() -> void:
	if is_instance_valid(hud_objective_label) and is_instance_valid(inv_mgr):
		hud_objective_label.text = "🎯 Target: " + inv_mgr.get_current_objective_title()

func _on_journal_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(clue_journal):
		clue_journal.toggle_journal()

func _on_reset_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player):
		player.global_position = Vector2(1170, 270)
		player.velocity = Vector2.ZERO

func _on_zoom_in_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player) and player.has_method("zoom_in"):
		player.zoom_in()

func _on_zoom_out_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player) and player.has_method("zoom_out"):
		player.zoom_out()

func _on_zoom_reset_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player) and player.has_method("reset_zoom"):
		player.reset_zoom()

func _start_ai_server() -> void:
	var exe_path = OS.get_executable_path().get_base_dir() + "/ai_server.exe"
	if FileAccess.file_exists(exe_path):
		server_pid = OS.create_process(exe_path, [])
		print("[Main] Server AI dimulai dari .exe (PID: %d)" % server_pid)
		return

	var dev_path = ProjectSettings.globalize_path("res://ai_server/main.py")
	if FileAccess.file_exists(dev_path):
		server_pid = OS.create_process("python", [dev_path])
		if server_pid != -1:
			print("[Main] Server AI Python development dimulai (PID: %d)" % server_pid)
		else:
			server_pid = OS.create_process("py", [dev_path])
			print("[Main] Server AI 'py' dimulai (PID: %d)" % server_pid)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if server_pid != -1:
			OS.kill(server_pid)
			print("[Main] Server AI dihentikan.")
		get_tree().quit()
