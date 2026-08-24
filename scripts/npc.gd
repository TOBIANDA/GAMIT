extends CharacterBody2D

# ── NPC System v8 - Multi-Character Custom Sprites (Boy, Girl, Police) ───────
# Fitur:
# 1. Tipe Karakter Dinamis: "Boy", "Girl", "Police", atau "Random" (menggunakan sprite PNG asli).
# 2. Skala Tinggi Otomatis: Disesuaikan dengan MC baru (~22px) secara proporsional.
# 3. Step Cycle Santai: Langkah kaki lebih natural dan tidak terburu-buru (3.2).
# 4. Anti-Nyangkut & Textbox Dialog Growtopia tetap aktif.

@export_enum("Boy", "Girl", "Police", "Random") var npc_type: String = "Random"
@export var target_height_px: float = 22.0    # Tinggi fisik target di layar (Menyamakan presisi dengan MC baru)
@export var too_close_radius: float = 110.0
@export var eavesdrop_radius: float = 220.0
@export var panic_time_limit: float = 7.0
@export var run_speed: float = 300.0
@export var wander_speed: float = 35.0

enum State { IDLE, WANDER, EAVESDROP, AFRAID, PANIC_RUN, DESPAWNED }
var current_state: State = State.IDLE

var player_ref: CharacterBody2D = null
var panic_timer: float = 0.0
var run_timer: float = 0.0
var run_direction: Vector2 = Vector2.ZERO
var tremble_offset: Vector2 = Vector2.ZERO

# Timer Tampil Textbox 2 Detik & Pause Antar Percakapan
var msg_display_timer: float = 0.0
var msg_cooldown_timer: float = 0.0
const MSG_DISPLAY_DURATION: float = 2.0
const MSG_COOLDOWN_DURATION: float = 1.2

# Textures untuk NPC (dari folder 'NPC_Boy', 'NPC_Girl', atau 'NPC_Police')
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

# Node Referensi (Growtopia Textbox)
var textbox_panel: PanelContainer
var textbox_label: Label
var textbox_pointer: Polygon2D
var textbox_scale: float = 0.0
var is_textbox_visible: bool = false
var current_text_msg: String = ""
var last_clue_index: int = -1

# Animasi pergerakan NPC
var step_cycle: float = 0.0
var is_moving: bool = false
var body_bob_y: float = 0.0
var wander_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO

# Pool Percakapan Misteri Halus (Zona Aman / Clue)
const CLUE_MESSAGES = [
	"Perasaanku tidak enak... hawa di sini dingin sekali...",
	"Jam dinding di ruangan itu... berhenti tepat jam dua.",
	"Mereka bilang... ada satu laporan investigasi yang belum selesai.",
	"Pakaianmu... rasanya aku pernah melihatnya di suatu tempat...",
	"Aneh... kenapa angin tidak menggerakkan pakaianmu sama sekali?",
	"Orang-orang di kota ini... tidak ada yang mau menjawabmu.",
	"Ada sesuatu tentang tempat ini... yang membuat bulu kuduk berdiri..."
]

# Pool Teriakan Panik (Terlalu Dekat > 7s)
const PANIC_MESSAGES = [
	"PERGI!! JANGAN MENDEKATIKU!! 🏃‍♂️",
	"Tolong! Rasanya tempat ini membuatku tercekik!! 🏃‍♂️",
	"Tidak... aku harus pergi dari sini sekarang!! 🏃‍♂️",
	"Aku tidak tahan lagi... hawa ini terlalu pekat!! 🏃‍♂️",
	"Jangan sentuh aku!! 🏃‍♂️"
]

func _ready() -> void:
	y_sort_enabled = true
	_determine_type_and_load_sprites()
	_build_growtopia_textbox()
	queue_redraw()

func _determine_type_and_load_sprites() -> void:
	var chosen_type = npc_type
	if chosen_type == "Random":
		var types = ["Boy", "Girl"]
		chosen_type = types[randi() % types.size()]

	var folder = "res://NPC_Boy/"
	match chosen_type:
		"Boy":
			folder = "res://NPC_Boy/"
		"Girl":
			folder = "res://NPC_Girl/"
		"Police":
			folder = "res://NPC_Police/"
		_:
			folder = "res://NPC_Boy/"

	tex_front   = load(folder + "front.png")
	tex_front_l = load(folder + "front_left.png")
	tex_front_r = load(folder + "front_right.png")

	tex_back   = load(folder + "back.png")
	tex_back_l = load(folder + "back_left.png")
	tex_back_r = load(folder + "back_right.png")

	tex_left   = load(folder + "left.png")
	tex_left_l = load(folder + "left_left.png")
	tex_left_r = load(folder + "left_right.png")

	tex_right   = load(folder + "right.png")
	tex_right_l = load(folder + "right_left.png")
	tex_right_r = load(folder + "right_right.png")

# ── Membuat UI Textbox Gaya Growtopia ───────────────────────────────────────
func _build_growtopia_textbox() -> void:
	var root_box = Node2D.new()
	root_box.name = "TextboxRoot"
	root_box.position = Vector2(0, -32)
	add_child(root_box)

	# Panel Putih Growtopia
	textbox_panel = PanelContainer.new()
	textbox_panel.position = Vector2(-80, -36)
	textbox_panel.size = Vector2(160, 32)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.98, 0.98, 0.98, 0.96)
	style_box.border_color = Color(0.08, 0.08, 0.12, 1.0)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(6)
	style_box.content_margin_left = 8.0
	style_box.content_margin_right = 8.0
	style_box.content_margin_top = 4.0
	style_box.content_margin_bottom = 4.0
	style_box.shadow_color = Color(0, 0, 0, 0.25)
	style_box.shadow_size = 2
	style_box.shadow_offset = Vector2(0, 2)

	textbox_panel.add_theme_stylebox_override("panel", style_box)
	root_box.add_child(textbox_panel)

	# Label Teks Hitam
	textbox_label = Label.new()
	textbox_label.text = ""
	textbox_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	textbox_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	textbox_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	textbox_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.12))
	textbox_label.add_theme_font_size_override("font_size", 10)
	textbox_panel.add_child(textbox_label)

	# Segitiga Ekor Textbox Growtopia
	textbox_pointer = Polygon2D.new()
	textbox_pointer.polygon = PackedVector2Array([
		Vector2(-5, -2), Vector2(5, -2), Vector2(0, 5)
	])
	textbox_pointer.color = Color(0.98, 0.98, 0.98, 0.96)
	root_box.add_child(textbox_pointer)

	var pointer_outline = Line2D.new()
	pointer_outline.points = PackedVector2Array([
		Vector2(-5, -2), Vector2(0, 5), Vector2(5, -2)
	])
	pointer_outline.width = 1.8
	pointer_outline.default_color = Color(0.08, 0.08, 0.12, 1.0)
	root_box.add_child(pointer_outline)

	root_box.scale = Vector2.ZERO

func _trigger_new_clue_dialogue() -> void:
	var next_idx = randi() % CLUE_MESSAGES.size()
	if next_idx == last_clue_index:
		next_idx = (next_idx + 1) % CLUE_MESSAGES.size()
	last_clue_index = next_idx

	current_text_msg = CLUE_MESSAGES[next_idx]
	if is_instance_valid(textbox_label):
		textbox_label.text = current_text_msg

	msg_display_timer = MSG_DISPLAY_DURATION
	is_textbox_visible = true

# ── Process & Physics ───────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if current_state == State.DESPAWNED:
		return

	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player_ref):
			player_ref = get_node_or_null("../Player")

	var dist_to_player = 9999.0
	if is_instance_valid(player_ref):
		dist_to_player = global_position.distance_to(player_ref.global_position)

	match current_state:
		State.IDLE, State.WANDER:
			_handle_idle_wander(delta, dist_to_player)

		State.EAVESDROP:
			_handle_eavesdrop_state(delta, dist_to_player)

		State.AFRAID:
			_handle_afraid_state(delta, dist_to_player)

		State.PANIC_RUN:
			_handle_panic_run(delta)

	_animate_textbox_scale(delta)
	
	# Eksekusi pergerakan fisika
	move_and_slide()

	# Cek jika menabrak tembok -> Lakukan pantulan otomatis
	if is_on_wall():
		_handle_wall_collision()

	queue_redraw()

# ── Penanganan Tabrakan Tembok (Anti-Nyangkut) ──────────────────────────────
func _handle_wall_collision() -> void:
	var wall_normal = get_wall_normal()
	
	if current_state in [State.IDLE, State.WANDER]:
		var bounce_dir = (wall_normal + Vector2(randf_range(-0.4, 0.4), randf_range(-0.4, 0.4))).normalized()
		wander_direction = bounce_dir
		wander_timer = randf_range(2.0, 5.0)
		velocity = wander_direction * wander_speed
	elif current_state == State.PANIC_RUN:
		var slide_dir = run_direction.slide(wall_normal).normalized()
		if slide_dir == Vector2.ZERO or slide_dir.length() < 0.1:
			slide_dir = wall_normal
		run_direction = slide_dir
		velocity = run_direction * run_speed

# ── Smart Navigation ────────────────────────────────────────────────────────
func _pick_smart_wander_direction() -> Vector2:
	if is_instance_valid(player_ref):
		var to_player = (player_ref.global_position - global_position).normalized()
		var away_angle = to_player.angle() + PI + randf_range(-PI * 0.35, PI * 0.35)
		return Vector2(cos(away_angle), sin(away_angle)).normalized()
	
	var angle = randf() * TAU
	return Vector2(cos(angle), sin(angle)).normalized()

# ── Handlers Logika State ───────────────────────────────────────────────────
func _handle_idle_wander(delta: float, dist: float) -> void:
	if dist <= too_close_radius:
		current_state = State.AFRAID
		panic_timer = 0.0
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return
	elif dist <= eavesdrop_radius:
		current_state = State.EAVESDROP
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return

	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(3.0, 7.0)
		if randf() > 0.45:
			wander_direction = _pick_smart_wander_direction()
			is_moving = true
		else:
			wander_direction = Vector2.ZERO
			is_moving = false

	if is_moving:
		velocity = wander_direction * wander_speed
		step_cycle += delta * 3.2 # Langkah lebih santai
		body_bob_y = abs(sin(step_cycle)) * -1.5
	else:
		velocity = Vector2.ZERO
		body_bob_y = move_toward(body_bob_y, 0.0, delta * 10.0)

	tremble_offset = Vector2.ZERO

func _handle_eavesdrop_state(delta: float, dist: float) -> void:
	if dist > eavesdrop_radius + 10.0:
		current_state = State.IDLE
		is_textbox_visible = false
		msg_display_timer = 0.0
		msg_cooldown_timer = 0.0
		velocity = Vector2.ZERO
		tremble_offset = Vector2.ZERO
		return
	elif dist <= too_close_radius:
		current_state = State.AFRAID
		panic_timer = 0.0
		return

	panic_timer = 0.0
	tremble_offset = Vector2.ZERO
	velocity = Vector2.ZERO
	is_moving = false

	if msg_display_timer > 0.0:
		msg_display_timer -= delta
		is_textbox_visible = true
		if msg_display_timer <= 0.0:
			is_textbox_visible = false
			msg_cooldown_timer = MSG_COOLDOWN_DURATION
	elif msg_cooldown_timer > 0.0:
		msg_cooldown_timer -= delta
		is_textbox_visible = false
		if msg_cooldown_timer <= 0.0:
			_trigger_new_clue_dialogue()

func _handle_afraid_state(delta: float, dist: float) -> void:
	if dist > too_close_radius and dist <= eavesdrop_radius:
		current_state = State.EAVESDROP
		tremble_offset = Vector2.ZERO
		return
	elif dist > eavesdrop_radius:
		current_state = State.IDLE
		is_textbox_visible = false
		panic_timer = 0.0
		velocity = Vector2.ZERO
		tremble_offset = Vector2.ZERO
		return

	panic_timer += delta
	velocity = Vector2.ZERO
	is_moving = false
	tremble_offset = Vector2(randf_range(-1.2, 1.2), randf_range(-1.2, 1.2))

	if msg_display_timer > 0.0:
		msg_display_timer -= delta
		is_textbox_visible = true
		if msg_display_timer <= 0.0:
			is_textbox_visible = false
			msg_cooldown_timer = MSG_COOLDOWN_DURATION
	elif msg_cooldown_timer > 0.0:
		msg_cooldown_timer -= delta
		is_textbox_visible = false
		if msg_cooldown_timer <= 0.0 and panic_timer < panic_time_limit - 0.5:
			_trigger_new_clue_dialogue()

	if panic_timer >= panic_time_limit:
		current_state = State.PANIC_RUN
		run_timer = 3.0
		current_text_msg = PANIC_MESSAGES[randi() % PANIC_MESSAGES.size()]
		if is_instance_valid(textbox_label):
			textbox_label.text = current_text_msg
		is_textbox_visible = true
		msg_display_timer = 3.0

		if is_instance_valid(player_ref):
			run_direction = (global_position - player_ref.global_position).normalized()
			if run_direction == Vector2.ZERO:
				run_direction = Vector2.RIGHT
		else:
			run_direction = Vector2.RIGHT

func _handle_panic_run(delta: float) -> void:
	run_timer -= delta
	is_moving = true

	velocity = run_direction * run_speed
	step_cycle += delta * 10.0
	body_bob_y = abs(sin(step_cycle)) * -3.0
	tremble_offset = Vector2.ZERO

	if run_timer <= 0.0:
		current_state = State.DESPAWNED
		is_textbox_visible = false
		queue_free()

# ── Smooth Scale Textbox Growtopia ──────────────────────────────────────────
func _animate_textbox_scale(delta: float) -> void:
	var target_scale = 1.0 if is_textbox_visible else 0.0
	textbox_scale = move_toward(textbox_scale, target_scale, delta * 9.0)

	var tb_root = get_node_or_null("TextboxRoot")
	if is_instance_valid(tb_root):
		tb_root.scale = Vector2(textbox_scale, textbox_scale)

# ── Get Texture Sprite NPC ──────────────────────────────────────────────────
func _get_current_sprite() -> Texture2D:
	var move_dir = velocity.normalized()
	if not is_moving or move_dir == Vector2.ZERO:
		move_dir = wander_direction.normalized()
	if move_dir == Vector2.ZERO:
		move_dir = Vector2.DOWN

	var is_horizontal = abs(move_dir.x) > abs(move_dir.y)
	var idle_tex: Texture2D
	var step_l_tex: Texture2D
	var step_r_tex: Texture2D

	if is_horizontal:
		if move_dir.x < 0:
			idle_tex   = tex_left
			step_l_tex = tex_left_l
			step_r_tex = tex_left_r
		else:
			idle_tex   = tex_right
			step_l_tex = tex_right_l
			step_r_tex = tex_right_r
	else:
		if move_dir.y < 0:
			idle_tex   = tex_back
			step_l_tex = tex_back_l
			step_r_tex = tex_back_r
		else:
			idle_tex   = tex_front
			step_l_tex = tex_front_l
			step_r_tex = tex_front_r

	if not is_moving:
		return idle_tex

	var anim_phase = fmod(step_cycle, 1.0)
	if anim_phase < 0.25:
		return idle_tex
	elif anim_phase < 0.50:
		return step_l_tex
	elif anim_phase < 0.75:
		return idle_tex
	else:
		return step_r_tex

# ── Custom Drawing Avatar ───────────────────────────────────────────────────
func _draw() -> void:
	if current_state == State.DESPAWNED:
		return

	var draw_pos = tremble_offset

	# 1. Bayangan lantai
	draw_set_transform(draw_pos, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 4), 6.0, Color(0, 0, 0, 0.3))
	draw_set_transform(draw_pos, 0.0, Vector2.ONE)

	# 2. Render Sprite Custom (Boy / Girl / Police)
	var cur_tex = _get_current_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		# Hitung Skala Otomatis agar tinggi fisik NPC presisi ~22px menyamai MC baru
		var calculated_scale = target_height_px / max(size.y, 1.0)
		
		draw_set_transform(draw_pos, 0.0, Vector2(calculated_scale, calculated_scale))
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 6.0)
		draw_texture(cur_tex, draw_offset)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
