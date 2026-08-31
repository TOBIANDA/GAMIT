extends Node2D

const RAIL_CENTER_X: float = 2240.0
const TRAIN_MAX_SPEED: float = 620.0
const TRAIN_START_Y: float = -950.0
const STATION_STOP_Y: float = 1150.0 # Posisi lokomotif berhenti pas di sepanjang peron stasiun
const TRAIN_END_Y: float = 2200.0
const STATION_STOP_DURATION: float = 5.5 # Berhenti 5.5 detik di stasiun

enum TrainState {
	INACTIVE,
	APPROACHING,
	DECELERATING,
	STOPPED_AT_STATION,
	ACCELERATING,
	RUNNING_FAST
}

@export var spawn_interval: float = 16.0
var spawn_timer: float = 4.0
var is_train_running: bool = false
var train_y: float = TRAIN_START_Y
var current_speed: float = TRAIN_MAX_SPEED
var train_state: TrainState = TrainState.INACTIVE
var station_wait_timer: float = 0.0
var accel_timer: float = 0.0
var has_blown_departure_whistle: bool = false

var audio_player_train: AudioStreamPlayer
var audio_player_horn: AudioStreamPlayer

var horn_sequence_step: int = 0
var horn_cooldown: float = 0.0

var smoke_particles: CPUParticles2D
var player_ref: CharacterBody2D

func _ready() -> void:
	z_index = 5
	position = Vector2(RAIL_CENTER_X, TRAIN_START_Y)
	_setup_audio_players()
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

func _get_sound_resource(filename: String) -> AudioStream:
	var paths = [
		"res://sound/" + filename,
		"res://audio/" + filename,
		"res://sound/" + filename.to_lower(),
		"res://audio/" + filename.to_lower()
	]
	for p in paths:
		if ResourceLoader.exists(p):
			return load(p) as AudioStream
	return null

func _setup_audio_players() -> void:
	# 1. Suara Rel & Mesin Kereta Berjalan Asli (TRAIN.mp3)
	audio_player_train = AudioStreamPlayer.new()
	audio_player_train.name = "TrainSoundPlayer"
	var train_stream = _get_sound_resource("TRAIN.mp3")
	if train_stream:
		audio_player_train.stream = train_stream
		audio_player_train.volume_db = -4.0
		audio_player_train.finished.connect(func():
			if is_train_running and is_instance_valid(audio_player_train):
				audio_player_train.play()
		)
	add_child(audio_player_train)

	# 2. Suara Klakson / Peluit Kereta Api Asli (Train Horn.mp3)
	audio_player_horn = AudioStreamPlayer.new()
	audio_player_horn.name = "TrainHornPlayer"
	var horn_stream = _get_sound_resource("Train Horn.mp3")
	if horn_stream:
		audio_player_horn.stream = horn_stream
		audio_player_horn.volume_db = 0.0
	add_child(audio_player_horn)

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
		_update_train_movement(delta)
		position = Vector2(RAIL_CENTER_X, train_y)

		_handle_horn_and_bell(delta, spatial_vol)
		_update_train_sound(spatial_vol)

		if train_y >= TRAIN_END_Y:
			_end_passing_train()

		queue_redraw()

func _update_train_movement(delta: float) -> void:
	match train_state:
		TrainState.APPROACHING:
			current_speed = TRAIN_MAX_SPEED
			train_y += delta * current_speed
			# Mulai melambat ketika mendekati stasiun (y >= 250)
			if train_y >= 250.0:
				train_state = TrainState.DECELERATING

		TrainState.DECELERATING:
			# Deselerasi halus menuju titik berhenti peron (STATION_STOP_Y)
			var dist_remaining := maxf(0.0, STATION_STOP_Y - train_y)
			var decel_ratio := clampf(dist_remaining / (STATION_STOP_Y - 250.0), 0.0, 1.0)
			current_speed = clampf(sqrt(decel_ratio) * TRAIN_MAX_SPEED, 30.0, TRAIN_MAX_SPEED)
			train_y += delta * current_speed

			if train_y >= STATION_STOP_Y - 3.0:
				train_y = STATION_STOP_Y
				current_speed = 0.0
				train_state = TrainState.STOPPED_AT_STATION
				station_wait_timer = STATION_STOP_DURATION
				has_blown_departure_whistle = false
				if is_instance_valid(smoke_particles):
					smoke_particles.initial_velocity_min = 10.0
					smoke_particles.initial_velocity_max = 25.0
					smoke_particles.gravity = Vector2(0, -25)
				print("[TrainSystem] 🛑 Kereta api berhenti di stasiun untuk naik-turun penumpang!")

		TrainState.STOPPED_AT_STATION:
			current_speed = 0.0
			station_wait_timer -= delta

			# Bunyikan peluit stasiun 1.5 detik sebelum berangkat
			if station_wait_timer <= 1.5 and not has_blown_departure_whistle:
				has_blown_departure_whistle = true
				_trigger_horn()

			if station_wait_timer <= 0.0:
				train_state = TrainState.ACCELERATING
				accel_timer = 0.0
				if is_instance_valid(smoke_particles):
					smoke_particles.initial_velocity_min = 30.0
					smoke_particles.initial_velocity_max = 70.0
					smoke_particles.gravity = Vector2(0, -60)
				print("[TrainSystem] 🟢 Kereta api berangkat melanjutkan perjalanan!")

		TrainState.ACCELERATING:
			# Akselerasi halus dari berhenti menuju kecepatan penuh
			accel_timer += delta * 0.45
			current_speed = lerpf(0.0, TRAIN_MAX_SPEED, clampf(accel_timer, 0.0, 1.0))
			train_y += delta * current_speed
			if accel_timer >= 1.0:
				current_speed = TRAIN_MAX_SPEED
				train_state = TrainState.RUNNING_FAST

		TrainState.RUNNING_FAST:
			current_speed = TRAIN_MAX_SPEED
			train_y += delta * current_speed

func _start_passing_train() -> void:
	is_train_running = true
	train_state = TrainState.APPROACHING
	current_speed = TRAIN_MAX_SPEED
	train_y = TRAIN_START_Y
	position = Vector2(RAIL_CENTER_X, train_y)
	if is_instance_valid(smoke_particles):
		smoke_particles.emitting = true
		smoke_particles.initial_velocity_min = 30.0
		smoke_particles.initial_velocity_max = 70.0
		smoke_particles.gravity = Vector2(0, -60)
	horn_sequence_step = 0
	horn_cooldown = 0.5
	if is_instance_valid(audio_player_train) and not audio_player_train.playing:
		audio_player_train.play()
	print("[TrainSystem] 🚂 Kereta api mulai melintas mendekati stasiun!")

func _end_passing_train() -> void:
	is_train_running = false
	train_state = TrainState.INACTIVE
	train_y = TRAIN_START_Y
	position = Vector2(RAIL_CENTER_X, train_y)
	if is_instance_valid(smoke_particles):
		smoke_particles.emitting = false
	if is_instance_valid(audio_player_train) and audio_player_train.playing:
		audio_player_train.stop()
	spawn_timer = randf_range(spawn_interval * 0.8, spawn_interval * 1.3)
	queue_redraw()

func _handle_horn_and_bell(delta: float, spatial_vol: float) -> void:
	horn_cooldown -= delta

	# Klakson saat mendekati stasiun
	if horn_sequence_step == 0 and train_y > -400.0 and horn_cooldown <= 0.0:
		_trigger_horn(spatial_vol)
		horn_sequence_step = 1
		horn_cooldown = 2.2
	elif horn_sequence_step == 1 and horn_cooldown <= 0.0 and train_y < 200.0:
		_trigger_horn(spatial_vol)
		horn_sequence_step = 2
		horn_cooldown = 3.0

func _trigger_horn(spatial_vol: float = 1.0) -> void:
	if is_instance_valid(audio_player_horn):
		audio_player_horn.volume_db = linear_to_db(clampf(spatial_vol * 1.2, 0.05, 1.0))
		audio_player_horn.play()

func _update_train_sound(spatial_vol: float) -> void:
	if not is_instance_valid(audio_player_train):
		return
	if is_train_running:
		if not audio_player_train.playing:
			audio_player_train.play()
		var speed_ratio := clampf(current_speed / TRAIN_MAX_SPEED, 0.3, 1.0)
		audio_player_train.pitch_scale = lerpf(0.85, 1.10, speed_ratio)
		audio_player_train.volume_db = linear_to_db(clampf(spatial_vol * speed_ratio, 0.05, 1.0))
	else:
		if audio_player_train.playing:
			audio_player_train.stop()

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
