extends CanvasLayer

signal safe_opened(success: bool)

var is_active: bool = false
var entered_digits: Array[int] = []

const CODE = [1, 4, 3]

var lcd_status_lbl: Label
var lcd_digits_lbl: Label
var status_label: Label
var safe_image_rect: TextureRect
var numpad_container: Control
var close_btn: Button
var reward_panel: PanelContainer
var reward_label: Label

var click_player: AudioStreamPlayer
var door_player: AudioStreamPlayer
var buzzer_player: AudioStreamPlayer

var tex_safe_closed: Texture2D
var tex_safe_opened: Texture2D
var tex_numpad: Texture2D

func _ready() -> void:
	layer = 16
	_load_assets()
	_setup_audio()
	_build_scene_ui()
	visible = false

func _load_assets() -> void:
	tex_safe_closed = load("res://Environment/interactable assets/berangkas.png")
	tex_safe_opened = load("res://Environment/interactable assets/berangkas-terbuka.png")
	tex_numpad = load("res://Environment/interactable assets/zoom-in numpad.png")

func _setup_audio() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "SafeClickPlayer"
	var c_stream = load("res://sound/Click sound.mp3")
	if c_stream:
		click_player.stream = c_stream
		click_player.volume_db = -2.0
	add_child(click_player)

	door_player = AudioStreamPlayer.new()
	door_player.name = "SafeDoorPlayer"
	var d_stream = load("res://sound/Door Open.mp3")
	if d_stream:
		door_player.stream = d_stream
		door_player.volume_db = 0.0
	add_child(door_player)

	buzzer_player = AudioStreamPlayer.new()
	buzzer_player.name = "SafeBuzzerPlayer"
	var b_stream = load("res://sound/Click sound.mp3")
	if b_stream:
		buzzer_player.stream = b_stream
		buzzer_player.volume_db = 2.0
		buzzer_player.pitch_scale = 0.6
	add_child(buzzer_player)

func _play_click(pitch: float = 1.0) -> void:
	if is_instance_valid(click_player) and click_player.is_inside_tree() and click_player.stream:
		click_player.pitch_scale = pitch
		click_player.play()

func _play_door() -> void:
	if is_instance_valid(door_player) and door_player.is_inside_tree() and door_player.stream:
		door_player.play()

func _play_buzzer() -> void:
	if is_instance_valid(buzzer_player) and buzzer_player.is_inside_tree() and buzzer_player.stream:
		buzzer_player.play()

func start_minigame() -> void:
	if not is_instance_valid(status_label):
		_load_assets()
		_setup_audio()
		_build_scene_ui()
	is_active = true
	visible = true
	entered_digits.clear()

	if is_instance_valid(safe_image_rect) and is_instance_valid(tex_safe_closed):
		safe_image_rect.texture = tex_safe_closed

	if is_instance_valid(reward_panel):
		reward_panel.visible = false

	if is_instance_valid(status_label):
		status_label.text = "Klik tombol angka pada Numpad atau tekan Keyboard (1-9):"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))

	_update_lcd_display()

func _update_lcd_display(custom_status: String = "", status_col: Color = Color(0.3, 0.9, 1.0)) -> void:
	if is_instance_valid(lcd_status_lbl):
		if custom_status.is_empty():
			lcd_status_lbl.text = "✦ INPUT PIN KEAMANAN ✦"
			lcd_status_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
		else:
			lcd_status_lbl.text = custom_status
			lcd_status_lbl.add_theme_color_override("font_color", status_col)

	if is_instance_valid(lcd_digits_lbl):
		var d_texts: Array[String] = []
		for i in range(3):
			if i < entered_digits.size():
				d_texts.append(str(entered_digits[i]))
			else:
				d_texts.append("_")
		lcd_digits_lbl.text = "[ %s ]  [ %s ]  [ %s ]" % [d_texts[0], d_texts[1], d_texts[2]]

func _on_key_pressed(digit: int) -> void:
	if not is_active:
		return
	if entered_digits.size() >= 3:
		return
	_play_click(1.0 + float(digit) * 0.04)
	entered_digits.append(digit)
	_update_lcd_display()

	if entered_digits.size() == 3:
		_try_unlock()

func _on_backspace_pressed() -> void:
	if not is_active:
		return
	_play_click(0.85)
	if entered_digits.size() > 0:
		entered_digits.pop_back()
	_update_lcd_display()

func _on_enter_pressed() -> void:
	if not is_active:
		return
	if entered_digits.size() == 3:
		_try_unlock()
	else:
		_play_click(0.7)
		_update_lcd_display("PIN HARUS 3 DIGIT!", Color(1.0, 0.7, 0.2))

func _try_unlock() -> void:
	if entered_digits.size() != 3:
		return

	if entered_digits == CODE:
		_play_door()
		if is_instance_valid(safe_image_rect) and is_instance_valid(tex_safe_opened):
			safe_image_rect.texture = tex_safe_opened

		_update_lcd_display("★ AKSES DITERIMA ★", Color(0.2, 1.0, 0.5))
		if is_instance_valid(status_label):
			status_label.text = "KLIK! MEKANISME BRANKAS TERBUKA!"
			status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

		if is_instance_valid(reward_panel):
			reward_panel.visible = true

		var inv_mgr = null
		if is_inside_tree():
			inv_mgr = get_node_or_null("/root/InvestigationManager")
			if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
				inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
		if is_instance_valid(inv_mgr):
			inv_mgr.unlock_clue("mother_emotional_locket")
			inv_mgr.safe_unlocked = true

		if is_inside_tree() and get_tree():
			await get_tree().create_timer(2.4).timeout
		_close_safe(true)
	else:
		_play_buzzer()
		_update_lcd_display("✖ KODE SALAH! ✖", Color(1.0, 0.3, 0.3))
		if is_instance_valid(status_label):
			status_label.text = "KOMBINASI SALAH! Periksa kembali petunjuk di sekitar rumah..."
			status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

		if is_inside_tree() and get_tree():
			await get_tree().create_timer(0.9).timeout
		if is_active:
			entered_digits.clear()
			_update_lcd_display()

func _close_safe(success: bool = false) -> void:
	is_active = false
	visible = false
	safe_opened.emit(success)

func _input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			_close_safe(false)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			if is_instance_valid(reward_panel) and reward_panel.visible:
				_close_safe(true)
			else:
				_on_enter_pressed()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_BACKSPACE:
			_on_backspace_pressed()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode >= KEY_0 and event.keycode <= KEY_9:
			_on_key_pressed(event.keycode - KEY_0)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
			_on_key_pressed(event.keycode - KEY_KP_0)
			get_viewport().set_input_as_handled()
			return

func _build_scene_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.06, 0.96)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 10)
	margin.add_child(main_box)

	# 1. Header
	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "BRANKAS BAJA KELUARGA — RUMAH MEDELINE"
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 17)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_btn.pressed.connect(func(): _close_safe(false))
	header.add_child(close_btn)

	# 2. Main Content (2 Columns: Safe Illustration, Interactive Numpad)
	var content_hb = HBoxContainer.new()
	content_hb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	content_hb.add_theme_constant_override("separation", 24)
	main_box.add_child(content_hb)

	# Kolom Kiri: Ilustrasi Asli Brankas Baja (Diperbesar 2x dan responsif)
	var safe_center = CenterContainer.new()
	safe_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	safe_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hb.add_child(safe_center)

	safe_image_rect = TextureRect.new()
	if is_instance_valid(tex_safe_closed):
		safe_image_rect.texture = tex_safe_closed
	safe_image_rect.custom_minimum_size = Vector2(620, 560)
	safe_image_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	safe_image_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	safe_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	safe_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	safe_center.add_child(safe_image_rect)

	# Kolom Kanan: Visual Keypad Numpad Asli (zoom-in numpad.png)
	var right_vb = VBoxContainer.new()
	right_vb.custom_minimum_size = Vector2(300, 0)
	right_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	right_vb.add_theme_constant_override("separation", 8)
	content_hb.add_child(right_vb)

	status_label = Label.new()
	status_label.text = "Klik tombol angka pada Numpad atau tekan Keyboard:"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 12.5)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	right_vb.add_child(status_label)

	var numpad_center = CenterContainer.new()
	right_vb.add_child(numpad_center)

	# Container Numpad Asli berukuran proporsional 250 x 385 px
	numpad_container = Control.new()
	numpad_container.custom_minimum_size = Vector2(250, 385)
	numpad_center.add_child(numpad_container)

	var numpad_img = TextureRect.new()
	numpad_img.set_anchors_preset(Control.PRESET_FULL_RECT)
	if is_instance_valid(tex_numpad):
		numpad_img.texture = tex_numpad
	numpad_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	numpad_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	numpad_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	numpad_container.add_child(numpad_img)

	# 1. Overlay Display LCD Screen di area atas layar monitor hitam numpad
	var lcd_screen = PanelContainer.new()
	lcd_screen.position = Vector2(22, 16)
	lcd_screen.size = Vector2(206, 82)
	var lcd_style = StyleBoxFlat.new()
	lcd_style.bg_color = Color(0.02, 0.05, 0.03, 0.95)
	lcd_style.border_color = Color(0.15, 0.45, 0.25, 0.8)
	lcd_style.set_border_width_all(1)
	lcd_style.set_corner_radius_all(4)
	lcd_screen.add_theme_stylebox_override("panel", lcd_style)
	numpad_container.add_child(lcd_screen)

	var lcd_vb = VBoxContainer.new()
	lcd_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	lcd_vb.add_theme_constant_override("separation", 2)
	lcd_screen.add_child(lcd_vb)

	lcd_status_lbl = Label.new()
	lcd_status_lbl.text = "✦ INPUT PIN KEAMANAN ✦"
	lcd_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lcd_status_lbl.add_theme_font_size_override("font_size", 10)
	lcd_status_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0))
	lcd_vb.add_child(lcd_status_lbl)

	lcd_digits_lbl = Label.new()
	lcd_digits_lbl.text = "[ _ ]  [ _ ]  [ _ ]"
	lcd_digits_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lcd_digits_lbl.add_theme_font_size_override("font_size", 22)
	lcd_digits_lbl.add_theme_color_override("font_color", Color(0.25, 1.0, 0.55))
	lcd_vb.add_child(lcd_digits_lbl)

	# 2. Overlay 12 Tombol Interaktif di atas 12 tuts numpad asli
	var col_xs = [25.0, 94.0, 164.0]
	var row_ys = [104.0, 169.0, 234.0, 299.0]
	var btn_w = 61.0
	var btn_h = 55.0

	var key_definitions = [
		{"label": "1", "row": 0, "col": 0, "action": func(): _on_key_pressed(1)},
		{"label": "2", "row": 0, "col": 1, "action": func(): _on_key_pressed(2)},
		{"label": "3", "row": 0, "col": 2, "action": func(): _on_key_pressed(3)},
		{"label": "4", "row": 1, "col": 0, "action": func(): _on_key_pressed(4)},
		{"label": "5", "row": 1, "col": 1, "action": func(): _on_key_pressed(5)},
		{"label": "6", "row": 1, "col": 2, "action": func(): _on_key_pressed(6)},
		{"label": "7", "row": 2, "col": 0, "action": func(): _on_key_pressed(7)},
		{"label": "8", "row": 2, "col": 1, "action": func(): _on_key_pressed(8)},
		{"label": "9", "row": 2, "col": 2, "action": func(): _on_key_pressed(9)},
		{"label": "DEL", "row": 3, "col": 0, "action": func(): _on_backspace_pressed()},
		{"label": "0", "row": 3, "col": 1, "action": func(): _on_key_pressed(0)},
		{"label": "ENT", "row": 3, "col": 2, "action": func(): _on_enter_pressed()},
	]

	for kd in key_definitions:
		var btn = Button.new()
		btn.position = Vector2(col_xs[kd["col"]], row_ys[kd["row"]])
		btn.size = Vector2(btn_w, btn_h)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.flat = true

		var b_norm = StyleBoxFlat.new()
		b_norm.bg_color = Color(0, 0, 0, 0.0)
		btn.add_theme_stylebox_override("normal", b_norm)

		var b_hov = StyleBoxFlat.new()
		b_hov.bg_color = Color(1.0, 1.0, 1.0, 0.16)
		b_hov.border_color = Color(1.0, 0.85, 0.35, 0.75)
		b_hov.set_border_width_all(2)
		b_hov.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("hover", b_hov)

		var b_press = StyleBoxFlat.new()
		b_press.bg_color = Color(1.0, 0.85, 0.25, 0.32)
		b_press.border_color = Color(1.0, 0.95, 0.6, 1.0)
		b_press.set_border_width_all(2)
		b_press.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("pressed", b_press)

		btn.text = kd["label"]
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0, 0.9))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.5))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 0.8))
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.z_index = 5
		btn.pressed.connect(kd["action"])
		numpad_container.add_child(btn)

	# 3. Reward Banner saat terbuka
	reward_panel = PanelContainer.new()
	var rew_style = StyleBoxFlat.new()
	rew_style.bg_color = Color(0.06, 0.18, 0.12, 0.98)
	rew_style.border_color = Color(0.4, 1.0, 0.6, 1.0)
	rew_style.set_border_width_all(2)
	rew_style.set_corner_radius_all(8)
	rew_style.content_margin_left = 18
	rew_style.content_margin_right = 18
	rew_style.content_margin_top = 8
	rew_style.content_margin_bottom = 8
	reward_panel.add_theme_stylebox_override("panel", rew_style)
	reward_panel.visible = false
	main_box.add_child(reward_panel)

	reward_label = Label.new()
	reward_label.text = "ITEM DIDAPATKAN: Liontin Perak & Surat Kasih Sayang Ibu Korban!\n'Untuk anakku tersayang... Apapun yang terjadi di dunia ini, ibu akan selalu menemanimu dan mendukung setiap langkahmu.'"
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.9))
	reward_label.add_theme_font_size_override("font_size", 13.5)
	reward_panel.add_child(reward_label)

	_update_lcd_display()

