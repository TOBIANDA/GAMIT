extends CanvasLayer

signal safe_opened(success: bool)

var is_active: bool = false
var digit1: int = 0
var digit2: int = 0
var digit3: int = 0
var active_digit_idx: int = 0

const CODE_1 = 1
const CODE_2 = 6
const CODE_3 = 4

var digit_labels: Array[Label] = []
var dial_boxes: Array[Control] = []
var status_label: Label
var riddle_label: Label
var safe_image_rect: TextureRect
var numpad_image_rect: TextureRect
var unlock_btn: Button
var close_btn: Button
var reward_panel: PanelContainer
var reward_label: Label

var click_player: AudioStreamPlayer
var door_player: AudioStreamPlayer

var tex_safe_closed: Texture2D
var tex_safe_opened: Texture2D
var tex_numpad: Texture2D

func _ready() -> void:
	layer = 14
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
		click_player.volume_db = -3.0
	add_child(click_player)

	door_player = AudioStreamPlayer.new()
	door_player.name = "SafeDoorPlayer"
	var d_stream = load("res://sound/Door Open.mp3")
	if d_stream:
		door_player.stream = d_stream
		door_player.volume_db = -1.0
	add_child(door_player)

func _play_click() -> void:
	if is_instance_valid(click_player) and click_player.stream:
		click_player.play()

func _play_door() -> void:
	if is_instance_valid(door_player) and door_player.stream:
		door_player.play()

func start_minigame() -> void:
	if not is_instance_valid(status_label):
		_load_assets()
		_setup_audio()
		_build_scene_ui()
	is_active = true
	visible = true
	digit1 = 0
	digit2 = 0
	digit3 = 0
	active_digit_idx = 0
	
	if is_instance_valid(safe_image_rect) and is_instance_valid(tex_safe_closed):
		safe_image_rect.texture = tex_safe_closed

	if is_instance_valid(reward_panel):
		reward_panel.visible = false

	if is_instance_valid(status_label):
		status_label.text = "🔒 Masukkan 3 digit kombinasi brankas (Gunakan Angka Keyboard atau Tombol ▲/▼):"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	
	if is_instance_valid(unlock_btn):
		unlock_btn.text = "🔓 BUKA BRANKAS [ENTER]"
		unlock_btn.disabled = false

	_update_digits_display()

func _update_digits_display() -> void:
	var digits = [digit1, digit2, digit3]
	for i in range(3):
		if i < digit_labels.size() and is_instance_valid(digit_labels[i]):
			digit_labels[i].text = str(digits[i])
			if i == active_digit_idx:
				digit_labels[i].add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
			else:
				digit_labels[i].add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))

		if i < dial_boxes.size() and is_instance_valid(dial_boxes[i]):
			var border_color = Color(1.0, 0.8, 0.2, 1.0) if i == active_digit_idx else Color(0.3, 0.35, 0.45, 0.6)
			var sb = dial_boxes[i].get_theme_stylebox("panel") as StyleBoxFlat
			if sb:
				sb.border_color = border_color
				sb.set_border_width_all(2 if i == active_digit_idx else 1)

func _change_digit(digit_idx: int, amount: int) -> void:
	_play_click()
	active_digit_idx = digit_idx - 1
	if digit_idx == 1:
		digit1 = posmod(digit1 + amount, 10)
	elif digit_idx == 2:
		digit2 = posmod(digit2 + amount, 10)
	elif digit_idx == 3:
		digit3 = posmod(digit3 + amount, 10)
	_update_digits_display()

func _set_digit_direct(val: int) -> void:
	_play_click()
	if active_digit_idx == 0:
		digit1 = val
		active_digit_idx = 1
	elif active_digit_idx == 1:
		digit2 = val
		active_digit_idx = 2
	elif active_digit_idx == 2:
		digit3 = val
		active_digit_idx = 0
	_update_digits_display()

func _try_unlock() -> void:
	if digit1 == CODE_1 and digit2 == CODE_2 and digit3 == CODE_3:
		_play_door()
		if is_instance_valid(safe_image_rect) and is_instance_valid(tex_safe_opened):
			safe_image_rect.texture = tex_safe_opened

		status_label.text = "🎉 KLIK! MEKANISME BRANKAS TERBUKA!"
		status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		unlock_btn.text = "✨ BRANKAS BERHASIL DIBUKA"
		unlock_btn.disabled = true

		if is_instance_valid(reward_panel):
			reward_panel.visible = true

		var inv_mgr = get_node_or_null("/root/InvestigationManager")
		if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
			inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
		if is_instance_valid(inv_mgr):
			inv_mgr.unlock_clue("mother_emotional_locket")
			inv_mgr.safe_unlocked = true

		if is_inside_tree() and get_tree():
			await get_tree().create_timer(2.4).timeout
		_close_safe(true)
	else:
		_play_click()
		status_label.text = "❌ KOMBINASI SALAH! Perhatikan teka-teki ibu di catatan (1-6-4)..."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

func _close_safe(success: bool = false) -> void:
	is_active = false
	visible = false
	safe_opened.emit(success)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			_close_safe(false)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			if is_instance_valid(reward_panel) and reward_panel.visible:
				_close_safe(true)
			else:
				_try_unlock()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_LEFT:
			active_digit_idx = posmod(active_digit_idx - 1, 3)
			_update_digits_display()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_RIGHT:
			active_digit_idx = posmod(active_digit_idx + 1, 3)
			_update_digits_display()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_UP:
			_change_digit(active_digit_idx + 1, 1)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_DOWN:
			_change_digit(active_digit_idx + 1, -1)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode >= KEY_0 and event.keycode <= KEY_9:
			_set_digit_direct(event.keycode - KEY_0)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
			_set_digit_direct(event.keycode - KEY_KP_0)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_BACKSPACE:
			active_digit_idx = posmod(active_digit_idx - 1, 3)
			_update_digits_display()
			get_viewport().set_input_as_handled()
			return

func _build_scene_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.05, 0.07, 0.96)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 12)
	margin.add_child(main_box)

	# 1. Header
	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "🗝️ BRANKAS BAJA KELUARGA — RUMAH MEDELINE"
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "✖ Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func(): _close_safe(false))
	header.add_child(close_btn)

	# 2. Main Content (3 Columns: Note, Safe Image, Dials)
	var content_hb = HBoxContainer.new()
	content_hb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hb.add_theme_constant_override("separation", 24)
	main_box.add_child(content_hb)

	# Kolom Kiri: Catatan Pesan Ibu Medeline
	var riddle_panel = PanelContainer.new()
	riddle_panel.custom_minimum_size = Vector2(340, 0)
	var r_style = StyleBoxFlat.new()
	r_style.bg_color = Color(0.10, 0.12, 0.16, 0.95)
	r_style.border_color = Color(0.85, 0.70, 0.35, 0.8)
	r_style.set_border_width_all(2)
	r_style.set_corner_radius_all(8)
	r_style.content_margin_left = 18
	r_style.content_margin_right = 18
	r_style.content_margin_top = 16
	r_style.content_margin_bottom = 16
	riddle_panel.add_theme_stylebox_override("panel", r_style)
	content_hb.add_child(riddle_panel)

	riddle_label = Label.new()
	riddle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	riddle_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.96))
	riddle_label.add_theme_font_size_override("font_size", 14)
	riddle_label.text = "📜 Catatan di Balik Foto Masa Kecil:\n\n'Untuk anakku tersayang Benedict...\n\nTiga angka ini menyimpan kenangan abadi keluarga kita:\n\n1. Angka Pertama:\nAwal waktu dunia ini membeku... (1)\n\n2. Angka Kedua:\nBulan kelahiranmu saat kita merayakannya... (6)\n\n3. Angka Ketiga:\nDetik terakhir pada jam tangan pemberian ibu... (4)\n\nKombinasi Rahasia: 1 - 6 - 4'"
	riddle_panel.add_child(riddle_label)

	# Kolom Tengah: Ilustrasi Asli Brankas Baja
	var safe_center = CenterContainer.new()
	safe_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hb.add_child(safe_center)

	safe_image_rect = TextureRect.new()
	if is_instance_valid(tex_safe_closed):
		safe_image_rect.texture = tex_safe_closed
	safe_image_rect.custom_minimum_size = Vector2(280, 280)
	safe_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	safe_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	safe_center.add_child(safe_image_rect)

	# Kolom Kanan: Dial Kontrol Kombinasi & Tombol
	var right_vb = VBoxContainer.new()
	right_vb.custom_minimum_size = Vector2(340, 0)
	right_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	right_vb.add_theme_constant_override("separation", 14)
	content_hb.add_child(right_vb)

	status_label = Label.new()
	status_label.text = "🔒 Masukkan 3 digit kombinasi brankas:"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	right_vb.add_child(status_label)

	var dials_hbox = HBoxContainer.new()
	dials_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	dials_hbox.add_theme_constant_override("separation", 16)
	right_vb.add_child(dials_hbox)

	digit_labels.clear()
	dial_boxes.clear()

	for i in range(1, 4):
		var dial_panel = PanelContainer.new()
		var dp_style = StyleBoxFlat.new()
		dp_style.bg_color = Color(0.06, 0.08, 0.11, 0.95)
		dp_style.border_color = Color(0.3, 0.35, 0.45, 0.6)
		dp_style.set_border_width_all(1)
		dp_style.set_corner_radius_all(8)
		dp_style.content_margin_left = 12
		dp_style.content_margin_right = 12
		dp_style.content_margin_top = 8
		dp_style.content_margin_bottom = 8
		dial_panel.add_theme_stylebox_override("panel", dp_style)
		dials_hbox.add_child(dial_panel)
		dial_boxes.append(dial_panel)

		var vb_dial = VBoxContainer.new()
		vb_dial.add_theme_constant_override("separation", 6)
		dial_panel.add_child(vb_dial)

		var btn_up = Button.new()
		btn_up.text = "▲"
		btn_up.custom_minimum_size = Vector2(50, 32)
		btn_up.focus_mode = Control.FOCUS_NONE
		var idx = i
		btn_up.pressed.connect(func(): _change_digit(idx, 1))
		vb_dial.add_child(btn_up)

		var lbl = Label.new()
		lbl.text = "0"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
		lbl.add_theme_font_size_override("font_size", 34)
		vb_dial.add_child(lbl)
		digit_labels.append(lbl)

		var btn_down = Button.new()
		btn_down.text = "▼"
		btn_down.custom_minimum_size = Vector2(50, 32)
		btn_down.focus_mode = Control.FOCUS_NONE
		btn_down.pressed.connect(func(): _change_digit(idx, -1))
		vb_dial.add_child(btn_down)

	unlock_btn = Button.new()
	unlock_btn.text = "🔓 BUKA BRANKAS [ENTER]"
	unlock_btn.custom_minimum_size = Vector2(260, 44)
	unlock_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	unlock_btn.focus_mode = Control.FOCUS_NONE
	var u_style = StyleBoxFlat.new()
	u_style.bg_color = Color(0.15, 0.55, 0.35, 1.0)
	u_style.border_color = Color(0.4, 0.9, 0.6, 1.0)
	u_style.set_border_width_all(2)
	u_style.set_corner_radius_all(6)
	unlock_btn.add_theme_stylebox_override("normal", u_style)
	unlock_btn.pressed.connect(_try_unlock)
	right_vb.add_child(unlock_btn)

	# 3. Reward Banner saat terbuka
	reward_panel = PanelContainer.new()
	var rew_style = StyleBoxFlat.new()
	rew_style.bg_color = Color(0.08, 0.20, 0.14, 0.98)
	rew_style.border_color = Color(0.4, 1.0, 0.6, 1.0)
	rew_style.set_border_width_all(2)
	rew_style.set_corner_radius_all(8)
	rew_style.content_margin_left = 20
	rew_style.content_margin_right = 20
	rew_style.content_margin_top = 10
	rew_style.content_margin_bottom = 10
	reward_panel.add_theme_stylebox_override("panel", rew_style)
	reward_panel.visible = false
	main_box.add_child(reward_panel)

	reward_label = Label.new()
	reward_label.text = "💎 ITEM DIDAPATKAN: Liontin Kenangan Ibu Medeline!\nDi dalam brankas tersimpan liontin perak berisi foto ibu dan Benedict kecil. Bukti cinta sejati yang mengikat arwahmu menuju Kedamaian Sejati (True Ending)!"
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.add_theme_color_override("font_color", Color(0.85, 1.0, 0.9))
	reward_label.add_theme_font_size_override("font_size", 14)
	reward_panel.add_child(reward_label)

	_update_digits_display()
