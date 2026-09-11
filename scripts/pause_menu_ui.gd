extends CanvasLayer

signal resumed
signal journal_requested
signal main_menu_requested

# ==============================================================================
# ⚙️ PENGATURAN MANUAL UKURAN & POSISI TOMBOL PAUSE (BISA DIEDIT BEBAS DI SINI)
# ==============================================================================
@export_group("Tombol Pause di Layar (HUD)")
## Lebar tombol pause HUD di pojok kanan atas (dalam piksel, default: 67.0)
@export var hud_pause_button_width: float = 67.0

## Tinggi tombol pause HUD di pojok kanan atas (dalam piksel, default: 67.0)
@export var hud_pause_button_height: float = 67.0

## Jarak tombol pause dari tepi kanan layar (margin kanan, default: 18.0)
@export var hud_pause_margin_right: float = 18.0

## Jarak tombol pause dari tepi atas layar (margin atas, default: 18.0)
@export var hud_pause_margin_top: float = 18.0

@export_group("Tombol Resume di Menu Pause")
## Tinggi tombol 'Lanjutkan Permainan' di dalam menu pause (default: 58.0)
@export var menu_resume_button_height: float = 58.0

## Ukuran font tombol resume (default: 16)
@export var menu_resume_font_size: int = 16
# ==============================================================================

var is_paused: bool = false

var root_control: Control
var menu_box: Control
var objective_hint_label: Label

var btn_resume: Button
var btn_journal: Button
var btn_options: Button
var btn_main_menu: Button
var btn_quit: Button

var options_modal: PanelContainer
var credit_modal: Control
var bgm_slider: HSlider
var sfx_slider: HSlider

var click_player: AudioStreamPlayer

var tex_paused: Texture2D
var tex_pause_button: Texture2D
var tex_btn_resume: Texture2D
var tex_btn_options: Texture2D
var tex_btn_main_menu: Texture2D
var tex_credit: Texture2D
var btn_credit: Button
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
	tex_credit = load("res://Main Menu/credit.png")

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
	if is_instance_valid(credit_modal):
		credit_modal.visible = false

func close_pause() -> void:
	is_paused = false
	if is_instance_valid(root_control):
		root_control.visible = false
	if is_instance_valid(hud_pause_button):
		hud_pause_button.visible = true
	if is_instance_valid(options_modal):
		options_modal.visible = false
	if is_instance_valid(credit_modal):
		credit_modal.visible = false

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
				if is_instance_valid(credit_modal) and credit_modal.visible:
					_play_click()
					credit_modal.visible = false
				elif is_instance_valid(options_modal) and options_modal.visible:
					_play_click()
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
		elif is_paused and event.keycode == KEY_C:
			if is_instance_valid(credit_modal):
				_play_click()
				credit_modal.visible = not credit_modal.visible
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

	# 2. Center Panel: Hanya 3 Tombol Kertas (RESUME, OPTIONS, MAIN MENU)
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 20)
	center.add_child(vb)
	menu_box = vb

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

	# 3 Tombol Aset Kertas (RESUME, OPTIONS, MAIN MENU)
	btn_resume = _create_paper_tag_button(tex_btn_resume)
	btn_resume.tooltip_text = "Lanjutkan Permainan [ESC]"
	btn_resume.pressed.connect(resume_game)
	vb.add_child(btn_resume)

	btn_options = _create_paper_tag_button(tex_btn_options)
	btn_options.tooltip_text = "Buka Pengaturan Suara & Layar"
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

	# 3. Settings Modal
	_build_settings_modal(center)

	# 4. Credit Modal
	_build_credit_modal()

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

func _build_settings_modal(parent_center: CenterContainer) -> void:
	options_modal = PanelContainer.new()
	options_modal.custom_minimum_size = Vector2(480, 350)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.13, 0.09, 0.07, 0.97)
	sb.border_color = Color(0.85, 0.70, 0.35, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.shadow_color = Color(0, 0, 0, 0.65)
	sb.shadow_size = 14
	sb.shadow_offset = Vector2(0, 4)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 22
	sb.content_margin_bottom = 22
	options_modal.add_theme_stylebox_override("panel", sb)
	options_modal.visible = false
	parent_center.add_child(options_modal)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	options_modal.add_child(vb)

	var t = Label.new()
	t.text = "PENGATURAN SUARA & TAMPILAN"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	t.add_theme_font_size_override("font_size", 16)
	vb.add_child(t)

	# 1. BGM Sound Slider (Sound backbar + frontbar + button)
	var bgm_ctrl = _create_custom_sound_slider("Volume Musik (BGM):", 0.8, func(v: float):
		var master_bus = AudioServer.get_bus_index("Master")
		if master_bus != -1:
			var db = linear_to_db(v) if v > 0.0 else -80.0
			AudioServer.set_bus_volume_db(master_bus, db)
	)
	vb.add_child(bgm_ctrl)

	# 2. SFX Sound Slider
	var sfx_ctrl = _create_custom_sound_slider("Volume Efek Suara (SFX):", 1.0, func(_v: float):
		_play_click()
	)
	vb.add_child(sfx_ctrl)

	# 3. Fullscreen Button
	var fs_hb = HBoxContainer.new()
	fs_hb.add_theme_constant_override("separation", 8)
	vb.add_child(fs_hb)
	var fs_lbl = Label.new()
	fs_lbl.text = "Mode Layar (Fullscreen):"
	fs_lbl.add_theme_color_override("font_color", Color(0.95, 0.90, 0.82))
	fs_lbl.add_theme_font_size_override("font_size", 13)
	fs_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs_hb.add_child(fs_lbl)
	var fs_btn = Button.new()
	var update_fs_text = func():
		var m = DisplayServer.window_get_mode()
		var is_fs = (m == DisplayServer.WINDOW_MODE_FULLSCREEN or m == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		fs_btn.text = "Layar Jendela (F11)" if is_fs else "Layar Penuh (F11)"
	update_fs_text.call()
	fs_btn.focus_mode = Control.FOCUS_NONE
	fs_btn.custom_minimum_size = Vector2(150, 32)
	fs_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var fs_sb = StyleBoxFlat.new()
	fs_sb.bg_color = Color(0.20, 0.15, 0.11, 0.95)
	fs_sb.border_color = Color(0.85, 0.70, 0.35, 0.8)
	fs_sb.set_border_width_all(1)
	fs_sb.set_corner_radius_all(4)
	fs_btn.add_theme_stylebox_override("normal", fs_sb)
	var fs_hov = fs_sb.duplicate()
	fs_hov.bg_color = Color(0.32, 0.24, 0.16, 1.0)
	fs_hov.border_color = Color(1.0, 0.88, 0.50, 1.0)
	fs_btn.add_theme_stylebox_override("hover", fs_hov)
	fs_btn.add_theme_stylebox_override("pressed", fs_hov)
	fs_btn.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75))
	fs_btn.add_theme_font_size_override("font_size", 12)
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

	# 4. Close Button
	var close_opt = Button.new()
	close_opt.text = "Simpan & Kembali"
	close_opt.custom_minimum_size = Vector2(180, 38)
	close_opt.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_opt.focus_mode = Control.FOCUS_NONE
	close_opt.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var c_btn_sb = StyleBoxFlat.new()
	c_btn_sb.bg_color = Color(0.22, 0.16, 0.12, 0.95)
	c_btn_sb.border_color = Color(0.85, 0.70, 0.35, 1.0)
	c_btn_sb.set_border_width_all(2)
	c_btn_sb.set_corner_radius_all(6)
	close_opt.add_theme_stylebox_override("normal", c_btn_sb)
	var c_btn_hov = c_btn_sb.duplicate()
	c_btn_hov.bg_color = Color(0.35, 0.26, 0.18, 1.0)
	c_btn_hov.border_color = Color(1.0, 0.88, 0.50, 1.0)
	close_opt.add_theme_stylebox_override("hover", c_btn_hov)
	close_opt.add_theme_stylebox_override("pressed", c_btn_hov)
	close_opt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.75))
	close_opt.add_theme_font_size_override("font_size", 13)
	close_opt.pressed.connect(func():
		_play_click()
		options_modal.visible = false
	)
	vb.add_child(close_opt)

func _build_credit_modal() -> void:
	if is_instance_valid(credit_modal):
		return
	credit_modal = Control.new()
	credit_modal.name = "CreditModal"
	credit_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	credit_modal.visible = false
	root_control.add_child(credit_modal)

	# 1. Dim background
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
