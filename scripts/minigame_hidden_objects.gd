extends CanvasLayer

# ── Mini Game 2: Hidden Objects di Stasiun Kereta (Sesuai GDD) ──────────────
# Benedict harus mencari 3 barang bukti di stasiun sebelum kereta tiba
# Kontrol: Klik kiri pada objek yang dicari.

signal minigame_completed(success: bool)

var is_active: bool = false
var time_left: float = 45.0

var items_to_find: Dictionary = {
	"envelope": {"found": false, "name": "✉️ Amplop Rol Foto", "pos": Vector2(480, 310), "size": Vector2(56, 42)},
	"ticket":   {"found": false, "name": "🎫 Tiket Kereta Api", "pos": Vector2(760, 440), "size": Vector2(48, 32)},
	"watch":    {"found": false, "name": "⏱️ Jam Saku Rusak (16:04)", "pos": Vector2(310, 220), "size": Vector2(40, 40)}
}

var root_control: Control
var timer_label: Label
var item_checklist: VBoxContainer
var status_banner: Label
var close_btn: Button

func _ready() -> void:
	layer = 14
	_build_scene_ui()
	visible = false

func start_minigame() -> void:
	is_active = true
	visible = true
	time_left = 45.0
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false
	_refresh_checklist()
	status_banner.text = "🔍 Klik objek tersembunyi di peron stasiun!"
	status_banner.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

func _process(delta: float) -> void:
	if not is_active:
		return

	time_left -= delta
	if is_instance_valid(timer_label):
		timer_label.text = "⏱️ Waktu Sebelum Kereta Tiba: %.1fs" % max(0.0, time_left)
		if time_left < 10.0:
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		else:
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))

	if time_left <= 0.0:
		_fail_timeout()

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
			lbl.text = "○ " + item["name"]
			lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95))
		lbl.add_theme_font_size_override("font_size", 14)
		item_checklist.add_child(lbl)

func _on_item_clicked(item_key: String) -> void:
	if not is_active or not items_to_find.has(item_key):
		return
	if items_to_find[item_key]["found"]:
		return

	items_to_find[item_key]["found"] = true
	_refresh_checklist()

	status_banner.text = "✨ Ditemukan: " + items_to_find[item_key]["name"]
	status_banner.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))

	# Cek apakah semua item sudah ditemukan
	var all_found = true
	for k in items_to_find.keys():
		if not items_to_find[k]["found"]:
			all_found = false
			break

	if all_found:
		_complete_victory()

func _complete_victory() -> void:
	is_active = false
	status_banner.text = "🎉 SEMUA BUKTI STASIUN TELAH DITEMUKAN!"
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("train_ticket")
		inv_mgr.unlock_clue("broken_pocket_watch")
		inv_mgr.unlock_clue("photo_envelope")
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_3_PHOTO)

	await get_tree().create_timer(1.8).timeout
	visible = false
	minigame_completed.emit(true)

func _fail_timeout() -> void:
	is_active = false
	status_banner.text = "❌ WAKTU HABIS! Kereta melintas dan menimbulkan kepanikan!"
	status_banner.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))

	await get_tree().create_timer(1.5).timeout
	# Reset
	time_left = 45.0
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false
	_refresh_checklist()
	is_active = true

# ── Membangun Visual Scene Stasiun & Objek Interaktif ──────────────────────
func _build_scene_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	var bg_overlay = ColorRect.new()
	bg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_overlay.color = Color(0.04, 0.05, 0.08, 0.94)
	root_control.add_child(bg_overlay)

	# Frame Stasiun
	var station_panel = PanelContainer.new()
	station_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	root_control.add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 12)
	margin.add_child(main_box)

	# Header Stasiun
	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "🚉 PERON STASIUN TIMUR — PENCARIAN BUKTI TERSEMBUNYI"
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	timer_label = Label.new()
	timer_label.text = "⏱️ Waktu Sebelum Kereta: 45.0s"
	timer_label.add_theme_font_size_override("font_size", 16)
	header.add_child(timer_label)

	close_btn = Button.new()
	close_btn.text = "✖ Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func(): visible = false; is_active = false)
	header.add_child(close_btn)

	status_banner = Label.new()
	status_banner.text = "🔍 Klik objek tersembunyi di peron stasiun!"
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 14)
	main_box.add_child(status_banner)

	# Area Gambar Peron Interaktif
	var canvas_area = Control.new()
	canvas_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas_area.custom_minimum_size = Vector2(0, 420)
	main_box.add_child(canvas_area)

	# Dekorasi Latar Stasiun Retro
	var decor_rect = ColorRect.new()
	decor_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	decor_rect.color = Color(0.12, 0.14, 0.18, 1.0)
	canvas_area.add_child(decor_rect)

	# Rel Kereta & Bangku Peron
	var rail = ColorRect.new()
	rail.position = Vector2(0, 360)
	rail.size = Vector2(1200, 50)
	rail.color = Color(0.24, 0.20, 0.16)
	canvas_area.add_child(rail)

	# Objek 1: Amplop Foto (Klik Area)
	var btn_env = Button.new()
	btn_env.text = "📁 [Amplop TKP]"
	btn_env.position = Vector2(480, 290)
	btn_env.size = Vector2(130, 44)
	btn_env.focus_mode = Control.FOCUS_NONE
	btn_env.pressed.connect(func(): _on_item_clicked("envelope"))
	canvas_area.add_child(btn_env)

	# Objek 2: Tiket Kereta (Klik Area)
	var btn_tkt = Button.new()
	btn_tkt.text = "🎫 [Tiket Kereta]"
	btn_tkt.position = Vector2(760, 360)
	btn_tkt.size = Vector2(120, 38)
	btn_tkt.focus_mode = Control.FOCUS_NONE
	btn_tkt.pressed.connect(func(): _on_item_clicked("ticket"))
	canvas_area.add_child(btn_tkt)

	# Objek 3: Jam Saku Rusak (Klik Area)
	var btn_wch = Button.new()
	btn_wch.text = "⏱️ [Jam Saku 16:04]"
	btn_wch.position = Vector2(280, 180)
	btn_wch.size = Vector2(140, 42)
	btn_wch.focus_mode = Control.FOCUS_NONE
	btn_wch.pressed.connect(func(): _on_item_clicked("watch"))
	canvas_area.add_child(btn_wch)

	# Checklist Bukti di Bawah
	var bottom_panel = PanelContainer.new()
	var bot_style = StyleBoxFlat.new()
	bot_style.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	bot_style.set_corner_radius_all(6)
	bot_style.content_margin_left = 16.0
	bot_style.content_margin_right = 16.0
	bot_style.content_margin_top = 8.0
	bot_style.content_margin_bottom = 8.0
	bottom_panel.add_theme_stylebox_override("panel", bot_style)
	main_box.add_child(bottom_panel)

	item_checklist = VBoxContainer.new()
	bottom_panel.add_child(item_checklist)
	_refresh_checklist()
