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
var credit_modal: Control

var bgm_slider: HSlider
var sfx_slider: HSlider
var fullscreen_toggle_btn: Button

var click_player: AudioStreamPlayer
var menu_bgm_player: AudioStreamPlayer

var tex_menu_bg: Texture2D
var tex_credit: Texture2D
var tex_title: Texture2D
var title_texture_rect: TextureRect

func _ready() -> void:
	layer = 100
	_load_assets()
	_setup_audio()
	_build_menu_ui()
	if is_active and is_instance_valid(menu_bgm_player) and menu_bgm_player.stream and not menu_bgm_player.playing:
		menu_bgm_player.play()

func _load_assets() -> void:
	tex_menu_bg = load("res://Main Menu/main-menu-meja.png")
	if not tex_menu_bg:
		tex_menu_bg = load("res://UI/Main Menu/main-menu-meja.png")
	tex_credit = load("res://Main Menu/credit.png")
	tex_title = load("res://judul.png")
	if not tex_title:
		tex_title = load("res://Main Menu/judul.png")

func _setup_audio() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "MenuClickPlayer"
	var c_stream = load("res://sound/Click sound.mp3")
	if c_stream:
		click_player.stream = c_stream
		click_player.volume_db = -3.0
	add_child(click_player)

	menu_bgm_player = AudioStreamPlayer.new()
	menu_bgm_player.name = "MenuBGMPlayer"
	var m_stream = load("res://main menu.mp3")
	if not m_stream:
		m_stream = load("res://sound/BGM.mp3")
	if m_stream:
		if m_stream is AudioStreamMP3:
			m_stream.loop = true
		menu_bgm_player.stream = m_stream
		menu_bgm_player.volume_db = -6.0
		menu_bgm_player.finished.connect(func(): if is_instance_valid(menu_bgm_player) and is_active: menu_bgm_player.play())
	add_child(menu_bgm_player)

func _play_click() -> void:
	if is_instance_valid(click_player) and click_player.stream:
		click_player.play()

func open_menu() -> void:
	is_active = true
	visible = true
	_load_assets()
	if not is_instance_valid(root_control):
		_build_menu_ui()
	elif is_instance_valid(title_texture_rect) and not title_texture_rect.texture and is_instance_valid(tex_title):
		title_texture_rect.texture = tex_title
	if is_instance_valid(options_modal):
		options_modal.visible = false
	if is_instance_valid(credit_modal):
		credit_modal.visible = false
	_update_button_positions()
	if is_instance_valid(menu_bgm_player) and menu_bgm_player.is_inside_tree() and menu_bgm_player.stream and not menu_bgm_player.playing:
		menu_bgm_player.play()

func close_menu() -> void:
	is_active = false
	visible = false
	if is_instance_valid(menu_bgm_player) and menu_bgm_player.playing:
		menu_bgm_player.stop()

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
	bg_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root_control.add_child(bg_texture_rect)

	# 2. Header Judul Game (res://judul.png)
	title_texture_rect = TextureRect.new()
	title_texture_rect.name = "TitleTextureRect"
	if is_instance_valid(tex_title):
		title_texture_rect.texture = tex_title
	title_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(title_texture_rect)

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
	var vp_size = get_viewport().get_visible_rect().size if is_inside_tree() and get_viewport() else root_control.size
	if vp_size.x <= 0 or vp_size.y <= 0:
		vp_size = Vector2(1600, 900)
	if root_control.anchor_right != 1.0 or root_control.anchor_bottom != 1.0:
		root_control.size = vp_size
		root_control.position = Vector2.ZERO

	var img_orig = Vector2(5760.0, 3240.0)
	var scale_factor = min(vp_size.x / img_orig.x, vp_size.y / img_orig.y)
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

	if is_instance_valid(title_texture_rect):
		var title_w: float = clamp(vp_size.x * 0.54, 420.0, 960.0)
		var title_h: float = title_w * (200.0 / 1920.0)
		title_texture_rect.size = Vector2(title_w, title_h)
		title_texture_rect.position = Vector2((vp_size.x - title_w) * 0.5, 10.0 * (vp_size.y / 900.0))

	if is_instance_valid(options_modal):
		var opt_w = options_modal.size.x if options_modal.size.x > 100.0 else options_modal.custom_minimum_size.x
		var opt_h = options_modal.size.y if options_modal.size.y > 100.0 else options_modal.custom_minimum_size.y
		options_modal.position = (vp_size - Vector2(opt_w, opt_h)) * 0.5
	if is_instance_valid(credit_modal):
		credit_modal.set_anchors_preset(Control.PRESET_FULL_RECT)

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

func _create_step_button(symbol: String) -> Button:
	var btn = Button.new()
	btn.text = symbol
	btn.custom_minimum_size = Vector2(34, 28)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.15, 0.11, 0.95)
	sb.border_color = Color(0.85, 0.70, 0.35, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", sb)
	var sb_hov = sb.duplicate()
	sb_hov.bg_color = Color(0.32, 0.24, 0.16, 1.0)
	sb_hov.border_color = Color(1.0, 0.88, 0.50, 1.0)
	btn.add_theme_stylebox_override("hover", sb_hov)
	btn.add_theme_stylebox_override("pressed", sb_hov)
	btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75))
	btn.add_theme_font_size_override("font_size", 13)
	return btn

func _create_custom_sound_slider(title_text: String, initial_val: float, on_change: Callable) -> Control:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 6)

	var header_hb = HBoxContainer.new()
	container.add_child(header_hb)

	var title_lbl = Label.new()
	title_lbl.text = title_text
	title_lbl.add_theme_color_override("font_color", Color(0.95, 0.90, 0.82))
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hb.add_child(title_lbl)

	var val_lbl = Label.new()
	val_lbl.text = "%d%%" % int(round(initial_val * 100.0))
	val_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	val_lbl.add_theme_font_size_override("font_size", 13)
	header_hb.add_child(val_lbl)

	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = initial_val
	slider.custom_minimum_size = Vector2(300, 26)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = Control.FOCUS_NONE
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var tex_back = load("res://UI/options/sound_backbar.png")
	var tex_front = load("res://UI/options/sound_frontbar.png")
	var tex_btn = load("res://UI/options/sound_button.png")
	var tex_btn_h = load("res://UI/options/sound_button_hover.png")

	if tex_back and tex_front and tex_btn:
		var sb_back = StyleBoxTexture.new()
		sb_back.texture = tex_back
		sb_back.texture_margin_left = 7
		sb_back.texture_margin_right = 7
		sb_back.texture_margin_top = 2
		sb_back.texture_margin_bottom = 2
		sb_back.content_margin_top = 6
		sb_back.content_margin_bottom = 6
		sb_back.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH

		var sb_front = StyleBoxTexture.new()
		sb_front.texture = tex_front
		sb_front.texture_margin_left = 7
		sb_front.texture_margin_right = 7
		sb_front.texture_margin_top = 2
		sb_front.texture_margin_bottom = 2
		sb_front.content_margin_top = 6
		sb_front.content_margin_bottom = 6
		sb_front.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH

		slider.add_theme_stylebox_override("slider", sb_back)
		slider.add_theme_stylebox_override("grabber_area", sb_front)
		slider.add_theme_stylebox_override("grabber_area_highlight", sb_front)
		slider.add_theme_icon_override("grabber", tex_btn)
		slider.add_theme_icon_override("grabber_highlight", tex_btn_h if tex_btn_h else tex_btn)

	container.add_child(slider)

	slider.value_changed.connect(func(v: float):
		val_lbl.text = "%d%%" % int(round(v * 100.0))
		on_change.call(v)
	)

	return container

func _build_options_modal() -> void:
	options_modal = PanelContainer.new()
	options_modal.set_anchors_preset(Control.PRESET_CENTER)
	options_modal.custom_minimum_size = Vector2(520, 360)
	options_modal.position = Vector2(540, 270)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.13, 0.09, 0.07, 0.97)
	sb.border_color = Color(0.85, 0.70, 0.35, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0, 0, 0, 0.65)
	sb.shadow_size = 14
	sb.shadow_offset = Vector2(0, 4)
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
	title.text = "PENGATURAN SUARA & TAMPILAN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	title.add_theme_font_size_override("font_size", 16)
	vb.add_child(title)

	# 1. BGM Slider (Sound backbar + frontbar + button)
	var bgm_ctrl = _create_custom_sound_slider("Volume Musik (BGM):", 0.8, func(v: float):
		_on_bgm_volume_changed(v)
	)
	vb.add_child(bgm_ctrl)

	# 2. SFX Slider (Sound backbar + frontbar + button)
	var sfx_ctrl = _create_custom_sound_slider("Volume Efek Suara (SFX):", 1.0, func(v: float):
		_on_sfx_volume_changed(v)
	)
	vb.add_child(sfx_ctrl)

	# 3. Mode Layar Penuh (F11)
	var fs_hb = HBoxContainer.new()
	fs_hb.add_theme_constant_override("separation", 8)
	vb.add_child(fs_hb)

	var fs_lbl = Label.new()
	fs_lbl.text = "Mode Layar Penuh (F11):"
	fs_lbl.add_theme_color_override("font_color", Color(0.95, 0.90, 0.82))
	fs_lbl.add_theme_font_size_override("font_size", 13)
	fs_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs_hb.add_child(fs_lbl)

	fullscreen_toggle_btn = Button.new()
	fullscreen_toggle_btn.text = "Layar Penuh (F11)"
	fullscreen_toggle_btn.custom_minimum_size = Vector2(140, 32)
	fullscreen_toggle_btn.focus_mode = Control.FOCUS_NONE
	fullscreen_toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var fs_sb = StyleBoxFlat.new()
	fs_sb.bg_color = Color(0.20, 0.15, 0.11, 0.95)
	fs_sb.border_color = Color(0.85, 0.70, 0.35, 0.8)
	fs_sb.set_border_width_all(1)
	fs_sb.set_corner_radius_all(4)
	fullscreen_toggle_btn.add_theme_stylebox_override("normal", fs_sb)
	var fs_hov = fs_sb.duplicate()
	fs_hov.bg_color = Color(0.32, 0.24, 0.16, 1.0)
	fs_hov.border_color = Color(1.0, 0.88, 0.50, 1.0)
	fullscreen_toggle_btn.add_theme_stylebox_override("hover", fs_hov)
	fullscreen_toggle_btn.add_theme_stylebox_override("pressed", fs_hov)
	fullscreen_toggle_btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75))
	fullscreen_toggle_btn.add_theme_font_size_override("font_size", 12)
	fullscreen_toggle_btn.pressed.connect(func():
		_play_click()
		_on_toggle_fullscreen()
	)
	fs_hb.add_child(fullscreen_toggle_btn)

	# 4. Tombol Simpan & Tutup
	var close_opt_btn = Button.new()
	close_opt_btn.text = "Simpan & Kembali"
	close_opt_btn.custom_minimum_size = Vector2(180, 38)
	close_opt_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_opt_btn.focus_mode = Control.FOCUS_NONE
	close_opt_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var c_btn_sb = StyleBoxFlat.new()
	c_btn_sb.bg_color = Color(0.24, 0.18, 0.12, 0.95)
	c_btn_sb.border_color = Color(0.85, 0.70, 0.35, 1.0)
	c_btn_sb.set_border_width_all(2)
	c_btn_sb.set_corner_radius_all(6)
	close_opt_btn.add_theme_stylebox_override("normal", c_btn_sb)
	var c_btn_hov = c_btn_sb.duplicate()
	c_btn_hov.bg_color = Color(0.36, 0.28, 0.18, 1.0)
	c_btn_hov.border_color = Color(1.0, 0.88, 0.50, 1.0)
	close_opt_btn.add_theme_stylebox_override("hover", c_btn_hov)
	close_opt_btn.add_theme_stylebox_override("pressed", c_btn_hov)
	close_opt_btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75))
	close_opt_btn.add_theme_font_size_override("font_size", 13)
	close_opt_btn.pressed.connect(func():
		_play_click()
		options_modal.visible = false
		options_closed.emit()
	)
	vb.add_child(close_opt_btn)

func _build_credit_modal() -> void:
	if is_instance_valid(credit_modal):
		return
	credit_modal = Control.new()
	credit_modal.name = "CreditModal"
	credit_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	credit_modal.visible = false
	root_control.add_child(credit_modal)

	# 1. Dim background overlay
	var dim = ColorRect.new()
	dim.name = "DimBackground"
	dim.color = Color(0.02, 0.03, 0.05, 0.95)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	credit_modal.add_child(dim)

	# 2. Gambar Credit 1920x1080 buatan Artist (Tampil Penuh Presisi)
	var credit_img = TextureRect.new()
	credit_img.name = "CreditImage"
	if not is_instance_valid(tex_credit):
		tex_credit = load("res://Main Menu/credit.png")
	if is_instance_valid(tex_credit):
		credit_img.texture = tex_credit
	credit_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	credit_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	credit_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	credit_img.mouse_filter = Control.MOUSE_FILTER_PASS
	credit_modal.add_child(credit_img)

	# 3. Tombol Tutup di Pojok Kanan Atas
	var close_crd_btn = Button.new()
	close_crd_btn.name = "BtnCloseCredit"
	close_crd_btn.text = "✖ TUTUP KREDIT [ESC]"
	close_crd_btn.custom_minimum_size = Vector2(200, 42)
	close_crd_btn.anchor_left = 1.0
	close_crd_btn.anchor_right = 1.0
	close_crd_btn.anchor_top = 0.0
	close_crd_btn.anchor_bottom = 0.0
	close_crd_btn.offset_left = -225
	close_crd_btn.offset_right = -25
	close_crd_btn.offset_top = 25
	close_crd_btn.offset_bottom = 67
	close_crd_btn.focus_mode = Control.FOCUS_NONE
	close_crd_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var c_sb = StyleBoxFlat.new()
	c_sb.bg_color = Color(0.12, 0.10, 0.08, 0.95)
	c_sb.border_color = Color(0.90, 0.75, 0.35, 1.0)
	c_sb.set_border_width_all(2)
	c_sb.set_corner_radius_all(6)
	close_crd_btn.add_theme_stylebox_override("normal", c_sb)
	var c_hov = c_sb.duplicate()
	c_hov.bg_color = Color(0.24, 0.18, 0.12, 1.0)
	c_hov.border_color = Color(1.0, 0.90, 0.55, 1.0)
	close_crd_btn.add_theme_stylebox_override("hover", c_hov)
	close_crd_btn.add_theme_stylebox_override("pressed", c_hov)
	close_crd_btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75))
	close_crd_btn.add_theme_font_size_override("font_size", 14)
	close_crd_btn.pressed.connect(func():
		_play_click()
		credit_modal.visible = false
	)
	credit_modal.add_child(close_crd_btn)

func _on_play_pressed() -> void:
	_play_click()
	close_menu()
	play_requested.emit()

func _on_options_pressed() -> void:
	_play_click()
	if is_instance_valid(credit_modal):
		credit_modal.visible = false
	if is_instance_valid(options_modal):
		_refresh_fullscreen_btn_label()
		var vp_size = get_viewport().get_visible_rect().size if is_inside_tree() and get_viewport() else root_control.size
		var opt_w = options_modal.size.x if options_modal.size.x > 100.0 else options_modal.custom_minimum_size.x
		var opt_h = options_modal.size.y if options_modal.size.y > 100.0 else options_modal.custom_minimum_size.y
		options_modal.position = (vp_size - Vector2(opt_w, opt_h)) * 0.5
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
	if is_instance_valid(menu_bgm_player):
		var db = linear_to_db(val) if val > 0.001 else -80.0
		menu_bgm_player.volume_db = db - 4.0
	var bgm_bus = AudioServer.get_bus_index("BGM")
	if bgm_bus == -1:
		bgm_bus = AudioServer.get_bus_index("Master")
	if bgm_bus != -1:
		var db = linear_to_db(val) if val > 0.001 else -80.0
		AudioServer.set_bus_volume_db(bgm_bus, db)

func _on_sfx_volume_changed(val: float) -> void:
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx == -1:
		AudioServer.add_bus()
		sfx_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")
	var db = linear_to_db(val) if val > 0.001 else -80.0
	AudioServer.set_bus_volume_db(sfx_idx, db)
	_play_click()

func _refresh_fullscreen_btn_label() -> void:
	if not is_instance_valid(fullscreen_toggle_btn):
		return
	var mode = DisplayServer.window_get_mode()
	var is_fs = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	fullscreen_toggle_btn.text = "Layar Jendela (F11)" if is_fs else "Layar Penuh (F11)"

func _on_toggle_fullscreen() -> void:
	_play_click()
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		var screen_size = DisplayServer.screen_get_size()
		var win_w = 1280
		var win_h = 720
		DisplayServer.window_set_size(Vector2i(win_w, win_h))
		DisplayServer.window_set_position(Vector2i((screen_size.x - win_w) / 2, (screen_size.y - win_h) / 2))
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_fullscreen_btn_label()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		if is_instance_valid(credit_modal) and credit_modal.visible:
			_play_click()
			credit_modal.visible = false
			get_viewport().set_input_as_handled()
		elif is_instance_valid(options_modal) and options_modal.visible:
			_play_click()
			options_modal.visible = false
			options_closed.emit()
			get_viewport().set_input_as_handled()
