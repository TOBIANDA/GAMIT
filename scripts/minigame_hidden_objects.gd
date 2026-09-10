extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var time_left: float = 60.0

var items_to_find: Dictionary = {
	"envelope": {"found": false, "name": "Amplop Foto Korban", "hint": "Di atas bangku tunggu stasiun"},
	"luggage":  {"found": false, "name": "Koper Biru & Tiket Kereta", "hint": "Di lantai dekat bangku tunggu"},
	"bag":      {"found": false, "name": "Tas Pribadi Korban", "hint": "Di atas sandaran bangku stasiun"}
}

var root_control: Control
var timer_label: Label
var item_checklist: VBoxContainer
var status_banner: Label
var close_btn: Button
var canvas_area: Control
var click_player: AudioStreamPlayer

var tex_station_bg: Texture2D
var tex_envelope: Texture2D
var tex_luggage: Texture2D
var tex_bag: Texture2D
var tex_umbrella: Texture2D
var tex_big_suitcase: Texture2D
var tex_trash_bin: Texture2D

var item_buttons: Dictionary = {}

func _ready() -> void:
	layer = 14
	_setup_audio()
	_load_assets()
	_build_scene_ui()
	visible = false

func _setup_audio() -> void:
	click_player = AudioStreamPlayer.new()
	click_player.name = "HiddenObjClickPlayer"
	var c_stream = load("res://sound/Click sound.mp3")
	if c_stream:
		click_player.stream = c_stream
		click_player.volume_db = -2.0
	add_child(click_player)

func _play_click() -> void:
	if is_instance_valid(click_player) and click_player.stream:
		click_player.play()

func _load_assets() -> void:
	if ResourceLoader.exists("res://stasiun/latar pake bayangan.png"):
		tex_station_bg = load("res://stasiun/latar pake bayangan.png")
	elif ResourceLoader.exists("res://stasiun/latar stasiun.png"):
		tex_station_bg = load("res://stasiun/latar stasiun.png")
	elif ResourceLoader.exists("res://Environment/stasiun/latar stasiun.png"):
		tex_station_bg = load("res://Environment/stasiun/latar stasiun.png")

	if ResourceLoader.exists("res://stasiun/surat diatas kursi.png"):
		tex_envelope = load("res://stasiun/surat diatas kursi.png")
	elif ResourceLoader.exists("res://Environment/interactable assets/surat.png"):
		tex_envelope = load("res://Environment/interactable assets/surat.png")

	if ResourceLoader.exists("res://stasiun/koperbiru.png"):
		tex_luggage = load("res://stasiun/koperbiru.png")

	if ResourceLoader.exists("res://stasiun/tas diatas kursi.png"):
		tex_bag = load("res://stasiun/tas diatas kursi.png")

	if ResourceLoader.exists("res://stasiun/payung depan.png"):
		tex_umbrella = load("res://stasiun/payung depan.png")

	if ResourceLoader.exists("res://stasiun/koperbesar.png"):
		tex_big_suitcase = load("res://stasiun/koperbesar.png")

	if ResourceLoader.exists("res://stasiun/tongsampah.png"):
		tex_trash_bin = load("res://stasiun/tongsampah.png")

func start_minigame() -> void:
	if not is_instance_valid(root_control):
		_load_assets()
		_setup_audio()
		_build_scene_ui()
	is_active = true
	visible = true
	time_left = 60.0
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false
		if item_buttons.has(k) and is_instance_valid(item_buttons[k]):
			item_buttons[k].visible = true
			item_buttons[k].modulate = Color.WHITE

	_refresh_checklist()
	if is_instance_valid(status_banner):
		status_banner.text = "Temukan 3 barang bukti korban di peron stasiun sebelum jadwal kereta berangkat!"
		status_banner.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

func _process(delta: float) -> void:
	if not is_active:
		return

	time_left -= delta
	if is_instance_valid(timer_label):
		timer_label.text = "Jadwal Kereta Berangkat: %.1fs" % max(0.0, time_left)
		if time_left < 15.0:
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		else:
			timer_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))

	# Efek pulsing lembut pada item yang belum ditemukan
	var pulse = 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.006)
	for k in items_to_find.keys():
		if not items_to_find[k]["found"] and item_buttons.has(k) and is_instance_valid(item_buttons[k]):
			item_buttons[k].modulate = Color(pulse, pulse, 1.0, 1.0)

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
			lbl.text = "" + item["name"] + " [DITEMUKAN]"
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

	_play_click()
	items_to_find[item_key]["found"] = true
	if item_buttons.has(item_key) and is_instance_valid(item_buttons[item_key]):
		item_buttons[item_key].visible = false

	_refresh_checklist()

	status_banner.text = "Ditemukan: " + items_to_find[item_key]["name"] + "!"
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
	status_banner.text = "SEMUA BUKTI DITEMUKAN! Amplop foto berhasil diamankan! Bawa ke Kantor Polisi untuk dicuci!"
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
		inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("train_ticket")
		inv_mgr.unlock_clue("photo_envelope")
		inv_mgr.has_cleared_station = true
		inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_3_PHOTO)

	if is_inside_tree() and get_tree():
		await get_tree().create_timer(2.2).timeout
	_finish_and_close(true)

func _fail_timeout() -> void:
	is_active = false
	status_banner.text = "WAKTU HABIS! Kereta melintas dan menimbulkan kepanikan! Mengulang pencarian..."
	status_banner.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	if is_inside_tree() and get_tree():
		await get_tree().create_timer(2.0).timeout
	time_left = 60.0
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

	if success and get_tree() and get_tree().root:
		var dlg = get_tree().root.find_child("DialogBox", true, false)
		if is_instance_valid(dlg) and dlg.has_method("start_monologue"):
			var lines: Array[String] = [
				"Di peron stasiun ini... aku menemukan tiket kereta dan amplop berisi rol film foto milik korban.",
				"Aku harus segera kembali ke Kantor Polisi (atau Kamar Gelap) untuk mencuci rol foto ini!",
				"Firasatku mengatakan... foto-foto ini akan membuka identitas korban yang sebenarnya."
			]
			dlg.start_monologue(lines, "Detektif Benedict", "[ Bukti Foto Didapatkan ]", "res://karakter/MC_Bingung.png")

func _build_scene_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	var bg_overlay = ColorRect.new()
	bg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_overlay.color = Color(0.04, 0.05, 0.08, 0.96)
	root_control.add_child(bg_overlay)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	root_control.add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 8)
	margin.add_child(main_box)

	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "PERON STASIUN TIMUR — PENCARIAN BARANG BUKTI KORBAN"
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	timer_label = Label.new()
	timer_label.text = "Jadwal Kereta: 60.0s"
	timer_label.add_theme_font_size_override("font_size", 16)
	header.add_child(timer_label)

	close_btn = Button.new()
	close_btn.text = "Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func(): _finish_and_close(false))
	header.add_child(close_btn)

	status_banner = Label.new()
	status_banner.text = "Klik objek bukti tersembunyi di peron stasiun!"
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 14)
	main_box.add_child(status_banner)

	# Canvas Area dengan Latar Belakang Asli Stasiun
	canvas_area = Control.new()
	canvas_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas_area.custom_minimum_size = Vector2(0, 440)
	main_box.add_child(canvas_area)

	var bg_station = TextureRect.new()
	if is_instance_valid(tex_station_bg):
		bg_station.texture = tex_station_bg
	bg_station.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_station.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_station.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	canvas_area.add_child(bg_station)

	# --- OBJEK DEKORATIF DARI ASET USER ---
	if is_instance_valid(tex_big_suitcase):
		var deco_koper = TextureRect.new()
		deco_koper.texture = tex_big_suitcase
		deco_koper.position = Vector2(880, 240)
		deco_koper.size = Vector2(170, 170)
		deco_koper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		deco_koper.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		canvas_area.add_child(deco_koper)

	if is_instance_valid(tex_umbrella):
		var deco_umbrella = TextureRect.new()
		deco_umbrella.texture = tex_umbrella
		deco_umbrella.position = Vector2(210, 220)
		deco_umbrella.size = Vector2(140, 140)
		deco_umbrella.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		deco_umbrella.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		canvas_area.add_child(deco_umbrella)

	if is_instance_valid(tex_trash_bin):
		var deco_trash = TextureRect.new()
		deco_trash.texture = tex_trash_bin
		deco_trash.position = Vector2(140, 260)
		deco_trash.size = Vector2(120, 120)
		deco_trash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		deco_trash.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		canvas_area.add_child(deco_trash)

	# --- 3 TARGET UTAMA PENCARIAN (INTERACTIVE BUTTONS) ---
	# 1. Amplop Surat di atas kursi
	var btn_env = _create_interactive_prop("envelope", tex_envelope, Vector2(390, 230), Vector2(180, 180), "Amplop Foto Korban")
	canvas_area.add_child(btn_env)
	item_buttons["envelope"] = btn_env

	# 2. Koper Biru di lantai dekat peron
	var btn_lug = _create_interactive_prop("luggage", tex_luggage, Vector2(720, 270), Vector2(180, 180), "Koper Biru Korban")
	canvas_area.add_child(btn_lug)
	item_buttons["luggage"] = btn_lug

	# 3. Tas di atas kursi
	var btn_bag = _create_interactive_prop("bag", tex_bag, Vector2(560, 220), Vector2(170, 170), "Tas Pribadi Korban")
	canvas_area.add_child(btn_bag)
	item_buttons["bag"] = btn_bag

	# Panel Checklist Bawah
	var bottom_panel = PanelContainer.new()
	var bot_style = StyleBoxFlat.new()
	bot_style.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	bot_style.border_color = Color(0.3, 0.35, 0.45, 0.8)
	bot_style.set_border_width_all(1)
	bot_style.set_corner_radius_all(8)
	bot_style.content_margin_left = 20.0
	bot_style.content_margin_right = 20.0
	bot_style.content_margin_top = 8.0
	bot_style.content_margin_bottom = 8.0
	bottom_panel.add_theme_stylebox_override("panel", bot_style)
	main_box.add_child(bottom_panel)

	item_checklist = VBoxContainer.new()
	bottom_panel.add_child(item_checklist)
	_refresh_checklist()

func _create_interactive_prop(item_key: String, tex: Texture2D, pos: Vector2, prop_size: Vector2, tooltip: String) -> Control:
	var btn = TextureButton.new()
	btn.name = "Prop_" + item_key
	btn.texture_normal = tex
	btn.position = pos
	btn.size = prop_size
	btn.custom_minimum_size = prop_size
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.tooltip_text = tooltip
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(func(): _on_item_clicked(item_key))
	return btn
