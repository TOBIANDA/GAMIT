extends CharacterBody2D

# ── NPC System v10 - Active Flow & Pedestrian-Only Hangouts ──────────────────
# Fitur:
# 1. 🚶‍♂️ Selalu Aktif Berjalan di Jalanan (Anti-Bengong di Tengah Jalan):
#    - NPC terus berjalan menyusuri jalan/trotoar tanpa berhenti di aspal.
#    - Sapaan berpapasan antar-NPC dilakukan sambil terus berjalan (Walking Sapaan).
# 2. 🌳 Istirahat Singkat Hanya di Area Pejalan Kaki (Taman, Peron Stasiun, Lobi RS):
#    - Destinasi dipindahkan 100% dari tengah aspal ke area pejalan kaki resmi.
#    - Waktu istirahat singkat (1.5 - 3.0 detik) lalu langsung berjalan kembali.
# 3. 🛡️ Navigasi Bebas Hambatan (Smart Wall Slide):
#    - NPC tidak macet saat menyentuh sudut tembok/pilar, otomatis meluncur mulus.
# 4. 👻 Overlapping Mulus dengan MC Benedict & Jangkauan Merinding Fokus.

enum NPCType { BOY, POLICE, GIRL }
@export var npc_type: NPCType = NPCType.BOY
@export var target_height_px: float = 38.0
@export var too_close_radius: float = 42.0
@export var eavesdrop_radius: float = 85.0
@export var panic_time_limit: float = 7.0
@export var run_speed: float = 380.0
@export var walk_speed: float = 52.0

enum State { IDLE, GO_TO_DESTINATION, EAVESDROP, AFRAID, PANIC_RUN, DESPAWNED }
var current_state: State = State.GO_TO_DESTINATION

var player_ref: CharacterBody2D = null
var panic_timer: float = 0.0
var run_timer: float = 0.0
var run_direction: Vector2 = Vector2.ZERO
var tremble_offset: Vector2 = Vector2.ZERO

# 📍 Destinasi Terpadu Khusus Area Pejalan Kaki (Bukan di Tengah Jalan)
const SHARED_DESTINATIONS = [
	Vector2(2088, 520), # Peron Stasiun Kereta Timur (Trotoar Peron)
	Vector2(1090, 435), # Taman Courtyard Atas (Taman Hijau)
	Vector2(780, 830),  # Taman Courtyard Bawah (Taman Hijau)
	Vector2(720, 480),  # Lobi Depan Rumah Sakit & Forensik
	Vector2(260, 250),  # Trotoar Bilik Depan Kantor Barat
	Vector2(1280, 920), # Area Bilik Pod Kerja
	Vector2(1750, 480)  # Lobi Gedung Kanan
]

# 👮 Rute Patroli Polisi
const POLICE_PATROL_WAYPOINTS = [
	Vector2(350, 258),   # Pos Polisi Barat
	Vector2(577, 258),   # Simpang Atas
	Vector2(1104, 780),  # Simpang Tengah
	Vector2(2088, 520),  # Stasiun Kereta
	Vector2(1581, 780),  # Koridor Kanan
	Vector2(411, 1278)   # Jalan Bawah
]

var target_destination: Vector2 = Vector2.ZERO
var current_patrol_idx: int = 0
var idle_hangout_timer: float = 0.0

# Interaksi Sosial Sambil Berjalan (Walking Chit-Chat)
var social_cooldown: float = 0.0

const SOCIAL_CHATS_CIVILIAN = [
	"Hai! Mau ke stasiun juga ya?",
	"Cuaca kota hari ini terasa dingin sekali...",
	"Kamu dengar suara kereta tadi? Tepat waktu ya.",
	"Hati-hati ya di jalan, ada detektif sedang menyelidiki.",
	"Mau mampir ke taman courtyard sebentar?",
	"Semoga urusanmu lancar hari ini!",
	"Aku baru saja dari rumah sakit, suasananya sepi sekali."
]

const SOCIAL_CHATS_POLICE = [
	"Selamat siang warga, situasi kota terpantau aman.",
	"Tetap berhati-hati di dekat rel kereta api timur.",
	"Ada laporan mencurigakan di area kuil lama...",
	"Lanjutkan perjalananmu dengan tertib ya."
]

# Timer Tampil Textbox & Cooldown
var msg_display_timer: float = 0.0
var msg_cooldown_timer: float = 0.0
const MSG_DISPLAY_DURATION: float = 2.4
const MSG_COOLDOWN_DURATION: float = 1.2

# Cache Sprite Textures
var sprite_sets: Dictionary = {}

# Node UI Textbox
var textbox_panel: PanelContainer
var textbox_label: Label
var textbox_pointer: Polygon2D
var textbox_scale: float = 0.0
var is_textbox_visible: bool = false
var current_text_msg: String = ""
var last_clue_index: int = -1

# Animasi pergerakan
var step_cycle: float = 0.0
var is_moving: bool = false
var body_bob_y: float = 0.0
var move_dir_facing: Vector2 = Vector2.DOWN

# Pool Percakapan Misteri saat Dekat Benedict
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

const PANIC_MESSAGES = [
	"PERGI!! JANGAN MENDEKATIKU!! 🏃‍♂️",
	"Tolong! Rasanya tempat ini membuatku tercekik!! 🏃‍♂️",
	"Tidak... aku harus pergi dari sini sekarang!! 🏃‍♂️",
	"Aku tidak tahan lagi... hawa ini terlalu pekat!! 🏃‍♂️",
	"Jangan sentuh aku!! 🏃‍♂️"
]

func _ready() -> void:
	add_to_group("npcs")
	y_sort_enabled = true
	collision_layer = 4
	collision_mask = 1 # Hanya bertabrakan dengan tembok (overlap dengan MC Benedict)
	
	_load_all_npc_sprite_sets()
	_build_growtopia_textbox()
	
	social_cooldown = randf_range(2.0, 6.0)
	_pick_next_destination()
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

# ── Textbox Growtopia ───────────────────────────────────────────────────────
func _build_growtopia_textbox() -> void:
	var root_box = Node2D.new()
	root_box.name = "TextboxRoot"
	root_box.position = Vector2(0, -42)
	add_child(root_box)

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

	textbox_label = Label.new()
	textbox_label.text = ""
	textbox_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	textbox_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	textbox_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	textbox_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.12))
	textbox_label.add_theme_font_size_override("font_size", 11)
	textbox_panel.add_child(textbox_label)

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

func show_chat_bubble(msg: String, duration: float = 2.5) -> void:
	current_text_msg = msg
	if is_instance_valid(textbox_label):
		textbox_label.text = current_text_msg
	msg_display_timer = duration
	is_textbox_visible = true

func _trigger_new_clue_dialogue() -> void:
	var msg_pool = CLUE_MESSAGES_POLICE if npc_type == NPCType.POLICE else CLUE_MESSAGES_CIVILIAN
	var next_idx = randi() % msg_pool.size()
	if next_idx == last_clue_index:
		next_idx = (next_idx + 1) % msg_pool.size()
	last_clue_index = next_idx

	show_chat_bubble(msg_pool[next_idx], MSG_DISPLAY_DURATION)

# ── Sistem Tujuan Terpadu ───────────────────────────────────────────────────
func _pick_next_destination() -> void:
	if npc_type == NPCType.POLICE:
		current_patrol_idx = (current_patrol_idx + 1) % POLICE_PATROL_WAYPOINTS.size()
		target_destination = POLICE_PATROL_WAYPOINTS[current_patrol_idx]
	else:
		var candidates = SHARED_DESTINATIONS.duplicate()
		candidates.shuffle()
		for pos in candidates:
			if pos.distance_to(global_position) > 120.0:
				target_destination = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
				break
		if target_destination == Vector2.ZERO:
			target_destination = candidates[0]

	current_state = State.GO_TO_DESTINATION

# ── Physics Process & AI Lifecycle ──────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if current_state == State.DESPAWNED:
		return

	if social_cooldown > 0.0:
		social_cooldown -= delta

	if msg_display_timer > 0.0:
		msg_display_timer -= delta
		if msg_display_timer <= 0.0:
			is_textbox_visible = false

	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player_ref):
			player_ref = get_node_or_null("../Player")

	var dist_to_player = 9999.0
	if is_instance_valid(player_ref):
		dist_to_player = global_position.distance_to(player_ref.global_position)

	match current_state:
		State.IDLE:
			_handle_idle_state(delta, dist_to_player)

		State.GO_TO_DESTINATION:
			_handle_travel_state(delta, dist_to_player)

		State.EAVESDROP:
			_handle_eavesdrop_state(delta, dist_to_player)

		State.AFRAID:
			_handle_afraid_state(delta, dist_to_player)

		State.PANIC_RUN:
			_handle_panic_run(delta)

	_animate_textbox_scale(delta)
	move_and_slide()

	if is_on_wall():
		_handle_wall_collision()

	queue_redraw()

# ── Handlers Logika State ───────────────────────────────────────────────────
func _handle_travel_state(delta: float, dist_to_player: float) -> void:
	if dist_to_player <= too_close_radius:
		current_state = State.AFRAID
		panic_timer = 0.0
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return
	elif dist_to_player <= eavesdrop_radius:
		current_state = State.EAVESDROP
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return

	# Sapaan saat berpapasan (tanpa berhenti jalan)
	if social_cooldown <= 0.0:
		_check_for_walking_greeting()

	var dist_to_goal = global_position.distance_to(target_destination)
	if dist_to_goal < 28.0:
		# Tiba di area pejalan kaki tujuan ➔ Istirahat singkat
		current_state = State.IDLE
		idle_hangout_timer = randf_range(1.5, 3.2)
		velocity = Vector2.ZERO
		is_moving = false
		return

	var move_dir = (target_destination - global_position).normalized()
	move_dir_facing = move_dir
	velocity = move_dir * walk_speed
	is_moving = true
	step_cycle += delta * 4.5
	body_bob_y = abs(sin(step_cycle)) * -1.5
	tremble_offset = Vector2.ZERO

func _handle_idle_state(delta: float, dist_to_player: float) -> void:
	if dist_to_player <= too_close_radius:
		current_state = State.AFRAID
		panic_timer = 0.0
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return
	elif dist_to_player <= eavesdrop_radius:
		current_state = State.EAVESDROP
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return

	velocity = Vector2.ZERO
	is_moving = false
	body_bob_y = move_toward(body_bob_y, 0.0, delta * 10.0)
	tremble_offset = Vector2.ZERO

	idle_hangout_timer -= delta
	if idle_hangout_timer <= 0.0:
		_pick_next_destination()

# ── Sapaan Berjalan Antar-NPC (Tanpa Macet di Jalan) ─────────────────────────
func _check_for_walking_greeting() -> void:
	var npcs = get_tree().get_nodes_in_group("npcs")
	for other in npcs:
		if other != self and is_instance_valid(other):
			if other.current_state == State.GO_TO_DESTINATION:
				var dist = global_position.distance_to(other.global_position)
				if dist < 60.0 and other.social_cooldown <= 0.0:
					var pool = SOCIAL_CHATS_POLICE if npc_type == NPCType.POLICE else SOCIAL_CHATS_CIVILIAN
					var msg = pool[randi() % pool.size()]
					show_chat_bubble(msg, 2.5)
					social_cooldown = 16.0
					other.social_cooldown = 16.0
					break

# ── Interaksi dengan Pemain (Benedict) ───────────────────────────────────────
func _handle_eavesdrop_state(delta: float, dist: float) -> void:
	if dist > eavesdrop_radius + 10.0:
		current_state = State.GO_TO_DESTINATION
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

	if msg_display_timer <= 0.0 and msg_cooldown_timer <= 0.0:
		_trigger_new_clue_dialogue()
		msg_cooldown_timer = MSG_COOLDOWN_DURATION
	elif msg_cooldown_timer > 0.0:
		msg_cooldown_timer -= delta

func _handle_afraid_state(delta: float, dist: float) -> void:
	if dist > too_close_radius and dist <= eavesdrop_radius:
		current_state = State.EAVESDROP
		tremble_offset = Vector2.ZERO
		return
	elif dist > eavesdrop_radius:
		current_state = State.GO_TO_DESTINATION
		is_textbox_visible = false
		panic_timer = 0.0
		velocity = Vector2.ZERO
		tremble_offset = Vector2.ZERO
		return

	panic_timer += delta
	velocity = Vector2.ZERO
	is_moving = false
	tremble_offset = Vector2(randf_range(-1.12, 1.12), randf_range(-1.12, 1.12))

	if msg_display_timer <= 0.0 and msg_cooldown_timer <= 0.0 and panic_timer < panic_time_limit - 0.5:
		_trigger_new_clue_dialogue()
		msg_cooldown_timer = MSG_COOLDOWN_DURATION
	elif msg_cooldown_timer > 0.0:
		msg_cooldown_timer -= delta

	if panic_timer >= panic_time_limit:
		current_state = State.PANIC_RUN
		run_timer = 3.0
		current_text_msg = PANIC_MESSAGES[randi() % PANIC_MESSAGES.size()]
		show_chat_bubble(current_text_msg, 3.0)

		if is_instance_valid(player_ref):
			run_direction = (global_position - player_ref.global_position).normalized()
			if run_direction == Vector2.ZERO:
				run_direction = Vector2.RIGHT
		else:
			run_direction = Vector2.RIGHT

func _handle_panic_run(delta: float) -> void:
	run_timer -= delta
	velocity = run_direction * run_speed
	is_moving = true
	step_cycle += delta * 12.0
	body_bob_y = abs(sin(step_cycle)) * -3.0
	tremble_offset = Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))

	if run_timer <= 0.0:
		current_state = State.DESPAWNED
		is_textbox_visible = false
		queue_free()

func _handle_wall_collision() -> void:
	var wall_normal = get_wall_normal()
	if current_state == State.GO_TO_DESTINATION:
		# Meluncur mulus menghindari sudut dinding
		var slide_dir = velocity.slide(wall_normal).normalized()
		if slide_dir != Vector2.ZERO:
			velocity = slide_dir * walk_speed
	elif current_state == State.PANIC_RUN:
		var slide_dir = run_direction.slide(wall_normal).normalized()
		if slide_dir == Vector2.ZERO or slide_dir.length() < 0.1:
			slide_dir = wall_normal
		run_direction = slide_dir
		velocity = run_direction * run_speed

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
		move_dir = move_dir_facing.normalized()
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

	# 1. Bayangan lantai oval untuk NPC
	draw_set_transform(draw_pos, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 6), 7.5, Color(0, 0, 0, 0.32))
	draw_set_transform(draw_pos, 0.0, Vector2.ONE)

	# 2. Render Sprite Custom Texture Sesuai NPCType
	var cur_tex = _get_current_npc_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		var calculated_scale = target_height_px / max(size.y, 1.0)
		
		draw_set_transform(draw_pos, 0.0, Vector2(calculated_scale, calculated_scale))
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 8.0)
		draw_texture(cur_tex, draw_offset)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
