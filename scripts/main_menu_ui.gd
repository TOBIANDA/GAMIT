extends CanvasLayer

signal play_requested
signal options_opened
signal options_closed

var is_active: bool = false

var root_control: Control
var bg_texture_rect: TextureRect
var btn_play: Button
var btn_options: Button
var btn_credit: Button
var btn_quit: Button

var options_modal: PanelContainer
var credit_modal: PanelContainer

var bgm_slider: HSlider
var sfx_slider: HSlider
var fullscreen_toggle_btn: Button

var click_player: AudioStreamPlayer

var tex_menu_bg: Texture2D

func _ready() -> void:
	layer = 100
	_load_assets()
	_setup_audio()
	_build_menu_ui()

func _load_assets() -> void:
	tex_menu_bg = load("res://UI/Main Menu/main-menu-meja.png")

func _setup_audio() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "MenuClickPlayer"
	var c_stream = load("res://sound/Click sound.mp3")
	if c_stream:
		click_player.stream = c_stream
		click_player.volume_db = -3.0
	add_child(click_player)

func _play_click() -> void:
	if is_instance_valid(click_player) and click_player.stream:
		click_player.play()

func open_menu() -> void:
	is_active = true
	visible = true
	if not is_instance_valid(root_control):
		_build_menu_ui()
	if is_instance_valid(options_modal):
		options_modal.visible = false
	if is_instance_valid(credit_modal):
		credit_modal.visible = false
	_update_button_positions()

func close_menu() -> void:
	is_active = false
	visible = false

func _build_menu_ui() -> void:
	if is_instance_valid(root_control):
		return
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	# 1. Background Ilustrasi Meja Investigasi (5760x3240 Asli)
	bg_texture_rect = TextureRect.new()
	if is_instance_valid(tex_menu_bg):
		bg_texture_rect.texture = tex_menu_bg
	bg_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	root_control.add_child(bg_texture_rect)

	# 2. Header Judul Game di Pojok Atas Tengah
	var title_panel = PanelContainer.new()
	title_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title_panel.position = Vector2(0, 16)
	var tp_style = StyleBoxFlat.new()
	tp_style.bg_color = Color(0.04, 0.05, 0.08, 0.75)
	tp_style.border_color = Color(0.85, 0.7, 0.3, 0.8)
	tp_style.set_border_width_all(1)
	tp_style.set_corner_radius_all(8)
	tp_style.content_margin_left = 24
	tp_style.content_margin_right = 24
	tp_style.content_margin_top = 8
	tp_style.content_margin_bottom = 8
	title_panel.add_theme_stylebox_override("panel", tp_style)
	root_control.add_child(title_panel)

	var title_vb = VBoxContainer.new()
	title_vb.add_theme_constant_override("separation", 2)
	title_panel.add_child(title_vb)

	var main_title = Label.new()
	main_title.text = "AFTER THE END: DETECTIVE BENEDICT"
	main_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	main_title.add_theme_font_size_override("font_size", 18)
	title_vb.add_child(main_title)

	var sub_title = Label.new()
	sub_title.text = "Penyelidikan Kematian Misterius di Dunia Setelah Kematian — Oleh 4 ayam 1 immo"
	sub_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_title.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95))
	sub_title.add_theme_font_size_override("font_size", 12)
	title_vb.add_child(sub_title)

	# 3. Hotspot Buttons Presisi Sesuai Kertas Papan Investigasi:
	# Ukuran asli di latar 5760x3240 adalah 742x209 px (di 1600x900 adalah 206x58 px)
	btn_play = _create_paper_hotspot("PLAY", Vector2(140, 117), Vector2(206, 58))
	btn_play.pressed.connect(_on_play_pressed)
	root_control.add_child(btn_play)

	btn_options = _create_paper_hotspot("OPTIONS", Vector2(141, 271), Vector2(206, 58))
	btn_options.pressed.connect(_on_options_pressed)
	root_control.add_child(btn_options)

	btn_credit = _create_paper_hotspot("CREDIT", Vector2(428, 479), Vector2(206, 58))
	btn_credit.pressed.connect(_on_credit_pressed)
	root_control.add_child(btn_credit)

	btn_quit = _create_paper_hotspot("QUIT", Vector2(160, 743), Vector2(206, 58))
	btn_quit.pressed.connect(_on_quit_pressed)
	root_control.add_child(btn_quit)

	# 4. Modals (Options & Credits)
	_build_options_modal()
	_build_credit_modal()

	root_control.resized.connect(_update_button_positions)
	_update_button_positions()

func _update_button_positions() -> void:
	if not is_instance_valid(root_control):
		return
	var vp_size = root_control.size
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = Vector2(1600, 900)

	var img_orig = Vector2(5760.0, 3240.0)
	var scale_factor = max(vp_size.x / img_orig.x, vp_size.y / img_orig.y)
	var displayed_size = img_orig * scale_factor
	var offset = (vp_size - displayed_size) * 0.5

	# Data posisi tag kertas pada resolusi asli ilustrasi meja 5760x3240
	var tag_data = {
		btn_play: [Vector2(504, 421), Vector2(742, 209)],
		btn_options: [Vector2(507, 975), Vector2(742, 209)],
		btn_credit: [Vector2(1541, 1724), Vector2(742, 209)],
		btn_quit: [Vector2(576, 2675), Vector2(742, 209)]
	}

	for btn in tag_data:
		if is_instance_valid(btn):
			var orig_pos: Vector2 = tag_data[btn][0]
			var orig_size: Vector2 = tag_data[btn][1]
			btn.position = offset + orig_pos * scale_factor
			btn.size = orig_size * scale_factor
			btn.custom_minimum_size = btn.size

func _create_paper_hotspot(btn_text: String, pos: Vector2, btn_size: Vector2) -> Button:
	var btn = Button.new()
	btn.name = "Btn" + btn_text
	btn.position = pos
	btn.size = btn_size
	btn.custom_minimum_size = btn_size
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Transparent normal style with subtle highlight on hover
	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	normal_sb.border_color = Color(1.0, 0.85, 0.3, 0.0)
	normal_sb.set_border_width_all(2)
	normal_sb.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", normal_sb)

	var hover_sb = StyleBoxFlat.new()
	hover_sb.bg_color = Color(1.0, 0.9, 0.5, 0.22)
	hover_sb.border_color = Color(1.0, 0.85, 0.3, 0.95)
	hover_sb.set_border_width_all(2)
	hover_sb.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", hover_sb)
	return btn

func _build_options_modal() -> void:
	options_modal = PanelContainer.new()
	options_modal.set_anchors_preset(Control.PRESET_CENTER)
	options_modal.custom_minimum_size = Vector2(520, 360)
	options_modal.position = Vector2(540, 270)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.10, 0.14, 0.98)
	sb.border_color = Color(0.85, 0.70, 0.35, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 32
	sb.content_margin_right = 32
	sb.content_margin_top = 24
	sb.content_margin_bottom = 24
	options_modal.add_theme_stylebox_override("panel", sb)
	options_modal.visible = false
	root_control.add_child(options_modal)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	options_modal.add_child(vb)

	var title = Label.new()
	title.text = "⚙️ PENGATURAN SUARA & TAMPILAN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 16)
	vb.add_child(title)

	# BGM Slider
	var bgm_hb = HBoxContainer.new()
	vb.add_child(bgm_hb)
	var bgm_lbl = Label.new()
	bgm_lbl.text = "🎵 Volume Musik (BGM):"
	bgm_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bgm_hb.add_child(bgm_lbl)
	bgm_slider = HSlider.new()
	bgm_slider.custom_minimum_size = Vector2(180, 20)
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.05
	bgm_slider.value = 0.8
	bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	bgm_hb.add_child(bgm_slider)

	# SFX Slider
	var sfx_hb = HBoxContainer.new()
	vb.add_child(sfx_hb)
	var sfx_lbl = Label.new()
	sfx_lbl.text = "🔊 Volume Efek Suara (SFX):"
	sfx_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_hb.add_child(sfx_lbl)
	sfx_slider = HSlider.new()
	sfx_slider.custom_minimum_size = Vector2(180, 20)
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = 1.0
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_hb.add_child(sfx_slider)

	# Fullscreen Toggle
	var fs_hb = HBoxContainer.new()
	vb.add_child(fs_hb)
	var fs_lbl = Label.new()
	fs_lbl.text = "🖥️ Mode Layar Penuh (F11):"
	fs_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs_hb.add_child(fs_lbl)
	fullscreen_toggle_btn = Button.new()
	fullscreen_toggle_btn.text = "Toggle Fullscreen"
	fullscreen_toggle_btn.focus_mode = Control.FOCUS_NONE
	fullscreen_toggle_btn.pressed.connect(_on_toggle_fullscreen)
	fs_hb.add_child(fullscreen_toggle_btn)

	# Close Button
	var close_opt_btn = Button.new()
	close_opt_btn.text = "✔ Simpan & Kembali"
	close_opt_btn.custom_minimum_size = Vector2(180, 38)
	close_opt_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_opt_btn.focus_mode = Control.FOCUS_NONE
	close_opt_btn.pressed.connect(func():
		_play_click()
		options_modal.visible = false
		options_closed.emit()
	)
	vb.add_child(close_opt_btn)

func _build_credit_modal() -> void:
	credit_modal = PanelContainer.new()
	credit_modal.set_anchors_preset(Control.PRESET_CENTER)
	credit_modal.custom_minimum_size = Vector2(560, 420)
	credit_modal.position = Vector2(520, 240)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.10, 0.14, 0.98)
	sb.border_color = Color(0.85, 0.70, 0.35, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 32
	sb.content_margin_right = 32
	sb.content_margin_top = 24
	sb.content_margin_bottom = 24
	credit_modal.add_theme_stylebox_override("panel", sb)
	credit_modal.visible = false
	root_control.add_child(credit_modal)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	credit_modal.add_child(vb)

	var title = Label.new()
	title.text = "📜 KREDIT & TIM PENGEMBANG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 16)
	vb.add_child(title)

	var info_lbl = Label.new()
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_lbl.add_theme_font_size_override("font_size", 13)
	info_lbl.text = "Game: After the End - Detective Benedict\nPengembang: Tim 4 ayam 1 immo\nEngine: Godot Engine 4.7.1\n\nGenre: Misteri, Kriminalitas, Narrative Adventure\nTema: 'After the End' — Di mana sang detektif tanpa sadar menyelidiki kematian dirinya sendiri yang telah tiada.\n\nKarakter:\n• Detektif Benedict (Tokoh Utama)\n• Inspektur Marcus (Rekan Kepolisian)\n• Ibu Medeline (Ibunda Tercinta & Pemilik Brankas)\n• Dewa Kematian / Grim (Pemandu Jiwa di Kuil Abadi)\n\nTerima kasih telah memainkan Game IPB!"
	vb.add_child(info_lbl)

	var close_crd_btn = Button.new()
	close_crd_btn.text = "✖ Tutup Kredit"
	close_crd_btn.custom_minimum_size = Vector2(160, 36)
	close_crd_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_crd_btn.focus_mode = Control.FOCUS_NONE
	close_crd_btn.pressed.connect(func():
		_play_click()
		credit_modal.visible = false
	)
	vb.add_child(close_crd_btn)

func _on_play_pressed() -> void:
	_play_click()
	close_menu()
	play_requested.emit()

func _on_options_pressed() -> void:
	_play_click()
	if is_instance_valid(credit_modal):
		credit_modal.visible = false
	if is_instance_valid(options_modal):
		options_modal.visible = true
		options_opened.emit()

func _on_credit_pressed() -> void:
	_play_click()
	if is_instance_valid(options_modal):
		options_modal.visible = false
	if is_instance_valid(credit_modal):
		credit_modal.visible = true

func _on_quit_pressed() -> void:
	_play_click()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _on_bgm_volume_changed(val: float) -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	# Atur audio bus Master jika belum ada bus BGM terpisah
	if master_bus != -1:
		var db = linear_to_db(val) if val > 0.0 else -80.0
		AudioServer.set_bus_volume_db(master_bus, db)

func _on_sfx_volume_changed(_val: float) -> void:
	_play_click()

func _on_toggle_fullscreen() -> void:
	_play_click()
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
