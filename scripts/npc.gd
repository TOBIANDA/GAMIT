extends CharacterBody2D

# ── NPC System v8 - Multi-Sprite Support (NPC Cowo, NPC Polisi, NPC Cewe) ─────
# Fitur:
# 1. Tiga Tipe NPC Resmi:
#    - NPCType.BOY: Karakter Cowo dari folder 'NPC_Boy' / 'posisi mc'
#    - NPCType.POLICE: Karakter Polisi dari folder 'NPC_Police'
#    - NPCType.GIRL: Karakter Cewe dari folder 'NPC_Girl'
# 2. Skala Fisik Otomatis (~28px) presisi menyamai MC
# 3. Fitur Anti-Nyangkut Tembok & Smart Avoidance Tetap Aktif
# 4. Textbox Dialog Misteri Halus (Growtopia Style)

enum NPCType { BOY, POLICE, GIRL }
@export var npc_type: NPCType = NPCType.BOY # Default NPC Cowo
@export var target_height_px: float = 38.0  # Menyamai ukuran MC (diperbesar sedikit)
@export var too_close_radius: float = 110.0
@export var eavesdrop_radius: float = 220.0
@export var panic_time_limit: float = 7.0
@export var run_speed: float = 380.0
@export var wander_speed: float = 42.0

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

# Cache Sprite Textures untuk ketiga tipe NPC
var sprite_sets: Dictionary = {}

# Node Referensi Textbox
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
const CLUE_MESSAGES_CIVILIAN = [
	"Perasaanku tidak enak... hawa di sini dingin sekali...",
	"Jam dinding di ruangan itu... berhenti tepat jam dua.",
	"Mereka bilang... ada satu laporan investigasi yang belum selesai.",
	"Pakaianmu... rasanya aku pernah melihatnya di suatu tempat...",
	"Aneh... kenapa angin tidak menggerakkan pakaianmu sama sekali?",
	"Orang-orang di kota ini... tidak ada yang mau menjawabmu.",
	"Ada sesuatu tentang tempat ini... yang membuat bulu kuduk berdiri..."
]

const CLUE_MESSAGES_POLICE = [
	"Laporan TKP nomor 404... korbannya belum dapat diidentifikasi.",
	"Semua pintu keluar kota diperintahkan ditutup rapat.",
	"Detektif... berkas kasus itu terkunci di ruang arsip.",
	"Jangan mendekati stasiun terlarang di ujung timur...",
	"Ada jejak aneh yang berhenti tepat di depan kuil itu."
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
	_load_all_npc_sprite_sets()
	_build_growtopia_textbox()
	queue_redraw()

func _load_all_npc_sprite_sets() -> void:
	sprite_sets[NPCType.BOY]    = _load_sprites_from_folder("res://NPC_Boy/")
	sprite_sets[NPCType.POLICE] = _load_sprites_from_folder("res://NPC_Police/")
	sprite_sets[NPCType.GIRL]   = _load_sprites_from_folder("res://NPC_Girl/")

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

# ── Membuat UI Textbox Gaya Growtopia ───────────────────────────────────────
func _build_growtopia_textbox() -> void:
	var root_box = Node2D.new()
	root_box.name = "TextboxRoot"
	root_box.position = Vector2(0, -42)
	add_child(root_box)

	# Panel Putih Growtopia
	textbox_panel = PanelContainer.new()
	textbox_panel.position = Vector2(-90, -40)
	textbox_panel.size = Vector2(180, 36)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.98, 0.98, 0.98, 0.96)
	style_box.border_color = Color(0.08, 0.08, 0.12, 1.0)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(7)
	style_box.content_margin_left = 8.0
	style_box.content_margin_right = 8.0
	style_box.content_margin_top = 4.0
	style_box.content_margin_bottom = 4.0
	style_box.shadow_color = Color(0, 0, 0, 0.25)
	style_box.shadow_size = 3
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
	textbox_label.add_theme_font_size_override("font_size", 11)
	textbox_panel.add_child(textbox_label)

	# Segitiga Ekor Textbox Growtopia
	textbox_pointer = Polygon2D.new()
	textbox_pointer.polygon = PackedVector2Array([
		Vector2(-6, -2), Vector2(6, -2), Vector2(0, 6)
	])
	textbox_pointer.color = Color(0.98, 0.98, 0.98, 0.96)
	root_box.add_child(textbox_pointer)

	var pointer_outline = Line2D.new()
	pointer_outline.points = PackedVector2Array([
		Vector2(-6, -2), Vector2(0, 6), Vector2(6, -2)
	])
	pointer_outline.width = 2.0
	pointer_outline.default_color = Color(0.08, 0.08, 0.12, 1.0)
	root_box.add_child(pointer_outline)

	root_box.scale = Vector2.ZERO

func _trigger_new_clue_dialogue() -> void:
	var msg_pool = CLUE_MESSAGES_POLICE if npc_type == NPCType.POLICE else CLUE_MESSAGES_CIVILIAN
	var next_idx = randi() % msg_pool.size()
	if next_idx == last_clue_index:
		next_idx = (next_idx + 1) % msg_pool.size()
	last_clue_index = next_idx

	current_text_msg = msg_pool[next_idx]
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

	# Cek tabrakan tembok/pilar -> auto-slide & bounce
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
		step_cycle += delta * 4.5
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
	tremble_offset = Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))

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
	step_cycle += delta * 18.0
	body_bob_y = abs(sin(step_cycle)) * -3.5
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

# ── Get Texture Sprite Berdasarkan NPCType ──────────────────────────────────
func _get_current_npc_sprite() -> Texture2D:
	var cur_set = sprite_sets.get(npc_type)
	if cur_set == null or cur_set.is_empty():
		return null

	var move_dir = velocity.normalized()
	if not is_moving or move_dir == Vector2.ZERO:
		move_dir = wander_direction.normalized()
	if move_dir == Vector2.ZERO:
		move_dir = Vector2.DOWN

	var is_horizontal = abs(move_dir.x) > abs(move_dir.y)
	var idle_key: String
	var step_l_key: String
	var step_r_key: String

	if is_horizontal:
		if move_dir.x < 0:
			idle_key   = "left"
			step_l_key = "left_left"
			step_r_key = "left_right"
		else:
			idle_key   = "right"
			step_l_key = "right_left"
			step_r_key = "right_right"
	else:
		if move_dir.y < 0:
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

# ── Custom Drawing Avatar NPC ───────────────────────────────────────────────
func _draw() -> void:
	if current_state == State.DESPAWNED:
		return

	var draw_pos = tremble_offset

	# Render Sprite Custom Texture Sesuai NPCType
	var cur_tex = _get_current_npc_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		# Skala Otomatis agar tinggi fisik NPC tepat ~28px menyamai MC
		var calculated_scale = target_height_px / max(size.y, 1.0)
		
		draw_set_transform(draw_pos, 0.0, Vector2(calculated_scale, calculated_scale))
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 8.0)
		draw_texture(cur_tex, draw_offset)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
