extends CharacterBody2D

@export var walk_speed: float = 90.0
@export var sprint_speed: float = 144.0
@export var max_speed: float = 90.0
@export var acceleration: float = 1600.0
@export var friction: float = 1800.0
@export var can_move: bool = true

enum MCType { DETECTIVE_BOY, CASUAL_BOY, GIRL }
@export var current_mc_type: MCType = MCType.DETECTIVE_BOY
@export var target_height_px: float = 38.0
@export var base_step_anim_speed: float = 2.0
@export var sprint_step_anim_speed: float = 3.2
var step_anim_speed: float = 2.0

var facing_direction: Vector2 = Vector2.DOWN
var step_cycle: float = 0.0
var is_moving: bool = false
var is_sprinting: bool = false

@export_group("Stamina & Energi Lari")
@export var max_stamina: float = 100.0
var stamina: float = 100.0
@export var stamina_drain_rate: float = 24.0 # Habis dalam ~4.2 detik sprint nonstop
@export var stamina_recover_rate: float = 20.0 # Pulih dalam ~5 detik saat jalan/diam
var is_exhausted: bool = false
const EXHAUSTION_RECOVERY_THRESHOLD: float = 20.0

var sprite_sets: Dictionary = {}
var footsteps_player: AudioStreamPlayer2D

@onready var camera: Camera2D = $Camera2D

@export var target_zoom_val: float = 2.0
@export var min_zoom_val: float = 1.40
@export var max_zoom_val: float = 2.60
@export var zoom_step: float = 0.20

var player_light: PointLight2D

func _ready() -> void:
	add_to_group("player")
	y_sort_enabled = true
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.15
	collision_layer = 2
	collision_mask = 1
	if is_instance_valid(camera):
		camera.enabled = true
		camera.make_current()
		target_zoom_val = clampf(target_zoom_val, min_zoom_val, max_zoom_val)
		camera.zoom = Vector2(target_zoom_val, target_zoom_val)
		setup_camera_limits(0, 0, 2400, 1450)

	_setup_player_ambient_light()
	_setup_footsteps_audio()
	_load_all_mc_sprite_sets()
	queue_redraw()

func setup_camera_limits(l: int, t: int, r: int, b: int) -> void:
	if not is_instance_valid(camera):
		camera = get_node_or_null("Camera2D")
	if is_instance_valid(camera):
		camera.limit_left = l
		camera.limit_top = t
		camera.limit_right = r
		camera.limit_bottom = b

func reset_camera_smoothing() -> void:
	if not is_instance_valid(camera):
		camera = get_node_or_null("Camera2D")
	if is_instance_valid(camera):
		camera.reset_smoothing()

func _setup_player_ambient_light() -> void:
	player_light = PointLight2D.new()
	player_light.name = "PlayerAmbientLight"
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(1.0, 0.95, 0.82, 0.40),
		Color(1.0, 0.90, 0.72, 0.18),
		Color(0.90, 0.80, 0.60, 0.05),
		Color(0.80, 0.70, 0.50, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.25, 0.65, 1.0])
	var light_tex := GradientTexture2D.new()
	light_tex.gradient = grad
	light_tex.fill = GradientTexture2D.FILL_RADIAL
	light_tex.fill_from = Vector2(0.5, 0.5)
	light_tex.fill_to = Vector2(1.0, 0.5)
	light_tex.width = 256
	light_tex.height = 256
	player_light.texture = light_tex
	player_light.texture_scale = 0.80
	player_light.energy = 0.32
	player_light.color = Color(1.0, 0.95, 0.82, 1.0)
	var ws = get_node_or_null("../WorldShader")
	var is_night = ws.is_night_mode if is_instance_valid(ws) and "is_night_mode" in ws else false
	player_light.enabled = is_night
	add_child(player_light)

func set_night_mode(is_night: bool) -> void:
	if is_instance_valid(player_light):
		player_light.enabled = is_night

func _setup_footsteps_audio() -> void:
	footsteps_player = AudioStreamPlayer2D.new()
	footsteps_player.name = "FootstepsPlayer"
	var footstep_stream = load("res://sound/Footsteps.mp3")
	if footstep_stream:
		footsteps_player.stream = footstep_stream
		footsteps_player.volume_db = -6.0
		footsteps_player.finished.connect(func():
			if is_moving and is_instance_valid(footsteps_player):
				footsteps_player.play()
		)
	add_child(footsteps_player)

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
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS:
			zoom_in()
		elif event.keycode == KEY_MINUS:
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
		if is_instance_valid(footsteps_player) and footsteps_player.playing:
			footsteps_player.stop()
		move_and_slide()
		queue_redraw()
		return

	var input_vector = _get_input_vector()

	var wants_sprint = Input.is_key_pressed(KEY_SHIFT) and input_vector != Vector2.ZERO

	if is_exhausted:
		if stamina >= EXHAUSTION_RECOVERY_THRESHOLD:
			is_exhausted = false
		else:
			wants_sprint = false

	if wants_sprint and stamina > 0.0:
		is_sprinting = true
		stamina = max(0.0, stamina - stamina_drain_rate * delta)
		if stamina <= 0.0:
			is_exhausted = true
			is_sprinting = false
	else:
		is_sprinting = false
		stamina = min(max_stamina, stamina + stamina_recover_rate * delta)

	max_speed = sprint_speed if is_sprinting else walk_speed
	step_anim_speed = sprint_step_anim_speed if is_sprinting else base_step_anim_speed

	if input_vector != Vector2.ZERO:
		is_moving = true
		facing_direction = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		step_cycle += delta * step_anim_speed

		if is_instance_valid(footsteps_player):
			footsteps_player.pitch_scale = 1.35 if is_sprinting else 1.0
			if not footsteps_player.playing:
				footsteps_player.play()
	else:
		is_moving = false
		is_sprinting = false
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		step_cycle = 0.0

		if is_instance_valid(footsteps_player) and footsteps_player.playing:
			footsteps_player.stop()

	move_and_slide()

	if is_instance_valid(camera):
		var target_vec = Vector2(target_zoom_val, target_zoom_val)
		camera.zoom = camera.zoom.lerp(target_vec, delta * 12.0)

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
	var cur_tex = _get_current_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		var calculated_scale = target_height_px / max(size.y, 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(calculated_scale, calculated_scale))
		
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 8.0)
		draw_texture(cur_tex, draw_offset)
		
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Indikator Visual Bar Stamina / Energi di bawah kaki MC saat tidak 100%
	if stamina < max_stamina:
		var bar_w := 26.0
		var bar_h := 3.5
		var bar_x := -bar_w * 0.5
		var bar_y := 12.0
		var pct := stamina / max_stamina
		var bar_col := Color(0.2, 0.9, 0.4) if not is_exhausted else Color(0.9, 0.3, 0.2)
		draw_rect(Rect2(bar_x - 1, bar_y - 1, bar_w + 2, bar_h + 2), Color(0.05, 0.05, 0.08, 0.75), true)
		draw_rect(Rect2(bar_x, bar_y, bar_w * pct, bar_h), bar_col, true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		velocity = Vector2.ZERO
		is_moving = false
		is_sprinting = false
		if is_instance_valid(footsteps_player) and footsteps_player.playing:
			footsteps_player.stop()
		queue_redraw()
