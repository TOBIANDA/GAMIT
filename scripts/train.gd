extends Node2D

# ── Passing Train System v1 (Kereta Api Melintas di Rel Timur) ─────────────
# Fitur:
# 1. Kereta Api Vintage (Lokomotif + Tender + 3 Gerbong Penumpang + Kabus Ekor)
# 2. Partikel Asap/Uap Cerobong (CPUParticles2D) & Lampu Sorot Depan
# 3. Suara Kereta Api Prosedural Open-Source (AudioStreamGenerator):
#    - Suara Klakson/Peluit Kereta 3-Nada Klasik (G-B-D Whistle)
#    - Suara Gemuruh Roda Rel (Rhythmic Chug & Track Click-Clack)
#    - Lonceng Peringatan Palang Stasiun (Station Crossing Bell)
# 4. Spatial Audio (Volume otomatis mengecil jika pemain jauh di sisi barat)

const RAIL_CENTER_X: float = 2240.0 # Posisi tengah rel (2160..2322)
const TRAIN_SPEED: float = 620.0     # Kecepatan melaju (px/s)
const TRAIN_START_Y: float = -950.0
const TRAIN_END_Y: float = 2200.0

@export var spawn_interval: float = 28.0 # Kereta lewat setiap ~28 detik
var spawn_timer: float = 8.0             # Kereta pertama lewat 8 detik setelah main
var is_train_running: bool = false
var train_y: float = TRAIN_START_Y

# Audio Prosedural
var audio_player_chug: AudioStreamPlayer
var playback_chug: AudioStreamGeneratorPlayback
var audio_player_horn: AudioStreamPlayer
var playback_horn: AudioStreamGeneratorPlayback
var audio_player_bell: AudioStreamPlayer
var playback_bell: AudioStreamGeneratorPlayback

# Sound Variables
var chug_phase: float = 0.0
var chug_tick_timer: float = 0.0
var horn_timer: float = 0.0
var is_horn_blowing: bool = false
var horn_sequence_step: int = 0
var horn_cooldown: float = 0.0
var bell_timer: float = 0.0

# Smoke Particles
var smoke_particles: CPUParticles2D
var player_ref: CharacterBody2D

func _ready() -> void:
	z_index = 5 # Di atas rel & lantai map
	position = Vector2(RAIL_CENTER_X, TRAIN_START_Y)
	_setup_audio_synthesizers()
	_setup_smoke_particles()

func _setup_smoke_particles() -> void:
	smoke_particles = CPUParticles2D.new()
	smoke_particles.position = Vector2(0, 80) # Cerobong lokomotif
	smoke_particles.amount = 40
	smoke_particles.lifetime = 1.6
	smoke_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	smoke_particles.emission_sphere_radius = 8.0
	smoke_particles.gravity = Vector2(0, -60)
	smoke_particles.direction = Vector2(0, -1)
	smoke_particles.spread = 25.0
	smoke_particles.initial_velocity_min = 30.0
	smoke_particles.initial_velocity_max = 70.0
	smoke_particles.scale_amount_min = 12.0
	smoke_particles.scale_amount_max = 34.0
	smoke_particles.color = Color(0.85, 0.88, 0.92, 0.45)
	smoke_particles.emitting = false
	add_child(smoke_particles)

# ── Audio Synthesizers ──────────────────────────────────────────────────────
func _setup_audio_synthesizers() -> void:
	# 1. Chug & Track Rumbling
	audio_player_chug = AudioStreamPlayer.new()
	var gen_chug = AudioStreamGenerator.new()
	gen_chug.mix_rate = 22050
	gen_chug.buffer_length = 0.15
	audio_player_chug.stream = gen_chug
	add_child(audio_player_chug)
	audio_player_chug.play()
	playback_chug = audio_player_chug.get_stream_playback()

	# 2. Train Horn / Whistle
	audio_player_horn = AudioStreamPlayer.new()
	var gen_horn = AudioStreamGenerator.new()
	gen_horn.mix_rate = 22050
	gen_horn.buffer_length = 0.15
	audio_player_horn.stream = gen_horn
	add_child(audio_player_horn)
	audio_player_horn.play()
	playback_horn = audio_player_horn.get_stream_playback()

	# 3. Station Crossing Bell
	audio_player_bell = AudioStreamPlayer.new()
	var gen_bell = AudioStreamGenerator.new()
	gen_bell.mix_rate = 22050
	gen_bell.buffer_length = 0.15
	audio_player_bell.stream = gen_bell
	add_child(audio_player_bell)
	audio_player_bell.play()
	playback_bell = audio_player_bell.get_stream_playback()

# ── Process Loop ────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player_ref):
			player_ref = get_node_or_null("../Player")

	# Spatial Volume Distance Calculation
	var spatial_vol = 1.0
	if is_instance_valid(player_ref):
		var dist_to_track = abs(player_ref.global_position.x - RAIL_CENTER_X)
		# Suara terdengar penuh di dekat rel (0..400px), memudar lembut hingga 2000px
		spatial_vol = clampf(1.0 - (dist_to_track / 2000.0), 0.05, 1.0)
		spatial_vol = pow(spatial_vol, 1.5) # Easing

	if not is_train_running:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_start_passing_train()
	else:
		# Kereta sedang melaju
		train_y += delta * TRAIN_SPEED
		position = Vector2(RAIL_CENTER_X, train_y)

		# Logika Klakson Kereta Berkala saat melintas
		_handle_horn_and_bell(delta, spatial_vol)

		# Suara Roda Rel (Chug-Chug)
		_synthesize_track_rumble(delta, spatial_vol)

		if train_y >= TRAIN_END_Y:
			_end_passing_train()

		queue_redraw()

func _start_passing_train() -> void:
	is_train_running = true
	train_y = TRAIN_START_Y
	position = Vector2(RAIL_CENTER_X, train_y)
	if is_instance_valid(smoke_particles):
		smoke_particles.emitting = true
	horn_sequence_step = 0
	horn_cooldown = 0.5
	print("[TrainSystem] 🚂 Kereta api mulai melintas di jalur rel timur!")

func _end_passing_train() -> void:
	is_train_running = false
	train_y = TRAIN_START_Y
	position = Vector2(RAIL_CENTER_X, train_y)
	if is_instance_valid(smoke_particles):
		smoke_particles.emitting = false
	spawn_timer = randf_range(spawn_interval * 0.8, spawn_interval * 1.3)
	queue_redraw()

# ── Logika Suara Klakson & Lonceng Palang ───────────────────────────────────
func _handle_horn_and_bell(delta: float, spatial_vol: float) -> void:
	horn_cooldown -= delta

	# Urutan Klakson: 2 Tiupan Panjang saat masuk + 1 Tiupan saat tiba di stasiun
	if horn_sequence_step == 0 and train_y > -400.0 and horn_cooldown <= 0.0:
		_trigger_horn(1.4) # Tiupan panjang 1
		horn_sequence_step = 1
		horn_cooldown = 1.9
	elif horn_sequence_step == 1 and horn_cooldown <= 0.0:
		_trigger_horn(1.2) # Tiupan panjang 2
		horn_sequence_step = 2
		horn_cooldown = 2.5
	elif horn_sequence_step == 2 and train_y > 400.0 and train_y < 700.0 and horn_cooldown <= 0.0:
		_trigger_horn(0.8) # Tiupan pendek stasiun
		horn_sequence_step = 3

	if is_horn_blowing:
		horn_timer -= delta
		_synthesize_train_horn(spatial_vol)
		if horn_timer <= 0.0:
			is_horn_blowing = false

	# Lonceng Stasiun Berdentang saat kereta mendekati stasiun (y: -200 .. 1100)
	if train_y >= -200.0 and train_y <= 1100.0:
		bell_timer += delta
		if bell_timer >= 0.55:
			bell_timer = 0.0
			_synthesize_crossing_bell(spatial_vol)

func _trigger_horn(duration: float) -> void:
	is_horn_blowing = true
	horn_timer = duration

# ── Sintesis Suara Prosedural (100% Bebas Royalti & Open Source) ────────────

# 1. Suara Rel Roda & Chug (Rumble)
func _synthesize_track_rumble(delta: float, spatial_vol: float) -> void:
	if playback_chug == null:
		return

	var frames_to_push = min(playback_chug.get_frames_available(), int(22050 * delta * 1.5))
	if frames_to_push <= 0:
		return

	for i in range(frames_to_push):
		chug_phase += 1.0 / 22050.0
		# Rhythmic click-clack pulse (4 ketukan per detik)
		var beat = fmod(chug_phase * 6.5, 1.0)
		var pulse = pow(sin(beat * PI), 8.0) * 0.45
		
		# Low rumble carrier (65Hz + 130Hz)
		var rumble = sin(chug_phase * 65.0 * TAU) * 0.3 + sin(chug_phase * 130.0 * TAU) * 0.2
		# White noise hiss untuk gesekan roda besi ke rel
		var hiss = (randf() * 2.0 - 1.0) * 0.12

		var total_sample = (rumble + hiss + pulse) * 0.38 * spatial_vol
		playback_chug.push_frame(Vector2(total_sample, total_sample))

# 2. Suara Peluit Klakson Kereta (3-Tone Vintage Chord: G4 392Hz, B4 494Hz, D5 587Hz)
func _synthesize_train_horn(spatial_vol: float) -> void:
	if playback_horn == null:
		return

	var frames = playback_horn.get_frames_available()
	if frames <= 0:
		return

	for i in range(frames):
		chug_phase += 1.0 / 22050.0
		var t = chug_phase
		# Chord peluit uap kereta retro
		var f1 = sin(t * 392.0 * TAU) * 0.35 # G4
		var f2 = sin(t * 494.0 * TAU) * 0.30 # B4
		var f3 = sin(t * 587.0 * TAU) * 0.25 # D5
		var breath = (randf() * 2.0 - 1.0) * 0.08 # Desis uap udara
		
		var sample = (f1 + f2 + f3 + breath) * 0.50 * spatial_vol
		playback_horn.push_frame(Vector2(sample, sample))

# 3. Suara Dentang Lonceng Palang Stasiun (1200 Hz Bell Ring)
func _synthesize_crossing_bell(spatial_vol: float) -> void:
	if playback_bell == null:
		return

	var sample_count = int(22050 * 0.12)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var decay = exp(-t * 22.0)
		var sample = sin(t * 1200.0 * TAU) * decay * 0.35 * spatial_vol
		if playback_bell.can_push_buffer(1):
			playback_bell.push_frame(Vector2(sample, sample))

# ── Visual Rendering Kereta Api Lengkap ────────────────────────────────────
func _draw() -> void:
	if not is_train_running:
		return

	# Lebar bodi kereta: 88px (berada tepat di atas rel 2185..2295)
	var tw = 88.0
	var htw = tw / 2.0

	# 1. Volumetric Headlight Cones (Lampu Sorot Kuning Terang Menembus Rel)
	var light_pts = PackedVector2Array([
		Vector2(-14, 180), Vector2(14, 180),
		Vector2(110, 680), Vector2(-110, 680)
	])
	draw_colored_polygon(light_pts, Color(1.0, 0.95, 0.6, 0.22))
	draw_circle(Vector2(0, 180), 22.0, Color(1.0, 1.0, 0.8, 0.75))

	# 2. Lokomotif Utama (Engine Car) : y = 40 .. 180
	_draw_locomotive(Vector2(-htw, 40), Vector2(tw, 140))

	# 3. Tender Batu Bara : y = -60 .. 25
	_draw_coal_tender(Vector2(-htw + 4, -60), Vector2(tw - 8, 85))

	# 4. Gerbong Penumpang 1 : y = -220 .. -75
	_draw_passenger_car(Vector2(-htw, -220), Vector2(tw, 145), Color(0.16, 0.28, 0.22), "1")

	# 5. Gerbong Penumpang 2 : y = -380 .. -235
	_draw_passenger_car(Vector2(-htw, -380), Vector2(tw, 145), Color(0.24, 0.16, 0.20), "2")

	# 6. Gerbong Penumpang 3 : y = -540 .. -395
	_draw_passenger_car(Vector2(-htw, -540), Vector2(tw, 145), Color(0.16, 0.28, 0.22), "3")

	# 7. Kabus Ekor (Caboose Merah dengan Lentera Berkedip) : y = -680 .. -555
	_draw_caboose(Vector2(-htw + 2, -680), Vector2(tw - 4, 125))

# ── Helper Gambar Bagian Kereta ─────────────────────────────────────────────
func _draw_locomotive(pos: Vector2, size: Vector2) -> void:
	# Bayangan bawah
	draw_rect(Rect2(pos + Vector2(4, 4), size), Color(0, 0, 0, 0.4), true)
	# Bodi Baja Hitam Metalik
	draw_rect(Rect2(pos, size), Color(0.12, 0.14, 0.18), true)
	draw_rect(Rect2(pos, size), Color(0.35, 0.40, 0.50), false, 2.5)

	# Cowcatcher / Bumper Merah di depan
	var plow_pts = PackedVector2Array([
		Vector2(pos.x - 4, pos.y + size.y),
		Vector2(pos.x + size.x + 4, pos.y + size.y),
		Vector2(pos.x + size.x / 2.0, pos.y + size.y + 18)
	])
	draw_colored_polygon(plow_pts, Color(0.75, 0.15, 0.15))

	# Garis Emas & Platina
	draw_line(Vector2(pos.x + 6, pos.y + 40), Vector2(pos.x + size.x - 6, pos.y + 40), Color(0.85, 0.70, 0.25), 2.5)
	draw_line(Vector2(pos.x + 6, pos.y + 90), Vector2(pos.x + size.x - 6, pos.y + 90), Color(0.85, 0.70, 0.25), 2.5)

	# Kaca Kabin Masinis (Cahaya Kuning Hangat)
	draw_rect(Rect2(pos.x + 12, pos.y + 15, size.x - 24, 22), Color(1.0, 0.85, 0.35, 0.95), true)
	draw_rect(Rect2(pos.x + 12, pos.y + 15, size.x - 24, 22), Color(0.1, 0.1, 0.1), false, 2.0)

	# Cerobong Asap Hitam
	draw_rect(Rect2(pos.x + size.x / 2.0 - 10, pos.y + 70, 20, 24), Color(0.2, 0.22, 0.26), true)
	draw_circle(Vector2(pos.x + size.x / 2.0, pos.y + 82), 12.0, Color(0.85, 0.70, 0.25))

func _draw_coal_tender(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), size), Color(0, 0, 0, 0.35), true)
	draw_rect(Rect2(pos, size), Color(0.16, 0.18, 0.22), true)
	draw_rect(Rect2(pos, size), Color(0.28, 0.32, 0.38), false, 2.0)
	# Tumpukan Batu Bara Hitam
	draw_rect(Rect2(pos.x + 6, pos.y + 8, size.x - 12, size.y - 16), Color(0.06, 0.06, 0.08), true)

func _draw_passenger_car(pos: Vector2, size: Vector2, color: Color, _num: String) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), size), Color(0, 0, 0, 0.35), true)
	# Bodi Gerbong
	draw_rect(Rect2(pos, size), color, true)
	draw_rect(Rect2(pos, size), Color(0.85, 0.70, 0.30, 0.8), false, 2.0)

	# Sambungan Bordes Antar Gerbong
	draw_rect(Rect2(pos.x + size.x / 2.0 - 8, pos.y - 12, 16, 14), Color(0.1, 0.1, 0.12), true)

	# Deretan Jendela Kaca yang Menyala Hangat
	for i in range(4):
		var wy = pos.y + 18 + i * 30
		draw_rect(Rect2(pos.x + 8, wy, 22, 18), Color(1.0, 0.90, 0.50, 0.9), true)
		draw_rect(Rect2(pos.x + 8, wy, 22, 18), Color(0.1, 0.1, 0.1), false, 1.5)
		draw_rect(Rect2(pos.x + size.x - 30, wy, 22, 18), Color(1.0, 0.90, 0.50, 0.9), true)
		draw_rect(Rect2(pos.x + size.x - 30, wy, 22, 18), Color(0.1, 0.1, 0.1), false, 1.5)

func _draw_caboose(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), size), Color(0, 0, 0, 0.35), true)
	# Bodi Merah Kabus Klasik
	draw_rect(Rect2(pos, size), Color(0.55, 0.14, 0.14), true)
	draw_rect(Rect2(pos, size), Color(0.85, 0.70, 0.30), false, 2.0)

	# Jendela Observasi Atas
	draw_rect(Rect2(pos.x + 14, pos.y + 35, size.x - 28, 35), Color(0.95, 0.85, 0.40, 0.9), true)

	# Lentera Ekor Merah Berkedip
	var blink = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)
	draw_circle(Vector2(pos.x + size.x / 2.0, pos.y + 10), 9.0, Color(1.0, 0.2, 0.2, blink))
	draw_circle(Vector2(pos.x + size.x / 2.0, pos.y + 10), 4.0, Color(1.0, 0.9, 0.9, 1.0))
