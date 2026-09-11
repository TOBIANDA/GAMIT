extends CanvasLayer

signal resumed
signal journal_requested
signal main_menu_requested

var is_paused: bool = false

var root_control: Control
var menu_box: PanelContainer
var objective_hint_label: Label

var btn_resume: Button
var btn_journal: Button
var btn_options: Button
var btn_main_menu: Button
var btn_quit: Button

var options_modal: PanelContainer
var bgm_slider: HSlider
var sfx_slider: HSlider

var click_player: AudioStreamPlayer

var tex_paused: Texture2D
var tex_pause_button: Texture2D
var hud_pause_button: Button

func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_assets()
	_setup_audio()
	_build_pause_ui()
	visible = true
	root_control.visible = false
	if is_instance_valid(hud_pause_button):
		hud_pause_button.visible = true

func _load_assets() -> void:
	tex_paused = load("res://PAUSED/PAUSED.png")
	tex_pause_button = load("res://PAUSED/pause button.png")

func _setup_audio() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "PauseClickPlayer"
	var c_stream = load("res://sound/Click sound.mp3")
	if c_stream:
		click_player.stream = c_stream
		click_player.volume_db = -3.0
	add_child(click_player)

func _play_click() -> void:
	if is_instance_valid(click_player) and click_player.stream:
		click_player.play()

func set_hud_button_visible(v: bool) -> void:
	if is_instance_valid(hud_pause_button):
		hud_pause_button.visible = v and not is_paused

func open_pause() -> void:
	is_paused = true
	visible = true
	if is_instance_valid(root_control):
		root_control.visible = true
	if is_instance_valid(hud_pause_button):
		hud_pause_button.visible = false
	_refresh_objective_hint()
	if is_instance_valid(options_modal):
		options_modal.visible = false

func close_pause() -> void:
	is_paused = false
	if is_instance_valid(root_control):
		root_control.visible = false
	if is_instance_valid(hud_pause_button):
		hud_pause_button.visible = true
	if is_instance_valid(options_modal):
		options_modal.visible = false

func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		open_pause()

func resume_game() -> void:
	_play_click()
	close_pause()
	resumed.emit()

func _refresh_objective_hint() -> void:
	if not is_instance_valid(objective_hint_label):
		return
	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
		inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr) and inv_mgr.has_method("get_current_objective_title"):
		objective_hint_label.text = "Target: " + inv_mgr.get_current_objective_title()
	else:
		objective_hint_label.text = "Lanjutkan investigasi..."

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			if is_paused:
				if is_instance_valid(options_modal) and options_modal.visible:
					options_modal.visible = false
				else:
					resume_game()
				get_viewport().set_input_as_handled()
			else:
				var main_menu = get_parent().find_child("MainMenuLayer", true, false) if get_parent() else null
				if is_instance_valid(main_menu) and main_menu.get("is_active"):
					return
				var dlg = get_parent().find_child("DialogBox", true, false) if get_parent() else null
				if is_instance_valid(dlg) and dlg.get("is_active"):
					return
				open_pause()
				get_viewport().set_input_as_handled()
		elif is_paused and event.keycode == KEY_J:
			resume_game()
			journal_requested.emit()
			get_viewport().set_input_as_handled()

func _build_pause_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	# 1. Dim Background Overlay
	var dim_bg = ColorRect.new()
	dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim_bg.color = Color(0.02, 0.03, 0.06, 0.85)
	root_control.add_child(dim_bg)

	# 2. Center Panel (Case File Folder Theme)
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center)

	menu_box = PanelContainer.new()
	menu_box.custom_minimum_size = Vector2(460, 510)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.09, 0.13, 0.98)
	sb.border_color = Color(0.85, 0.70, 0.35, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 22
	sb.content_margin_bottom = 22
	menu_box.add_theme_stylebox_override("panel", sb)
	center.add_child(menu_box)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	menu_box.add_child(vb)

	# Banner PAUSED.png
	if is_instance_valid(tex_paused):
		var pause_banner = TextureRect.new()
		pause_banner.texture = tex_paused
		pause_banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pause_banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pause_banner.custom_minimum_size = Vector2(0, 85)
		vb.add_child(pause_banner)
	else:
		var title = Label.new()
		title.text = "PERMAINAN DIJEDA (PAUSE)"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
		title.add_theme_font_size_override("font_size", 18)
		vb.add_child(title)

	objective_hint_label = Label.new()
	objective_hint_label.text = "Target: Menyelidiki Kasus..."
	objective_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_hint_label.add_theme_color_override("font_color", Color(0.6, 0.9, 1.0))
	objective_hint_label.add_theme_font_size_override("font_size", 13)
	vb.add_child(objective_hint_label)

	var sep = HSeparator.new()
	vb.add_child(sep)

	# Tombol Jeda di Layar (HUD Pause Button)
	hud_pause_button = Button.new()
	hud_pause_button.name = "HudPauseButton"
	hud_pause_button.anchor_left = 1.0
	hud_pause_button.anchor_top = 0.0
	hud_pause_button.anchor_right = 1.0
	hud_pause_button.anchor_bottom = 0.0
	hud_pause_button.offset_left = -86
	hud_pause_button.offset_top = 18
	hud_pause_button.offset_right = -18
	hud_pause_button.offset_bottom = 86
	hud_pause_button.focus_mode = Control.FOCUS_NONE
	hud_pause_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hud_pause_button.tooltip_text = "Jeda Permainan [ESC / P]"

	var p_empty = StyleBoxEmpty.new()
	hud_pause_button.add_theme_stylebox_override("normal", p_empty)
	hud_pause_button.add_theme_stylebox_override("focus", p_empty)
	
	var p_hov = StyleBoxFlat.new()
	p_hov.bg_color = Color(1.0, 1.0, 1.0, 0.18)
	p_hov.set_corner_radius_all(14)
	hud_pause_button.add_theme_stylebox_override("hover", p_hov)
	hud_pause_button.add_theme_stylebox_override("pressed", p_hov)

	if is_instance_valid(tex_pause_button):
		var p_icon = TextureRect.new()
		p_icon.texture = tex_pause_button
		p_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		p_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		p_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		p_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud_pause_button.add_child(p_icon)

	hud_pause_button.pressed.connect(toggle_pause)
	add_child(hud_pause_button)

	# Buttons
	btn_resume = _create_menu_button("▶  Lanjutkan Permainan [ESC]", Color(0.18, 0.65, 0.38))
	btn_resume.custom_minimum_size = Vector2(0, 58)
	btn_resume.add_theme_font_size_override("font_size", 16)
	btn_resume.pressed.connect(resume_game)
	vb.add_child(btn_resume)

	btn_journal = _create_menu_button("Buka Jurnal Kasus & Bukti [J]", Color(0.2, 0.45, 0.7))
	btn_journal.pressed.connect(func():
		_play_click()
		close_pause()
		journal_requested.emit()
	)
	vb.add_child(btn_journal)

	btn_options = _create_menu_button("Pengaturan Audio & Layar", Color(0.35, 0.35, 0.45))
	btn_options.pressed.connect(func():
		_play_click()
		if is_instance_valid(options_modal):
			options_modal.visible = true
	)
	vb.add_child(btn_options)

	btn_main_menu = _create_menu_button("Kembali ke Menu Utama", Color(0.6, 0.4, 0.2))
	btn_main_menu.pressed.connect(func():
		_play_click()
		close_pause()
		main_menu_requested.emit()
	)
	vb.add_child(btn_main_menu)

	btn_quit = _create_menu_button("Keluar ke Desktop", Color(0.6, 0.2, 0.2))
	btn_quit.pressed.connect(func():
		_play_click()
		get_tree().quit()
	)
	vb.add_child(btn_quit)

	# 3. Settings Modal
	_build_settings_modal(center)

func _create_menu_button(label: String, tint_col: Color) -> Button:
	var btn = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(0, 44)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 14)

	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(tint_col.r * 0.4, tint_col.g * 0.4, tint_col.b * 0.4, 0.9)
	sb.border_color = tint_col
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", sb)

	var sb_h = sb.duplicate()
	sb_h.bg_color = tint_col
	sb_h.border_color = Color.WHITE
	btn.add_theme_stylebox_override("hover", sb_h)
	btn.add_theme_stylebox_override("pressed", sb_h)

	return btn

func _build_settings_modal(parent_center: CenterContainer) -> void:
	options_modal = PanelContainer.new()
	options_modal.custom_minimum_size = Vector2(460, 320)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.11, 0.16, 0.98)
	sb.border_color = Color(1.0, 0.8, 0.35, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	options_modal.add_theme_stylebox_override("panel", sb)
	options_modal.visible = false
	parent_center.add_child(options_modal)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	options_modal.add_child(vb)

	var t = Label.new()
	t.text = "PENGATURAN"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	t.add_theme_font_size_override("font_size", 16)
	vb.add_child(t)

	var bgm_hb = HBoxContainer.new()
	vb.add_child(bgm_hb)
	var bgm_lbl = Label.new()
	bgm_lbl.text = "Volume Musik (BGM):"
	bgm_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bgm_hb.add_child(bgm_lbl)
	bgm_slider = HSlider.new()
	bgm_slider.custom_minimum_size = Vector2(160, 20)
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.05
	bgm_slider.value = 0.8
	bgm_slider.value_changed.connect(func(v):
		var master_bus = AudioServer.get_bus_index("Master")
		if master_bus != -1:
			var db = linear_to_db(v) if v > 0.0 else -80.0
			AudioServer.set_bus_volume_db(master_bus, db)
	)
	bgm_hb.add_child(bgm_slider)

	var fs_hb = HBoxContainer.new()
	vb.add_child(fs_hb)
	var fs_lbl = Label.new()
	fs_lbl.text = "Mode Layar (Fullscreen):"
	fs_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs_hb.add_child(fs_lbl)
	var fs_btn = Button.new()
	var update_fs_text = func():
		var m = DisplayServer.window_get_mode()
		var is_fs = (m == DisplayServer.WINDOW_MODE_FULLSCREEN or m == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		fs_btn.text = "Layar Jendela (F11)" if is_fs else "Layar Penuh (F11)"
	update_fs_text.call()
	fs_btn.focus_mode = Control.FOCUS_NONE
	fs_btn.pressed.connect(func():
		_play_click()
		var mode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		update_fs_text.call()
	)
	fs_hb.add_child(fs_btn)

	var close_opt = Button.new()
	close_opt.text = "Selesai"
	close_opt.custom_minimum_size = Vector2(140, 36)
	close_opt.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_opt.focus_mode = Control.FOCUS_NONE
	close_opt.pressed.connect(func():
		_play_click()
		options_modal.visible = false
	)
	vb.add_child(close_opt)
