extends CharacterBody2D

# ── NPC System v3 - Subtle Eerie Mystery Dialogues & Flee Logic ─────────────
# Fitur:
# 1. Dekat player (<140px) -> Bisikkan petunjuk misteri secara halus (tidak merusak plot twist)
# 2. Textbox Growtopia HANYA MUNCUL 2 DETIK per percakapan (lalu hilang/cycle)
# 3. Durasi berhenti ketakutan sebelum lari = 7 DETIK!
# 4. Jauh dari player (>140px) -> Textbox langsung hilang & timer reset
# 5. Teriakan lari berupa ekspresi cemas/panik psikologis (tanpa sebut "setan" agar plot twist terjaga)

@export var detect_radius: float = 140.0
@export var panic_time_limit: float = 7.0  # 7 Detik ketakutan sebelum lari
@export var run_speed: float = 430.0
@export var wander_speed: float = 50.0

enum State { IDLE, WANDER, AFRAID, PANIC_RUN, DESPAWNED }
var current_state: State = State.IDLE

var player_ref: CharacterBody2D = null
var panic_timer: float = 0.0
var run_timer: float = 0.0
var run_direction: Vector2 = Vector2.ZERO
var tremble_offset: Vector2 = Vector2.ZERO

# Timer Tampil Textbox 2 Detik & Pause Antar Percakapan
var msg_display_timer: float = 0.0
var msg_cooldown_timer: float = 0.0
const MSG_DISPLAY_DURATION: float = 2.0  # Box hanya tampil 2 detik!
const MSG_COOLDOWN_DURATION: float = 1.0 # Pause 1 detik sebelum percakapan berikutnya

# Randomization visual NPC
var hair_color: Color
var shirt_color: Color
var pants_color: Color

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

# Pool Percakapan Misteri Halus (Menjaga Plot Twist / Tidak Obvious)
const CLUE_MESSAGES = [
	"Perasaanku tidak enak... hawa di sini dingin sekali...",
	"Jam dinding di ruangan itu... berhenti tepat jam dua.",
	"Mereka bilang... ada satu laporan investigasi yang belum selesai.",
	"Pakaianmu... rasanya aku pernah melihatnya di suatu tempat...",
	"Aneh... kenapa angin tidak menggerakkan pakaianmu sama sekali?",
	"Orang-orang di kota ini... tidak ada yang mau menjawabmu.",
	"Ada sesuatu tentang dirimu... yang membuatku merinding..."
]

# Pool Teriakan Panik (Gaya Psikologis Thriller, Tanpa Sebut "Setan")
const PANIC_MESSAGES = [
	"PERGI!! JANGAN MENDEKATIKU!! 🏃‍♂️",
	"Tolong! Rasanya tempat ini membuatku tercekik!! 🏃‍♂️",
	"Tidak... aku harus pergi dari sini sekarang!! 🏃‍♂️",
	"Aku tidak tahan lagi... hawa ini terlalu pekat!! 🏃‍♂️",
	"Jangan sentuh aku!! 🏃‍♂️"
]

func _ready() -> void:
	y_sort_enabled = true
	_generate_random_appearance()
	_build_growtopia_textbox()
	queue_redraw()

# ── Random Tampilan Visual NPC ──────────────────────────────────────────────
func _generate_random_appearance() -> void:
	var hairs = [
		Color(0.2, 0.15, 0.1),  # Cokelat tua
		Color(0.8, 0.6, 0.2),   # Pirang
		Color(0.1, 0.1, 0.12),  # Hitam
		Color(0.6, 0.25, 0.15), # Merah bata
		Color(0.4, 0.4, 0.45)   # Abu-abu
	]
	var shirts = [
		Color(0.85, 0.3, 0.25), # Merah
		Color(0.25, 0.65, 0.35),# Hijau
		Color(0.2, 0.5, 0.8),   # Biru
		Color(0.9, 0.7, 0.2),   # Kuning
		Color(0.6, 0.3, 0.7)    # Ungu
	]
	var pants = [
		Color(0.15, 0.18, 0.25), # Jeans gelap
		Color(0.3, 0.25, 0.2),   # Cokelat khaki
		Color(0.1, 0.1, 0.12)    # Hitam
	]
	hair_color  = hairs[randi() % hairs.size()]
	shirt_color = shirts[randi() % shirts.size()]
	pants_color = pants[randi() % pants.size()]

# ── Membuat UI Textbox Gaya Growtopia ───────────────────────────────────────
func _build_growtopia_textbox() -> void:
	var root_box = Node2D.new()
	root_box.name = "TextboxRoot"
	root_box.position = Vector2(0, -60)
	add_child(root_box)

	# Panel Putih Growtopia
	textbox_panel = PanelContainer.new()
	textbox_panel.position = Vector2(-90, -42)
	textbox_panel.size = Vector2(180, 38)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.98, 0.98, 0.98, 0.96)
	style_box.border_color = Color(0.08, 0.08, 0.12, 1.0)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(7)
	style_box.content_margin_left = 10.0
	style_box.content_margin_right = 10.0
	style_box.content_margin_top = 5.0
	style_box.content_margin_bottom = 5.0
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
		Vector2(-6, -2), Vector2(6, -2), Vector2(0, 7)
	])
	textbox_pointer.color = Color(0.98, 0.98, 0.98, 0.96)
	root_box.add_child(textbox_pointer)

	var pointer_outline = Line2D.new()
	pointer_outline.points = PackedVector2Array([
		Vector2(-6, -2), Vector2(0, 7), Vector2(6, -2)
	])
	pointer_outline.width = 2.0
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

	msg_display_timer = MSG_DISPLAY_DURATION # Tampil persis 2 detik
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

		State.AFRAID:
			_handle_afraid_state(delta, dist_to_player)

		State.PANIC_RUN:
			_handle_panic_run(delta)

	_animate_textbox_scale(delta)
	move_and_slide()
	queue_redraw()

# ── Logika State ────────────────────────────────────────────────────────────
func _handle_idle_wander(delta: float, dist: float) -> void:
	if dist <= detect_radius:
		current_state = State.AFRAID
		panic_timer = 0.0
		msg_cooldown_timer = 0.0
		_trigger_new_clue_dialogue()
		return

	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(2.5, 6.0)
		if randf() > 0.4:
			var angle = randf() * TAU
			wander_direction = Vector2(cos(angle), sin(angle))
			is_moving = true
		else:
			wander_direction = Vector2.ZERO
			is_moving = false

	if is_moving:
		velocity = wander_direction * wander_speed
		step_cycle += delta * 8.0
		body_bob_y = abs(sin(step_cycle)) * -2.0
	else:
		velocity = Vector2.ZERO
		body_bob_y = move_toward(body_bob_y, 0.0, delta * 10.0)

	tremble_offset = Vector2.ZERO

func _handle_afraid_state(delta: float, dist: float) -> void:
	# 1. Jika player MENJAUH (> detect_radius) -> Textbox LANGSUNG HILANG & Timer Reset
	if dist > detect_radius + 20.0:
		current_state = State.IDLE
		is_textbox_visible = false
		panic_timer = 0.0
		msg_display_timer = 0.0
		msg_cooldown_timer = 0.0
		velocity = Vector2.ZERO
		tremble_offset = Vector2.ZERO
		return

	# 2. Tambah Timer Ketakutan (Target: 7 DETIK berhenti ketakutan sebelum lari)
	panic_timer += delta
	velocity = Vector2.ZERO
	is_moving = false

	# Efek gemetar ketakutan
	tremble_offset = Vector2(randf_range(-1.8, 1.8), randf_range(-1.8, 1.8))

	# 3. Kelola Durasi Textbox Tampil PERSIS 2 DETIK
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

	# 4. Jika SUDAH 7 DETIK BERHENTI KETAKUTAN -> PANIC FLEE (LARI MENJAUH!)
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
	step_cycle += delta * 22.0
	body_bob_y = abs(sin(step_cycle)) * -5.0
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

# ── Custom Drawing Avatar ───────────────────────────────────────────────────
func _draw() -> void:
	if current_state == State.DESPAWNED:
		return

	var draw_pos = tremble_offset

	# Bayangan lantai
	draw_set_transform(draw_pos, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 8), 14.0, Color(0, 0, 0, 0.3))
	draw_set_transform(draw_pos, 0.0, Vector2.ONE)

	# Kaki
	var foot_l = draw_pos + Vector2(-6, 2)
	var foot_r = draw_pos + Vector2(6, 2)
	if is_moving:
		var swing = sin(step_cycle) * 4.0
		foot_l.y += swing
		foot_r.y -= swing

	draw_circle(foot_l, 3.5, pants_color)
	draw_circle(foot_r, 3.5, pants_color)

	# Badan
	var torso_pos = draw_pos + Vector2(0, -11 + body_bob_y)
	draw_rect(Rect2(torso_pos.x - 10, torso_pos.y - 6, 20, 15), shirt_color, true, 4.0)

	# Kepala & Rambut
	var head_pos = draw_pos + Vector2(0, -26 + body_bob_y)
	var skin_color = Color(0.96, 0.82, 0.72)
	draw_circle(head_pos, 11.0, skin_color)
	draw_circle(head_pos + Vector2(0, -4), 11.0, hair_color)

	# Mata Ketakutan
	if current_state in [State.AFRAID, State.PANIC_RUN]:
		draw_circle(head_pos + Vector2(-4, 1), 3.2, Color.WHITE)
		draw_circle(head_pos + Vector2(-4, 1), 1.2, Color.BLACK)
		draw_circle(head_pos + Vector2(4, 1), 3.2, Color.WHITE)
		draw_circle(head_pos + Vector2(4, 1), 1.2, Color.BLACK)
	else:
		draw_circle(head_pos + Vector2(-4, 1), 2.0, Color(0.1, 0.1, 0.15))
		draw_circle(head_pos + Vector2(4, 1), 2.0, Color(0.1, 0.1, 0.15))
