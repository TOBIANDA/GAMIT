extends Node2D

# ── Opening Cutscene v5 - Fullscreen Responsive, Drifting Fog & Typewriter Audio ───
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur:
# 1. Fullscreen Otomatis & Dynamic Viewport Resize
# 2. Tiga Layer Awan Kabut Melayang (Drifting Fog Particles)
# 3. Efek Mesin Tik Karakter-demi-Karakter + Suara Ketikan Sintetis
# 4. Aura Glow Misterius & Transisi Fade Halus

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT   = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT  = "— Haruki Murakami"
const TYPING_SPEED = 0.045
const AUTHOR_SPEED = 0.050

# Referensi Node
var bg_rect: ColorRect
var center_glow: ColorRect
var fog_particles1: CPUParticles2D
var fog_particles2: CPUParticles2D
var fog_particles3: CPUParticles2D
var ui_center: CenterContainer
var text_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label
var fade_rect: ColorRect

# Audio Generator untuk suara ketikan mesin tik sintetis
var audio_player: AudioStreamPlayer
var audio_generator: AudioStreamGeneratorPlayback

# State Machine
enum State { FADE_IN, TYPING_QUOTE, WAIT_AUTHOR, TYPING_AUTHOR, HOLD, FADE_OUT, DONE }
var current_state: State = State.FADE_IN

var state_timer: float = 0.0
var char_index: int = 0
var typing_timer: float = 0.0
var fade_alpha: float = 1.0

func _ready() -> void:
	_build_scene_nodes()
	_setup_synthetic_audio()
	_start_cutscene()

	# Listen resize viewport agar selalu full-screen sempurna
	get_viewport().size_changed.connect(_on_viewport_resized)

# ── Membangun Hierarki Node Fullscreen ──────────────────────────────────────
func _build_scene_nodes() -> void:
	var vp = get_viewport_rect().size
	if vp.x < 100 or vp.y < 100:
		vp = Vector2(1600, 900)

	# 1. Background Void Hitam-Ungu Gelap Fullscreen
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.02, 0.015, 0.04, 1.0)
	bg_rect.position = Vector2.ZERO
	bg_rect.size = vp * 2.0
	add_child(bg_rect)

	# 2. Glow Center Aura (Pusat Cahaya Ungu)
	center_glow = ColorRect.new()
	center_glow.color = Color(0.25, 0.12, 0.40, 0.22)
	center_glow.position = Vector2(vp.x * 0.15, vp.y * 0.2)
	center_glow.size = Vector2(vp.x * 0.7, vp.y * 0.6)
	add_child(center_glow)

	# 3. Layer Awan Kabut 1 (Dari Kiri Melayang ke Kanan)
	fog_particles1 = CPUParticles2D.new()
	fog_particles1.position = Vector2(-80, vp.y * 0.45)
	fog_particles1.amount = 55
	fog_particles1.lifetime = 12.0
	fog_particles1.preprocess = 6.0
	fog_particles1.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles1.emission_rect_extents = Vector2(50, vp.y * 0.55)
	fog_particles1.gravity = Vector2(0, 0)
	fog_particles1.direction = Vector2(1, 0.05)
	fog_particles1.spread = 18.0
	fog_particles1.initial_velocity_min = 40.0
	fog_particles1.initial_velocity_max = 85.0
	fog_particles1.scale_amount_min = 100.0
	fog_particles1.scale_amount_max = 240.0
	fog_particles1.color = Color(0.40, 0.32, 0.60, 0.16)
	add_child(fog_particles1)

	# 4. Layer Awan Kabut 2 (Dari Kanan Melayang ke Kiri)
	fog_particles2 = CPUParticles2D.new()
	fog_particles2.position = Vector2(vp.x + 80, vp.y * 0.5)
	fog_particles2.amount = 45
	fog_particles2.lifetime = 10.0
	fog_particles2.preprocess = 5.0
	fog_particles2.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles2.emission_rect_extents = Vector2(50, vp.y * 0.5)
	fog_particles2.gravity = Vector2(0, 0)
	fog_particles2.direction = Vector2(-1, -0.05)
	fog_particles2.spread = 22.0
	fog_particles2.initial_velocity_min = 45.0
	fog_particles2.initial_velocity_max = 90.0
	fog_particles2.scale_amount_min = 120.0
	fog_particles2.scale_amount_max = 260.0
	fog_particles2.color = Color(0.28, 0.20, 0.44, 0.14)
	add_child(fog_particles2)

	# 5. Layer Awan Kabut 3 (Kabut Bawah Melayang Naik)
	fog_particles3 = CPUParticles2D.new()
	fog_particles3.position = Vector2(vp.x * 0.5, vp.y + 30)
	fog_particles3.amount = 35
	fog_particles3.lifetime = 8.0
	fog_particles3.preprocess = 4.0
	fog_particles3.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles3.emission_rect_extents = Vector2(vp.x * 0.55, 30)
	fog_particles3.gravity = Vector2(0, -12)
	fog_particles3.direction = Vector2(0, -1)
	fog_particles3.spread = 30.0
	fog_particles3.initial_velocity_min = 20.0
	fog_particles3.initial_velocity_max = 50.0
	fog_particles3.scale_amount_min = 140.0
	fog_particles3.scale_amount_max = 300.0
	fog_particles3.color = Color(0.32, 0.25, 0.48, 0.12)
	add_child(fog_particles3)

	# 6. Container UI Tengah Presisi Fullscreen
	ui_center = CenterContainer.new()
	ui_center.position = Vector2.ZERO
	ui_center.size = vp
	add_child(ui_center)

	text_container = VBoxContainer.new()
	text_container.custom_minimum_size = Vector2(min(vp.x * 0.85, 1100.0), 0)
	text_container.add_theme_constant_override("separation", 28)
	ui_center.add_child(text_container)

	# 7. Label Quote (Besar, Berbayang & Elegan)
	quote_label = Label.new()
	quote_label.text = ""
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(1.0, 0.98, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.1, 0.05, 0.2, 0.95))
	quote_label.add_theme_constant_override("shadow_offset_x", 3)
	quote_label.add_theme_constant_override("shadow_offset_y", 3)
	quote_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	quote_label.add_theme_constant_override("outline_size", 5)
	quote_label.add_theme_font_size_override("font_size", 34)
	text_container.add_child(quote_label)

	# 8. Label Penulis (Haruki Murakami)
	author_label = Label.new()
	author_label.text = ""
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.85, 0.72, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.04, 0.15, 0.95))
	author_label.add_theme_constant_override("shadow_offset_x", 2)
	author_label.add_theme_constant_override("shadow_offset_y", 2)
	author_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	author_label.add_theme_constant_override("outline_size", 4)
	author_label.add_theme_font_size_override("font_size", 24)
	text_container.add_child(author_label)

	# 9. Petunjuk Skip / Lanjut di Bagian Bawah Layar
	skip_hint_label = Label.new()
	skip_hint_label.text = "[ SPACE / Klik untuk lanjut ]"
	skip_hint_label.position = Vector2(0, vp.y - 65)
	skip_hint_label.size = Vector2(vp.x, 30)
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.65, 0.75))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 3)
	skip_hint_label.add_theme_font_size_override("font_size", 14)
	add_child(skip_hint_label)

	# 10. Overlay Transition Fade (Hitam)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1.0)
	fade_rect.position = Vector2.ZERO
	fade_rect.size = vp * 2.0
	add_child(fade_rect)

# ── Dynamic Responsive Resize ────────────────────────────────────────────────
func _on_viewport_resized() -> void:
	var vp = get_viewport_rect().size
	if is_instance_valid(bg_rect):
		bg_rect.size = vp * 2.0
	if is_instance_valid(fade_rect):
		fade_rect.size = vp * 2.0
	if is_instance_valid(center_glow):
		center_glow.position = Vector2(vp.x * 0.15, vp.y * 0.2)
		center_glow.size = Vector2(vp.x * 0.7, vp.y * 0.6)
	if is_instance_valid(ui_center):
		ui_center.size = vp
	if is_instance_valid(skip_hint_label):
		skip_hint_label.position = Vector2(0, vp.y - 65)
		skip_hint_label.size = Vector2(vp.x, 30)
	if is_instance_valid(fog_particles2):
		fog_particles2.position = Vector2(vp.x + 80, vp.y * 0.5)
	if is_instance_valid(fog_particles3):
		fog_particles3.position = Vector2(vp.x * 0.5, vp.y + 30)

# ── Suara Ketikan Mesin Tik Sintetis ─────────────────────────────────────────
func _setup_synthetic_audio() -> void:
	audio_player = AudioStreamPlayer.new()
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.1
	audio_player.stream = generator
	add_child(audio_player)
	audio_player.play()
	audio_generator = audio_player.get_stream_playback()

func _play_typewriter_click() -> void:
	if audio_generator == null:
		return
	var sample_count = int(22050 * 0.018)
	var freq = randf_range(1200.0, 1800.0)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var sample = sin(t * freq * TAU) * (1.0 - (float(i) / sample_count)) * 0.15
		if audio_generator.can_push_buffer(1):
			audio_generator.push_frame(Vector2(sample, sample))

# ── State Machine & Loop Processing ─────────────────────────────────────────
func _start_cutscene() -> void:
	current_state = State.FADE_IN
	fade_alpha = 1.0
	quote_label.text = ""
	author_label.text = ""

func _process(delta: float) -> void:
	# Animasi kedip lembut tombol skip hint
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.4 + 0.45 * sin(Time.get_ticks_msec() * 0.0035)

	match current_state:
		State.FADE_IN:
			fade_alpha = move_toward(fade_alpha, 0.0, delta * 1.2)
			fade_rect.color.a = fade_alpha
			if fade_alpha <= 0.0:
				current_state = State.TYPING_QUOTE
				char_index = 0
				typing_timer = 0.0

		State.TYPING_QUOTE:
			typing_timer += delta
			if typing_timer >= TYPING_SPEED:
				typing_timer = 0.0
				if char_index < QUOTE_TEXT.length():
					quote_label.text += QUOTE_TEXT[char_index]
					_play_typewriter_click()
					char_index += 1
				else:
					current_state = State.WAIT_AUTHOR
					state_timer = 0.6

		State.WAIT_AUTHOR:
			state_timer -= delta
			if state_timer <= 0.0:
				current_state = State.TYPING_AUTHOR
				char_index = 0
				typing_timer = 0.0

		State.TYPING_AUTHOR:
			typing_timer += delta
			if typing_timer >= AUTHOR_SPEED:
				typing_timer = 0.0
				if char_index < AUTHOR_TEXT.length():
					author_label.text += AUTHOR_TEXT[char_index]
					_play_typewriter_click()
					char_index += 1
				else:
					current_state = State.HOLD
					state_timer = 2.6

		State.HOLD:
			state_timer -= delta
			if state_timer <= 0.0:
				_start_fade_out()

		State.FADE_OUT:
			fade_alpha = move_toward(fade_alpha, 1.0, delta * 1.0)
			fade_rect.color.a = fade_alpha
			if fade_alpha >= 1.0:
				current_state = State.DONE
				_change_to_main_scene()

# ── User Input (Skip / Speed Up) ────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_ESCAPE]:
			_handle_user_skip()
	elif event is InputEventMouseButton and event.pressed:
		_handle_user_skip()

func _handle_user_skip() -> void:
	match current_state:
		State.TYPING_QUOTE, State.WAIT_AUTHOR:
			# Instan tampilkan seluruh quote
			quote_label.text = QUOTE_TEXT
			current_state = State.TYPING_AUTHOR
			char_index = 0

		State.TYPING_AUTHOR:
			# Instan tampilkan nama penulis & masuk ke HOLD
			author_label.text = AUTHOR_TEXT
			current_state = State.HOLD
			state_timer = 1.0

		State.HOLD:
			# Langsung fade out ke scene utama
			_start_fade_out()

func _start_fade_out() -> void:
	current_state = State.FADE_OUT

func _change_to_main_scene() -> void:
	print("[OpeningCutscene] Transisi ke scene utama: ", NEXT_SCENE_PATH)
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
