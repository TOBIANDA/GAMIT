extends CharacterBody2D

# ── Konfigurasi Pergerakan 3/4 Top-Down ─────────────────────────────────────
@export var max_speed: float = 120.0       # Diperlambat agar terasa nuansa investigasi
@export var acceleration: float = 1600.0   # Akselerasi yang halus
@export var friction: float = 1800.0       # Gesekan menghentikan pergerakan
@export var can_move: bool = true
@export var sprite_scale: float = 0.055    # Skala diperkecil lagi agar lebih proporsional dengan map luas
@export var step_animation_speed: float = 3.2 # Jumlah step perdetik dikurangi agar langkah santai & natural

@export_enum("MC", "Boy", "Girl", "Police") var character_skin: String = "MC"

# ── Variabel Visual & Animasi 3/4 ──────────────────────────────────────────
var facing_direction: Vector2 = Vector2.DOWN
var step_cycle: float = 0.0
var is_moving: bool = false

# ── Textures Sprite Karakter (4 Arah x 3 Frame Langkah) ─────────────────────
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

# ── Node References & Zoom Kontrol ─────────────────────────────────────────
@onready var camera: Camera2D = $Camera2D

@export var target_zoom_val: float = 1.8   # Nilai zoom aktif default
@export var min_zoom_val: float = 0.35     # Penglihatan paling luas
@export var max_zoom_val: float = 3.5      # Penglihatan paling dekat
@export var zoom_step: float = 0.20        # Langkah per scroll / klik

func _ready() -> void:
	add_to_group("player")
	y_sort_enabled = true
	if is_instance_valid(camera):
		camera.zoom = Vector2(target_zoom_val, target_zoom_val)

	_load_current_skin()
	queue_redraw()

func _load_current_skin() -> void:
	var base_folder = "res://posisi mc/"
	match character_skin:
		"Boy":
			base_folder = "res://NPC_Boy/"
		"Girl":
			base_folder = "res://NPC_Girl/"
		"Police":
			base_folder = "res://NPC_Police/"
		_:
			base_folder = "res://posisi mc/"

	tex_front   = load(base_folder + "front.png")
	tex_front_l = load(base_folder + "front_left.png")
	tex_front_r = load(base_folder + "front_right.png")

	tex_back   = load(base_folder + "back.png")
	tex_back_l = load(base_folder + "back_left.png")
	tex_back_r = load(base_folder + "back_right.png")

	tex_left   = load(base_folder + "left.png")
	tex_left_l = load(base_folder + "left_left.png")
	tex_left_r = load(base_folder + "left_right.png")

	tex_right   = load(base_folder + "right.png")
	tex_right_l = load(base_folder + "right_left.png")
	tex_right_r = load(base_folder + "right_right.png")

func set_character_skin(skin_name: String) -> void:
	character_skin = skin_name
	_load_current_skin()
	queue_redraw()

func switch_to_next_skin() -> void:
	match character_skin:
		"MC":
			set_character_skin("Boy")
		"Boy":
			set_character_skin("Girl")
		"Girl":
			set_character_skin("Police")
		"Police":
			set_character_skin("MC")

func _unhandled_input(event: InputEvent) -> void:
	# 1. Mouse Scroll Wheel untuk Zoom
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

	# 2. Keyboard Hotkeys Zoom & Skin
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS or event.keycode == KEY_I or event.keycode == KEY_BRACKETRIGHT:
			zoom_in()
		elif event.keycode == KEY_MINUS or event.keycode == KEY_O or event.keycode == KEY_BRACKETLEFT:
			zoom_out()
		elif event.keycode == KEY_0:
			reset_zoom()
		elif event.keycode == KEY_G:
			switch_to_next_skin()

func zoom_in() -> void:
	target_zoom_val = clampf(target_zoom_val + zoom_step, min_zoom_val, max_zoom_val)

func zoom_out() -> void:
	target_zoom_val = clampf(target_zoom_val - zoom_step, min_zoom_val, max_zoom_val)

func reset_zoom() -> void:
	target_zoom_val = 1.8

func get_zoom_level() -> float:
	return target_zoom_val

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
		# Step perdetik lebih santai
		step_cycle += delta * step_animation_speed
	else:
		is_moving = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		step_cycle = 0.0

	# 3. Fisika pergerakan dan tabrakan
	move_and_slide()

	# 4. Smooth Camera Zoom Lerp
	if is_instance_valid(camera):
		var target_vec = Vector2(target_zoom_val, target_zoom_val)
		camera.zoom = camera.zoom.lerp(target_vec, delta * 12.0)

	# 5. Trigger redraw untuk rendering sprite MC
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
	draw_circle(Vector2(0, 4), 6.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Gambar Sprite Art MC dari texture aktif dengan Skala Proporsional
	var cur_tex = _get_current_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(sprite_scale, sprite_scale))
		
		# Offset agar posisi kaki tepat berada di origin
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 6.0)
		draw_texture(cur_tex, draw_offset)
		
		# Reset transform kembali ke normal
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
