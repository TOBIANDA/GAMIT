extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var time_left: float = 60.0

var items_to_find: Dictionary = {
	"envelope": {"found": false, "name": "Amplop Foto Korban", "hint": "Di atas bangku tunggu stasiun (kertas putih)"},
	"luggage":  {"found": false, "name": "Koper Biru & Tiket Kereta", "hint": "Tumpukan koper di lantai peron stasiun"},
	"bag":      {"found": false, "name": "Tas Pribadi Korban", "hint": "Tas koper merah di atas bangku tunggu"}
}

var root_control: Control
var aspect_container: AspectRatioContainer
var station_canvas: Control
var station_bg: TextureRect
var timer_label: Label
var item_checklist: VBoxContainer
var status_banner: Label
var close_btn: Button
var click_player: AudioStreamPlayer

# Aset Stasiun
var tex_station_bg: Texture2D

var item_buttons: Dictionary = {}
var item_found_badges: Dictionary = {}

# Koordinat persentase (anchor) presisi sub-pixel 1:1 sesuai ilustrasi utuh stasiun (5760x3240)
const ITEM_ANCHORS := {
	"envelope": {
		"left": 0.7680,
		"top": 0.7400,
		"right": 0.8350,
		"bottom": 0.8200,
		"name": "Amplop Foto Korban"
	},
	"bag": {
		"left": 0.7680,
		"top": 0.8130,
		"right": 0.9330,
		"bottom": 0.9070,
		"name": "Tas Pribadi Korban"
	},
	"luggage": {
		"left": 0.4160,
		"top": 0.6160,
		"right": 0.5020,
		"bottom": 0.7080,
		"name": "Koper Biru & Tiket Kereta"
	}
}

func _ready() -> void:
	layer = 15
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
	if is_instance_valid(click_player) and click_player.is_inside_tree() and click_player.stream:
		click_player.play()

func _load_assets() -> void:
	# Prioritaskan latar stasiun utuh (5760x3240) yang sudah berisi komposisi lengkap gambar kedua
	if ResourceLoader.exists("res://stasiun/latar stasiun.png"):
		tex_station_bg = load("res://stasiun/latar stasiun.png")
	elif ResourceLoader.exists("res://stasiun/latar pake bayangan.png"):
		tex_station_bg = load("res://stasiun/latar pake bayangan.png")
	elif ResourceLoader.exists("res://Environment/stasiun/latar stasiun.png"):
		tex_station_bg = load("res://Environment/stasiun/latar stasiun.png")

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
			item_buttons[k].disabled = false
			item_buttons[k].modulate = Color.WHITE
		if item_found_badges.has(k) and is_instance_valid(item_found_badges[k]):
			item_found_badges[k].visible = false

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
			lbl.text = "✔ " + item["name"] + " [BERHASIL DIAMANKAN]"
			lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		else:
			lbl.text = "○ " + item["name"] + " — " + item["hint"]
			lbl.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98))
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
		item_buttons[item_key].disabled = true
	
	if item_found_badges.has(item_key) and is_instance_valid(item_found_badges[item_key]):
		var badge = item_found_badges[item_key]
		badge.visible = true
		badge.modulate = Color(1, 1, 1, 0)
		var tw = create_tween()
		tw.tween_property(badge, "modulate:a", 1.0, 0.25)

	_refresh_checklist()

	status_banner.text = "Ditemukan: " + items_to_find[item_key]["name"] + "!"
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))

	var all_found = true
	for k in items_to_find.keys():
		if not items_to_find[k]["found"]:
			all_found = false
			break

	if all_found:
		_complete_victory()

func _complete_victory() -> void:
	is_active = false
	status_banner.text = "SEMUA BUKTI DITEMUKAN! Amplop berisi rol foto berhasil diamankan!"
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	var inv_mgr = null
	if is_inside_tree():
		inv_mgr = get_node_or_null("/root/InvestigationManager")
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
	status_banner.text = "WAKTU HABIS! Kereta melintas membuyarkan pencarian. Mengulang investigasi..."
	status_banner.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	if is_inside_tree() and get_tree():
		await get_tree().create_timer(2.0).timeout
	time_left = 60.0
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false
		if item_buttons.has(k) and is_instance_valid(item_buttons[k]):
			item_buttons[k].visible = true
			item_buttons[k].disabled = false
			item_buttons[k].modulate = Color.WHITE
		if item_found_badges.has(k) and is_instance_valid(item_found_badges[k]):
			item_found_badges[k].visible = false
	_refresh_checklist()
	is_active = true

func _finish_and_close(success: bool = true) -> void:
	is_active = false
	visible = false
	minigame_completed.emit(success)

	if success and is_inside_tree() and get_tree() and get_tree().root:
		var dlg = get_tree().root.find_child("DialogBox", true, false)
		if is_instance_valid(dlg) and dlg.has_method("start_monologue"):
			var lines: Array[String] = [
				"Di peron stasiun ini... aku menemukan tiket kereta dan amplop berisi rol film foto milik korban.",
				"Aku harus segera kembali ke Kantor Polisi (atau Kamar Gelap) untuk mencuci rol foto ini!",
				"Firasatku mengatakan... foto-foto ini akan mengungkap identitas korban yang sebenarnya."
			]
			dlg.start_monologue(lines, "Detektif Benedict", "[ Bukti Foto Didapatkan ]", "res://karakter/MC_Bingung.png")

func _build_scene_ui() -> void:
	if is_instance_valid(root_control):
		return

	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	var bg_overlay = ColorRect.new()
	bg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_overlay.color = Color(0.03, 0.04, 0.06, 0.98)
	root_control.add_child(bg_overlay)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	root_control.add_child(margin)

	var main_box = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 6)
	margin.add_child(main_box)

	# 1. Header & Timer
	var header = HBoxContainer.new()
	main_box.add_child(header)

	var title = Label.new()
	title.text = "PERON STASIUN TIMUR — PENCARIAN BARANG BUKTI KORBAN"
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	timer_label = Label.new()
	timer_label.text = "Jadwal Kereta: 60.0s"
	timer_label.add_theme_font_size_override("font_size", 15)
	header.add_child(timer_label)

	close_btn = Button.new()
	close_btn.text = "Tutup [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_btn.pressed.connect(func(): _finish_and_close(false))
	header.add_child(close_btn)

	# 2. Status Banner
	status_banner = Label.new()
	status_banner.text = "Temukan 3 barang bukti korban di peron stasiun!"
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 13)
	main_box.add_child(status_banner)

	# 3. Panggung Utama 16:9 Proporsional Penuh (Sesuai Gambar Kedua)
	aspect_container = AspectRatioContainer.new()
	aspect_container.ratio = 16.0 / 9.0
	aspect_container.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	aspect_container.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	aspect_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aspect_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.add_child(aspect_container)

	station_canvas = Control.new()
	station_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	aspect_container.add_child(station_canvas)

	station_bg = TextureRect.new()
	if is_instance_valid(tex_station_bg):
		station_bg.texture = tex_station_bg
	station_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	station_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	station_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	station_canvas.add_child(station_bg)

	# 4. Tiga Hotspot Interaktif Sesuai Posisi Gambar Asli Stasiun
	for item_key in ITEM_ANCHORS.keys():
		var data = ITEM_ANCHORS[item_key]
		var btn = Button.new()
		btn.name = "Target_" + item_key
		btn.anchor_left = data["left"]
		btn.anchor_top = data["top"]
		btn.anchor_right = data["right"]
		btn.anchor_bottom = data["bottom"]
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.tooltip_text = "Klik untuk mengamankan " + data["name"]

		# Status normal: 100% transparan / StyleBoxEmpty (tidak ada kotak bayangan/garis terlihat)
		var style_normal = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("focus", style_normal)
		btn.add_theme_stylebox_override("disabled", style_normal)

		# Status hover: highlight garis emas halus saat kursor mengarah tepat ke atas objek
		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = Color(1.0, 0.95, 0.4, 0.12)
		style_hover.border_color = Color(1.0, 0.9, 0.4, 0.85)
		style_hover.set_border_width_all(2)
		style_hover.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_hover)

		var k_copy = item_key
		btn.pressed.connect(func(): _on_item_clicked(k_copy))
		station_canvas.add_child(btn)
		item_buttons[item_key] = btn

		# Badge "✔ DIAMANKAN" saat berhasil ditemukan
		var badge = Label.new()
		badge.text = "✔ DIAMANKAN"
		badge.anchor_left = data["left"]
		badge.anchor_top = data["top"]
		badge.anchor_right = data["right"]
		badge.anchor_bottom = data["top"]
		badge.offset_top = -24
		badge.offset_bottom = -2
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		badge.add_theme_font_size_override("font_size", 12)
		
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(0.05, 0.12, 0.08, 0.85)
		b_style.border_color = Color(0.3, 1.0, 0.5, 0.8)
		b_style.set_border_width_all(1)
		b_style.set_corner_radius_all(4)
		badge.add_theme_stylebox_override("panel", b_style)
		badge.visible = false
		station_canvas.add_child(badge)
		item_found_badges[item_key] = badge

	# 5. Panel Checklist di Bagian Bawah
	var bottom_panel = PanelContainer.new()
	var bot_style = StyleBoxFlat.new()
	bot_style.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	bot_style.border_color = Color(0.35, 0.45, 0.6, 0.8)
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
