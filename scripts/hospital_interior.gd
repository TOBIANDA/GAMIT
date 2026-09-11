extends Node2D
class_name HospitalInterior

# ===========================================================================
# INTERIOR RUMAH SAKIT & RUANG JENAZAH (HOSPITAL LABYRINTH INTERIOR)
# Menggunakan render prosedural _draw() bentuk dasar, lorong labirin klinis,
# dan efek shader distorsi glitch saat adegan penyadaran diri mayat.
# ===========================================================================

signal hospital_completed
signal exit_requested

const ROOM_ORIGIN := Vector2(7000.0, 400.0)
const ROOM_SIZE   := Vector2(860.0, 580.0)

const ENTRANCE_POS  := Vector2(7000.0 + 65.0, 400.0 + 300.0)
const EXIT_DOOR_POS := Vector2(7000.0 + 25.0, 400.0 + 300.0)
const COFFIN_POS    := Vector2(7000.0 + 744.0, 400.0 + 300.0)

# Dinding Kolisi Labirin Rumah Sakit (Koordinat Lokal terhadap ROOM_ORIGIN)
# Seluruh lorong memiliki lebar 72-80 px (sangat pas untuk ukuran Detektif ~20 px)
const LABYRINTH_WALLS: Array[Rect2] = [
	# 1. Dinding Keliling Luar
	Rect2(0.0, 0.0, 860.0, 36.0),            # Dinding Utara Luar
	Rect2(0.0, 544.0, 860.0, 36.0),          # Dinding Selatan Luar
	Rect2(0.0, 0.0, 36.0, 260.0),            # Dinding Barat Atas
	Rect2(0.0, 340.0, 36.0, 240.0),          # Dinding Barat Bawah (Celah Pintu Masuk di Y=260..340)
	Rect2(824.0, 0.0, 36.0, 580.0),          # Dinding Timur Luar
	
	# 2. Blok Dinding Sekat Pulau Labirin
	Rect2(252.0, 180.0, 160.0, 80.0),        # Pulau 1 (Sekat Lorong Utara & Tengah-Barat)
	Rect2(484.0, 180.0, 140.0, 80.0),        # Pulau 2 (Sekat Lorong Utara & Tengah-Timur)
	Rect2(252.0, 332.0, 220.0, 68.0),        # Pulau 3 (Sekat Lorong Tengah & Selatan-Barat)
	Rect2(472.0, 332.0, 80.0, 68.0),         # Pulau 4 (Sekat Tengah-Selatan)
	
	# 3. Sekat Ruang Kamar Jenazah (Morgue Vaults & Isolasi dengan Pintu Masuk)
	Rect2(648.0, 36.0, 176.0, 144.0),        # Dinding Kamar Jenazah Sisi Utara (Ruang Freezer Jenazah)
	Rect2(648.0, 420.0, 176.0, 124.0),       # Dinding Kamar Jenazah Sisi Selatan (Ruang Autopsi Tertutup)
	Rect2(648.0, 180.0, 24.0, 80.0),         # Tembok Pembatas Kamar Jenazah Atas (Y=180..260)
	Rect2(648.0, 340.0, 24.0, 80.0),         # Tembok Pembatas Kamar Jenazah Bawah (Y=340..420)
	# Celah Pintu Masuk Kamar Jenazah di X=648..672, Y=260..340 (lebar 80 px)
	
	# 4. Meja Resepsionis / Rintangan Lorong Depan
	Rect2(110.0, 275.0, 36.0, 50.0)          # Meja Perawat / Resepsionis Masuk
]

var walls_body: StaticBody2D
var coffin_sprite: Sprite2D
var coffin_glow: PointLight2D
var coffin_collision: StaticBody2D

# Lampu-lampu plafon lorong labirin
var corridor_lights: Array[PointLight2D] = []

var prompt_label: Label
var is_player_near_coffin: bool = false
var is_player_near_exit: bool = false
var has_revealed: bool = false
var is_glitching: bool = false

# Visual FX Distorsi & Audio
var glitch_layer: CanvasLayer
var glitch_distortion_rect: ColorRect
var glitch_material: ShaderMaterial
var glitch_status_label: Label
var fade_rect: ColorRect
var glitch_elapsed_time: float = 0.0
var glitch_current_intensity: float = 0.0

var hospital_audio: AudioStreamPlayer
var shock_audio: AudioStreamPlayer
var breathing_audio: AudioStreamPlayer

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_setup_labyrinth_collisions()
	_setup_lighting()
	_setup_coffin()
	_setup_prompts()
	_setup_glitch_distortion_fx()
	_setup_audio()
	queue_redraw()

func _setup_labyrinth_collisions() -> void:
	walls_body = StaticBody2D.new()
	walls_body.name = "LabyrinthWalls"
	walls_body.position = ROOM_ORIGIN
	walls_body.collision_layer = 1
	walls_body.collision_mask = 0
	add_child(walls_body)

	for r in LABYRINTH_WALLS:
		var col_shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = r.size
		col_shape.shape = rect_shape
		col_shape.position = r.position + r.size * 0.5
		walls_body.add_child(col_shape)

func _setup_lighting() -> void:
	# Sumber cahaya klinis dingin di persimpangan labirin
	var light_positions: Array[Vector2] = [
		Vector2(110.0, 300.0),   # Resepsionis Barat
		Vector2(216.0, 144.0),   # Lorong Utara (Kamar Pasien)
		Vector2(534.0, 144.0),   # Lorong Utara Timur
		Vector2(332.0, 296.0),   # Lorong Tengah
		Vector2(216.0, 436.0),   # Lorong Selatan (Radiologi)
		Vector2(588.0, 436.0),   # Lorong Selatan Timur
		Vector2(656.0, 296.0),   # Pintu Masuk Kamar Jenazah
		Vector2(744.0, 300.0)    # Spotlight Meja Autopsi / Peti Jenazah
	]

	var light_tex = _generate_lamp_texture()

	for pos in light_positions:
		var light = PointLight2D.new()
		light.position = ROOM_ORIGIN + pos
		light.texture = light_tex
		light.energy = 0.95
		light.texture_scale = 1.8
		light.color = Color(0.70, 0.88, 1.0, 0.85) # Cahaya Fluorescent Dingin
		add_child(light)
		corridor_lights.append(light)

func _generate_lamp_texture() -> Texture2D:
	var grad = Gradient.new()
	grad.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 1.0),
		Color(0.7, 0.85, 1.0, 0.55),
		Color(0.5, 0.75, 1.0, 0.15),
		Color(0.2, 0.4, 0.8, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.25, 0.65, 1.0])
	var g_tex = GradientTexture2D.new()
	g_tex.gradient = grad
	g_tex.fill = GradientTexture2D.FILL_RADIAL
	g_tex.fill_from = Vector2(0.5, 0.5)
	g_tex.fill_to = Vector2(1.0, 0.5)
	g_tex.width = 128
	g_tex.height = 128
	return g_tex

func _setup_coffin() -> void:
	# Ranjang / Kasur Mayat di Ujung Lorong Kamar Jenazah
	coffin_sprite = Sprite2D.new()
	coffin_sprite.name = "MorgueCoffin"
	var bed_tex = load("res://Environment/Ruang Mayat/kasurmayat.png")
	if not bed_tex:
		bed_tex = load("res://Environment/kasur mayat.png")
	if not bed_tex:
		bed_tex = load("res://Environment/Ruang Mayat/kasur mayat.png")
	if not bed_tex:
		bed_tex = load("res://Environment/kasurmayat.png")
	coffin_sprite.texture = bed_tex
	coffin_sprite.position = COFFIN_POS
	coffin_sprite.rotation_degrees = 0.0
	coffin_sprite.scale = Vector2(0.06, 0.06)
	coffin_sprite.z_index = 0
	add_child(coffin_sprite)

	# Collision box kasur mayat agar tidak ditembus pemain
	coffin_collision = StaticBody2D.new()
	coffin_collision.name = "CoffinCollision"
	coffin_collision.position = COFFIN_POS
	var col = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = Vector2(90.0, 55.0)
	col.shape = box
	coffin_collision.add_child(col)
	add_child(coffin_collision)

	# Lampu Bedah Dingin Mengarah Langsung ke Peti
	coffin_glow = PointLight2D.new()
	coffin_glow.position = COFFIN_POS
	coffin_glow.color = Color(0.60, 0.85, 1.0, 1.0)
	coffin_glow.energy = 1.4
	coffin_glow.texture_scale = 1.4
	coffin_glow.texture = _generate_lamp_texture()
	add_child(coffin_glow)

func _setup_prompts() -> void:
	prompt_label = Label.new()
	prompt_label.name = "HospitalPrompt"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 14)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	prompt_label.add_theme_constant_override("outline_size", 4)
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

func _setup_glitch_distortion_fx() -> void:
	glitch_layer = CanvasLayer.new()
	glitch_layer.name = "HospitalGlitchLayer"
	glitch_layer.layer = 50
	add_child(glitch_layer)

	# Fullscreen Distortion Rect dengan Custom Shader
	glitch_distortion_rect = ColorRect.new()
	glitch_distortion_rect.name = "GlitchDistortionRect"
	glitch_distortion_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	glitch_distortion_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader_res = load("res://shaders/glitch_distortion.gdshader")
	if shader_res:
		glitch_material = ShaderMaterial.new()
		glitch_material.shader = shader_res
		glitch_material.set_shader_parameter("distortion_intensity", 0.0)
		glitch_material.set_shader_parameter("glitch_time", 0.0)
		glitch_material.set_shader_parameter("color_flash", 0.0)
		glitch_distortion_rect.material = glitch_material

	glitch_distortion_rect.visible = false
	glitch_layer.add_child(glitch_distortion_rect)

	# Teks Korup / Status Penyadaran Benedict
	glitch_status_label = Label.new()
	glitch_status_label.name = "GlitchStatusLabel"
	glitch_status_label.set_anchors_preset(Control.PRESET_CENTER)
	glitch_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glitch_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glitch_status_label.add_theme_font_size_override("font_size", 24)
	glitch_status_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	glitch_status_label.add_theme_color_override("font_outline_color", Color.BLACK)
	glitch_status_label.add_theme_constant_override("outline_size", 6)
	glitch_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glitch_status_label.visible = false
	glitch_layer.add_child(glitch_status_label)

	# Fade Screen ke Hitam Pekat
	fade_rect = ColorRect.new()
	fade_rect.name = "HospitalFadeRect"
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glitch_layer.add_child(fade_rect)

func start_hospital() -> void:
	visible = true
	has_revealed = false
	is_glitching = false
	glitch_current_intensity = 0.0
	if is_instance_valid(glitch_layer):
		glitch_layer.visible = true
	if is_instance_valid(fade_rect):
		fade_rect.color = Color(0, 0, 0, 0)
	if is_instance_valid(glitch_distortion_rect):
		glitch_distortion_rect.visible = false
	if is_instance_valid(glitch_status_label):
		glitch_status_label.visible = false
	if is_instance_valid(glitch_material):
		glitch_material.set_shader_parameter("distortion_intensity", 0.0)
	if is_instance_valid(hospital_audio) and not hospital_audio.playing:
		hospital_audio.play()

func stop_hospital() -> void:
	visible = false
	if is_instance_valid(glitch_layer):
		glitch_layer.visible = false
	if is_instance_valid(fade_rect):
		fade_rect.color = Color(0, 0, 0, 0)
	if is_instance_valid(glitch_distortion_rect):
		glitch_distortion_rect.visible = false
	if is_instance_valid(glitch_status_label):
		glitch_status_label.visible = false
	if is_instance_valid(hospital_audio) and hospital_audio.playing:
		hospital_audio.stop()
	if is_instance_valid(shock_audio) and shock_audio.playing:
		shock_audio.stop()
	if is_instance_valid(breathing_audio) and breathing_audio.playing:
		breathing_audio.stop()

func _process(delta: float) -> void:
	if not visible:
		return

	# Kedip dinamis lampu-lampu lorong
	var t = Time.get_ticks_msec() * 0.003
	if is_instance_valid(coffin_glow):
		var flicker = 0.88 + 0.12 * sin(t * 1.5) + (0.1 if randf() < 0.03 else 0.0)
		coffin_glow.energy = 1.3 * flicker

	for i in range(corridor_lights.size()):
		var l = corridor_lights[i]
		if is_instance_valid(l) and l != coffin_glow:
			# Lampu lorong berkedip pelan khas rumah sakit tua
			var f = 0.90 + 0.10 * sin(t + float(i) * 1.7)
			if randf() < 0.02 and (i == 1 or i == 3): # Lorong utara kadang flicker
				f *= 0.4
			l.energy = 0.95 * f

	if is_glitching:
		_process_glitch_distortion(delta)
		return

	# Cek jarak pemain terhadap Peti Jenazah dan Pintu Keluar
	var player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		return

	var d_coffin = player.global_position.distance_to(COFFIN_POS)
	var d_exit   = player.global_position.distance_to(EXIT_DOOR_POS)

	if d_coffin <= 60.0 and not has_revealed:
		is_player_near_coffin = true
		is_player_near_exit = false
		prompt_label.visible = true
		prompt_label.text = "[ F / E / Spasi ] PERIKSA PETI JENAZAH"
		prompt_label.position = COFFIN_POS + Vector2(-110.0, -48.0)
	elif d_exit <= 48.0 and not has_revealed:
		is_player_near_exit = true
		is_player_near_coffin = false
		prompt_label.visible = true
		prompt_label.text = "[ F / E / Spasi ] KELUAR KE KOTA"
		prompt_label.position = EXIT_DOOR_POS + Vector2(15.0, -32.0)
	else:
		is_player_near_coffin = false
		is_player_near_exit = false
		prompt_label.visible = false

func _process_glitch_distortion(delta: float) -> void:
	glitch_elapsed_time += delta
	if is_instance_valid(glitch_material):
		glitch_material.set_shader_parameter("glitch_time", glitch_elapsed_time * 20.0)
		glitch_material.set_shader_parameter("distortion_intensity", glitch_current_intensity)
		if randf() < 0.12 * glitch_current_intensity:
			glitch_material.set_shader_parameter("color_flash", randf_range(0.4, 1.0))
		else:
			glitch_material.set_shader_parameter("color_flash", 0.0)

	# Goncangan kamera intensitas sesuai distorsi
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		var cam = player.get_node_or_null("Camera2D")
		if is_instance_valid(cam):
			var shake_amp = 8.0 * glitch_current_intensity
			cam.offset = Vector2(randf_range(-shake_amp, shake_amp), randf_range(-shake_amp, shake_amp))

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

	if is_instance_valid(shock_audio) and shock_audio.stream:
		shock_audio.play()
	if is_instance_valid(breathing_audio) and breathing_audio.stream:
		breathing_audio.play()

	# Efek pulsa cahaya intens pada peti
	if is_instance_valid(coffin_glow):
		var tw_glow = create_tween()
		tw_glow.tween_property(coffin_glow, "energy", 3.8, 0.4)
		tw_glow.tween_property(coffin_glow, "energy", 1.5, 0.6)

	var monologue_lines: Array[String] = [
		"Peti jenazah bernomor 1604... Hawa dingin menusuk dari dalam kain penutup...",
		"T-tidak... TIDAK MUNGKIN!!",
		"Wajah mayat yang terbujur kaku di dalam peti ini... jas detektif ini... luka di pelipis ini...",
		"MAYAT YANG BERADA DI RUANG JENAZAH INI... ADALAH DIRIKU SENDIRI?!",
		"Jam dinding kota yang mati di 16:04... tatapan ngeri orang-orang di jalan... rol foto di stasiun...",
		"Aku bukan sedang menyelidiki kasus pembunuhan orang lain... AKU TELAH MATI SEJAK AWAL!!",
		"Udara di sekitarku bergetar hebat... Realitas dan kesadaranku mulai hancur terdistorsi..."
	]

	var dlg = null
	var main_node = get_parent()
	if is_instance_valid(main_node):
		dlg = main_node.get_node_or_null("DialogBox")

	if is_instance_valid(dlg) and dlg.has_method("start_monologue"):
		dlg.start_monologue(monologue_lines, "Detektif Benedict", "[ KEBENARAN MENGERIKAN ]", "res://karakter/MC_Kaget.png")
		dlg.monologue_finished.connect(func():
			_trigger_distortion_glitch_sequence()
		, CONNECT_ONE_SHOT)
	else:
		await get_tree().create_timer(3.0).timeout
		_trigger_distortion_glitch_sequence()

func _trigger_distortion_glitch_sequence() -> void:
	is_glitching = true
	glitch_distortion_rect.visible = true
	glitch_status_label.visible = true

	var corrupted_messages = [
		"ERROR: SUBJEK TELAH MENINGGAL DUNIA",
		"WAKTU KEMATIAN: 16:04:00",
		"BENEDICT... KAU TELAH TIADA SEJAK AWAL",
		"KESADARAN HANCUR TERDISTORSI...",
		"GERBANG ALAM KEMATIAN DIBUKA..."
	]

	var glitch_duration = 3.2
	var tw_distort = create_tween()
	
	# Naikkan intensitas distorsi secara dramatis dari 0.15 hingga 1.0 (Full Reality Break)
	tw_distort.tween_property(self, "glitch_current_intensity", 1.0, glitch_duration).from(0.15)
	
	# Ganti pesan korup secara acak selama distorsi berlangsung
	var tw_text = create_tween()
	tw_text.set_loops(8)
	tw_text.tween_callback(func():
		glitch_status_label.text = corrupted_messages[randi() % corrupted_messages.size()]
		glitch_status_label.position = Vector2(
			(get_viewport_rect().size.x - glitch_status_label.size.x) * 0.5 + randf_range(-15.0, 15.0),
			(get_viewport_rect().size.y - glitch_status_label.size.y) * 0.5 + randf_range(-15.0, 15.0)
		)
	)
	tw_text.tween_interval(0.35)

	# Fade layar ke hitam total di akhir distorsi
	var tw_fade = create_tween()
	tw_fade.tween_interval(glitch_duration - 1.2)
	tw_fade.tween_property(fade_rect, "color:a", 1.0, 1.2)
	tw_fade.tween_interval(1.0) # Jeda hening di kegelapan total (0.8-1.2 detik)
	tw_fade.tween_callback(func():
		var player = get_tree().get_first_node_in_group("player")
		if is_instance_valid(player):
			var cam = player.get_node_or_null("Camera2D")
			if is_instance_valid(cam):
				cam.offset = Vector2.ZERO
		glitch_distortion_rect.visible = false
		glitch_status_label.visible = false
		stop_hospital()
		hospital_completed.emit()
	)

func _draw() -> void:
	var ox = ROOM_ORIGIN.x
	var oy = ROOM_ORIGIN.y
	var w = ROOM_SIZE.x
	var h = ROOM_SIZE.y

	# 1. LANTAI DASAR RUMAH SAKIT
	# Ubin keramik klinis (mint/cyan lembut)
	var tile_size = 28.0
	var col_tile_a = Color(0.82, 0.88, 0.88)
	var col_tile_b = Color(0.78, 0.85, 0.86)
	var col_grout  = Color(0.68, 0.76, 0.78, 0.45)

	draw_rect(Rect2(ox, oy, w, h), col_tile_a, true)

	var cols = int(ceil(w / tile_size))
	var rows = int(ceil(h / tile_size))
	for r in range(rows):
		for c in range(cols):
			var px = ox + float(c) * tile_size
			var py = oy + float(r) * tile_size
			var t_rect = Rect2(px, py, tile_size, tile_size)
			if (r + c) % 2 == 1:
				draw_rect(t_rect, col_tile_b, true)
			draw_rect(t_rect, col_grout, false, 1.0)

	# 2. LANTAI KHUSUS RUANG JENAZAH (MORGUE CHAMBER)
	# Ubin dingin abu-abu baja di area timur (X=648..824, Y=180..420)
	var morgue_floor = Rect2(ox + 648.0, oy + 180.0, 176.0, 240.0)
	var col_morgue_a = Color(0.42, 0.48, 0.54)
	var col_morgue_b = Color(0.38, 0.44, 0.50)
	draw_rect(morgue_floor, col_morgue_a, true)
	
	var m_cols = int(ceil(morgue_floor.size.x / tile_size))
	var m_rows = int(ceil(morgue_floor.size.y / tile_size))
	for mr in range(m_rows):
		for mc in range(m_cols):
			var mpx = morgue_floor.position.x + float(mc) * tile_size
			var mpy = morgue_floor.position.y + float(mr) * tile_size
			if (mr + mc) % 2 == 1:
				draw_rect(Rect2(mpx, mpy, tile_size, tile_size), col_morgue_b, true)
			draw_rect(Rect2(mpx, mpy, tile_size, tile_size), Color(0.25, 0.32, 0.38, 0.5), false, 1.0)

	# Garis pembatas bahaya (Kuning-Hitam Hazard Stripes) di ambang Kamar Jenazah
	for hz in range(6):
		var hy = oy + 260.0 + float(hz) * 12.0
		var h_col = Color(0.9, 0.75, 0.1) if hz % 2 == 0 else Color(0.12, 0.12, 0.12)
		draw_rect(Rect2(ox + 646.0, hy, 6.0, 12.0), h_col, true)

	# 3. DINDING LABIRIN DENGAN KEDALAMAN 3D
	var wall_dark = Color(0.16, 0.20, 0.24)   # Dinding utama
	var wall_top  = Color(0.24, 0.30, 0.36)   # Atap dinding
	var wall_trim = Color(0.36, 0.44, 0.50)   # Lis plin bawah
	var shadow_col = Color(0.0, 0.0, 0.0, 0.32) # Bayangan dinding ke lantai

	for r in LABYRINTH_WALLS:
		var world_r = Rect2(ox + r.position.x, oy + r.position.y, r.size.x, r.size.y)
		
		# Bayangan bawah
		draw_rect(Rect2(world_r.position.x + 4.0, world_r.position.y + world_r.size.y, world_r.size.x, 8.0), shadow_col, true)
		
		# Dinding utama
		draw_rect(world_r, wall_dark, true)
		
		# Bagian atas dinding (permukaan atas dengan outline trim)
		var top_h = min(12.0, world_r.size.y * 0.4)
		draw_rect(Rect2(world_r.position.x, world_r.position.y, world_r.size.x, top_h), wall_top, true)
		draw_line(Vector2(world_r.position.x, world_r.position.y + top_h), Vector2(world_r.position.x + world_r.size.x, world_r.position.y + top_h), wall_trim, 1.5)
		
		# Lis bawah dinding
		draw_rect(Rect2(world_r.position.x, world_r.position.y + world_r.size.y - 4.0, world_r.size.x, 4.0), wall_trim, true)

	# 4. PINTU-PINTU KAMAR KLINIS & PAPAN NAMA
	# Pintu UGD / Masuk di Dinding Barat (Y=260..340)
	var door_w = Rect2(ox + 2.0, oy + 264.0, 32.0, 72.0)
	draw_rect(door_w, Color(0.22, 0.32, 0.40), true)
	draw_rect(door_w, Color(0.50, 0.65, 0.75), false, 2.0)
	draw_rect(Rect2(ox + 8.0, oy + 280.0, 20.0, 36.0), Color(0.65, 0.85, 0.95, 0.6), true) # Kaca pintu
	# Tanda EXIT hijau menyala di atas pintu barat
	draw_rect(Rect2(ox + 6.0, oy + 250.0, 24.0, 10.0), Color(0.1, 0.85, 0.3), true)

	# Pintu Kamar Pasien di Lorong Utara (Kamar 101, 102, 103, ICU)
	_draw_clinic_door(Vector2(ox + 270.0, oy + 36.0), "101")
	_draw_clinic_door(Vector2(ox + 350.0, oy + 36.0), "102")
	_draw_clinic_door(Vector2(ox + 430.0, oy + 36.0), "103")
	_draw_clinic_door(Vector2(ox + 520.0, oy + 36.0), "ICU")

	# Pintu Laboratorium & Radiologi di Lorong Selatan
	_draw_clinic_door(Vector2(ox + 290.0, oy + 512.0), "LAB")
	_draw_clinic_door(Vector2(ox + 380.0, oy + 512.0), "RONTGEN")
	_draw_clinic_door(Vector2(ox + 470.0, oy + 512.0), "FARMASI")

	# 5. LEMARI PENDINGIN MAYAT BAJA (CORPSE REFRIGERATOR VAULTS)
	# Digambar pada dinding utara Kamar Jenazah (X=660..810, Y=40..170)
	var vault_base = Rect2(ox + 660.0, oy + 42.0, 150.0, 130.0)
	draw_rect(vault_base, Color(0.32, 0.36, 0.40), true)
	draw_rect(vault_base, Color(0.55, 0.62, 0.68), false, 2.0)

	# 6 Kotak laci pendingin mayat (2 baris x 3 kolom)
	var v_cols = 3
	var v_rows = 2
	var v_w = 44.0
	var v_h = 54.0
	for vr in range(v_rows):
		for vc in range(v_cols):
			var vx = vault_base.position.x + 6.0 + float(vc) * 48.0
			var vy = vault_base.position.y + 6.0 + float(vr) * 60.0
			var v_rect = Rect2(vx, vy, v_w, v_h)
			draw_rect(v_rect, Color(0.24, 0.28, 0.32), true)
			draw_rect(v_rect, Color(0.48, 0.54, 0.60), false, 1.5)
			# Handle pintu laci baja
			draw_rect(Rect2(vx + 14.0, vy + 24.0, 16.0, 5.0), Color(0.75, 0.82, 0.88), true)
			# Indikator nomor laci mayat (Kotak 6 memiliki label 16:04)
			var is_target_vault = (vr == 1 and vc == 2)
			var badge_col = Color(0.9, 0.2, 0.2) if is_target_vault else Color(0.2, 0.8, 0.4)
			draw_circle(Vector2(vx + 36.0, vy + 12.0), 3.0, badge_col)

	# Papan peringatan merah telah dihapus sesuai permintaan

	# Meja Resepsionis / Kursi Perawat di Lorong Barat
	var desk_rect = Rect2(ox + 110.0, oy + 275.0, 36.0, 50.0)
	draw_rect(desk_rect, Color(0.35, 0.28, 0.22), true)
	draw_rect(desk_rect, Color(0.55, 0.42, 0.32), false, 1.5)
	# Buku rekam medis & telepon di atas meja
	draw_rect(Rect2(ox + 116.0, oy + 282.0, 12.0, 16.0), Color(0.9, 0.9, 0.95), true)
	draw_rect(Rect2(ox + 118.0, oy + 306.0, 10.0, 8.0), Color(0.15, 0.15, 0.15), true)

func _draw_clinic_door(pos: Vector2, label_txt: String) -> void:
	var d_rect = Rect2(pos.x, pos.y, 34.0, 24.0)
	draw_rect(d_rect, Color(0.30, 0.38, 0.44), true)
	draw_rect(d_rect, Color(0.52, 0.62, 0.70), false, 1.5)
	# Gagang pintu
	draw_circle(Vector2(pos.x + 6.0, pos.y + 12.0), 2.0, Color(0.85, 0.85, 0.40))
	# Pelat nama kecil di atas pintu
	draw_rect(Rect2(pos.x + 8.0, pos.y + 2.0, 18.0, 6.0), Color(0.85, 0.90, 0.95), true)
