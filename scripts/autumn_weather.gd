extends CanvasLayer

# ── Autumn Weather System (Efek Musim Gugur & Daun Berguguran) ──────────────
# Fitur:
# 1. 3 Layer Daun Musim Gugur (Merah Maple, Oranye Amber, & Emas Keemasan)
# 2. Fisika Daun Melayang & Berputar Mengikuti Hembusan Angin (Swirling Leaves)
# 3. Audio Desir Angin Musim Gugur & Gemerisik Daun Lembut (Autumn Breeze)
# 4. Atmosfer Hangat & Nostalgia Sesuai Tema Musim Gugur

var leaf_particles_fg: CPUParticles2D
var leaf_particles_mg: CPUParticles2D
var leaf_particles_bg: CPUParticles2D

# Audio Angin Musim Gugur
var audio_player_breeze: AudioStreamPlayer
var playback_breeze: AudioStreamGeneratorPlayback
var breeze_time: float = 0.0

func _ready() -> void:
	layer = 8 # Di atas map, di bawah HUD
	_build_autumn_leaves()
	_setup_autumn_breeze_audio()
	get_viewport().size_changed.connect(_on_viewport_resized)

func _build_autumn_leaves() -> void:
	var vp = get_viewport().get_visible_rect().size
	if vp.x < 100 or vp.y < 100:
		vp = Vector2(1600, 900)

	# 1. Daun Latar Belakang (Daun Halus Berterbangan di Angin)
	leaf_particles_bg = CPUParticles2D.new()
	leaf_particles_bg.position = Vector2(vp.x * 0.5, -30)
	leaf_particles_bg.amount = 85
	leaf_particles_bg.lifetime = 9.0
	leaf_particles_bg.preprocess = 4.5
	leaf_particles_bg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	leaf_particles_bg.emission_rect_extents = Vector2(vp.x * 0.7, 15)
	leaf_particles_bg.gravity = Vector2(25, 45) # Melayang ke kanan bawah
	leaf_particles_bg.direction = Vector2(0.8, 1.0)
	leaf_particles_bg.spread = 25.0
	leaf_particles_bg.initial_velocity_min = 30.0
	leaf_particles_bg.initial_velocity_max = 65.0
	leaf_particles_bg.angular_velocity_min = -120.0
	leaf_particles_bg.angular_velocity_max = 120.0
	leaf_particles_bg.angle_min = -180.0
	leaf_particles_bg.angle_max = 180.0
	leaf_particles_bg.scale_amount_min = 2.5
	leaf_particles_bg.scale_amount_max = 4.5
	leaf_particles_bg.color = Color(0.88, 0.48, 0.22, 0.65) # Oranye tembaga
	add_child(leaf_particles_bg)

	# 2. Daun Tengah (Daun Maple Merah & Kuning Emas)
	leaf_particles_mg = CPUParticles2D.new()
	leaf_particles_mg.position = Vector2(vp.x * 0.5, -40)
	leaf_particles_mg.amount = 60
	leaf_particles_mg.lifetime = 7.5
	leaf_particles_mg.preprocess = 3.5
	leaf_particles_mg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	leaf_particles_mg.emission_rect_extents = Vector2(vp.x * 0.75, 15)
	leaf_particles_mg.gravity = Vector2(35, 60)
	leaf_particles_mg.direction = Vector2(0.9, 1.0)
	leaf_particles_mg.spread = 30.0
	leaf_particles_mg.initial_velocity_min = 45.0
	leaf_particles_mg.initial_velocity_max = 90.0
	leaf_particles_mg.angular_velocity_min = -180.0
	leaf_particles_mg.angular_velocity_max = 180.0
	leaf_particles_mg.angle_min = -180.0
	leaf_particles_mg.angle_max = 180.0
	leaf_particles_mg.scale_amount_min = 5.0
	leaf_particles_mg.scale_amount_max = 8.5
	leaf_particles_mg.color = Color(0.85, 0.28, 0.18, 0.85) # Merah maple gugur
	add_child(leaf_particles_mg)

	# 3. Daun Depan (Daun Besar Mengapung Dekat Kamera)
	leaf_particles_fg = CPUParticles2D.new()
	leaf_particles_fg.position = Vector2(vp.x * 0.5, -50)
	leaf_particles_fg.amount = 25
	leaf_particles_fg.lifetime = 6.0
	leaf_particles_fg.preprocess = 2.5
	leaf_particles_fg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	leaf_particles_fg.emission_rect_extents = Vector2(vp.x * 0.8, 15)
	leaf_particles_fg.gravity = Vector2(45, 80)
	leaf_particles_fg.direction = Vector2(1.0, 1.0)
	leaf_particles_fg.spread = 35.0
	leaf_particles_fg.initial_velocity_min = 60.0
	leaf_particles_fg.initial_velocity_max = 120.0
	leaf_particles_fg.angular_velocity_min = -220.0
	leaf_particles_fg.angular_velocity_max = 220.0
	leaf_particles_fg.angle_min = -180.0
	leaf_particles_fg.angle_max = 180.0
	leaf_particles_fg.scale_amount_min = 9.0
	leaf_particles_fg.scale_amount_max = 14.0
	leaf_particles_fg.color = Color(0.95, 0.65, 0.20, 0.90) # Emas amber keemasan
	add_child(leaf_particles_fg)

func _on_viewport_resized() -> void:
	var vp = get_viewport().get_visible_rect().size
	if is_instance_valid(leaf_particles_bg):
		leaf_particles_bg.position = Vector2(vp.x * 0.5, -30)
		leaf_particles_bg.emission_rect_extents = Vector2(vp.x * 0.7, 15)
	if is_instance_valid(leaf_particles_mg):
		leaf_particles_mg.position = Vector2(vp.x * 0.5, -40)
		leaf_particles_mg.emission_rect_extents = Vector2(vp.x * 0.75, 15)
	if is_instance_valid(leaf_particles_fg):
		leaf_particles_fg.position = Vector2(vp.x * 0.5, -50)
		leaf_particles_fg.emission_rect_extents = Vector2(vp.x * 0.8, 15)

# ── Suara Angin Musim Gugur Prosedural ──────────────────────────────────────
func _setup_autumn_breeze_audio() -> void:
	audio_player_breeze = AudioStreamPlayer.new()
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.15
	audio_player_breeze.stream = generator
	audio_player_breeze.volume_db = -14.0
	add_child(audio_player_breeze)
	audio_player_breeze.play()
	playback_breeze = audio_player_breeze.get_stream_playback()

func _process(delta: float) -> void:
	breeze_time += delta
	# Variasi hembusan angin musim gugur
	var wind_gust = sin(breeze_time * 0.5) * 22.0

	if is_instance_valid(leaf_particles_mg):
		leaf_particles_mg.gravity.x = 35.0 + wind_gust
	if is_instance_valid(leaf_particles_fg):
		leaf_particles_fg.gravity.x = 45.0 + wind_gust * 1.6

	_synthesize_autumn_breeze(delta)

func _synthesize_autumn_breeze(delta: float) -> void:
	if playback_breeze == null:
		return

	var frames = min(playback_breeze.get_frames_available(), int(22050 * delta * 1.5))
	if frames <= 0:
		return

	for i in range(frames):
		breeze_time += 1.0 / 22050.0
		var gust = (0.5 + 0.5 * sin(breeze_time * 0.4)) * (0.7 + 0.3 * sin(breeze_time * 0.9))
		var noise = (randf() * 2.0 - 1.0)
		# Suara desau daun kering bergesek lembut
		var rustle = sin(breeze_time * 440.0 * TAU) * (randf() * 0.06)
		
		var sample = (noise * 0.10 + rustle) * gust * 0.12
		playback_breeze.push_frame(Vector2(sample, sample))
