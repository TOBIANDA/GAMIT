extends Node2D

# ── Cinematic Opening Cutscene v6 - Vivid Fog Clouds, Bright Glow & Typewriter ──
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur:
# 1. Background Nebula Ungu-Indigo Bergradasi Mewah & Bintang Debu Berkilau
# 2. Layer Awan Kabut Melayang Dinamis (Drifting Mist Clouds dengan animasi lembut)
# 3. Tipografi Teks Terang Menyala (White Glow) + Kursor Ketik Berkedip '|'
# 4. Efek Suara Mesin Tik Sintetis Retro
# 5. Tombol Skip / Klik Langsung Masuk ke Game Utama

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT   = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT  = "— Haruki Murakami"
const TYPING_SPEED = 0.042
const AUTHOR_SPEED = 0.048

# State Machine
enum State { FADE_IN, TYPING_QUOTE, WAIT_AUTHOR, TYPING_AUTHOR, HOLD, FADE_OUT, DONE }
var current_state: State = State.FADE_IN

var state_timer: float = 0.0
var char_index: int = 0
var typing_timer: float = 0.0
var fade_alpha: float = 1.0
var anim_time: float = 0.0

# UI Controls
var ui_center: CenterContainer
var text_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label

# Audio Generator Mesin Tik
var audio_player: AudioStreamPlayer
var audio_generator: AudioStreamGeneratorPlayback

# Struktur Data Awan Kabut & Bintang
var fog_clouds: Array[Dictionary] = []
var stars: Array[Vector2] = []

func _ready() -> void:
	_init_fog_and_stars()
	_build_ui_nodes()
	_setup_synthetic_audio()
	_start_cutscene()
	get_viewport().size_changed.connect(queue_redraw)

# ── Inisialisasi Partikel Awan Kabut & Bintang ──────────────────────────────
func _init_fog_and_stars() -> void:
	fog_clouds.clear()
	stars.clear()

	# 18 Gumpalan Awan Kabut Atmosferik
	for i in range(22):
		fog_clouds.append({
			"pos": Vector2(randf_range(-100, 1800), randf_range(50, 950)),
			"speed": randf_range(18.0, 48.0),
			"radius": randf_range(120.0, 260.0),
			"color": Color(randf_range(0.35, 0.55), randf_range(0.20, 0.40), randf_range(0.65, 0.90), randf_range(0.08, 0.18)),
			"phase": randf() * TAU
		})

	# 45 Bintang Berkilau di Latar Belakang
	for i in range(50):
		stars.append(Vector2(randf_range(0, 1920), randf_range(0, 1080)))

# ── Membangun UI Tipografi yang Terang & Tajam ──────────────────────────────
func _build_ui_nodes() -> void:
	var vp = get_viewport_rect().size
	if vp.x < 100 or vp.y < 100:
		vp = Vector2(1600, 900)

	ui_center = CenterContainer.new()
	ui_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_center)

	text_container = VBoxContainer.new()
	text_container.custom_minimum_size = Vector2(min(vp.x * 0.88, 1150.0), 0)
	text_container.add_theme_constant_override("separation", 24)
	ui_center.add_child(text_container)

	# Label Quote Utama: Putih Terang, Outline Tebal, dan Bayangan Violet
	quote_label = Label.new()
	quote_label.text = ""
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.35, 0.15, 0.60, 0.95))
	quote_label.add_theme_constant_override("shadow_offset_x", 4)
	quote_label.add_theme_constant_override("shadow_offset_y", 4)
	quote_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.05, 1.0))
	quote_label.add_theme_constant_override("outline_size", 8)
	quote_label.add_theme_font_size_override("font_size", 36)
	text_container.add_child(quote_label)

	# Label Penulis: Ungu Muda Terang
	author_label = Label.new()
	author_label.text = ""
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.92, 0.80, 1.0, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.25, 0.10, 0.45, 0.95))
	author_label.add_theme_constant_override("shadow_offset_x", 3)
	author_label.add_theme_constant_override("shadow_offset_y", 3)
	author_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.05, 1.0))
	author_label.add_theme_constant_override("outline_size", 6)
	author_label.add_theme_font_size_override("font_size", 24)
	text_container.add_child(author_label)

	# Hint Skip di Bawah
	skip_hint_label = Label.new()
	skip_hint_label.text = "✦ [ SPACE / ENTER / KLIK ] UNTUK MEMULAI ✦"
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.85, 0.80, 1.0, 0.85))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 4)
	skip_hint_label.add_theme_font_size_override("font_size", 15)
	add_child(skip_hint_label)

# ── Suara Ketikan Mesin Tik ─────────────────────────────────────────────────
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
	var sample_count = int(22050 * 0.022)
	var freq = randf_range(1350.0, 1950.0)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var decay = 1.0 - (float(i) / sample_count)
		var sample = sin(t * freq * TAU) * decay * 0.22
		if audio_generator.can_push_buffer(1):
			audio_generator.push_frame(Vector2(sample, sample))

# ── Loop Animasi & State Machine ────────────────────────────────────────────
func _start_cutscene() -> void:
	current_state = State.FADE_IN
	fade_alpha = 1.0
	quote_label.text = ""
	author_label.text = ""

func _process(delta: float) -> void:
	anim_time += delta

	# 1. Update Posisi Awan Kabut (Melayang ke Kanan Secara Sinusoidal)
	var vp = get_viewport_rect().size
	for cloud in fog_clouds:
		cloud["pos"].x += cloud["speed"] * delta
		cloud["pos"].y += sin(anim_time * 0.6 + cloud["phase"]) * 12.0 * delta
		if cloud["pos"].x > vp.x + cloud["radius"]:
			cloud["pos"].x = -cloud["radius"]
			cloud["pos"].y = randf_range(40, vp.y - 40)

	# 2. Update Posisi Hint Label di Bawah
	if is_instance_valid(skip_hint_label):
		skip_hint_label.position = Vector2(0, vp.y - 60)
		skip_hint_label.size = Vector2(vp.x, 30)
		skip_hint_label.modulate.a = 0.45 + 0.5 * abs(sin(anim_time * 2.8))

	# 3. Kursor Ketik Berkedip
	var cursor = " |" if int(anim_time * 4.0) % 2 == 0 else ""

	# 4. State Machine
	match current_state:
		State.FADE_IN:
			fade_alpha = move_toward(fade_alpha, 0.0, delta * 1.5)
			if fade_alpha <= 0.0:
				current_state = State.TYPING_QUOTE
				char_index = 0
				typing_timer = 0.0

		State.TYPING_QUOTE:
			typing_timer += delta
			if typing_timer >= TYPING_SPEED:
				typing_timer = 0.0
				if char_index < QUOTE_TEXT.length():
					char_index += 1
					quote_label.text = QUOTE_TEXT.substr(0, char_index) + cursor
					_play_typewriter_click()
				else:
					quote_label.text = QUOTE_TEXT
					current_state = State.WAIT_AUTHOR
					state_timer = 0.5

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
					char_index += 1
					author_label.text = AUTHOR_TEXT.substr(0, char_index) + cursor
					_play_typewriter_click()
				else:
					author_label.text = AUTHOR_TEXT
					current_state = State.HOLD
					state_timer = 3.2

		State.HOLD:
			state_timer -= delta
			if state_timer <= 0.0:
				_start_fade_out()

		State.FADE_OUT:
			fade_alpha = move_toward(fade_alpha, 1.0, delta * 1.6)
			if fade_alpha >= 1.0:
				current_state = State.DONE
				_change_to_main_scene()

	queue_redraw()

# ── Render Visual Background, Awan Kabut & Glow ─────────────────────────────
func _draw() -> void:
	var vp = get_viewport_rect().size
	if vp.x < 100 or vp.y < 100:
		vp = Vector2(1600, 900)

	# 1. Background Void Gelap Mewah (Deep Indigo Twilight)
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.03, 0.02, 0.06, 1.0), true)

	# 2. Radiant Central Aura Glow (Pusat Cahaya Ungu Menyala Lembut)
	var center = vp * 0.5
	var pulse_glow = 1.0 + 0.08 * sin(anim_time * 1.5)
	draw_circle(center, 420.0 * pulse_glow, Color(0.20, 0.10, 0.35, 0.25))
	draw_circle(center, 260.0 * pulse_glow, Color(0.32, 0.15, 0.52, 0.30))
	draw_circle(center, 120.0 * pulse_glow, Color(0.45, 0.22, 0.70, 0.35))

	# 3. Bintang / Debu Ethereal Berkilau
	for s in stars:
		var star_pos = Vector2(fmod(s.x, vp.x), fmod(s.y, vp.y))
		var twinkle = 0.3 + 0.7 * abs(sin(anim_time * 2.0 + s.x * 0.05))
		draw_circle(star_pos, 1.5, Color(0.85, 0.80, 1.0, 0.45 * twinkle))

	# 4. Awan Kabut Melayang (Drifting Fog Clouds)
	for cloud in fog_clouds:
		var c_alpha_pulse = 0.8 + 0.2 * sin(anim_time + cloud["phase"])
		var c_color = cloud["color"]
		c_color.a *= c_alpha_pulse
		draw_circle(cloud["pos"], cloud["radius"], c_color)
		draw_circle(cloud["pos"] + Vector2(cloud["radius"] * 0.25, -10), cloud["radius"] * 0.7, c_color * 1.15)

	# 5. Vignette Frame Pinggir Layar
	draw_rect(Rect2(0, 0, vp.x, 60), Color(0.01, 0.01, 0.03, 0.6), true)
	draw_rect(Rect2(0, vp.y - 60, vp.x, 60), Color(0.01, 0.01, 0.03, 0.6), true)

	# 6. Smooth Transition Fade Overlay (Hitam)
	if fade_alpha > 0.001:
		draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.0, 0.0, 0.0, fade_alpha), true)

# ── User Input (Skip / Langsung Masuk) ──────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_ESCAPE, KEY_F]:
			_handle_user_skip()
	elif event is InputEventMouseButton and event.pressed:
		_handle_user_skip()

func _handle_user_skip() -> void:
	match current_state:
		State.TYPING_QUOTE, State.WAIT_AUTHOR:
			quote_label.text = QUOTE_TEXT
			current_state = State.TYPING_AUTHOR
			char_index = 0
		State.TYPING_AUTHOR:
			author_label.text = AUTHOR_TEXT
			current_state = State.HOLD
			state_timer = 0.8
		State.HOLD, State.FADE_IN:
			_start_fade_out()

func _start_fade_out() -> void:
	current_state = State.FADE_OUT

func _change_to_main_scene() -> void:
	print("[OpeningCutscene] Pindah ke main gameplay: ", NEXT_SCENE_PATH)
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
