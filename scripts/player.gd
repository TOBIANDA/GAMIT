extends CharacterBody2D

# ── Konfigurasi Pergerakan 3/4 Top-Down ─────────────────────────────────────
@export var max_speed: float = 195.0       # Kecepatan jalan diperlambat agar pas dengan suasana investigasi
@export var acceleration: float = 1600.0   # Akselerasi yang lebih halus
@export var friction: float = 1800.0       # Gesekan menghentikan pergerakan
@export var can_move: bool = true
@export var sprite_scale: float = 0.14  # Skala diperkecil 20% lagi agar lebih proporsional

# ── Variabel Visual & Animasi 3/4 ──────────────────────────────────────────
var facing_direction: Vector2 = Vector2.DOWN
var step_cycle: float = 0.0
var is_moving: bool = false

# ── Textures Sprite MC (dari folder 'posisi mc') ────────────────────────────
var tex_front: Texture2D
var tex_front_l: Texture2D
var tex_front_r: Texture2D

var tex_back: Texture2D
var tex_back_l: Texture2D
var tex_back_r: Texture2D

var tex_left: Texture2D
var tex_left_l: Texture2D
var tex_left_r: Texture2D

var tex_right: Texture2D
var tex_right_l: Texture2D
var tex_right_r: Texture2D

# ── Node References ────────────────────────────────────────────────────────
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("player")
	y_sort_enabled = true

	# Load 12 sprite textures dari folder 'posisi mc'
	_load_mc_sprites()
	queue_redraw()

func _load_mc_sprites() -> void:
	tex_front   = load("res://posisi mc/front.png")
	tex_front_l = load("res://posisi mc/front_left.png")
	tex_front_r = load("res://posisi mc/front_right.png")

	tex_back   = load("res://posisi mc/back.png")
	tex_back_l = load("res://posisi mc/back_left.png")
	tex_back_r = load("res://posisi mc/back_right.png")

	tex_left   = load("res://posisi mc/left.png")
	tex_left_l = load("res://posisi mc/left_left.png")
	tex_left_r = load("res://posisi mc/left_right.png")

	tex_right   = load("res://posisi mc/right.png")
	tex_right_l = load("res://posisi mc/right_left.png")
	tex_right_r = load("res://posisi mc/right_right.png")

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = false
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
		step_cycle += delta * 5.0 # Kecepatan animasi langkah kaki disesuaikan dengan kecepatan jalan
	else:
		is_moving = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		step_cycle = 0.0

	# 3. Fisika pergerakan dan tabrakan
	move_and_slide()

	# 4. Trigger redraw untuk rendering sprite MC
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

# ── Dapatkan Texture Sprite yang Sesuai dengan Arah & Animasi Langkah ───────
func _get_current_sprite() -> Texture2D:
	var is_horizontal = abs(facing_direction.x) > abs(facing_direction.y)

	var idle_tex: Texture2D
	var step_l_tex: Texture2D
	var step_r_tex: Texture2D

	if is_horizontal:
		if facing_direction.x < 0:
			idle_tex   = tex_left
			step_l_tex = tex_left_l
			step_r_tex = tex_left_r
		else:
			idle_tex   = tex_right
			step_l_tex = tex_right_l
			step_r_tex = tex_right_r
	else:
		if facing_direction.y < 0:
			idle_tex   = tex_back
			step_l_tex = tex_back_l
			step_r_tex = tex_back_r
		else:
			idle_tex   = tex_front
			step_l_tex = tex_front_l
			step_r_tex = tex_front_r

	if not is_moving:
		return idle_tex

	# Animasi 4-frame walk cycle (Idle -> Step Left -> Idle -> Step Right)
	var anim_phase = fmod(step_cycle, 1.0)
	if anim_phase < 0.25:
		return idle_tex
	elif anim_phase < 0.50:
		return step_l_tex
	elif anim_phase < 0.75:
		return idle_tex
	else:
		return step_r_tex

func _draw() -> void:
	# 1. Bayangan di lantai (Ground Shadow Oval)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 6), 14.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Gambar Sprite Art MC dari 'posisi mc' dengan Skala Teratur
	var cur_tex = _get_current_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		# Terapkan skala transform agar gambar resolusi tinggi pas dengan ukuran karakter game
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(sprite_scale, sprite_scale))
		
		# Offset agar posisi kaki tepat berada di origin
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 12.0)
		draw_texture(cur_tex, draw_offset)
		
		# Reset transform kembali ke normal
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
