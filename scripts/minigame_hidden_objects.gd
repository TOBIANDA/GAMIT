extends CanvasLayer

signal minigame_completed(success: bool)

var is_active: bool = false
var time_left: float = 60.0

var items_to_find: Dictionary = {
	"surat": {
		"found": false,
		"name": "Surat Bukti Korban",
		"hint": "Di atas bangku tunggu stasiun (kertas putih)",
		"tex_path": "res://Environment/interactable assets/surat.png"
	},
	"jam": {
		"found": false,
		"name": "Jam Saku Korban",
		"hint": "Di lantai dekat tangga peron stasiun",
		"tex_path": "res://stasiun/jam_clue.png"
	},
	"tiket": {
		"found": false,
		"name": "Tiket Kereta Api",
		"hint": "Di lantai bawah papan tulis peron stasiun",
		"tex_path": "res://stasiun/tiket_clue.png"
	}
}

var root_control: Control
var aspect_container: AspectRatioContainer
var station_canvas: Control
var station_bg: TextureRect
var timer_label: Label
var status_banner: Label
var close_btn: Button
var click_player: AudioStreamPlayer

# Aset Gambar Stasiun & Clue
var tex_station_bg: Texture2D
var tex_clues: Dictionary = {}

# Interaksi dan HUD Siluet
var item_buttons: Dictionary = {}
var item_found_badges: Dictionary = {}
var item_scene_sprites: Dictionary = {}
var silhouette_cards: Dictionary = {}

# Koordinat persentase (anchor) presisi 1:1 sesuai layout stasiun (16:9)
const ITEM_ANCHORS := {
	"surat": {
		"left": 0.7680,
		"top": 0.7400,
		"right": 0.8350,
		"bottom": 0.8200,
		"name": "Surat Bukti Korban"
	},
	"jam": {
		"left": 0.5850,
		"top": 0.6100,
		"right": 0.6300,
		"bottom": 0.6700,
		"name": "Jam Saku Korban"
	},
	"tiket": {
		"left": 0.1450,
		"top": 0.8400,
		"right": 0.2200,
		"bottom": 0.9100,
		"name": "Tiket Kereta Api"
	}
}

const SILHOUETTE_LOW_OPACITY: Color = Color(0.28, 0.30, 0.36, 0.35)
const SILHOUETTE_FULL_OPACITY: Color = Color(1.0, 1.0, 1.0, 1.0)

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
	# Prioritaskan latar stasiun utuh
	if ResourceLoader.exists("res://stasiun/latar stasiun.png"):
		tex_station_bg = load("res://stasiun/latar stasiun.png")
	elif ResourceLoader.exists("res://stasiun/latar pake bayangan.png"):
		tex_station_bg = load("res://stasiun/latar pake bayangan.png")
	elif ResourceLoader.exists("res://Environment/stasiun/latar stasiun.png"):
		tex_station_bg = load("res://Environment/stasiun/latar stasiun.png")

	# Clue textures
	if ResourceLoader.exists("res://Environment/interactable assets/surat.png"):
		tex_clues["surat"] = load("res://Environment/interactable assets/surat.png")
	elif ResourceLoader.exists("res://stasiun/surat diatas kursi.png"):
		tex_clues["surat"] = load("res://stasiun/surat diatas kursi.png")

	if ResourceLoader.exists("res://stasiun/jam_clue.png"):
		tex_clues["jam"] = load("res://stasiun/jam_clue.png")
	elif ResourceLoader.exists("res://jamingame.png"):
		tex_clues["jam"] = load("res://jamingame.png")
	elif ResourceLoader.exists("res://jam.png"):
		tex_clues["jam"] = load("res://jam.png")

	if ResourceLoader.exists("res://stasiun/tiket_clue.png"):
		tex_clues["tiket"] = load("res://stasiun/tiket_clue.png")
	elif ResourceLoader.exists("res://tiketkereta.png"):
		tex_clues["tiket"] = load("res://tiketkereta.png")

func start_minigame() -> void:
	if not is_instance_valid(root_control):
		_load_assets()
		_setup_audio()
		_build_scene_ui()
	is_active = true
	visible = true
	time_left = 60.0

	# Sembunyikan tombol HUD pause agar tidak tumpang tindih
	if is_inside_tree() and get_tree() and get_tree().root:
		var pm = get_tree().root.find_child("PauseMenuLayer", true, false)
		if is_instance_valid(pm) and pm.has_method("set_hud_button_visible"):
			pm.set_hud_button_visible(false)

	# Reset items and UI state
	for k in items_to_find.keys():
		items_to_find[k]["found"] = false

		if item_buttons.has(k) and is_instance_valid(item_buttons[k]):
			item_buttons[k].visible = true
			item_buttons[k].disabled = false

		if item_found_badges.has(k) and is_instance_valid(item_found_badges[k]):
			item_found_badges[k].visible = false

		if item_scene_sprites.has(k) and is_instance_valid(item_scene_sprites[k]):
			item_scene_sprites[k].visible = true
			item_scene_sprites[k].modulate = Color(1.0, 1.0, 1.0, 1.0)
			item_scene_sprites[k].scale = Vector2(1.0, 1.0)

		# Reset siluet di sebelah kiri ke opacity rendah
		_reset_silhouette_card(k)

	if is_instance_valid(status_banner):
		status_banner.text = "Perhatikan 3 bentuk siluet di sebelah kiri, lalu temukan barangnya di peron stasiun!"
		status_banner.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))

func _reset_silhouette_card(item_key: String) -> void:
	if not silhouette_cards.has(item_key):
		return
	var card_data = silhouette_cards[item_key]
	var icon: TextureRect = card_data["icon"]
	var status_lbl: Label = card_data["status"]
	var panel: PanelContainer = card_data["panel"]

	if is_instance_valid(icon):
		icon.modulate = SILHOUETTE_LOW_OPACITY
		icon.scale = Vector2(1.0, 1.0)

	if is_instance_valid(status_lbl):
		status_lbl.text = "○ Belum Ditemukan"
		status_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 0.7))

	if is_instance_valid(panel):
		var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
		if style:
			style.border_color = Color(0.25, 0.35, 0.5, 0.45)
			style.bg_color = Color(0.08, 0.11, 0.16, 0.88)

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

func _on_item_clicked(item_key: String) -> void:
	if not is_active or not items_to_find.has(item_key):
		return
	if items_to_find[item_key]["found"]:
		return

	_play_click()
	items_to_find[item_key]["found"] = true

	# Nonaktifkan tombol hotspot
	if item_buttons.has(item_key) and is_instance_valid(item_buttons[item_key]):
		item_buttons[item_key].disabled = true

	# Tampilkan badge centang di panggung stasiun
	if item_found_badges.has(item_key) and is_instance_valid(item_found_badges[item_key]):
		var badge = item_found_badges[item_key]
		badge.visible = true
		badge.modulate = Color(1, 1, 1, 0)
		var tw_b = create_tween()
		tw_b.tween_property(badge, "modulate:a", 1.0, 0.25)

	# Animasi highlight pada sprite di stasiun
	if item_scene_sprites.has(item_key) and is_instance_valid(item_scene_sprites[item_key]):
		var spr = item_scene_sprites[item_key]
		var tw_s = create_tween()
		tw_s.tween_property(spr, "scale", Vector2(1.2, 1.2), 0.15)
		tw_s.tween_property(spr, "scale", Vector2(1.0, 1.0), 0.2)

	# Animasi SILUET DI SEBELAH KIRI (TRANSISI KE OPACITY PENUH 1.0)
	_activate_silhouette_card(item_key)

	status_banner.text = "DITEMUKAN: %s!" % items_to_find[item_key]["name"]
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))

	# Cek apakah ketiga barang bukti sudah ditemukan semua
	var all_found = true
	for k in items_to_find.keys():
		if not items_to_find[k]["found"]:
			all_found = false
			break

	if all_found:
		_complete_victory()

func _activate_silhouette_card(item_key: String) -> void:
	if not silhouette_cards.has(item_key):
		return
	var card_data = silhouette_cards[item_key]
	var icon: TextureRect = card_data["icon"]
	var status_lbl: Label = card_data["status"]
	var panel: PanelContainer = card_data["panel"]

	# 1. Transisi opacity icon dari 0.35 ke 1.0 dengan efek bounce
	if is_instance_valid(icon):
		var tw = create_tween().set_parallel(true)
		tw.tween_property(icon, "modulate", SILHOUETTE_FULL_OPACITY, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(icon, "scale", Vector2(1.25, 1.25), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.chain().tween_property(icon, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# 2. Update status label
	if is_instance_valid(status_lbl):
		status_lbl.text = "✔ DITEMUKAN"
		status_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	# 3. Highlight kartu dengan border hijau zamrud bercahaya
	if is_instance_valid(panel):
		var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
		if style:
			style.border_color = Color(0.3, 1.0, 0.55, 0.95)
			style.bg_color = Color(0.08, 0.15, 0.12, 0.95)

func _complete_victory() -> void:
	is_active = false
	status_banner.text = "SEMUA BARANG BUKTI DITEMUKAN! Surat, jam saku, dan tiket berhasil diamankan!"
	status_banner.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))

	var inv_mgr = null
	if is_inside_tree():
		inv_mgr = get_node_or_null("/root/InvestigationManager")
		if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
			inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("train_ticket")
		inv_mgr.unlock_clue("photo_envelope")
		inv_mgr.unlock_clue("pocket_watch")
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
		if item_found_badges.has(k) and is_instance_valid(item_found_badges[k]):
			item_found_badges[k].visible = false
		if item_scene_sprites.has(k) and is_instance_valid(item_scene_sprites[k]):
			item_scene_sprites[k].visible = true
			item_scene_sprites[k].modulate = Color.WHITE
		_reset_silhouette_card(k)
	is_active = true

func _finish_and_close(success: bool = true) -> void:
	is_active = false
	visible = false
	minigame_completed.emit(success)

	# Kembalikan tombol HUD pause saat minigame selesai/ditutup
	if is_inside_tree() and get_tree() and get_tree().root:
		var pm = get_tree().root.find_child("PauseMenuLayer", true, false)
		if is_instance_valid(pm) and pm.has_method("set_hud_button_visible"):
			pm.set_hud_button_visible(true)

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
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	root_control.add_child(margin)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(main_vbox)

	# 1. Header & Timer
	var header = HBoxContainer.new()
	main_vbox.add_child(header)

	var title = Label.new()
	title.text = "PERON STASIUN TIMUR — PENCARIAN 3 BARANG BUKTI KORBAN"
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
	status_banner.text = "Perhatikan 3 bentuk siluet di sebelah kiri, lalu temukan barangnya di peron stasiun!"
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 13)
	main_vbox.add_child(status_banner)

	# 3. Konten Utama: Sidebar Siluet di Kiri + Panggung Stasiun di Kanan
	var content_hbox = HBoxContainer.new()
	content_hbox.add_theme_constant_override("separation", 16)
	content_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content_hbox)

	# --- SIDEBAR SILUET CLUE (SEBELAH KIRI) ---
	var left_sidebar = PanelContainer.new()
	left_sidebar.custom_minimum_size = Vector2(230, 0)
	left_sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var side_style = StyleBoxFlat.new()
	side_style.bg_color = Color(0.06, 0.08, 0.13, 0.94)
	side_style.border_color = Color(0.35, 0.45, 0.6, 0.7)
	side_style.set_border_width_all(2)
	side_style.set_corner_radius_all(10)
	side_style.content_margin_left = 12.0
	side_style.content_margin_right = 12.0
	side_style.content_margin_top = 12.0
	side_style.content_margin_bottom = 12.0
	left_sidebar.add_theme_stylebox_override("panel", side_style)
	content_hbox.add_child(left_sidebar)

	var side_vbox = VBoxContainer.new()
	side_vbox.add_theme_constant_override("separation", 10)
	side_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_sidebar.add_child(side_vbox)

	var clue_header = Label.new()
	clue_header.text = "🔍 SILUET CLUE"
	clue_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clue_header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	clue_header.add_theme_font_size_override("font_size", 15)
	side_vbox.add_child(clue_header)

	var clue_sub = Label.new()
	clue_sub.text = "Bentuk 3 Barang Bukti"
	clue_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clue_sub.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	clue_sub.add_theme_font_size_override("font_size", 11)
	side_vbox.add_child(clue_sub)

	var h_sep = HSeparator.new()
	side_vbox.add_child(h_sep)

	# Bangun 3 Kartu Siluet (Surat, Jam, Tiket)
	for item_key in ["surat", "jam", "tiket"]:
		var item_data = items_to_find[item_key]
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 140)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.09, 0.12, 0.18, 0.88)
		card_style.border_color = Color(0.25, 0.35, 0.5, 0.45)
		card_style.set_border_width_all(2)
		card_style.set_corner_radius_all(8)
		card_style.content_margin_left = 8.0
		card_style.content_margin_right = 8.0
		card_style.content_margin_top = 8.0
		card_style.content_margin_bottom = 8.0
		card.add_theme_stylebox_override("panel", card_style)
		side_vbox.add_child(card)

		var card_vbox = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 6)
		card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(card_vbox)

		# Kontainer Ikon Siluet
		var icon_center = CenterContainer.new()
		icon_center.custom_minimum_size = Vector2(0, 68)
		card_vbox.add_child(icon_center)

		var icon_rect = TextureRect.new()
		if tex_clues.has(item_key) and is_instance_valid(tex_clues[item_key]):
			icon_rect.texture = tex_clues[item_key]
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.pivot_offset = Vector2(32, 32)
		# Awalnya ber-opacity rendah (siluet samar)
		icon_rect.modulate = SILHOUETTE_LOW_OPACITY
		icon_center.add_child(icon_rect)

		var name_lbl = Label.new()
		name_lbl.text = item_data["name"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98))
		name_lbl.add_theme_font_size_override("font_size", 12)
		card_vbox.add_child(name_lbl)

		var status_lbl = Label.new()
		status_lbl.text = "○ Belum Ditemukan"
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 0.7))
		status_lbl.add_theme_font_size_override("font_size", 11)
		card_vbox.add_child(status_lbl)

		silhouette_cards[item_key] = {
			"panel": card,
			"icon": icon_rect,
			"status": status_lbl,
			"name": name_lbl
		}

	# --- PANGGUNG STASIUN (SEBELAH KANAN) ---
	var right_stage_vbox = VBoxContainer.new()
	right_stage_vbox.add_theme_constant_override("separation", 6)
	right_stage_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_stage_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hbox.add_child(right_stage_vbox)

	aspect_container = AspectRatioContainer.new()
	aspect_container.ratio = 16.0 / 9.0
	aspect_container.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	aspect_container.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	aspect_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aspect_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_stage_vbox.add_child(aspect_container)

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

	# Item In-Scene Sprites (Jam & Tiket pada lantai peron stasiun sesuai layout)
	# 1. Jam Saku di lantai dekat tangga
	var jam_spr = TextureRect.new()
	jam_spr.name = "Scene_Jam"
	if tex_clues.has("jam"):
		jam_spr.texture = tex_clues["jam"]
	jam_spr.anchor_left = ITEM_ANCHORS["jam"]["left"]
	jam_spr.anchor_top = ITEM_ANCHORS["jam"]["top"]
	jam_spr.anchor_right = ITEM_ANCHORS["jam"]["right"]
	jam_spr.anchor_bottom = ITEM_ANCHORS["jam"]["bottom"]
	jam_spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	jam_spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	station_canvas.add_child(jam_spr)
	item_scene_sprites["jam"] = jam_spr

	# 2. Tiket Kereta di lantai bawah papan tulis
	var tiket_spr = TextureRect.new()
	tiket_spr.name = "Scene_Tiket"
	if tex_clues.has("tiket"):
		tiket_spr.texture = tex_clues["tiket"]
	tiket_spr.anchor_left = ITEM_ANCHORS["tiket"]["left"]
	tiket_spr.anchor_top = ITEM_ANCHORS["tiket"]["top"]
	tiket_spr.anchor_right = ITEM_ANCHORS["tiket"]["right"]
	tiket_spr.anchor_bottom = ITEM_ANCHORS["tiket"]["bottom"]
	tiket_spr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tiket_spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	station_canvas.add_child(tiket_spr)
	item_scene_sprites["tiket"] = tiket_spr

	# 3. Tiga Hotspot Interaktif Sesuai Posisi Gambar Asli Stasiun
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

		# Status normal: 100% transparan
		var style_normal = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("focus", style_normal)
		btn.add_theme_stylebox_override("disabled", style_normal)

		# Status hover: highlight garis emas halus saat kursor mengarah tepat ke atas objek
		var style_hover = StyleBoxFlat.new()
		style_hover.bg_color = Color(1.0, 0.95, 0.4, 0.15)
		style_hover.border_color = Color(1.0, 0.9, 0.4, 0.9)
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
		b_style.bg_color = Color(0.05, 0.12, 0.08, 0.88)
		b_style.border_color = Color(0.3, 1.0, 0.5, 0.85)
		b_style.set_border_width_all(1)
		b_style.set_corner_radius_all(4)
		badge.add_theme_stylebox_override("panel", b_style)
		badge.visible = false
		station_canvas.add_child(badge)
		item_found_badges[item_key] = badge

	# Footer Tips Bar
	var footer_panel = PanelContainer.new()
	var foot_style = StyleBoxFlat.new()
	foot_style.bg_color = Color(0.06, 0.08, 0.12, 0.9)
	foot_style.border_color = Color(0.25, 0.35, 0.45, 0.6)
	foot_style.set_border_width_all(1)
	foot_style.set_corner_radius_all(6)
	foot_style.content_margin_left = 16.0
	foot_style.content_margin_right = 16.0
	foot_style.content_margin_top = 6.0
	foot_style.content_margin_bottom = 6.0
	footer_panel.add_theme_stylebox_override("panel", foot_style)
	right_stage_vbox.add_child(footer_panel)

	var foot_lbl = Label.new()
	foot_lbl.text = "💡 Petunjuk: Cocokkan 3 bentuk siluet di sebelah kiri dengan barang bukti yang tercecer di lantai dan bangku peron stasiun."
	foot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot_lbl.add_theme_color_override("font_color", Color(0.75, 0.8, 0.9))
	foot_lbl.add_theme_font_size_override("font_size", 12)
	footer_panel.add_child(foot_lbl)
