extends Control

# ── Cinematic Opening Cutscene v7 - 100% Guaranteed Control Hierarchy ───────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur:
# 1. Root Control Full-Screen (PRESET_FULL_RECT) - Bekerja di semua Renderer
# 2. Background Void Deep Indigo + Glowing Nebula Center Glow
# 3. Layer Awan Kabut Melayang Dinamis (Animasi Sinusoidal Halus)
# 4. Efek Ketikan Mesin Tik Karakter-demi-Karakter + Kursor Berkedip '|'
# 5. Audio Mesin Tik Sintetis Aman (Safe Audio Playback)
# 6. Tombol Skip / Klik Mouse Langsung Masuk ke Gameplay

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

# Node UI
var bg_color_rect: ColorRect
var nebula_glow: Panel
var stars_container: Control
var fog_container: Control
var ui_center: CenterContainer
var text_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label
var fade_overlay: ColorRect

# Audio Generator Mesin Tik
var audio_player: AudioStreamPlayer
var audio_generator: AudioStreamGeneratorPlayback

# Data Awan Kabut
var fog_items: Array[Dictionary] = []

func _ready() -> void:
	# Set Control Fullscreen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	_build_ui_tree()
	_setup_audio()
	_start_cutscene()

# ── Membangun Hierarki UI Control Fullscreen ────────────────────────────────
func _build_ui_tree() -> void:
	# 1. Background Gelap Deep Indigo
	bg_color_rect = ColorRect.new()
	bg_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_color_rect.color = Color(0.04, 0.025, 0.07, 1.0)
	bg_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_color_rect)

	# 2. Glowing Nebula Center Aura (Panel dengan StyleBox Circular Glow)
	nebula_glow = Panel.new()
	nebula_glow.set_anchors_preset(Control.PRESET_CENTER)
	nebula_glow.custom_minimum_size = Vector2(800, 500)
	nebula_glow.position = Vector2(-400, -250)
	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = Color(0.35, 0.15, 0.55, 0.22)
	glow_style.set_corner_radius_all(250)
	glow_style.shadow_color = Color(0.40, 0.18, 0.65, 0.30)
	glow_style.shadow_size = 80
	nebula_glow.add_theme_stylebox_override("panel", glow_style)
	nebula_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(nebula_glow)

	# 3. Layer Awan Kabut Melayang
	fog_container = Control.new()
	fog_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	fog_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fog_container)

	fog_items.clear()
	for i in range(16):
		var pnl = Panel.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(randf_range(0.30, 0.55), randf_range(0.18, 0.38), randf_range(0.60, 0.85), randf_range(0.08, 0.16))
		var r = randf_range(90, 180)
		p_style.set_corner_radius_all(int(r))
		pnl.add_theme_stylebox_override("panel", p_style)
		pnl.custom_minimum_size = Vector2(r * 2.0, r * 1.4)
		pnl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fog_container.add_child(pnl)

		fog_items.append({
			"node": pnl,
			"pos": Vector2(randf_range(-100, 1700), randf_range(50, 850)),
			"speed": randf_range(25.0, 60.0),
			"radius": r,
			"phase": randf() * TAU
		})

	# 4. Container Teks Tengah Presisi
	ui_center = CenterContainer.new()
	ui_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_center)

	text_container = VBoxContainer.new()
	text_container.custom_minimum_size = Vector2(1100, 0)
	text_container.add_theme_constant_override("separation", 24)
	ui_center.add_child(text_container)

	# Label Quote Utama: Putih Terang, Outline Hitam Tebal & Shadow Violet
	quote_label = Label.new()
	quote_label.text = ""
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.40, 0.15, 0.70, 1.0))
	quote_label.add_theme_constant_override("shadow_offset_x", 3)
	quote_label.add_theme_constant_override("shadow_offset_y", 3)
	quote_label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.02, 1.0))
	quote_label.add_theme_constant_override("outline_size", 8)
	quote_label.add_theme_font_size_override("font_size", 34)
	text_container.add_child(quote_label)

	# Label Penulis: Ungu Muda Terang
	author_label = Label.new()
	author_label.text = ""
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.92, 0.82, 1.0, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.30, 0.10, 0.50, 1.0))
	author_label.add_theme_constant_override("shadow_offset_x", 2)
	author_label.add_theme_constant_override("shadow_offset_y", 2)
	author_label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.02, 1.0))
	author_label.add_theme_constant_override("outline_size", 6)
	author_label.add_theme_font_size_override("font_size", 24)
	text_container.add_child(author_label)

	# 5. Petunjuk Skip di Bawah Layar
	skip_hint_label = Label.new()
	skip_hint_label.text = "✦ [ SPACE / ENTER / KLIK ] UNTUK MEMULAI ✦"
	skip_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	skip_hint_label.offset_top = -65.0
	skip_hint_label.offset_bottom = -25.0
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.85, 0.80, 1.0, 0.9))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 4)
	skip_hint_label.add_theme_font_size_override("font_size", 15)
	add_child(skip_hint_label)

	# 6. Fade Overlay (Hanya aktif saat transisi)
	fade_overlay = ColorRect.new()
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_overlay)

# ── Suara Ketikan Mesin Tik ─────────────────────────────────────────────────
func _setup_audio() -> void:
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
	var sample_count = int(22050 * 0.02)
	var freq = randf_range(1350.0, 1900.0)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var decay = 1.0 - (float(i) / sample_count)
		var sample = sin(t * freq * TAU) * decay * 0.20
		if audio_generator.can_push_buffer(1):
			audio_generator.push_frame(Vector2(sample, sample))

# ── Loop Proses & Animasi ───────────────────────────────────────────────────
func _start_cutscene() -> void:
	current_state = State.FADE_IN
	fade_alpha = 1.0
	quote_label.text = ""
	author_label.text = ""

func _process(delta: float) -> void:
	anim_time += delta
	var vp_size = get_viewport_rect().size

	# 1. Update Posisi Awan Kabut
	for item in fog_items:
		var n: Panel = item["node"]
		item["pos"].x += item["speed"] * delta
		item["pos"].y += sin(anim_time * 0.7 + item["phase"]) * 14.0 * delta
		if item["pos"].x > vp_size.x + item["radius"]:
			item["pos"].x = -item["radius"] * 2.0
			item["pos"].y = randf_range(30, vp_size.y - 100)
		if is_instance_valid(n):
			n.position = item["pos"]

	# 2. Animasi Pulsing Nebula Glow di Tengah
	if is_instance_valid(nebula_glow):
		nebula_glow.position = Vector2(vp_size.x * 0.5 - 400, vp_size.y * 0.5 - 250)
		var p_scale = 1.0 + 0.06 * sin(anim_time * 1.8)
		nebula_glow.scale = Vector2(p_scale, p_scale)

	# 3. Kedip Tombol Skip
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.5 + 0.45 * abs(sin(anim_time * 3.0))

	# 4. Kursor Ketik
	var cursor = " |" if int(anim_time * 4.0) % 2 == 0 else ""

	# 5. State Machine Ketikan
	match current_state:
		State.FADE_IN:
			fade_alpha = move_toward(fade_alpha, 0.0, delta * 1.8)
			fade_overlay.color.a = fade_alpha
			if fade_alpha <= 0.0:
				current_state = State.TYPING_QUOTE
				char_index = 0
				typing_timer = 0.0

		State.TYPING_QUOTE:
			fade_overlay.visible = false
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
			fade_overlay.visible = true
			fade_alpha = move_toward(fade_alpha, 1.0, delta * 1.8)
			fade_overlay.color.a = fade_alpha
			if fade_alpha >= 1.0:
				current_state = State.DONE
				_change_to_main_scene()

# ── User Input Skip ─────────────────────────────────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_handle_user_skip()

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
	print("[OpeningCutscene] Masuk ke gameplay utama: ", NEXT_SCENE_PATH)
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
