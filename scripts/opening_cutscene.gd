extends Node2D

# ── Opening Cutscene - Atmospheric Dark Pixel Intro ─────────────────────────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami

const NEXT_SCENE_PATH = "res://scenes/main.tscn"
const TYPING_SPEED    = 0.05  # Detik per karakter untuk quote
const AUTHOR_SPEED    = 0.04  # Detik per karakter untuk nama penulis

const QUOTE_TEXT = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT = "— Haruki Murakami"

# ── Referensi Node (Programmatic / Onready) ─────────────────────────────────
var bg_rect: ColorRect
var fog_particles1: CPUParticles2D
var fog_particles2: CPUParticles2D
var vignette_rect: ColorRect
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

# ── Membangun Hierarki Node ────────────────────────────────────────────────
func _build_scene_nodes() -> void:
	# 1. Background Void Hitam-Ungu Pezat
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.03, 0.02, 0.06, 1.0)
	bg_rect.size = Vector2(1280, 720)
	add_child(bg_rect)

	# 2. Kabut Layer 1 (CPUParticles2D - Lembut Melayang)
	fog_particles1 = CPUParticles2D.new()
	fog_particles1.position = Vector2(-100, 360)
	fog_particles1.amount = 35
	fog_particles1.lifetime = 14.0
	fog_particles1.preprocess = 7.0
	fog_particles1.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles1.emission_rect_extents = Vector2(50, 400)
	fog_particles1.gravity = Vector2(0, 0)
	fog_particles1.direction = Vector2(1, 0)
	fog_particles1.spread = 15.0
	fog_particles1.initial_velocity_min = 25.0
	fog_particles1.initial_velocity_max = 50.0
	fog_particles1.scale_amount_min = 60.0
	fog_particles1.scale_amount_max = 140.0
	fog_particles1.color = Color(0.35, 0.3, 0.5, 0.08)
	add_child(fog_particles1)

	# 3. Kabut Layer 2 (Kabut Bawah Lebih Gelap & Cepat)
	fog_particles2 = CPUParticles2D.new()
	fog_particles2.position = Vector2(1380, 450)
	fog_particles2.amount = 25
	fog_particles2.lifetime = 10.0
	fog_particles2.preprocess = 5.0
	fog_particles2.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles2.emission_rect_extents = Vector2(50, 300)
	fog_particles2.gravity = Vector2(0, 0)
	fog_particles2.direction = Vector2(-1, 0)
	fog_particles2.spread = 20.0
	fog_particles2.initial_velocity_min = 35.0
	fog_particles2.initial_velocity_max = 70.0
	fog_particles2.scale_amount_min = 80.0
	fog_particles2.scale_amount_max = 180.0
	fog_particles2.color = Color(0.2, 0.15, 0.32, 0.06)
	add_child(fog_particles2)

	# 4. Container UI Tengah
	var ui_container = VBoxContainer.new()
	ui_container.position = Vector2(190, 240)
	ui_container.size = Vector2(900, 300)
	ui_container.add_theme_constant_override("separation", 24)
	add_child(ui_container)

	# 5. Label Quote
	quote_label = Label.new()
	quote_label.text = ""
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(0.92, 0.9, 0.98))
	quote_label.add_theme_font_size_override("font_size", 28)
	ui_container.add_child(quote_label)

	# 6. Label Penulis (Haruki Murakami)
	author_label = Label.new()
	author_label.text = ""
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.75, 0.65, 0.9))
	author_label.add_theme_font_size_override("font_size", 20)
	ui_container.add_child(author_label)

	# 7. Petunjuk Skip / Lanjut
	skip_hint_label = Label.new()
	skip_hint_label.text = "[ Tekan SPACE / Klik untuk lanjut ]"
	skip_hint_label.position = Vector2(440, 660)
	skip_hint_label.size = Vector2(400, 30)
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.55, 0.6))
	skip_hint_label.add_theme_font_size_override("font_size", 13)
	add_child(skip_hint_label)

	# 8. Overlay Transition Fade (Hitam)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1.0)
	fade_rect.size = Vector2(1280, 720)
	add_child(fade_rect)

# ── Suara Ketikan Mesin Tik Sintetis (Tanpa File Audio Eksternal) ───────────
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
	# Buat 20ms suara 'clack' mesin tik sintetis
	var sample_count = int(22050 * 0.018)
	var freq = randf_range(1200.0, 1800.0)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var sample = Math.sin(t * freq * TAU) * (1.0 - (float(i) / sample_count)) * 0.15
		if audio_generator.can_push_buffer(1):
			audio_generator.push_frame(Vector2(sample, sample))

# Math.sin helper
class Math:
	static func sin(v: float) -> float:
		return sin(v)

# ── State Machine & Loop Processing ─────────────────────────────────────────
func _start_cutscene() -> void:
	current_state = State.FADE_IN
	fade_alpha = 1.0
	quote_label.text = ""
	author_label.text = ""

func _process(delta: float) -> void:
	# Animasi kedip lembut tombol skip hint
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.4 + 0.4 * sin(Time.get_ticks_msec() * 0.003)

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
					state_timer = 2.8

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
