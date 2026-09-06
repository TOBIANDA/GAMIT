extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var time_left: float = 45.0

var items_to_find: Dictionary = {
	"envelope": {"found": false, "name": "✉️ Amplop Berisi Rol Foto TKP", "hint": "Di dekat tangga peron stasiun"},
	"ticket":   {"found": false, "name": "🎫 Tiket Kereta Luar Kota", "hint": "Di area loket tiket stasiun"},
	"watch":    {"found": false, "name": "⏱️ Jam Saku Arwah (Macet 16:04)", "hint": "Di bawah jam besar stasiun"}
}

var root_control: Control
var timer_label: Label
var item_checklist: VBoxContainer
var status_banner: Label
var close_btn: Button
var canvas_area: Control

var tex_station_bg: Texture2D
var tex_envelope: Texture2D

var item_buttons: Dictionary = {}

func _ready() -> void:
	layer = 14
	_load_assets()
	_build_scene_ui()
	visible = false

func _load_assets() -> void:
	tex_station_bg = load("res://Environment/stasiun/latar stasiun.png")
	tex_envelope = load("res://Environment/interactable assets/surat.png")

func start_minigame() -> void:
	is_active = true
	visible = true
	time_left = 45.0
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false
		if item_buttons.has(k) and is_instance_valid(item_buttons[k]):
			item_buttons[k].visible = true

	_refresh_checklist()
	status_banner.text = "🔍 Temukan 3 barang bukti korban di peron stasiun sebelum kereta berangkat!"
	status_banner.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

func _process(delta: float) -> void:
	if not is_active:
		return

	time_left -= delta
	if is_instance_valid(timer_label):
		timer_label.text = "⏱️ Jadwal Kereta Berangkat: %.1fs" % max(0.0, time_left)
		if time_left < 10.0:
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		else:
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))

	if time_left <= 0.0:
		_fail_timeout()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		_finish_and_close(false)
		get_viewport().set_input_as_handled()

func _refresh_checklist() -> void:
	if not is_instance_valid(item_checklist):
		return
	for c in item_checklist.get_children():
		c.queue_free()

	for k in items_to_find.keys():
		var item = items_to_find[k]
		var lbl = Label.new()
		if item["found"]:
			lbl.text = "✔ " + item["name"] + " [DITEMUKAN]"
			lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
		else:
			lbl.text = "○ " + item["name"] + " — " + item["hint"]
			lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
		lbl.add_theme_font_size_override("font_size", 14)
		item_checklist.add_child(lbl)

func _on_item_clicked(item_key: String) -> void:
	if not is_active or not items_to_find.has(item_key):
		return
	if items_to_find[item_key]["found"]:
		return

	items_to_find[item_key]["found"] = true
	if item_buttons.has(item_key) and is_instance_valid(item_buttons[item_key]):
		item_buttons[item_key].visible = false

	_refresh_checklist()

	status_banner.text = "✨ Ditemukan: " + items_to_find[item_key]["name"]
	status_banner.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))

	var all_found = true
	for k in items_to_find.keys():
		if not items_to_find[k]["found"]:
			all_found = false
			break

	if all_found:
		_complete_victory()

func _complete_victory() -> void:
	is_active = false
	status_banner.text = "🎉 SEMUA BUKTI BERHASIL DIKUMPULKAN! Bawa amplop foto pulang ke rumah untuk dicuci!"
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("train_ticket")
		inv_mgr.unlock_clue("broken_pocket_watch")
		inv_mgr.unlock_clue("photo_envelope")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_3_PHOTO)

	await get_tree().create_timer(2.0).timeout
	_finish_and_close(true)

func _fail_timeout() -> void:
	is_active = false
	status_banner.text = "❌ WAKTU HABIS! Kereta melintas dan menimbulkan kepanikan arwah! Mengulang..."
	status_banner.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

	await get_tree().create_timer(1.8).timeout
	time_left = 45.0
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false
		if item_buttons.has(k) and is_instance_valid(item_buttons[k]):
			item_buttons[k].visible = true
	_refresh_checklist()
	is_active = true

func _finish_and_close(success: bool = true) -> void:
	is_active = false
	visible = false
	minigame_completed.emit(success)

func _build_scene_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	var bg_overlay = ColorRect.new()
	bg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_overlay.color = Color(0.04, 0.05, 0.08, 0.95)
	root_control.add_child(bg_overlay)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	root_control.add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 10)
	margin.add_child(main_box)

	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "🚉 PERON STASIUN TIMUR — PENCARIAN BARANG BUKTI KORBAN"
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	timer_label = Label.new()
	timer_label.text = "⏱️ Jadwal Kereta: 45.0s"
	timer_label.add_theme_font_size_override("font_size", 16)
	header.add_child(timer_label)

	close_btn = Button.new()
	close_btn.text = "✖ Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func(): _finish_and_close(false))
	header.add_child(close_btn)

	status_banner = Label.new()
	status_banner.text = "🔍 Klik objek tersembunyi di peron stasiun!"
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 14)
	main_box.add_child(status_banner)

	# Canvas Area dengan Latar Belakang Ilustrasi Asli Stasiun
	canvas_area = Control.new()
	canvas_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas_area.custom_minimum_size = Vector2(0, 420)
	main_box.add_child(canvas_area)

	var bg_station = TextureRect.new()
	if is_instance_valid(tex_station_bg):
		bg_station.texture = tex_station_bg
	bg_station.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_station.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_station.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	canvas_area.add_child(bg_station)

	# 1. Amplop Foto TKP (di dekat tangga stasiun)
	var btn_env = Button.new()
	btn_env.text = "✉️ Amplop Foto TKP"
	btn_env.position = Vector2(620, 290)
	btn_env.custom_minimum_size = Vector2(160, 42)
	btn_env.focus_mode = Control.FOCUS_NONE
	_style_item_button(btn_env, Color(0.9, 0.7, 0.2))
	btn_env.pressed.connect(func(): _on_item_clicked("envelope"))
	canvas_area.add_child(btn_env)
	item_buttons["envelope"] = btn_env

	# 2. Tiket Kereta (di dekat loket TICKET kanan)
	var btn_tkt = Button.new()
	btn_tkt.text = "🎫 Tiket Kereta Luar Kota"
	btn_tkt.position = Vector2(870, 240)
	btn_tkt.custom_minimum_size = Vector2(170, 40)
	btn_tkt.focus_mode = Control.FOCUS_NONE
	_style_item_button(btn_tkt, Color(0.3, 0.8, 1.0))
	btn_tkt.pressed.connect(func(): _on_item_clicked("ticket"))
	canvas_area.add_child(btn_tkt)
	item_buttons["ticket"] = btn_tkt

	# 3. Jam Saku Rusak 16:04 (di bawah jam stasiun tengah atas)
	var btn_wch = Button.new()
	btn_wch.text = "⏱️ Jam Saku (16:04)"
	btn_wch.position = Vector2(430, 140)
	btn_wch.custom_minimum_size = Vector2(160, 40)
	btn_wch.focus_mode = Control.FOCUS_NONE
	_style_item_button(btn_wch, Color(1.0, 0.4, 0.4))
	btn_wch.pressed.connect(func(): _on_item_clicked("watch"))
	canvas_area.add_child(btn_wch)
	item_buttons["watch"] = btn_wch

	# Panel Checklist Bawah
	var bottom_panel = PanelContainer.new()
	var bot_style = StyleBoxFlat.new()
	bot_style.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	bot_style.border_color = Color(0.3, 0.35, 0.45, 0.8)
	bot_style.set_border_width_all(1)
	bot_style.set_corner_radius_all(8)
	bot_style.content_margin_left = 20.0
	bot_style.content_margin_right = 20.0
	bot_style.content_margin_top = 10.0
	bot_style.content_margin_bottom = 10.0
	bottom_panel.add_theme_stylebox_override("panel", bot_style)
	main_box.add_child(bottom_panel)

	item_checklist = VBoxContainer.new()
	bottom_panel.add_child(item_checklist)
	_refresh_checklist()

func _style_item_button(btn: Button, border_col: Color) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.08, 0.12, 0.88)
	sb.border_color = border_col
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	btn.add_theme_stylebox_override("normal", sb)
	
	var sb_h = sb.duplicate()
	sb_h.bg_color = Color(border_col.r * 0.3, border_col.g * 0.3, border_col.b * 0.3, 0.95)
	btn.add_theme_stylebox_override("hover", sb_h)
