extends Node2D
class_name HospitalInterior

# ===========================================================================
# INTERIOR LORONG RUMAH SAKIT & RUANG JENAZAH (HOSPITAL INTERIOR)
# Menggunakan peta resolusi tinggi layout rumah sakit.png dan peti hostpital.svg
# ===========================================================================

signal hospital_completed
signal exit_requested

const ROOM_ORIGIN := Vector2(7000.0, 400.0)
const ROOM_SIZE   := Vector2(2016.0, 1134.0)

const ENTRANCE_POS  := Vector2(7000.0 + 100.0, 400.0 + 520.0)
const EXIT_DOOR_POS := Vector2(7000.0 + 35.0, 400.0 + 520.0)
const COFFIN_POS    := Vector2(7000.0 + 1850.0, 400.0 + 520.0)

# 20 Blok Tembok Presisi hasil dekomposisi area biru layout rumah sakit.png (skala 0.35)
const WALL_RECTS: Array[Rect2] = [
	Rect2(0.0, 0.0, 2016.0, 70.0),
	Rect2(0.0, 70.0, 70.0, 371.0),
	Rect2(343.0, 70.0, 182.0, 175.0),
	Rect2(1239.0, 70.0, 147.0, 161.0),
	Rect2(1645.0, 70.0, 182.0, 161.0),
	Rect2(1946.0, 70.0, 70.0, 385.0),
	Rect2(924.0, 231.0, 182.0, 182.0),
	Rect2(70.0, 259.0, 161.0, 189.0),
	Rect2(497.0, 392.0, 196.0, 175.0),
	Rect2(1477.0, 413.0, 168.0, 175.0),
	Rect2(49.0, 441.0, 21.0, 7.0),
	Rect2(1071.0, 567.0, 189.0, 147.0),
	Rect2(0.0, 595.0, 70.0, 539.0),
	Rect2(1946.0, 602.0, 70.0, 532.0),
	Rect2(784.0, 714.0, 175.0, 154.0),
	Rect2(350.0, 882.0, 252.0, 252.0),
	Rect2(1267.0, 882.0, 231.0, 252.0),
	Rect2(70.0, 1064.0, 280.0, 70.0),
	Rect2(602.0, 1064.0, 665.0, 70.0),
	Rect2(1498.0, 1064.0, 448.0, 70.0)
]

var bg_sprite: Sprite2D
var walls_body: StaticBody2D
var coffin_sprite: Sprite2D
var coffin_glow: PointLight2D
var coffin_collision: StaticBody2D

var prompt_label: Label
var is_player_near_coffin: bool = false
var is_player_near_exit: bool = false
var has_revealed: bool = false
var is_glitching: bool = false

# Visual FX & Audio
var glitch_layer: CanvasLayer
var glitch_overlay: Control
var glitch_status_label: Label
var fade_rect: ColorRect

var hospital_audio: AudioStreamPlayer
var shock_audio: AudioStreamPlayer
var breathing_audio: AudioStreamPlayer

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_setup_background_and_walls()
	_setup_coffin()
	_setup_prompts()
	_setup_glitch_fx()
	_setup_audio()

func _setup_background_and_walls() -> void:
	# 1. Peta Lantai & Dinding Layout Rs
	bg_sprite = Sprite2D.new()
	bg_sprite.name = "LayoutBackground"
	var tex = load("res://layout rumah sakit.png")
	if not tex:
		tex = load("res://Environment/RS/layout rumah sakit.png")
	bg_sprite.texture = tex
	bg_sprite.position = ROOM_ORIGIN
	bg_sprite.scale = Vector2(0.35, 0.35)
	bg_sprite.centered = false
	bg_sprite.z_index = -2
	add_child(bg_sprite)

	# 2. Dinding Kolisi
	walls_body = StaticBody2D.new()
	walls_body.name = "HospitalWalls"
	walls_body.position = ROOM_ORIGIN
	walls_body.collision_layer = 1
	walls_body.collision_mask = 0
	add_child(walls_body)

	for r in WALL_RECTS:
		var col_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = r.size
		col_shape.shape = rect_shape
		col_shape.position = r.position + r.size * 0.5
		walls_body.add_child(col_shape)

func _setup_coffin() -> void:
	# Ranjang / Peti Kematian di Ujung Lorong (hostpital.svg)
	coffin_sprite = Sprite2D.new()
	coffin_sprite.name = "MorgueCoffin"
	var svg_tex = load("res://Environment/RS/hostpital.svg")
	if not svg_tex:
		svg_tex = load("res://hostpital.svg")
	coffin_sprite.texture = svg_tex
	coffin_sprite.position = COFFIN_POS
	# Rotasi 90 derajat horizontal agar seperti ranjang membujur
	coffin_sprite.rotation_degrees = -90.0
	coffin_sprite.scale = Vector2(0.14, 0.14)
	coffin_sprite.z_index = 0
	add_child(coffin_sprite)

	# Collision box peti agar tidak ditembus pemain
	coffin_collision = StaticBody2D.new()
	coffin_collision.name = "CoffinCollision"
	coffin_collision.position = COFFIN_POS
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(140.0, 75.0)
	col.shape = box
	coffin_collision.add_child(col)
	add_child(coffin_collision)

	# Lampu Klinis Dingin di atas Peti
	coffin_glow = PointLight2D.new()
	coffin_glow.position = COFFIN_POS
	coffin_glow.color = Color(0.65, 0.85, 1.0, 0.9)
	coffin_glow.energy = 1.3
	coffin_glow.texture_scale = 1.6
	if ResourceLoader.exists("res://Environment/RS/FloorTile/FloorTileDiffuse.png"):
		coffin_glow.texture = load("res://Environment/RS/FloorTile/FloorTileDiffuse.png")
	add_child(coffin_glow)

func _setup_prompts() -> void:
	prompt_label = Label.new()
	prompt_label.name = "HospitalPrompt"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 15)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	prompt_label.z_index = 20
	prompt_label.visible = false
	add_child(prompt_label)

func _setup_audio() -> void:
	hospital_audio = AudioStreamPlayer.new()
	hospital_audio.name = "HospitalAmbientAudio"
	if ResourceLoader.exists("res://sound/HOSPITAL.mp3"):
		hospital_audio.stream = load("res://sound/HOSPITAL.mp3")
		hospital_audio.volume_db = -4.0
	add_child(hospital_audio)

	shock_audio = AudioStreamPlayer.new()
	shock_audio.name = "HospitalShockAudio"
	if ResourceLoader.exists("res://sound/FLASHBACK.mp3"):
		shock_audio.stream = load("res://sound/FLASHBACK.mp3")
		shock_audio.volume_db = 0.0
	elif ResourceLoader.exists("res://sound/Suspense.mp3"):
		shock_audio.stream = load("res://sound/Suspense.mp3")
		shock_audio.volume_db = 0.0
	add_child(shock_audio)

	breathing_audio = AudioStreamPlayer.new()
	breathing_audio.name = "HospitalBreathingAudio"
	if ResourceLoader.exists("res://sound/Heavy Breathing.mp3"):
		breathing_audio.stream = load("res://sound/Heavy Breathing.mp3")
		breathing_audio.volume_db = -2.0
	add_child(breathing_audio)

func _setup_glitch_fx() -> void:
	glitch_layer = CanvasLayer.new()
	glitch_layer.layer = 25
	add_child(glitch_layer)

	glitch_overlay = Control.new()
	glitch_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glitch_overlay.visible = false
	glitch_layer.add_child(glitch_overlay)

	glitch_status_label = Label.new()
	glitch_status_label.set_anchors_preset(Control.PRESET_CENTER)
	glitch_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glitch_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glitch_status_label.add_theme_font_size_override("font_size", 22)
	glitch_status_label.add_theme_color_override("font_color", Color.WHITE)
	glitch_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glitch_overlay.add_child(glitch_status_label)

	fade_rect = ColorRect.new()
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glitch_layer.add_child(fade_rect)

func start_hospital() -> void:
	visible = true
	has_revealed = false
	is_glitching = false
	fade_rect.color = Color(0, 0, 0, 0)
	glitch_overlay.visible = false
	if is_instance_valid(hospital_audio) and not hospital_audio.playing:
		hospital_audio.play()

func stop_hospital() -> void:
	visible = false
	if is_instance_valid(hospital_audio) and hospital_audio.playing:
		hospital_audio.stop()
	if is_instance_valid(shock_audio) and shock_audio.playing:
		shock_audio.stop()
	if is_instance_valid(breathing_audio) and breathing_audio.playing:
		breathing_audio.stop()

func _process(_delta: float) -> void:
	if not visible or is_glitching:
		return

	# Kedipan lampu peti mati
	if is_instance_valid(coffin_glow):
		var flicker = 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.003)
		coffin_glow.energy = 1.1 + flicker * 0.4

	# Cek jarak pemain terhadap Peti Jenazah dan Pintu Keluar
	var player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		return

	var d_coffin = player.global_position.distance_to(COFFIN_POS)
	var d_exit   = player.global_position.distance_to(EXIT_DOOR_POS)

	if d_coffin <= 110.0 and not has_revealed:
		is_player_near_coffin = true
		is_player_near_exit = false
		prompt_label.visible = true
		prompt_label.text = "[ F / E / Spasi ] PERIKSA PETI JENAZAH"
		prompt_label.position = COFFIN_POS + Vector2(-150.0, -80.0)
	elif d_exit <= 80.0 and not has_revealed:
		is_player_near_exit = true
		is_player_near_coffin = false
		prompt_label.visible = true
		prompt_label.text = "[ F / E / Spasi ] KELUAR KE KOTA"
		prompt_label.position = EXIT_DOOR_POS + Vector2(20.0, -50.0)
	else:
		is_player_near_coffin = false
		is_player_near_exit = false
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or has_revealed or is_glitching:
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode in [KEY_E, KEY_F, KEY_SPACE, KEY_ENTER]:
			if is_player_near_coffin:
				get_viewport().set_input_as_handled()
				_trigger_corpse_revelation()
			elif is_player_near_exit:
				get_viewport().set_input_as_handled()
				exit_requested.emit()

func _trigger_corpse_revelation() -> void:
	if has_revealed:
		return
	has_revealed = true
	prompt_label.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.can_move = false

	# Play Shock & Breathing Audio
	if is_instance_valid(shock_audio) and shock_audio.stream:
		shock_audio.play()
	if is_instance_valid(breathing_audio) and breathing_audio.stream:
		breathing_audio.play()

	# Efek pulsa cahaya intens pada peti
	if is_instance_valid(coffin_glow):
		var tw_glow = create_tween()
		tw_glow.tween_property(coffin_glow, "energy", 3.5, 0.4)
		tw_glow.tween_property(coffin_glow, "energy", 1.6, 0.6)

	# Buka Monolog Penyadaran Benedict
	var monologue_lines: Array[String]= [
		"Peti jenazah bernomor 1604... Hawa dingin menusuk dari dalam kain penutup...",
		"T-tidak... TIDAK MUNGKIN!!",
		"Wajah mayat yang terbujur kaku di dalam peti ini... jas detektif ini... luka di pelipis ini...",
		"MAYAT YANG BERADA DI RUANG JENAZAH INI... ADALAH DIRIKU SENDIRI?_",
		"Jam dinding kota yang mati di 16:04... tatapan ngeri orang-orang di jalan... rol foto di stasiun...",
		"Aku bukan sedang menyelidiki kasus pembunuhan orang lain... AKU TELAH MATI SEJAK AWAL!!",
		"Udara di sekitarku bergetar hebat... Realitas dan kesadaranku mulai hancur lebur..."
	]

	var dlg = null
	var main_node = get_parent()
	if is_instance_valid(main_node):
		dlg = main_node.get_node_or_null("DialogBox")

	if is_instance_valid(dlg) and dlg.has_method("start_monologue"):
		dlg.start_monologue(monologue_lines, "Detektif Benedict", "[ KEBENARAN MENGERIKAN ]", "res://karakter/MC_Kaget.png")
		dlg.monologue_finished.connect(func():
			_trigger_glitch_and_fade()
		, CONNECT_ONE_SHOT)
	else:
		await get_tree().create_timer(3.0).timeout
		_trigger_glitch_and_fade()

func _trigger_glitch_and_fade() -> void:
	is_glitching = true
	glitch_overlay.visible = true

	var corrupted_messages = [
		"ERROR 404: SUBJEK TEL H TEWAS",
		"WAKTU KEMATIAN: 16:04:00",
		"BENEDICT... KAU SUDAH TIADA",
		"MENGHUBUNGKAN KE ALAM DEWA KEMATIAN..."
	]

	var glitch_duration = 2.6
	var tw_glitch = create_tween()
	tw_glitch.tween_method(func(_prog: float):
		if randf() < 0.45:
			glitch_status_label.text = corrupted_messages[randi() % corrupted_messages.size()]
			glitch_status_label.add_theme_color_override("font_color", Color.WHITE if randf() < 0.5 else Color(0.8, 0.3, 0.3))

		for c in glitch_overlay.get_children():
			if c != glitch_status_label:
				c.queue_free()

		var num_slices = randi_range(6, 14)
		var view_sz = glitch_overlay.get_viewport_rect().size
		var palette = [Color.WHITE, Color.BLACK, Color(0.15, 0.15, 0.15), Color(0.85, 0.85, 0.85)]

		for i in range(num_slices):
			var slice = ColorRect.new()
			var sy = randf_range(0.0, view_sz.y)
			var sh = randf_range(4.0, 36.0)
			slice.position = Vector2(0.0, sy)
			slice.size = Vector2(view_sz.x, sh)
			slice.color = palette[randi() % palette.size()]
			slice.color.a = randf_range(0.65, 0.95)
			glitch_overlay.add_child(slice)
	, 0.0, 1.0, glitch_duration)

	# Fade to total black
	tw_glitch.tween_callback(func():
		for c in glitch_overlay.get_children():
			if c != glitch_status_label:
				c.queue_free()
		glitch_overlay.visible = false

		var tw_black = create_tween()
		tw_black.tween_property(fade_rect, "color:a", 1.0, 1.5)
		tw_black.tween_interval(0.8)
		tw_black.tween_callback(func():
			stop_hospital()
			hospital_completed.emit()
		)
	)
