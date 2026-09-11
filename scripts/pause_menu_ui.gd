extends CanvasLayer

signal resumed
signal journal_requested
signal main_menu_requested

# ==============================================================================
# ⚙️ PENGATURAN MANUAL UKURAN & POSISI TOMBOL PAUSE (BISA DIEDIT BEBAS DI SINI)
# ==============================================================================
@export_group("Tombol Pause di Layar (HUD)")
## Lebar tombol pause HUD di pojok kanan atas (dalam piksel, default: 84.0)
@export var hud_pause_button_width: float = 84.0

## Tinggi tombol pause HUD di pojok kanan atas (dalam piksel, default: 84.0)
@export var hud_pause_button_height: float = 84.0

## Jarak tombol pause dari tepi kanan layar (margin kanan, default: 20.0)
@export var hud_pause_margin_right: float = 20.0

## Jarak tombol pause dari tepi atas layar (margin atas, default: 20.0)
@export var hud_pause_margin_top: float = 20.0

@export_group("Tombol Resume di Menu Pause")
## Tinggi tombol 'Lanjutkan Permainan' di dalam menu pause (default: 58.0)
@export var menu_resume_button_height: float = 58.0

## Ukuran font tombol resume (default: 16)
@export var menu_resume_font_size: int = 16
# ==============================================================================

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
var tex_btn_resume: Texture2D
var tex_btn_options: Texture2D
var tex_btn_main_menu: Texture2D
var hud_pause_button: BaseButton

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
	tex_btn_resume = load("res://PAUSED/btn_resume.png")
	tex_btn_options = load("res://PAUSED/btn_options.png")
	tex_btn_main_menu = load("res://PAUSED/btn_main_menu.png")

	if not tex_btn_resume and tex_paused:
		var a0 = AtlasTexture.new()
		a0.atlas = tex_paused
		a0.region = Rect2(301, 286, 434, 126)
		tex_btn_resume = a0
	if not tex_btn_options and tex_paused:
		var a1 = AtlasTexture.new()
		a1.atlas = tex_paused
		a1.region = Rect2(304, 475, 434, 126)
		tex_btn_options = a1
	if not tex_btn_main_menu and tex_paused:
		var a2 = AtlasTexture.new()
		a2.atlas = tex_paused
		a2.region = Rect2(301, 655, 434, 126)
		tex_btn_main_menu = a2

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

func update_hud_pause_button_transform() -> void:
	if not is_instance_valid(hud_pause_button):
		return
	hud_pause_button.offset_left = -(hud_pause_margin_right + hud_pause_button_width)
	hud_pause_button.offset_top = hud_pause_margin_top
	hud_pause_button.offset_right = -hud_pause_margin_right
	hud_pause_button.offset_bottom = hud_pause_margin_top + hud_pause_button_height
	hud_pause_button.pivot_offset = Vector2(hud_pause_button_width * 0.5, hud_pause_button_height * 0.5)

func set_hud_pause_size(new_width: float, new_height: float, new_margin_right: float = -1.0, new_margin_top: float = -1.0) -> void:
	hud_pause_button_width = new_width
	hud_pause_button_height = new_height
	if new_margin_right >= 0.0:
		hud_pause_margin_right = new_margin_right
	if new_margin_top >= 0.0:
		hud_pause_margin_top = new_margin_top
	update_hud_pause_button_transform()

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

	var title = Label.new()
	title.text = "PERMAINAN DIJEDA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	title.add_theme_font_size_override("font_size", 17)
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
	var tb = TextureButton.new()
	tb.name = "HudPauseButton"
	tb.texture_normal = tex_pause_button
	tb.ignore_texture_size = true
	tb.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	tb.anchor_left = 1.0
	tb.anchor_top = 0.0
	tb.anchor_right = 1.0
	tb.anchor_bottom = 0.0
	tb.focus_mode = Control.FOCUS_NONE
	tb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tb.tooltip_text = "Jeda Permainan [ESC / P]"

	# Bidang pencet (click mask) mengikuti persis bentuk lingkaran & 2 batang
	if is_instance_valid(tex_pause_button):
		var img = tex_pause_button.get_image()
		if img:
			var mask = BitMap.new()
			mask.create_from_image_alpha(img)
			tb.texture_click_mask = mask

	# Hover micro-animation
	tb.mouse_entered.connect(func():
		tb.modulate = Color(1.18, 1.18, 1.15)
		var tw = tb.create_tween()
		tw.tween_property(tb, "scale", Vector2(1.06, 1.06), 0.08)
	)
	tb.mouse_exited.connect(func():
		tb.modulate = Color.WHITE
		var tw = tb.create_tween()
		tw.tween_property(tb, "scale", Vector2(1.0, 1.0), 0.08)
	)
	tb.button_down.connect(func():
		tb.modulate = Color(0.85, 0.85, 0.85)
	)
	tb.button_up.connect(func():
		tb.modulate = Color(1.18, 1.18, 1.15)
	)

	tb.pressed.connect(toggle_pause)
	hud_pause_button = tb
	update_hud_pause_button_transform()
	add_child(hud_pause_button)

	# Tombol Aset Kertas (RESUME, OPTIONS, MAIN MENU)
	btn_resume = _create_paper_tag_button(tex_btn_resume)
	btn_resume.tooltip_text = "Lanjutkan Permainan [ESC]"
	btn_resume.pressed.connect(resume_game)
	vb.add_child(btn_resume)

	btn_options = _create_paper_tag_button(tex_btn_options)
	btn_options.tooltip_text = "Buka Pengaturan Audio & Layar"
	btn_options.pressed.connect(func():
		_play_click()
		if is_instance_valid(options_modal):
			options_modal.visible = true
	)
	vb.add_child(btn_options)

	btn_main_menu = _create_paper_tag_button(tex_btn_main_menu)
	btn_main_menu.tooltip_text = "Kembali ke Menu Utama"
	btn_main_menu.pressed.connect(func():
		_play_click()
		close_pause()
		main_menu_requested.emit()
	)
	vb.add_child(btn_main_menu)

	# Footer Links (Journal & Quit)
	var footer_hb = HBoxContainer.new()
	footer_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	footer_hb.add_theme_constant_override("separation", 24)
	vb.add_child(footer_hb)

	btn_journal = _create_text_link_button("[J] Jurnal Kasus & Bukti", Color(0.45, 0.75, 1.0))
	btn_journal.pressed.connect(func():
		_play_click()
		close_pause()
		journal_requested.emit()
	)
	footer_hb.add_child(btn_journal)

	btn_quit = _create_text_link_button("[Q] Keluar ke Desktop", Color(0.85, 0.45, 0.45))
	btn_quit.pressed.connect(func():
		_play_click()
		get_tree().quit()
	)
	footer_hb.add_child(btn_quit)

	# 3. Settings Modal
	_build_settings_modal(center)

func _create_paper_tag_button(tex: Texture2D) -> Button:
	var btn = Button.new()
	var w = 310.0
	var h = 90.0
	btn.custom_minimum_size = Vector2(w, h)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var empty_sb = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_sb)
	btn.add_theme_stylebox_override("focus", empty_sb)

	var hov_sb = StyleBoxFlat.new()
	hov_sb.bg_color = Color(1.0, 1.0, 1.0, 0.08)
	hov_sb.border_color = Color(1.0, 0.88, 0.45, 0.8)
	hov_sb.set_border_width_all(2)
	hov_sb.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("hover", hov_sb)

	var press_sb = StyleBoxFlat.new()
	press_sb.bg_color = Color(0.0, 0.0, 0.0, 0.25)
	press_sb.border_color = Color(1.0, 0.88, 0.45, 1.0)
	press_sb.set_border_width_all(2)
	press_sb.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("pressed", press_sb)

	if is_instance_valid(tex):
		var trect = TextureRect.new()
		trect.texture = tex
		trect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		trect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		trect.set_anchors_preset(Control.PRESET_FULL_RECT)
		trect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		trect.pivot_offset = Vector2(w * 0.5, h * 0.5)
		btn.add_child(trect)

		btn.mouse_entered.connect(func():
			var tw = btn.create_tween()
			tw.tween_property(trect, "scale", Vector2(1.03, 1.03), 0.08)
		)
		btn.mouse_exited.connect(func():
			var tw = btn.create_tween()
			tw.tween_property(trect, "scale", Vector2(1.0, 1.0), 0.08)
		)
	return btn

func _create_text_link_button(label_text: String, col: Color = Color(0.8, 0.85, 0.95)) -> Button:
	var btn = Button.new()
	btn.text = label_text
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 12)
	btn.add_theme_color_override("font_color", col)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	var empty_sb = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_sb)
	btn.add_theme_stylebox_override("focus", empty_sb)
	btn.add_theme_stylebox_override("hover", empty_sb)
	btn.add_theme_stylebox_override("pressed", empty_sb)
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
