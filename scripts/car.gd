extends CharacterBody2D

# ── Car System - Smart Top-Down Vehicle with Safety Brake & Passenger Drop-off ──
# Fitur:
# 1. 🚗 4 Tipe Kendaraan: Sedan Hitam, Taksi Kuning, Mobil Polisi, Sedan Merah.
# 2. 🛑 Sensor Pengereman Cerdas (Forward Anti-Collision):
#    - Otomatis mengerem berhenti jika ada MC Benedict atau NPC menyeberang jalan di depan mobil.
#    - Lampu rem belakang menyala merah saat berhenti & membunyikan klakson lembut.
# 3. 👥 Sistem Drop-off Penumpang:
#    - Menepi di trotoar (Stasiun / RS), menurunkan NPC baru, lalu melanjutkan perjalanan.
# 4. 💡 Lampu Sorot Depan (Headlights) & Audio Mesin Prosedural.

enum CarType { SEDAN_BLACK, TAXI, POLICE, SEDAN_RED }
@export var car_type: CarType = CarType.SEDAN_BLACK
@export var max_speed: float = 120.0
@export var acceleration: float = 180.0
@export var brake_deceleration: float = 320.0

var waypoints: Array[Vector2] = []
var current_waypoint_idx: int = 0
var current_speed: float = 0.0

var has_passenger: bool = false
var dropoff_waypoint_idx: int = -1
var is_dropping_off: bool = false
var dropoff_timer: float = 0.0

var is_braking: bool = false
var honk_cooldown: float = 0.0

var engine_sound_player: AudioStreamPlayer2D
var honk_sound_player: AudioStreamPlayer2D

var npc_scene = preload("res://scenes/npc.tscn")

func _ready() -> void:
	z_index = 0
	collision_layer = 8
	collision_mask = 0 # Mobil melaju di jalur terbuka jalan raya
	_setup_procedural_audio()
	queue_redraw()

func initialize_route(route_points: Array[Vector2], type: CarType, with_passenger: bool = false, drop_idx: int = -1) -> void:
	waypoints = route_points
	car_type = type
	has_passenger = with_passenger
	dropoff_waypoint_idx = drop_idx
	current_waypoint_idx = 0
	
	if waypoints.size() > 0:
		global_position = waypoints[0]
		if waypoints.size() > 1:
			rotation = (waypoints[1] - waypoints[0]).angle()

func _physics_process(delta: float) -> void:
	if waypoints.is_empty():
		return

	if honk_cooldown > 0.0:
		honk_cooldown -= delta

	# 1. Cek Rintangan di Depan Mobil (Sensor Keselamatan Anti-Tabrakan)
	var obstacle_ahead = _check_obstacle_ahead()

	# 2. Penanganan Drop-off Penumpang
	if is_dropping_off:
		_handle_dropoff_passenger(delta)
		return

	if obstacle_ahead:
		# Rem berhenti jika ada pejalan kaki/MC di depan
		is_braking = true
		current_speed = move_toward(current_speed, 0.0, brake_deceleration * delta)
		if honk_cooldown <= 0.0:
			_play_car_honk()
			honk_cooldown = 4.0
	else:
		is_braking = false
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)

	# 3. Navigasi Jalur Waypoint
	if current_waypoint_idx < waypoints.size():
		var target_pt = waypoints[current_waypoint_idx]
		var dist = global_position.distance_to(target_pt)

		# Cek apakah tiba di titik drop-off
		if has_passenger and current_waypoint_idx == dropoff_waypoint_idx and dist < 25.0:
			is_dropping_off = true
			dropoff_timer = 2.2
			current_speed = 0.0
			return

		if dist < 20.0:
			current_waypoint_idx += 1
			if current_waypoint_idx >= waypoints.size():
				# Selesai rute ➔ Keluar map
				queue_free()
				return

		var move_dir = (target_pt - global_position).normalized()
		var target_rot = move_dir.angle()
		rotation = rotate_toward(rotation, target_rot, delta * 4.0)

		velocity = Vector2.RIGHT.rotated(rotation) * current_speed
		move_and_slide()

	# Update pitch audio mesin sesuai kecepatan
	if is_instance_valid(engine_sound_player):
		engine_sound_player.pitch_scale = 0.8 + (current_speed / max_speed) * 0.4

	queue_redraw()

# ── Sensor Anti-Tabrakan (Forward Distance & Cone Check) ────────────────────
func _check_obstacle_ahead() -> bool:
	var forward_vec = Vector2.RIGHT.rotated(rotation)
	var front_check_origin = global_position + (forward_vec * 28.0)
	var check_dist = 68.0

	# 1. Cek MC Benedict
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		var to_player = player.global_position - front_check_origin
		if to_player.length() < check_dist:
			var dot = forward_vec.dot(to_player.normalized())
			if dot > 0.45:
				return true

	# 2. Cek Seluruh NPC Pejalan Kaki
	var npcs = get_tree().get_nodes_in_group("npcs")
	for npc in npcs:
		if is_instance_valid(npc):
			var to_npc = npc.global_position - front_check_origin
			if to_npc.length() < check_dist:
				var dot = forward_vec.dot(to_npc.normalized())
				if dot > 0.45:
					return true

	return false

# ── Drop-off Penumpang di Trotoar ───────────────────────────────────────────
func _handle_dropoff_passenger(delta: float) -> void:
	current_speed = 0.0
	velocity = Vector2.ZERO
	dropoff_timer -= delta

	if dropoff_timer <= 0.0:
		# Spawn NPC baru turun ke trotoar
		has_passenger = false
		is_dropping_off = false
		_spawn_passenger_npc()
		current_waypoint_idx += 1 # Lanjut perjalanan

func _spawn_passenger_npc() -> void:
	if not is_instance_valid(npc_scene):
		return

	var new_npc = npc_scene.instantiate()
	# Tentukan tipe NPC acak (Cowo atau Cewe)
	var random_type = 0 if randf() > 0.5 else 2 # NPCType.BOY or GIRL
	new_npc.npc_type = random_type
	
	# Tempatkan di sisi trotoar mobil
	var curb_offset = Vector2(0, 22.0).rotated(rotation)
	new_npc.global_position = global_position + curb_offset
	
	get_parent().add_child(new_npc)
	
	if new_npc.has_method("show_chat_bubble"):
		var greeting = "Terima kasih pak sopir!" if randf() > 0.5 else "Akhirnya sampai di stasiun."
		new_npc.show_chat_bubble(greeting, 2.5)

# ── Audio Mesin & Klakson Prosedural ─────────────────────────────────────────
func _setup_procedural_audio() -> void:
	# Mesin Mobil Loop
	engine_sound_player = AudioStreamPlayer2D.new()
	engine_sound_player.max_distance = 650.0
	engine_sound_player.volume_db = -12.0
	engine_sound_player.stream = _generate_engine_stream()
	add_child(engine_sound_player)
	engine_sound_player.play()

	# Klakson Mobil
	honk_sound_player = AudioStreamPlayer2D.new()
	honk_sound_player.max_distance = 800.0
	honk_sound_player.volume_db = -6.0
	add_child(honk_sound_player)

func _generate_engine_stream() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 1.0
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var val = sin(t * TAU * 55.0) * 0.4 + sin(t * TAU * 110.0) * 0.25
		val += (randf() - 0.5) * 0.1
		var byte_val = int(clampf(val * 127.0 + 128.0, 0, 255))
		data[i] = byte_val

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = num_samples
	wav.data = data
	return wav

func _play_car_honk() -> void:
	if not is_instance_valid(honk_sound_player):
		return

	var sample_rate = 22050
	var duration = 0.35
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples)

	for i in range(num_samples):
		var t = float(i) / sample_rate
		var env = 1.0 - (t / duration)
		var val = (sin(t * TAU * 440.0) * 0.5 + sin(t * TAU * 554.37) * 0.5) * env
		var byte_val = int(clampf(val * 127.0 + 128.0, 0, 255))
		data[i] = byte_val

	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	honk_sound_player.stream = wav
	honk_sound_player.play()

# ── Render Visual Mobil Top-Down Prosedural ──────────────────────────────────
func _draw() -> void:
	# 1. Bayangan Mobil
	draw_rect(Rect2(-24, -12, 48, 24), Color(0, 0, 0, 0.32), true)

	# 2. Body Utama Mobil Berdasarkan CarType
	var body_color: Color
	var roof_color: Color
	
	match car_type:
		CarType.SEDAN_BLACK:
			body_color = Color(0.14, 0.15, 0.17, 1.0)
			roof_color = Color(0.10, 0.11, 0.13, 1.0)
		CarType.TAXI:
			body_color = Color(0.94, 0.78, 0.18, 1.0)
			roof_color = Color(0.90, 0.72, 0.12, 1.0)
		CarType.POLICE:
			body_color = Color(0.12, 0.14, 0.18, 1.0)
			roof_color = Color(0.95, 0.95, 0.95, 1.0) # Atap putih
		CarType.SEDAN_RED:
			body_color = Color(0.68, 0.18, 0.20, 1.0)
			roof_color = Color(0.52, 0.12, 0.15, 1.0)

	# Bumper Chrome
	draw_rect(Rect2(20, -11, 4, 22), Color(0.75, 0.78, 0.82), true)
	draw_rect(Rect2(-24, -11, 4, 22), Color(0.75, 0.78, 0.82), true)

	# Body Mobil
	draw_rect(Rect2(-22, -11, 44, 22), body_color, true)
	draw_rect(Rect2(-22, -11, 44, 22), Color(0.08, 0.08, 0.10), false, 1.5)

	# Kaca Depan & Belakang (Windshield)
	draw_rect(Rect2(6, -9, 7, 18), Color(0.35, 0.55, 0.75, 0.85), true)
	draw_rect(Rect2(-13, -9, 6, 18), Color(0.35, 0.55, 0.75, 0.85), true)

	# Atap Mobil (Roof)
	draw_rect(Rect2(-7, -9, 13, 18), roof_color, true)

	# Polisi: Sirine Lampu Merah & Biru
	if car_type == CarType.POLICE:
		var siren_pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.015)
		draw_rect(Rect2(-3, -7, 6, 6), Color(0.9, 0.15, 0.15, 0.85 + siren_pulse * 0.15), true)
		draw_rect(Rect2(-3, 1, 6, 6), Color(0.15, 0.45, 0.95, 0.85 + (1.0 - siren_pulse) * 0.15), true)

	# Taksi: Plang TAXI Kuning
	if car_type == CarType.TAXI:
		draw_rect(Rect2(-2, -5, 4, 10), Color(0.98, 0.98, 0.98), true)
		draw_rect(Rect2(-2, -5, 4, 10), Color(0.1, 0.1, 0.1), false, 1.0)

	# Lampu Belakang (Brake Lights)
	var brake_color = Color(1.0, 0.1, 0.1, 0.95) if is_braking else Color(0.5, 0.1, 0.1, 0.6)
	draw_rect(Rect2(-22, -10, 2, 5), brake_color, true)
	draw_rect(Rect2(-22, 5, 2, 5), brake_color, true)

	# Lampu Sorot Depan (Headlights)
	draw_rect(Rect2(21, -10, 2, 5), Color(1.0, 0.95, 0.6, 0.95), true)
	draw_rect(Rect2(21, 5, 2, 5), Color(1.0, 0.95, 0.6, 0.95), true)

	# Kerucut Cahaya Lampu Depan (Headlight Beam)
	var light_pts = PackedVector2Array([
		Vector2(22, -10), Vector2(90, -32),
		Vector2(90, 32), Vector2(22, 10)
	])
	draw_colored_polygon(light_pts, Color(1.0, 0.98, 0.70, 0.12))
