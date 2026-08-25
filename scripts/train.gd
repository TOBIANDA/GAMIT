extends Node2D

const RAIL_CENTER_X: float = 2240.0
const TRAIN_SPEED: float = 620.0
const TRAIN_START_Y: float = -950.0
const TRAIN_END_Y: float = 2200.0

@export var spawn_interval: float = 15.0
var spawn_timer: float = 4.0
var is_train_running: bool = false
var train_y: float = TRAIN_START_Y

var audio_player_chug: AudioStreamPlayer
var playback_chug: AudioStreamGeneratorPlayback
var audio_player_horn: AudioStreamPlayer
var playback_horn: AudioStreamGeneratorPlayback
var audio_player_bell: AudioStreamPlayer
var playback_bell: AudioStreamGeneratorPlayback

var chug_phase: float = 0.0
var chug_tick_timer: float = 0.0
var horn_timer: float = 0.0
var is_horn_blowing: bool = false
var horn_sequence_step: int = 0
var horn_cooldown: float = 0.0
var bell_timer: float = 0.0

var smoke_particles: CPUParticles2D
var player_ref: CharacterBody2D

func _ready() -> void:
	z_index = 5
	position = Vector2(RAIL_CENTER_X, TRAIN_START_Y)
	_setup_audio_synthesizers()
	_setup_smoke_particles()

func _setup_smoke_particles() -> void:
	smoke_particles = CPUParticles2D.new()
	smoke_particles.position = Vector2(0, 80)
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

func _setup_audio_synthesizers() -> void:
	audio_player_chug = AudioStreamPlayer.new()
	var gen_chug = AudioStreamGenerator.new()
	gen_chug.mix_rate = 22050
	gen_chug.buffer_length = 0.15
	audio_player_chug.stream = gen_chug
	add_child(audio_player_chug)
	audio_player_chug.play()
	playback_chug = audio_player_chug.get_stream_playback()

	audio_player_horn = AudioStreamPlayer.new()
	var gen_horn = AudioStreamGenerator.new()
	gen_horn.mix_rate = 22050
	gen_horn.buffer_length = 0.15
	audio_player_horn.stream = gen_horn
	add_child(audio_player_horn)
	audio_player_horn.play()
	playback_horn = audio_player_horn.get_stream_playback()

	audio_player_bell = AudioStreamPlayer.new()
	var gen_bell = AudioStreamGenerator.new()
	gen_bell.mix_rate = 22050
	gen_bell.buffer_length = 0.15
	audio_player_bell.stream = gen_bell
	add_child(audio_player_bell)
	audio_player_bell.play()
	playback_bell = audio_player_bell.get_stream_playback()

func _process(delta: float) -> void:
	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player_ref):
			player_ref = get_node_or_null("../Player")

	var spatial_vol = 1.0
	if is_instance_valid(player_ref):
		var dist_to_track = abs(player_ref.global_position.x - RAIL_CENTER_X)
		spatial_vol = clampf(1.0 - (dist_to_track / 2000.0), 0.05, 1.0)
		spatial_vol = pow(spatial_vol, 1.5)

	if not is_train_running:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_start_passing_train()
	else:
		train_y += delta * TRAIN_SPEED
		position = Vector2(RAIL_CENTER_X, train_y)

		_handle_horn_and_bell(delta, spatial_vol)

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

func _handle_horn_and_bell(delta: float, spatial_vol: float) -> void:
	horn_cooldown -= delta

	if horn_sequence_step == 0 and train_y > -400.0 and horn_cooldown <= 0.0:
		_trigger_horn(1.4)
		horn_sequence_step = 1
		horn_cooldown = 1.9
	elif horn_sequence_step == 1 and horn_cooldown <= 0.0:
		_trigger_horn(1.2)
		horn_sequence_step = 2
		horn_cooldown = 2.5
	elif horn_sequence_step == 2 and train_y > 400.0 and train_y < 700.0 and horn_cooldown <= 0.0:
		_trigger_horn(0.8)
		horn_sequence_step = 3

	if is_horn_blowing:
		horn_timer -= delta
		_synthesize_train_horn(spatial_vol)
		if horn_timer <= 0.0:
			is_horn_blowing = false

	if train_y >= -200.0 and train_y <= 1100.0:
		bell_timer += delta
		if bell_timer >= 0.55:
			bell_timer = 0.0
			_synthesize_crossing_bell(spatial_vol)

func _trigger_horn(duration: float) -> void:
	is_horn_blowing = true
	horn_timer = duration

func _synthesize_track_rumble(delta: float, spatial_vol: float) -> void:
	if playback_chug == null:
		return

	var frames_to_push = min(playback_chug.get_frames_available(), int(22050 * delta * 1.5))
	if frames_to_push <= 0:
		return

	for i in range(frames_to_push):
		chug_phase += 1.0 / 22050.0
		var beat = fmod(chug_phase * 6.5, 1.0)
		var pulse = pow(sin(beat * PI), 8.0) * 0.45
		
		var rumble = sin(chug_phase * 65.0 * TAU) * 0.3 + sin(chug_phase * 130.0 * TAU) * 0.2
		var hiss = (randf() * 2.0 - 1.0) * 0.12

		var total_sample = (rumble + hiss + pulse) * 0.38 * spatial_vol
		playback_chug.push_frame(Vector2(total_sample, total_sample))

func _synthesize_train_horn(spatial_vol: float) -> void:
	if playback_horn == null:
		return

	var frames = playback_horn.get_frames_available()
	if frames <= 0:
		return

	for i in range(frames):
		chug_phase += 1.0 / 22050.0
		var t = chug_phase
		var f1 = sin(t * 392.0 * TAU) * 0.35
		var f2 = sin(t * 494.0 * TAU) * 0.30
		var f3 = sin(t * 587.0 * TAU) * 0.25
		var breath = (randf() * 2.0 - 1.0) * 0.08
		
		var sample = (f1 + f2 + f3 + breath) * 0.50 * spatial_vol
		playback_horn.push_frame(Vector2(sample, sample))

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

func _draw() -> void:
	if not is_train_running:
		return

	var tw = 88.0
	var htw = tw / 2.0

	var light_pts = PackedVector2Array([
		Vector2(-14, 180), Vector2(14, 180),
		Vector2(110, 680), Vector2(-110, 680)
	])
	draw_colored_polygon(light_pts, Color(1.0, 0.95, 0.6, 0.22))
	draw_circle(Vector2(0, 180), 22.0, Color(1.0, 1.0, 0.8, 0.75))

	_draw_locomotive(Vector2(-htw, 40), Vector2(tw, 140))

	_draw_coal_tender(Vector2(-htw + 4, -60), Vector2(tw - 8, 85))

	_draw_passenger_car(Vector2(-htw, -220), Vector2(tw, 145), Color(0.16, 0.28, 0.22), "1")

	_draw_passenger_car(Vector2(-htw, -380), Vector2(tw, 145), Color(0.24, 0.16, 0.20), "2")

	_draw_passenger_car(Vector2(-htw, -540), Vector2(tw, 145), Color(0.16, 0.28, 0.22), "3")

	_draw_caboose(Vector2(-htw + 2, -680), Vector2(tw - 4, 125))

func _draw_locomotive(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(4, 4), size), Color(0, 0, 0, 0.4), true)
	draw_rect(Rect2(pos, size), Color(0.12, 0.14, 0.18), true)
	draw_rect(Rect2(pos, size), Color(0.35, 0.40, 0.50), false, 2.5)

	var plow_pts = PackedVector2Array([
		Vector2(pos.x - 4, pos.y + size.y),
		Vector2(pos.x + size.x + 4, pos.y + size.y),
		Vector2(pos.x + size.x / 2.0, pos.y + size.y + 18)
	])
	draw_colored_polygon(plow_pts, Color(0.75, 0.15, 0.15))

	draw_line(Vector2(pos.x + 6, pos.y + 40), Vector2(pos.x + size.x - 6, pos.y + 40), Color(0.85, 0.70, 0.25), 2.5)
	draw_line(Vector2(pos.x + 6, pos.y + 90), Vector2(pos.x + size.x - 6, pos.y + 90), Color(0.85, 0.70, 0.25), 2.5)

	draw_rect(Rect2(pos.x + 12, pos.y + 15, size.x - 24, 22), Color(1.0, 0.85, 0.35, 0.95), true)
	draw_rect(Rect2(pos.x + 12, pos.y + 15, size.x - 24, 22), Color(0.1, 0.1, 0.1), false, 2.0)

	draw_rect(Rect2(pos.x + size.x / 2.0 - 10, pos.y + 70, 20, 24), Color(0.2, 0.22, 0.26), true)
	draw_circle(Vector2(pos.x + size.x / 2.0, pos.y + 82), 12.0, Color(0.85, 0.70, 0.25))

func _draw_coal_tender(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), size), Color(0, 0, 0, 0.35), true)
	draw_rect(Rect2(pos, size), Color(0.16, 0.18, 0.22), true)
	draw_rect(Rect2(pos, size), Color(0.28, 0.32, 0.38), false, 2.0)
	draw_rect(Rect2(pos.x + 6, pos.y + 8, size.x - 12, size.y - 16), Color(0.06, 0.06, 0.08), true)

func _draw_passenger_car(pos: Vector2, size: Vector2, color: Color, _num: String) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), size), Color(0, 0, 0, 0.35), true)
	draw_rect(Rect2(pos, size), color, true)
	draw_rect(Rect2(pos, size), Color(0.85, 0.70, 0.30, 0.8), false, 2.0)

	draw_rect(Rect2(pos.x + size.x / 2.0 - 8, pos.y - 12, 16, 14), Color(0.1, 0.1, 0.12), true)

	for i in range(4):
		var wy = pos.y + 18 + i * 30
		draw_rect(Rect2(pos.x + 8, wy, 22, 18), Color(1.0, 0.90, 0.50, 0.9), true)
		draw_rect(Rect2(pos.x + 8, wy, 22, 18), Color(0.1, 0.1, 0.1), false, 1.5)
		draw_rect(Rect2(pos.x + size.x - 30, wy, 22, 18), Color(1.0, 0.90, 0.50, 0.9), true)
		draw_rect(Rect2(pos.x + size.x - 30, wy, 22, 18), Color(0.1, 0.1, 0.1), false, 1.5)

func _draw_caboose(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(3, 3), size), Color(0, 0, 0, 0.35), true)
	draw_rect(Rect2(pos, size), Color(0.55, 0.14, 0.14), true)
	draw_rect(Rect2(pos, size), Color(0.85, 0.70, 0.30), false, 2.0)

	draw_rect(Rect2(pos.x + 14, pos.y + 35, size.x - 28, 35), Color(0.95, 0.85, 0.40, 0.9), true)

	var blink = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)
	draw_circle(Vector2(pos.x + size.x / 2.0, pos.y + 10), 9.0, Color(1.0, 0.2, 0.2, blink))
	draw_circle(Vector2(pos.x + size.x / 2.0, pos.y + 10), 4.0, Color(1.0, 0.9, 0.9, 1.0))
