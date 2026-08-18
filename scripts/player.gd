extends CharacterBody2D

# ── Konfigurasi Pergerakan ──────────────────────────────────────────────────
@export var max_speed: float = 320.0
@export var acceleration: float = 2400.0
@export var friction: float = 2800.0

# ── Variabel Visual & Animasi ───────────────────────────────────────────────
var facing_direction: Vector2 = Vector2.DOWN
var anim_timer: float = 0.0
var visual_scale: Vector2 = Vector2.ONE

# ── Node References ────────────────────────────────────────────────────────
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	# Pastikan queue redraw berjalan jika menggunakan draw
	queue_redraw()

func _physics_process(delta: float) -> void:
	# 1. Dapatkan arah input (WASD + Arrow Keys + Gamepad / UI Actions)
	var input_vector = _get_input_vector()

	# 2. Update kecepatan dengan akselerasi & friksi (smooth feel)
	if input_vector != Vector2.ZERO:
		facing_direction = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		
		# Animasi procedural jalan (bobbing / squash-stretch)
		anim_timer += delta * 12.0
		var squash = sin(anim_timer) * 0.08
		visual_scale = Vector2(1.0 + squash, 1.0 - squash)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		# Kembali ke bentuk normal saat berhenti
		visual_scale = visual_scale.move_toward(Vector2.ONE, delta * 10.0)
		anim_timer = 0.0

	# 3. Eksekusi pergerakan fisika dengan tabrakan (Collision)
	move_and_slide()

	# 4. Trigger gambar ulang untuk efek rotasi arah hadap & bobbing
	queue_redraw()

func _get_input_vector() -> Vector2:
	var dir = Vector2.ZERO

	# Dukung WASD langsung dan tombol panah
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
	# Bayangan bawah karakter
	draw_circle(Vector2(0, 16), 18, Color(0, 0, 0, 0.25))

	# Tubuh Karakter Utama (Lingkaran bernuansa cyan/teal modern)
	var body_color = Color(0.2, 0.7, 0.9, 1.0)
	var border_color = Color(0.08, 0.35, 0.5, 1.0)
	
	# Gambar tubuh dengan skala animasi bobbing
	draw_set_transform(Vector2.ZERO, 0.0, visual_scale)
	draw_circle(Vector2.ZERO, 20.0, body_color)
	draw_arc(Vector2.ZERO, 20.0, 0, TAU, 32, border_color, 2.5, true)

	# Indikator Arah Hadap (Mata / Pointer)
	var eye_offset = facing_direction * 9.0
	var eye_perp = Vector2(-facing_direction.y, facing_direction.x) * 6.0
	
	# Gambar dua titik mata
	draw_circle(eye_offset + eye_perp, 3.5, Color.WHITE)
	draw_circle(eye_offset + eye_perp + facing_direction * 1.5, 1.8, Color(0.05, 0.1, 0.2))
	
	draw_circle(eye_offset - eye_perp, 3.5, Color.WHITE)
	draw_circle(eye_offset - eye_perp + facing_direction * 1.5, 1.8, Color(0.05, 0.1, 0.2))

	# Reset transform
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
