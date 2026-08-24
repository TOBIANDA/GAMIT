extends Control

# ── Cinematic Opening Cutscene v8 - Bright, Crystal Clear & Responsive ──────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT   = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT  = "— Haruki Murakami"
const TYPING_SPEED = 0.040
const AUTHOR_SPEED = 0.045

# State Machine
enum State { TYPING_QUOTE, WAIT_AUTHOR, TYPING_AUTHOR, HOLD, FADE_OUT, DONE }
var current_state: State = State.TYPING_QUOTE

var state_timer: float = 0.0
var char_index: int = 0
var typing_timer: float = 0.0
var anim_time: float = 0.0
var is_transitioning: bool = false

# UI Nodes
var bg_rect: ColorRect
var nebula_center: Panel
var fog_container: Control
var ui_center: CenterContainer
var text_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label

# Audio
var audio_player: AudioStreamPlayer
var audio_generator: AudioStreamGeneratorPlayback

# Fog items
var fog_items: Array[Dictionary] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	_build_scene()
	_setup_audio()
	_start()

func _build_scene() -> void:
	# 1. Background Void Deep Indigo Luminous
	bg_rect = ColorRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = Color(0.06, 0.04, 0.10, 1.0)
	bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_rect)

	# 2. Glowing Nebula Center Aura
	nebula_center = Panel.new()
	nebula_center.set_anchors_preset(Control.PRESET_CENTER)
	nebula_center.custom_minimum_size = Vector2(900, 550)
	nebula_center.position = Vector2(-450, -275)
	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = Color(0.35, 0.14, 0.60, 0.28)
	glow_style.set_corner_radius_all(275)
	glow_style.shadow_color = Color(0.45, 0.20, 0.75, 0.40)
	glow_style.shadow_size = 120
	nebula_center.add_theme_stylebox_override("panel", glow_style)
	nebula_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(nebula_center)

	# 3. Layer Awan Kabut Melayang
	fog_container = Control.new()
	fog_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	fog_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fog_container)

	fog_items.clear()
	for i in range(18):
		var pnl = Panel.new()
		var p_style = StyleBoxFlat.new()
		var r = randf_range(110, 220)
		p_style.bg_color = Color(randf_range(0.38, 0.60), randf_range(0.20, 0.42), randf_range(0.68, 0.95), randf_range(0.10, 0.20))
		p_style.set_corner_radius_all(int(r))
		pnl.add_theme_stylebox_override("panel", p_style)
		pnl.custom_minimum_size = Vector2(r * 2.0, r * 1.3)
		pnl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fog_container.add_child(pnl)

		fog_items.append({
			"node": pnl,
			"pos": Vector2(randf_range(-150, 1800), randf_range(40, 860)),
			"speed": randf_range(30.0, 70.0),
			"radius": r,
			"phase": randf() * TAU
		})

	# 4. Container Teks Tengah
	ui_center = CenterContainer.new()
	ui_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_center)

	text_container = VBoxContainer.new()
	text_container.custom_minimum_size = Vector2(1150, 0)
	text_container.add_theme_constant_override("separation", 28)
	ui_center.add_child(text_container)

	# Label Quote: Putih Terang Menyala
	quote_label = Label.new()
	quote_label.text = ""
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.45, 0.18, 0.80, 1.0))
	quote_label.add_theme_constant_override("shadow_offset_x", 4)
	quote_label.add_theme_constant_override("shadow_offset_y", 4)
	quote_label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.03, 1.0))
	quote_label.add_theme_constant_override("outline_size", 8)
	quote_label.add_theme_font_size_override("font_size", 36)
	text_container.add_child(quote_label)

	# Label Penulis: Ungu Muda Terang
	author_label = Label.new()
	author_label.text = ""
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.94, 0.84, 1.0, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.35, 0.12, 0.60, 1.0))
	author_label.add_theme_constant_override("shadow_offset_x", 3)
	author_label.add_theme_constant_override("shadow_offset_y", 3)
	author_label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.03, 1.0))
	author_label.add_theme_constant_override("outline_size", 6)
	author_label.add_theme_font_size_override("font_size", 24)
	text_container.add_child(author_label)

	# 5. Tombol Skip / Petunjuk di Bawah
	skip_hint_label = Label.new()
	skip_hint_label.text = "✦ [ SPACE / ENTER / KLIK MOUSE ] UNTUK MEMULAI ✦"
	skip_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	skip_hint_label.offset_top = -65.0
	skip_hint_label.offset_bottom = -20.0
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.90, 0.85, 1.0, 0.95))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 4)
	skip_hint_label.add_theme_font_size_override("font_size", 15)
	add_child(skip_hint_label)

# ── Suara Ketikan ───────────────────────────────────────────────────────────
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
	var freq = randf_range(1300.0, 1850.0)
	for i in range(sample_count):
		var t = float(i) / 22050.0
		var decay = 1.0 - (float(i) / sample_count)
		var sample = sin(t * freq * TAU) * decay * 0.22
		if audio_generator.can_push_buffer(1):
			audio_generator.push_frame(Vector2(sample, sample))

# ── Proses Animasi ──────────────────────────────────────────────────────────
func _start() -> void:
	current_state = State.TYPING_QUOTE
	char_index = 0
	typing_timer = 0.0
	quote_label.text = ""
	author_label.text = ""
	is_transitioning = false

func _process(delta: float) -> void:
	anim_time += delta
	var vp_size = get_viewport().get_visible_rect().size

	# 1. Update Awan Kabut
	for item in fog_items:
		var n: Panel = item["node"]
		item["pos"].x += item["speed"] * delta
		item["pos"].y += sin(anim_time * 0.8 + item["phase"]) * 16.0 * delta
		if item["pos"].x > vp_size.x + item["radius"]:
			item["pos"].x = -item["radius"] * 2.0
			item["pos"].y = randf_range(30, vp_size.y - 100)
		if is_instance_valid(n):
			n.position = item["pos"]

	# 2. Denyut Nebula Center Aura
	if is_instance_valid(nebula_center):
		nebula_center.position = Vector2(vp_size.x * 0.5 - 450, vp_size.y * 0.5 - 275)
		var s = 1.0 + 0.08 * sin(anim_time * 2.0)
		nebula_center.scale = Vector2(s, s)

	# 3. Kedip Tombol Skip
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.5 + 0.45 * abs(sin(anim_time * 3.2))

	# 4. Kursor Ketik
	var cursor = " |" if int(anim_time * 4.0) % 2 == 0 else ""

	# 5. State Machine Ketikan
	match current_state:
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
					state_timer = 3.5

		State.HOLD:
			state_timer -= delta
			if state_timer <= 0.0:
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
	if is_transitioning:
		return

	match current_state:
		State.TYPING_QUOTE, State.WAIT_AUTHOR:
			quote_label.text = QUOTE_TEXT
			current_state = State.TYPING_AUTHOR
			char_index = 0
		State.TYPING_AUTHOR:
			author_label.text = AUTHOR_TEXT
			current_state = State.HOLD
			state_timer = 1.0
		State.HOLD:
			_change_to_main_scene()

func _change_to_main_scene() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	print("[OpeningCutscene] Masuk ke gameplay utama: ", NEXT_SCENE_PATH)
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
