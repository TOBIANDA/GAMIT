extends CanvasLayer

signal safe_opened(success: bool)

var is_active: bool = false
var digit1: int = 0
var digit2: int = 0
var digit3: int = 0

const CODE_1 = 1
const CODE_2 = 6
const CODE_3 = 4

var digit1_label: Label
var digit2_label: Label
var digit3_label: Label
var status_label: Label
var riddle_label: Label
var unlock_btn: Button
var close_btn: Button

func _ready() -> void:
	layer = 14
	_build_scene_ui()
	visible = false

func start_minigame() -> void:
	is_active = true
	visible = true
	digit1 = 0
	digit2 = 0
	digit3 = 0
	_update_digits_display()
	status_label.text = "🔒 Masukkan 3 digit kombinasi brankas:"
	status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	unlock_btn.disabled = false

func _update_digits_display() -> void:
	if is_instance_valid(digit1_label):
		digit1_label.text = str(digit1)
	if is_instance_valid(digit2_label):
		digit2_label.text = str(digit2)
	if is_instance_valid(digit3_label):
		digit3_label.text = str(digit3)

func _change_digit(digit_idx: int, amount: int) -> void:
	if digit_idx == 1:
		digit1 = posmod(digit1 + amount, 10)
	elif digit_idx == 2:
		digit2 = posmod(digit2 + amount, 10)
	elif digit_idx == 3:
		digit3 = posmod(digit3 + amount, 10)
	_update_digits_display()

func _try_unlock() -> void:
	if digit1 == CODE_1 and digit2 == CODE_2 and digit3 == CODE_3:
		status_label.text = "🎉 KLIK! BRANKAS TERBUKA!"
		status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		unlock_btn.disabled = true

		var inv_mgr = get_node_or_null("/root/InvestigationManager")
		if is_instance_valid(inv_mgr):
			inv_mgr.unlock_clue("mother_emotional_locket")
			inv_mgr.safe_unlocked = true

		await get_tree().create_timer(1.8).timeout
		is_active = false
		visible = false
		safe_opened.emit(true)
	else:
		status_label.text = "❌ KOMBINASI SALAH! Perhatikan teka-teki ibu di catatan..."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

func _build_scene_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.04, 0.06, 0.94)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 120)
	margin.add_theme_constant_override("margin_right", 120)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 14)
	margin.add_child(main_box)

	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "🗝️ BRANKAS BAJA KELUARGA — RUMAH IBU MEDELINE"
	title.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	close_btn = Button.new()
	close_btn.text = "✖ Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func(): is_active = false; visible = false)
	header.add_child(close_btn)

	var riddle_panel = PanelContainer.new()
	var r_style = StyleBoxFlat.new()
	r_style.bg_color = Color(0.12, 0.14, 0.18, 0.95)
	r_style.border_color = Color(0.8, 0.65, 0.3, 0.8)
	r_style.set_border_width_all(2)
	r_style.set_corner_radius_all(8)
	r_style.content_margin_left = 16
	r_style.content_margin_right = 16
	r_style.content_margin_top = 12
	r_style.content_margin_bottom = 12
	riddle_panel.add_theme_stylebox_override("panel", r_style)
	main_box.add_child(riddle_panel)

	riddle_label = Label.new()
	riddle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	riddle_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	riddle_label.add_theme_font_size_override("font_size", 13)
	riddle_label.text = "📜 Catatan di samping brankas:\n'Untuk anakku tersayang Benedict... Tiga angka ini menyimpan kenangan abadi kita:\n1. Angka pertama: Awal waktu dunia ini membeku... (1)\n2. Angka kedua: Bulan kenangan kita merayakan ulang tahunmu... (6)\n3. Angka ketiga: Detik terakhir pada jam tangan pemberian ibu... (4)'"
	riddle_panel.add_child(riddle_label)

	status_label = Label.new()
	status_label.text = "Masukkan 3 digit kombinasi brankas:"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 15)
	main_box.add_child(status_label)

	var dials_hbox = HBoxContainer.new()
	dials_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	dials_hbox.add_theme_constant_override("separation", 30)
	main_box.add_child(dials_hbox)

	var d1_box = _create_dial_widget(1, func(amt): _change_digit(1, amt))
	digit1_label = d1_box.get_node("DigitLabel")
	dials_hbox.add_child(d1_box)

	var d2_box = _create_dial_widget(2, func(amt): _change_digit(2, amt))
	digit2_label = d2_box.get_node("DigitLabel")
	dials_hbox.add_child(d2_box)

	var d3_box = _create_dial_widget(3, func(amt): _change_digit(3, amt))
	digit3_label = d3_box.get_node("DigitLabel")
	dials_hbox.add_child(d3_box)

	unlock_btn = Button.new()
	unlock_btn.text = "🔓 BUKA BRANKAS"
	unlock_btn.custom_minimum_size = Vector2(260, 44)
	unlock_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	unlock_btn.focus_mode = Control.FOCUS_NONE
	unlock_btn.pressed.connect(_try_unlock)
	main_box.add_child(unlock_btn)

func _create_dial_widget(_idx: int, on_change_callback: Callable) -> VBoxContainer:
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)

	var btn_up = Button.new()
	btn_up.text = "▲"
	btn_up.custom_minimum_size = Vector2(60, 32)
	btn_up.focus_mode = Control.FOCUS_NONE
	btn_up.pressed.connect(func(): on_change_callback.call(1))
	vb.add_child(btn_up)

	var lbl = Label.new()
	lbl.name = "DigitLabel"
	lbl.text = "0"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	lbl.add_theme_font_size_override("font_size", 38)
	vb.add_child(lbl)

	var btn_down = Button.new()
	btn_down.text = "▼"
	btn_down.custom_minimum_size = Vector2(60, 32)
	btn_down.focus_mode = Control.FOCUS_NONE
	btn_down.pressed.connect(func(): on_change_callback.call(-1))
	vb.add_child(btn_down)

	return vb
