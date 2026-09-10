extends CharacterBody2D

signal player_entered(car: CharacterBody2D)
signal player_exited(car: CharacterBody2D)

@export var car_color: Color = Color(0.20, 0.45, 0.85)
@export var is_taxi: bool = false
@export var car_name: String = "Mobil Sedan"

var is_being_driven: bool = false
var player_ref: CharacterBody2D = null
var current_speed: float = 0.0
var car_heading: float = 0.0 # radians (0 = menghadap kanan, PI/2 = bawah, PI = kiri, -PI/2 = atas)

var max_forward_speed: float = 460.0
var max_reverse_speed: float = 190.0
var acceleration: float = 1250.0
var brake_decel: float = 1800.0
var friction: float = 700.0
var steer_speed: float = 14.0

var is_player_nearby: bool = false
var is_braking: bool = false

# Audio Synthesizer
var audio_player_engine: AudioStreamPlayer
var playback_engine: AudioStreamGeneratorPlayback
var audio_player_horn: AudioStreamPlayer
var playback_horn: AudioStreamGeneratorPlayback

var engine_phase: float = 0.0
var horn_timer: float = 0.0
var is_honking: bool = false

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	collision_layer = 1
	collision_mask = 1
	_setup_audio()
	
	if is_instance_valid(interaction_area):
		interaction_area.body_entered.connect(_on_interaction_body_entered)
		interaction_area.body_exited.connect(_on_interaction_body_exited)

func _setup_audio() -> void:
	audio_player_engine = AudioStreamPlayer.new()
	var gen_engine = AudioStreamGenerator.new()
	gen_engine.mix_rate = 22050
	gen_engine.buffer_length = 0.15
	audio_player_engine.stream = gen_engine
	add_child(audio_player_engine)

	audio_player_horn = AudioStreamPlayer.new()
	var gen_horn = AudioStreamGenerator.new()
	gen_horn.mix_rate = 22050
	gen_horn.buffer_length = 0.15
	audio_player_horn.stream = gen_horn
	add_child(audio_player_horn)

func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		player_ref = body as CharacterBody2D
		queue_redraw()

func _on_interaction_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not is_being_driven:
		is_player_nearby = false
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_E:
			if is_being_driven:
				_exit_car()
				get_viewport().set_input_as_handled()
			elif is_player_nearby and is_instance_valid(player_ref):
				_enter_car()
				get_viewport().set_input_as_handled()
		elif is_being_driven and (event.keycode == KEY_H or event.keycode == KEY_SPACE):
			_trigger_horn(0.4)
			get_viewport().set_input_as_handled()

func _enter_car() -> void:
	if not is_instance_valid(player_ref):
		return
	is_being_driven = true
	is_player_nearby = false
	player_ref.visible = false
	player_ref.can_move = false
	player_ref.collision_layer = 0
	player_ref.collision_mask = 0
	current_speed = 0.0
	if is_instance_valid(audio_player_engine):
		if not audio_player_engine.playing:
			audio_player_engine.play()
		playback_engine = audio_player_engine.get_stream_playback()
	emit_signal("player_entered", self)
	print("[CarSystem] 🚗 Pemain masuk ke dalam mobil: ", car_name)
	queue_redraw()

func _exit_car() -> void:
	if not is_instance_valid(player_ref):
		return
	is_being_driven = false
	current_speed = 0.0
	if is_instance_valid(audio_player_engine) and audio_player_engine.playing:
		audio_player_engine.stop()
	
	# Tempatkan pemain di samping pintu pengemudi (kiri mobil)
	var left_normal = Vector2(-sin(car_heading), cos(car_heading))
	var exit_pos = global_position + left_normal * 28.0
	
	player_ref.global_position = exit_pos
	player_ref.visible = true
	player_ref.can_move = true
	player_ref.collision_layer = 2
	player_ref.collision_mask = 1
	emit_signal("player_exited", self)
	print("[CarSystem] 🚶 Pemain keluar dari mobil.")
	queue_redraw()

func _physics_process(delta: float) -> void:
	if is_being_driven:
		_process_driving(delta)
		# Sinkronkan posisi player agar kamera dan audio listener tetap fokus di mobil
		if is_instance_valid(player_ref):
			player_ref.global_position = global_position
		_synthesize_engine_sound(delta)
		_handle_horn(delta)
	else:
		if abs(current_speed) > 1.0:
			current_speed = move_toward(current_speed, 0.0, friction * delta)
			velocity = Vector2(cos(car_heading), sin(car_heading)) * current_speed
			move_and_slide()
		else:
			current_speed = 0.0
			velocity = Vector2.ZERO

	queue_redraw()

func _process_driving(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input_vector.x += 1.0

	is_braking = false

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		var target_heading = input_vector.angle()
		
		# Hitung selisih sudut untuk pengereman tajam saat berbalik arah
		var angle_diff = abs(angle_difference(car_heading, target_heading))
		
		# Putar arah moncong mobil langsung ke arah tombol yang ditekan (W=Atas, S=Bawah, A=Kiri, D=Kanan)
		car_heading = rotate_toward(car_heading, target_heading, steer_speed * delta)
		rotation = car_heading
		
		# Jika membalik arah tajam (> 110 derajat), aktifkan efek rem/drift sebelum melaju kencang
		if angle_diff > 2.0 and current_speed > 80.0:
			is_braking = true
			current_speed = move_toward(current_speed, 50.0, brake_decel * delta)
		else:
			current_speed = move_toward(current_speed, max_forward_speed, acceleration * delta)
	else:
		# Tanpa input: mobil meluncur melambat dengan gesekan
		current_speed = move_toward(current_speed, 0.0, friction * delta)

	velocity = Vector2(cos(car_heading), sin(car_heading)) * current_speed
	move_and_slide()

func _trigger_horn(duration: float) -> void:
	is_honking = true
	horn_timer = duration
	if is_instance_valid(audio_player_horn):
		if not audio_player_horn.playing:
			audio_player_horn.play()
		playback_horn = audio_player_horn.get_stream_playback()

func _handle_horn(delta: float) -> void:
	if is_honking:
		horn_timer -= delta
		_synthesize_horn_sound()
		if horn_timer <= 0.0:
			is_honking = false
			if is_instance_valid(audio_player_horn) and audio_player_horn.playing:
				audio_player_horn.stop()

func _synthesize_engine_sound(delta: float) -> void:
	if not is_being_driven or playback_engine == null:
		return
	var frames = min(playback_engine.get_frames_available(), int(22050 * delta * 1.5))
	if frames <= 0:
		return

	var speed_ratio = clampf(abs(current_speed) / max_forward_speed, 0.0, 1.0)
	var base_freq = 50.0 + speed_ratio * 120.0 # Nada mesin naik seiring kecepatan
	var vol = 0.16 + speed_ratio * 0.16

	for i in range(frames):
		engine_phase += 1.0 / 22050.0
		var r1 = sin(engine_phase * base_freq * TAU) * 0.50
		var r2 = sin(engine_phase * base_freq * 2.0 * TAU) * 0.30
		var r3 = sin(engine_phase * base_freq * 3.0 * TAU) * 0.12
		var sample = (r1 + r2 + r3) * vol
		playback_engine.push_frame(Vector2(sample, sample))

func _synthesize_horn_sound() -> void:
	if playback_horn == null:
		return
	var frames = playback_horn.get_frames_available()
	if frames <= 0:
		return
	for i in range(frames):
		engine_phase += 1.0 / 22050.0
		var f1 = sin(engine_phase * 440.0 * TAU) * 0.35
		var f2 = sin(engine_phase * 554.37 * TAU) * 0.30
		var sample = (f1 + f2) * 0.45
		playback_horn.push_frame(Vector2(sample, sample))

func _draw() -> void:
	var cw := 46.0 # Panjang bodi mobil
	var ch := 24.0 # Lebar bodi mobil
	var hx := -cw * 0.5
	var hy := -ch * 0.5

	# 1. Sorot Lampu Depan (Headlight Beams saat dikendarai)
	if is_being_driven:
		var beam_len := 160.0
		var beam_w := 60.0
		var beam_pts = PackedVector2Array([
			Vector2(hx + cw, hy + 4),
			Vector2(hx + cw + beam_len, hy - beam_w * 0.5),
			Vector2(hx + cw + beam_len, hy + ch + beam_w * 0.5),
			Vector2(hx + cw, hy + ch - 4)
		])
		draw_colored_polygon(beam_pts, Color(1.0, 0.98, 0.70, 0.20))

	# 2. Bayangan Jatuh Mobil
	draw_rect(Rect2(hx - 2, hy + 3, cw + 4, ch + 2), Color(0.06, 0.07, 0.10, 0.38), true)

	# 3. Empat Roda Ban Hitam
	draw_rect(Rect2(hx + 7, hy - 3, 10, 4), Color(0.1, 0.1, 0.1), true)
	draw_rect(Rect2(hx + cw - 17, hy - 3, 10, 4), Color(0.1, 0.1, 0.1), true)
	draw_rect(Rect2(hx + 7, hy + ch - 1, 10, 4), Color(0.1, 0.1, 0.1), true)
	draw_rect(Rect2(hx + cw - 17, hy + ch - 1, 10, 4), Color(0.1, 0.1, 0.1), true)

	# 4. Bodi Utama Mobil (Chassis)
	draw_rect(Rect2(hx, hy, cw, ch), car_color, true)
	draw_rect(Rect2(hx, hy, cw, ch), car_color.darkened(0.40), false, 1.5)

	# 5. Kaca Depan (Windshield - Menghadap Kanan)
	draw_rect(Rect2(hx + 28, hy + 3, 7, ch - 6), Color(0.14, 0.18, 0.24), true)
	draw_line(Vector2(hx + 30, hy + 5), Vector2(hx + 33, hy + ch - 6), Color(0.80, 0.92, 1.0, 0.75), 1.2)

	# 6. Kaca Belakang (Rear Window)
	draw_rect(Rect2(hx + 9, hy + 3, 6, ch - 6), Color(0.14, 0.18, 0.24), true)

	# 7. Kaca Samping Kiri & Kanan
	draw_rect(Rect2(hx + 15, hy + 2, 13, 3), Color(0.14, 0.18, 0.24), true)
	draw_rect(Rect2(hx + 15, hy + ch - 5, 13, 3), Color(0.14, 0.18, 0.24), true)

	# 8. Atap Mobil (Roof)
	draw_rect(Rect2(hx + 15, hy + 4, 13, ch - 8), car_color.darkened(0.18), true)

	# 9. Lampu Depan Kuning/Putih
	draw_rect(Rect2(hx + cw - 2, hy + 2, 2, 5), Color(0.98, 0.95, 0.60), true)
	draw_rect(Rect2(hx + cw - 2, hy + ch - 7, 2, 5), Color(0.98, 0.95, 0.60), true)

	# 10. Lampu Belakang (Merah - Menyala Terang saat Pengereman)
	var brake_color = Color(1.0, 0.15, 0.15) if (is_braking or current_speed < -1.0) else Color(0.65, 0.10, 0.10)
	draw_rect(Rect2(hx, hy + 2, 2, 5), brake_color, true)
	draw_rect(Rect2(hx, hy + ch - 7, 2, 5), brake_color, true)

	# 11. Spion Luar Kiri & Kanan
	draw_rect(Rect2(hx + 28, hy - 3, 3, 3), car_color.darkened(0.30), true)
	draw_rect(Rect2(hx + 28, hy + ch, 3, 3), car_color.darkened(0.30), true)

	# 12. Plang Topi Taksi (Jika Taksi)
	if is_taxi:
		draw_rect(Rect2(hx + 18, hy + 8, 8, 8), Color(0.98, 0.92, 0.20), true)
		draw_rect(Rect2(hx + 18, hy + 8, 8, 8), Color(0.1, 0.1, 0.1), false, 1.0)
		draw_line(Vector2(hx + 20, hy + 12), Vector2(hx + 24, hy + 12), Color(0.1, 0.1, 0.1), 1.5)

	# 13. Floating Interaction Tooltip (Selalu tegak terhadap layar)
	if is_player_nearby and not is_being_driven:
		draw_set_transform(Vector2.ZERO, -rotation, Vector2.ONE)
		_draw_tooltip_badge(Vector2(0, -28), "[E] Kendarai " + car_name)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	elif is_being_driven:
		draw_set_transform(Vector2.ZERO, -rotation, Vector2.ONE)
		_draw_tooltip_badge(Vector2(0, -32), "[WASD] Kemudi  •  [E] Keluar  •  [H] Klakson")
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_tooltip_badge(pos: Vector2, text: String) -> void:
	var font = ThemeDB.fallback_font
	var font_size = 10
	var str_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var pad = Vector2(8, 4)
	var bg_rect = Rect2(pos.x - str_size.x * 0.5 - pad.x, pos.y - str_size.y * 0.5 - pad.y, str_size.x + pad.x * 2.0, str_size.y + pad.y * 2.0)
	draw_rect(bg_rect, Color(0.06, 0.08, 0.12, 0.88), true)
	draw_rect(bg_rect, Color(0.35, 0.65, 0.95, 0.80), false, 1.5)
	draw_string(font, Vector2(pos.x - str_size.x * 0.5, pos.y + font_size * 0.35), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.95, 0.95, 0.95))
