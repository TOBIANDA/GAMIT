extends CharacterBody2D

# ── Konfigurasi Pergerakan 3/4 Top-Down Sesuai GDD ────────────────────────────
@export var walk_speed: float = 90.0        # 0.75x dari kecepatan semula (120 * 0.75)
@export var sprint_speed: float = 144.0     # 1.20x dari kecepatan semula (120 * 1.20)
@export var max_speed: float = 90.0         # Kecepatan aktif saat ini
@export var acceleration: float = 1600.0    # Akselerasi halus
@export var friction: float = 1800.0        # Gesekan
@export var can_move: bool = true

# ── Pilihan Karakter MC (Default: MC Detektif Asli 'posisi mc') ────────────
enum MCType { DETECTIVE_BOY, CASUAL_BOY, GIRL }
@export var current_mc_type: MCType = MCType.DETECTIVE_BOY # MC Detektif Asli (Benedict)
@export var target_height_px: float = 38.0                 # Ukuran badan MC diperbesar sedikit & proporsional
@export var base_step_anim_speed: float = 2.0              # Langkah jalan santai
@export var sprint_step_anim_speed: float = 3.2            # Langkah saat lari
var step_anim_speed: float = 2.0

# ── Variabel Visual & Animasi 3/4 ──────────────────────────────────────────
var facing_direction: Vector2 = Vector2.DOWN
var step_cycle: float = 0.0
var is_moving: bool = false
var is_sprinting: bool = false

# Dictionary untuk menyimpan 12 texture per karakter
var sprite_sets: Dictionary = {}

# ── Node References & Zoom Kontrol ─────────────────────────────────────────
@onready var camera: Camera2D = $Camera2D

@export var target_zoom_val: float = 2.0   # Nilai zoom aktif default (2.0x)
@export var min_zoom_val: float = 0.35     # Penglihatan paling luas
@export var max_zoom_val: float = 3.5      # Penglihatan paling dekat
@export var zoom_step: float = 0.20        # Langkah per scroll / klik

func _ready() -> void:
	add_to_group("player")
	y_sort_enabled = true
	if is_instance_valid(camera):
		camera.zoom = Vector2(target_zoom_val, target_zoom_val)

	# Load semua set sprite MC (posisi mc, NPC_Boy, NPC_Girl)
	_load_all_mc_sprite_sets()
	queue_redraw()

func _load_all_mc_sprite_sets() -> void:
	sprite_sets[MCType.DETECTIVE_BOY] = _load_sprites_from_folder("res://posisi mc/")
	sprite_sets[MCType.CASUAL_BOY]    = _load_sprites_from_folder("res://NPC_Boy/")
	sprite_sets[MCType.GIRL]          = _load_sprites_from_folder("res://NPC_Girl/")

func _load_sprites_from_folder(folder_path: String) -> Dictionary:
	var set_dict: Dictionary = {}
	set_dict["front"]       = load(folder_path + "front.png")
	set_dict["front_left"]  = load(folder_path + "front_left.png")
	set_dict["front_right"] = load(folder_path + "front_right.png")
	
	set_dict["back"]        = load(folder_path + "back.png")
	set_dict["back_left"]   = load(folder_path + "back_left.png")
	set_dict["back_right"]  = load(folder_path + "back_right.png")
	
	set_dict["left"]        = load(folder_path + "left.png")
	set_dict["left_left"]   = load(folder_path + "left_left.png")
	set_dict["left_right"]  = load(folder_path + "left_right.png")
	
	set_dict["right"]       = load(folder_path + "right.png")
	set_dict["right_left"]  = load(folder_path + "right_left.png")
	set_dict["right_right"] = load(folder_path + "right_right.png")
	return set_dict

func _unhandled_input(event: InputEvent) -> void:
	# 1. Mouse Scroll Wheel untuk Zoom
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

	# 2. Keyboard Hotkeys Zoom
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS or event.keycode == KEY_I or event.keycode == KEY_BRACKETRIGHT:
			zoom_in()
		elif event.keycode == KEY_MINUS or event.keycode == KEY_O or event.keycode == KEY_BRACKETLEFT:
			zoom_out()
		elif event.keycode == KEY_0:
			reset_zoom()

func zoom_in() -> void:
	target_zoom_val = clampf(target_zoom_val + zoom_step, min_zoom_val, max_zoom_val)

func zoom_out() -> void:
	target_zoom_val = clampf(target_zoom_val - zoom_step, min_zoom_val, max_zoom_val)

func reset_zoom() -> void:
	target_zoom_val = 2.0

func get_zoom_level() -> float:
	return target_zoom_val

func get_mc_model_name() -> String:
	return "Detektif Benedict (MC)"

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = false
		is_sprinting = false
		move_and_slide()
		queue_redraw()
		return

	# 1. Dapatkan arah input 8-arah
	var input_vector = _get_input_vector()

	# 2. Cek apakah tombol Shift ditekan untuk Sprint (Lari)
	is_sprinting = Input.is_key_pressed(KEY_SHIFT)
	max_speed = sprint_speed if is_sprinting else walk_speed
	step_anim_speed = sprint_step_anim_speed if is_sprinting else base_step_anim_speed

	# 3. Update kecepatan & pergerakan
	if input_vector != Vector2.ZERO:
		is_moving = true
		facing_direction = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		# Step cycle disesuaikan saat lari vs jalan
		step_cycle += delta * step_anim_speed
	else:
		is_moving = false
		is_sprinting = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		step_cycle = 0.0

	# 4. Fisika pergerakan dan tabrakan
	move_and_slide()

	# 5. Smooth Camera Zoom Lerp
	if is_instance_valid(camera):
		var target_vec = Vector2(target_zoom_val, target_zoom_val)
		camera.zoom = camera.zoom.lerp(target_vec, delta * 12.0)

	# 6. Trigger redraw untuk rendering sprite MC
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
	var cur_set = sprite_sets.get(current_mc_type)
	if cur_set == null or cur_set.is_empty():
		return null

	var is_horizontal = abs(facing_direction.x) > abs(facing_direction.y)

	var idle_key: String
	var step_l_key: String
	var step_r_key: String

	if is_horizontal:
		if facing_direction.x < 0:
			idle_key   = "left"
			step_l_key = "left_left"
			step_r_key = "left_right"
		else:
			idle_key   = "right"
			step_l_key = "right_left"
			step_r_key = "right_right"
	else:
		if facing_direction.y < 0:
			idle_key   = "back"
			step_l_key = "back_left"
			step_r_key = "back_right"
		else:
			idle_key   = "front"
			step_l_key = "front_left"
			step_r_key = "front_right"

	if not is_moving:
		return cur_set.get(idle_key)

	# Animasi 4-frame walk cycle (Idle -> Step Left -> Idle -> Step Right)
	var anim_phase = fmod(step_cycle, 1.0)
	if anim_phase < 0.25:
		return cur_set.get(idle_key)
	elif anim_phase < 0.50:
		return cur_set.get(step_l_key)
	elif anim_phase < 0.75:
		return cur_set.get(idle_key)
	else:
		return cur_set.get(step_r_key)

func _draw() -> void:
	# Gambar Sprite Art MC dengan Ukuran Badan Proporsional
	var cur_tex = _get_current_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		# Skala dinamis agar tinggi fisik MC tepat target_height_px (~36px)
		var calculated_scale = target_height_px / max(size.y, 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(calculated_scale, calculated_scale))
		
		# Offset agar posisi kaki tepat berada di origin
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 8.0)
		draw_texture(cur_tex, draw_offset)
		
		# Reset transform
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
