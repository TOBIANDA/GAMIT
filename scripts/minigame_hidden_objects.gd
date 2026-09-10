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
var aspect_container: AspectRatioContainer
var stage_root: Control
var timer_label: Label
var item_checklist: VBoxContainer
var status_banner: Label
var close_btn: Button
var click_player: AudioStreamPlayer

# Aset Stasiun
var tex_station_bg: Texture2D
var tex_kursi: Texture2D
var tex_envelope: Texture2D
var tex_luggage: Texture2D
var tex_bag: Texture2D
var tex_big_suitcase: Texture2D
var tex_hanging_lamp: Texture2D
var tex_trash_bin: Texture2D
var tex_umbrella: Texture2D
var tex_sign: Texture2D
var tex_banana: Texture2D
var tex_bag_green: Texture2D
var tex_bag_purple: Texture2D

var item_buttons: Dictionary = {}
var item_nodes: Dictionary = {}

const STAGE_W := 1280.0
const STAGE_H := 720.0

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
	if is_instance_valid(click_player) and click_player.is_inside_tree() and click_player.stream:
		click_player.play()

func _load_assets() -> void:
	if ResourceLoader.exists("res://stasiun/latar pake bayangan.png"):
		tex_station_bg = load("res://stasiun/latar pake bayangan.png")
	elif ResourceLoader.exists("res://stasiun/latar stasiun.png"):
		tex_station_bg = load("res://stasiun/latar stasiun.png")

	if ResourceLoader.exists("res://stasiun/kursi.png"):
		tex_kursi = load("res://stasiun/kursi.png")

	if ResourceLoader.exists("res://stasiun/surat diatas kursi.png"):
		tex_envelope = load("res://stasiun/surat diatas kursi.png")

	if ResourceLoader.exists("res://stasiun/tas diatas kursi.png"):
		tex_bag = load("res://stasiun/tas diatas kursi.png")

	if ResourceLoader.exists("res://stasiun/koperbiru.png"):
		tex_luggage = load("res://stasiun/koperbiru.png")

	if ResourceLoader.exists("res://stasiun/koperbesar.png"):
		tex_big_suitcase = load("res://stasiun/koperbesar.png")

	if ResourceLoader.exists("res://stasiun/lampu gantung.png"):
		tex_hanging_lamp = load("res://stasiun/lampu gantung.png")

	if ResourceLoader.exists("res://stasiun/tongsampah.png"):
		tex_trash_bin = load("res://stasiun/tongsampah.png")

	if ResourceLoader.exists("res://stasiun/payung depan.png"):
		tex_umbrella = load("res://stasiun/payung depan.png")

	if ResourceLoader.exists("res://stasiun/rambu.png"):
		tex_sign = load("res://stasiun/rambu.png")

	if ResourceLoader.exists("res://stasiun/pisang.png"):
		tex_banana = load("res://stasiun/pisang.png")

	if ResourceLoader.exists("res://stasiun/tas ijo.png"):
		tex_bag_green = load("res://stasiun/tas ijo.png")

	if ResourceLoader.exists("res://stasiun/tas ungu.png"):
		tex_bag_purple = load("res://stasiun/tas ungu.png")

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
		if item_nodes.has(k) and is_instance_valid(item_nodes[k]):
			item_nodes[k].visible = true
			item_nodes[k].modulate = Color.WHITE

	_refresh_checklist()
	if is_instance_valid(status_banner):
		status_banner.text = "Temukan 3 barang bukti korban di peron stasiun sebelum jadwal kereta berangkat!"
		status_banner.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))

	_on_aspect_resized()

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

	# Efek pulsing lembut pada item target yang belum ditemukan
	var pulse = 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.007)
	for k in items_to_find.keys():
		if not items_to_find[k]["found"]:
			if item_buttons.has(k) and is_instance_valid(item_buttons[k]):
				item_buttons[k].modulate = Color(pulse, pulse, 1.0, 1.0)
			if item_nodes.has(k) and is_instance_valid(item_nodes[k]):
				item_nodes[k].modulate = Color(pulse, pulse, 1.0, 1.0)

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
		item_buttons[item_key].visible = false
	if item_nodes.has(item_key) and is_instance_valid(item_nodes[item_key]):
		var tw = create_tween()
		tw.tween_property(item_nodes[item_key], "modulate", Color(0.2, 1.0, 0.4, 0.0), 0.35)
		tw.tween_callback(func():
			if is_instance_valid(item_nodes[item_key]):
				item_nodes[item_key].visible = false
		)

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
		if item_nodes.has(k) and is_instance_valid(item_nodes[k]):
			item_nodes[k].visible = true
			item_nodes[k].modulate = Color.WHITE
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

	status_banner = Label.new()
	status_banner.text = "Temukan 3 barang bukti korban di peron stasiun!"
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 13)
	main_box.add_child(status_banner)

	# --- PANGGUNG 16:9 DENGAN SELURUH ASET STASIUN LENGKAP ---
	aspect_container = AspectRatioContainer.new()
	aspect_container.ratio = 16.0 / 9.0
	aspect_container.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	aspect_container.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	aspect_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aspect_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	aspect_container.resized.connect(_on_aspect_resized)
	main_box.add_child(aspect_container)

	stage_root = Control.new()
	stage_root.custom_minimum_size = Vector2(STAGE_W, STAGE_H)
	stage_root.size = Vector2(STAGE_W, STAGE_H)
	aspect_container.add_child(stage_root)

	# 1. Latar Belakang Stasiun (Latar dengan bayangan peron)
	var bg_station = TextureRect.new()
	if is_instance_valid(tex_station_bg):
		bg_station.texture = tex_station_bg
	bg_station.size = Vector2(STAGE_W, STAGE_H)
	bg_station.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_station.stretch_mode = TextureRect.STRETCH_SCALE
	stage_root.add_child(bg_station)

	# 2. Lampu Gantung Atap Stasiun
	if is_instance_valid(tex_hanging_lamp):
		var lamp = TextureRect.new()
		lamp.texture = tex_hanging_lamp
		lamp.position = Vector2(450, 20)
		lamp.size = Vector2(130, 200)
		lamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(lamp)

	# 3. Rambu Peron Kereta
	if is_instance_valid(tex_sign):
		var sign_rect = TextureRect.new()
		sign_rect.texture = tex_sign
		sign_rect.position = Vector2(240, 250)
		sign_rect.size = Vector2(110, 180)
		sign_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sign_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(sign_rect)

	# 4. Payung di Dekat Loket
	if is_instance_valid(tex_umbrella):
		var umbrella_rect = TextureRect.new()
		umbrella_rect.texture = tex_umbrella
		umbrella_rect.position = Vector2(1050, 330)
		umbrella_rect.size = Vector2(130, 150)
		umbrella_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		umbrella_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(umbrella_rect)

	# 5. Tong Sampah Stasiun
	if is_instance_valid(tex_trash_bin):
		var trash_rect = TextureRect.new()
		trash_rect.texture = tex_trash_bin
		trash_rect.position = Vector2(1110, 380)
		trash_rect.size = Vector2(110, 150)
		trash_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		trash_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(trash_rect)

	# 6. Koper Besar Cokelat di Peron
	if is_instance_valid(tex_big_suitcase):
		var big_lug = TextureRect.new()
		big_lug.texture = tex_big_suitcase
		big_lug.position = Vector2(980, 420)
		big_lug.size = Vector2(180, 180)
		big_lug.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		big_lug.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(big_lug)

	# 7. Tas Penumpang Hijau & Ungu
	if is_instance_valid(tex_bag_green):
		var bag_g = TextureRect.new()
		bag_g.texture = tex_bag_green
		bag_g.position = Vector2(780, 490)
		bag_g.size = Vector2(110, 110)
		bag_g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bag_g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(bag_g)

	# 8. Kulit Pisang di Lantai Peron
	if is_instance_valid(tex_banana):
		var banana_rect = TextureRect.new()
		banana_rect.texture = tex_banana
		banana_rect.position = Vector2(480, 530)
		banana_rect.size = Vector2(60, 60)
		banana_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		banana_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(banana_rect)

	# 9. BANGKU TUNGGU PERON (KURSI STASIUN)
	var bench_pos = Vector2(650, 310)
	var bench_size = Vector2(380, 380)
	if is_instance_valid(tex_kursi):
		var bench_rect = TextureRect.new()
		bench_rect.texture = tex_kursi
		bench_rect.position = bench_pos
		bench_rect.size = bench_size
		bench_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bench_rect.stretch_mode = TextureRect.STRETCH_SCALE
		stage_root.add_child(bench_rect)

	# --- 3 TARGET UTAMA PENCARIAN DENGAN HIGHLIGHT INTERAKTIF ---

	# TARGET 1: Amplop Foto Korban di Atas Bangku
	if is_instance_valid(tex_envelope):
		var env_tex_rect = TextureRect.new()
		env_tex_rect.texture = tex_envelope
		env_tex_rect.position = bench_pos
		env_tex_rect.size = bench_size
		env_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		env_tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		stage_root.add_child(env_tex_rect)
		item_nodes["envelope"] = env_tex_rect

	var btn_env = _create_interactive_button("envelope", Vector2(785, 485), Vector2(115, 38), "Amplop Foto Korban")
	stage_root.add_child(btn_env)
	item_buttons["envelope"] = btn_env

	# TARGET 2: Tas Pribadi Korban di Atas Sandaran Bangku
	if is_instance_valid(tex_bag):
		var bag_tex_rect = TextureRect.new()
		bag_tex_rect.texture = tex_bag
		bag_tex_rect.position = bench_pos
		bag_tex_rect.size = bench_size
		bag_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bag_tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
		stage_root.add_child(bag_tex_rect)
		item_nodes["bag"] = bag_tex_rect

	var btn_bag = _create_interactive_button("bag", Vector2(745, 465), Vector2(185, 60), "Tas Pribadi Korban")
	stage_root.add_child(btn_bag)
	item_buttons["bag"] = btn_bag

	# TARGET 3: Koper Biru & Tiket di Lantai Dekat Bangku
	if is_instance_valid(tex_luggage):
		var lug_tex_rect = TextureRect.new()
		lug_tex_rect.texture = tex_luggage
		lug_tex_rect.position = Vector2(540, 430)
		lug_tex_rect.size = Vector2(170, 170)
		lug_tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lug_tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stage_root.add_child(lug_tex_rect)
		item_nodes["luggage"] = lug_tex_rect

	var btn_lug = _create_interactive_button("luggage", Vector2(595, 495), Vector2(75, 48), "Koper Biru & Tiket Kereta")
	stage_root.add_child(btn_lug)
	item_buttons["luggage"] = btn_lug

	# Panel Checklist Bawah
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

func _create_interactive_button(item_key: String, pos: Vector2, b_size: Vector2, tooltip: String) -> Button:
	var btn = Button.new()
	btn.name = "ClickTarget_" + item_key
	btn.position = pos
	btn.size = b_size
	btn.custom_minimum_size = b_size
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.tooltip_text = tooltip

	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(1.0, 0.9, 0.2, 0.08)
	style_normal.border_color = Color(1.0, 0.85, 0.2, 0.45)
	style_normal.set_border_width_all(1)
	style_normal.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", style_normal)

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(1.0, 1.0, 0.4, 0.25)
	style_hover.border_color = Color(1.0, 1.0, 0.5, 0.95)
	style_hover.set_border_width_all(2)
	style_hover.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_hover)

	btn.pressed.connect(func(): _on_item_clicked(item_key))
	return btn

func _on_aspect_resized() -> void:
	if not is_instance_valid(aspect_container) or not is_instance_valid(stage_root):
		return
	var c_sz = aspect_container.size
	if c_sz.x <= 0 or c_sz.y <= 0:
		return
	var sx = c_sz.x / STAGE_W
	var sy = c_sz.y / STAGE_H
	var s = minf(sx, sy)
	stage_root.scale = Vector2(s, s)
	stage_root.position = (c_sz - Vector2(STAGE_W * s, STAGE_H * s)) * 0.5
