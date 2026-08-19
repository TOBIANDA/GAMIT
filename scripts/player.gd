extends CharacterBody2D

# ── Konfigurasi Pergerakan 3/4 Top-Down ─────────────────────────────────────
@export var max_speed: float = 300.0
@export var acceleration: float = 2200.0
@export var friction: float = 2600.0
@export var can_move: bool = true

# ── Variabel Visual & Animasi 3/4 ──────────────────────────────────────────
var facing_direction: Vector2 = Vector2.DOWN
var step_cycle: float = 0.0
var is_moving: bool = false
var body_bob_y: float = 0.0

# ── Node References ────────────────────────────────────────────────────────
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("player")
	# Y-Sorting aktif agar urutan rendering diatur oleh posisi sumbu Y
	y_sort_enabled = true
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = false
		body_bob_y = move_toward(body_bob_y, 0.0, delta * 15.0)
		move_and_slide()
		queue_redraw()
		return

	# 1. Dapatkan arah input 8-arah
	var input_vector = _get_input_vector()

	# 2. Update kecepatan & pergerakan
	if input_vector != Vector2.ZERO:
		is_moving = true
		facing_direction = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		
		# Siklus animasi langkah kaki & bobbing tubuh
		step_cycle += delta * 14.0
		body_bob_y = abs(sin(step_cycle)) * -3.5
	else:
		is_moving = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		body_bob_y = move_toward(body_bob_y, 0.0, delta * 15.0)
		step_cycle = 0.0

	# 3. Fisika pergerakan dan tabrakan
	move_and_slide()

	# 4. Trigger redraw untuk rendering 3/4
	queue_redraw()

func _get_input_vector() -> Vector2:
	var dir = Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		dir.y += 1.0

	return dir.normalized()

func _draw() -> void:
	# 1. Bayangan di lantai (Ground Shadow Oval)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 8), 16.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Kaki Pemain (Animasi melangkah kiri & kanan)
	var foot_offset_l = Vector2(-7, 2)
	var foot_offset_r = Vector2(7, 2)
	if is_moving:
		var step_swing = sin(step_cycle) * 4.0
		foot_offset_l.y += step_swing
		foot_offset_r.y -= step_swing

	var shoe_color = Color(0.12, 0.15, 0.22)
	draw_circle(foot_offset_l, 4.0, shoe_color)
	draw_circle(foot_offset_r, 4.0, shoe_color)

	# 3. Tubuh / Jubah (Torso dengan ketinggian vertikal 3/4)
	var torso_pos = Vector2(0, -12 + body_bob_y)
	var body_color = Color(0.18, 0.65, 0.85) # Cyan teal modern
	var body_shadow_color = Color(0.1, 0.4, 0.55) # Bayangan sisi tubuh
	
	# Gambar mantel/badan
	draw_rect(Rect2(torso_pos.x - 11, torso_pos.y - 6, 22, 16), body_color, true, 5.0)
	draw_rect(Rect2(torso_pos.x - 11, torso_pos.y + 4, 22, 6), body_shadow_color, true, 3.0)

	# Sabuk / Ikat pinggang
	draw_rect(Rect2(torso_pos.x - 9, torso_pos.y + 1, 18, 3), Color(0.1, 0.12, 0.18))
	draw_rect(Rect2(torso_pos.x - 2, torso_pos.y, 4, 5), Color(0.9, 0.75, 0.2)) # Gesper emas

	# 4. Kepala (Head dengan ketinggian 3/4)
	var head_pos = Vector2(0, -28 + body_bob_y)
	var skin_color = Color(0.96, 0.82, 0.72)
	var hair_color = Color(0.15, 0.18, 0.28) # Rambut gelap stylish

	# Bayangan leher
	draw_circle(head_pos + Vector2(0, 7), 6.0, Color(0.8, 0.65, 0.55))

	# Bentuk Kepala Utama
	draw_circle(head_pos, 12.0, skin_color)

	# 5. Rambut dan Arah Hadap Wajah (8 Arah)
	var is_facing_up = facing_direction.y < -0.4
	var is_facing_down = facing_direction.y > 0.4
	var is_facing_left = facing_direction.x < -0.3
	var is_facing_right = facing_direction.x > 0.3

	if is_facing_up:
		# Tampak Belakang: Rambut menutupi seluruh kepala bagian atas dan belakang
		draw_circle(head_pos + Vector2(0, -3), 12.0, hair_color)
		draw_circle(head_pos + Vector2(0, 3), 10.0, hair_color)
	else:
		# Tampak Depan / Samping: Rambut bagian atas + Wajah & Mata
		draw_circle(head_pos + Vector2(0, -5), 12.0, hair_color)

		# Posisi mata sesuai arah hadap
		var eye_center = head_pos + Vector2(facing_direction.x * 4.0, 1.0)
		var eye_dist = 4.5

		if is_facing_left and not is_facing_down:
			# Hadap Samping Kiri
			draw_circle(eye_center + Vector2(-2, 0), 2.5, Color.WHITE)
			draw_circle(eye_center + Vector2(-3, 0), 1.3, Color(0.08, 0.12, 0.2))
		elif is_facing_right and not is_facing_down:
			# Hadap Samping Kanan
			draw_circle(eye_center + Vector2(2, 0), 2.5, Color.WHITE)
			draw_circle(eye_center + Vector2(3, 0), 1.3, Color(0.08, 0.12, 0.2))
		else:
			# Hadap Depan / 3/4 Bawah
			# Mata Kiri
			draw_circle(eye_center + Vector2(-eye_dist, 0), 2.5, Color.WHITE)
			draw_circle(eye_center + Vector2(-eye_dist + facing_direction.x * 0.8, facing_direction.y * 0.8), 1.4, Color(0.08, 0.12, 0.2))
			# Mata Kanan
			draw_circle(eye_center + Vector2(eye_dist, 0), 2.5, Color.WHITE)
			draw_circle(eye_center + Vector2(eye_dist + facing_direction.x * 0.8, facing_direction.y * 0.8), 1.4, Color(0.08, 0.12, 0.2))
