extends Control

signal cutscene_completed

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT   = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT  = "— Haruki Murakami"
const TYPING_SPEED = 0.038
const AUTHOR_SPEED = 0.042

enum State {
	TYPING_QUOTE,
	WAIT_AUTHOR,
	TYPING_AUTHOR,
	HOLD_QUOTE,
	FADE_TO_BLACK,
	BLACK_SCREEN_HOLD,
	CS_IMAGE_1,
	CS_FADE_DIM,
	CS_IMAGE_2,
	FADE_OUT,
	DONE,
	HOLD
}
var current_state: State = State.TYPING_QUOTE

var state_timer: float = 0.0
var char_index: int = 0
var typing_timer: float = 0.0
var anim_time: float = 0.0
var is_transitioning: bool = false
var is_dimming: bool = false

# Intro Elements (Quote, Nebula, Floating Fog, Stars)
var bg_rect: ColorRect
var nebula_center: Panel
var fog_container: Control
var fog_items: Array[Dictionary] = []
var stars: Array[Dictionary] = []
var ui_center: CenterContainer
var text_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label

# Cutscene Elements (CS1, CS2, Black Overlay)
var cs_container: Control
var cs_image_1: TextureRect
var cs_image_2: TextureRect
var black_overlay: ColorRect
var active_tween: Tween = null

# Audio Players
var typewriter_player: AudioStreamPlayer
var breathing_player: AudioStreamPlayer

# Textures
var tex_cs1: Texture2D
var tex_cs2: Texture2D

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_load_resources()
	_build_scene()
	_setup_audio()
	_init_stars()
	_start()

func _load_resources() -> void:
	tex_cs1 = load("res://UI/CS/CS(ITTODAY)1.png")
	if not tex_cs1:
		tex_cs1 = load("res://CS/CS(ITTODAY)1.png")
	tex_cs2 = load("res://UI/CS/CS(ITTODAY)2.png")
	if not tex_cs2:
		tex_cs2 = load("res://CS/CS(ITTODAY)2.png")

func _init_stars() -> void:
	stars.clear()
	for i in range(54):
		stars.append({
			"pos": Vector2(randf(), randf()),
			"size": randf_range(1.2, 2.8),
			"alpha_base": randf_range(0.35, 0.90),
			"freq": randf_range(1.5, 4.0),
			"phase": randf() * TAU
		})

func _build_scene() -> void:
	# 1. Background Void Gelap Pekat Indah
	bg_rect = ColorRect.new()
	bg_rect.name = "BackgroundVoid"
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = Color(0.05, 0.03, 0.09, 1.0)
	bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_rect)

	# 2. Glowing Nebula Center Aura
	nebula_center = Panel.new()
	nebula_center.name = "NebulaCenter"
	nebula_center.set_anchors_preset(Control.PRESET_CENTER)
	nebula_center.custom_minimum_size = Vector2(960, 580)
	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = Color(0.34, 0.13, 0.60, 0.28)
	glow_style.set_corner_radius_all(290)
	glow_style.shadow_color = Color(0.46, 0.19, 0.78, 0.40)
	glow_style.shadow_size = 130
	nebula_center.add_theme_stylebox_override("panel", glow_style)
	nebula_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(nebula_center)

	# 3. Layer Awan-Awan Kabut Melayang (Drifting Clouds)
	fog_container = Control.new()
	fog_container.name = "FogContainer"
	fog_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	fog_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fog_container)

	fog_items.clear()
	for i in range(20):
		var pnl = Panel.new()
		var p_style = StyleBoxFlat.new()
		var r = randf_range(120.0, 240.0)
		var hue_pick = randf()
		var cloud_color: Color
		if hue_pick < 0.45:
			cloud_color = Color(randf_range(0.38, 0.58), randf_range(0.18, 0.38), randf_range(0.68, 0.92), randf_range(0.12, 0.22))
		elif hue_pick < 0.8:
			cloud_color = Color(randf_range(0.20, 0.35), randf_range(0.25, 0.48), randf_range(0.68, 0.88), randf_range(0.11, 0.19))
		else:
			cloud_color = Color(randf_range(0.48, 0.68), randf_range(0.38, 0.58), randf_range(0.78, 0.98), randf_range(0.14, 0.25))

		p_style.bg_color = cloud_color
		p_style.set_corner_radius_all(int(r))
		p_style.shadow_color = cloud_color
		p_style.shadow_size = int(r * 0.35)
		pnl.add_theme_stylebox_override("panel", p_style)
		pnl.custom_minimum_size = Vector2(r * 2.4, r * 1.5)
		pnl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fog_container.add_child(pnl)

		fog_items.append({
			"node": pnl,
			"pos": Vector2(randf_range(-250.0, 1850.0), randf_range(20.0, 880.0)),
			"speed": randf_range(26.0, 62.0),
			"radius": r,
			"phase": randf() * TAU
		})

	# 4. Container Teks Monolog Tengah
	ui_center = CenterContainer.new()
	ui_center.name = "UICenter"
	ui_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_center)

	text_container = VBoxContainer.new()
	text_container.custom_minimum_size = Vector2(1150, 0)
	text_container.add_theme_constant_override("separation", 26)
	ui_center.add_child(text_container)

	quote_label = Label.new()
	quote_label.text = ""
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(0.99, 0.99, 1.0, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.42, 0.16, 0.75, 0.9))
	quote_label.add_theme_constant_override("shadow_offset_x", 3)
	quote_label.add_theme_constant_override("shadow_offset_y", 3)
	quote_label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.03, 1.0))
	quote_label.add_theme_constant_override("outline_size", 5)
	quote_label.add_theme_font_size_override("font_size", 38)
	text_container.add_child(quote_label)

	author_label = Label.new()
	author_label.text = ""
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.98, 0.95))
	author_label.add_theme_color_override("font_shadow_color", Color(0.35, 0.12, 0.58, 0.8))
	author_label.add_theme_constant_override("shadow_offset_x", 2)
	author_label.add_theme_constant_override("shadow_offset_y", 2)
	author_label.add_theme_color_override("font_outline_color", Color(0.01, 0.01, 0.03, 0.9))
	author_label.add_theme_constant_override("outline_size", 4)
	author_label.add_theme_font_size_override("font_size", 24)
	text_container.add_child(author_label)

	# 5. Layer Cutscene Gambar (CS1 & CS2)
	cs_container = Control.new()
	cs_container.name = "CSContainer"
	cs_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	cs_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cs_container.visible = false
	add_child(cs_container)

	cs_image_1 = TextureRect.new()
	cs_image_1.name = "CSImage1"
	cs_image_1.set_anchors_preset(Control.PRESET_FULL_RECT)
	cs_image_1.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cs_image_1.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cs_image_1.texture = tex_cs1
	cs_image_1.modulate = Color(1, 1, 1, 1.0)
	cs_image_1.visible = false
	cs_image_1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cs_container.add_child(cs_image_1)

	cs_image_2 = TextureRect.new()
	cs_image_2.name = "CSImage2"
	cs_image_2.set_anchors_preset(Control.PRESET_FULL_RECT)
	cs_image_2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cs_image_2.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	cs_image_2.texture = tex_cs2
	cs_image_2.modulate = Color(1, 1, 1, 1.0)
	cs_image_2.visible = false
	cs_image_2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cs_container.add_child(cs_image_2)

	# 6. Black Screen & Dimming Overlay
	black_overlay = ColorRect.new()
	black_overlay.name = "BlackOverlay"
	black_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	black_overlay.color = Color(0, 0, 0, 0.0)
	black_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black_overlay)

	# 7. Tombol Petunjuk Skip
	skip_hint_label = Label.new()
	skip_hint_label.name = "SkipHintLabel"
	skip_hint_label.text = "✦ [ TEKAN SPACE / ENTER / KLIK MOUSE ] UNTUK MELANJUTKAN ✦"
	skip_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	skip_hint_label.offset_top = -65.0
	skip_hint_label.offset_bottom = -20.0
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.88, 0.85, 0.98, 0.90))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.04, 1.0))
	skip_hint_label.add_theme_constant_override("outline_size", 3)
	skip_hint_label.add_theme_font_size_override("font_size", 14)
	add_child(skip_hint_label)

func _setup_audio() -> void:
	# Typewriter sound player untuk intro quote
	typewriter_player = AudioStreamPlayer.new()
	typewriter_player.name = "TypewriterAudio"
	var tw_stream = load("res://sound/keyboardtype.mp3")
	if not tw_stream:
		tw_stream = load("res://keyboardtype.mp3")
	if tw_stream:
		typewriter_player.stream = tw_stream
		typewriter_player.volume_db = -3.0
	add_child(typewriter_player)

	# Heavy breathing audio player untuk cutscene
	breathing_player = AudioStreamPlayer.new()
	breathing_player.name = "HeavyBreathingAudio"
	var breath_stream = load("res://sound/Heavy Breathing.mp3")
	if not breath_stream:
		breath_stream = load("res://Heavy Breathing.mp3")
	if breath_stream:
		breathing_player.stream = breath_stream
		breathing_player.volume_db = -12.0
		breathing_player.finished.connect(func():
			if is_instance_valid(breathing_player) and not is_transitioning:
				breathing_player.play()
		)
	add_child(breathing_player)

func _start_typing_audio() -> void:
	if is_instance_valid(typewriter_player) and typewriter_player.stream:
		if not typewriter_player.playing:
			typewriter_player.play(2.0)

func _stop_typing_audio() -> void:
	if is_instance_valid(typewriter_player) and typewriter_player.playing:
		typewriter_player.stop()

func _start() -> void:
	current_state = State.TYPING_QUOTE
	char_index = 0
	typing_timer = 0.0
	quote_label.text = ""
	author_label.text = ""
	is_transitioning = false
	is_dimming = false
	cs_container.visible = false
	_start_typing_audio()

func _process(delta: float) -> void:
	anim_time += delta
	var vp_size = get_viewport().get_visible_rect().size

	# Animasi Awan-Awan Kabut & Nebula (Hanya saat Intro aktif)
	if current_state in [State.TYPING_QUOTE, State.WAIT_AUTHOR, State.TYPING_AUTHOR, State.HOLD_QUOTE, State.HOLD]:
		for item in fog_items:
			var n: Panel = item["node"]
			item["pos"].x += item["speed"] * delta
			item["pos"].y += sin(anim_time * 0.75 + item["phase"]) * 14.0 * delta
			if item["pos"].x > vp_size.x + item["radius"] * 2.5:
				item["pos"].x = -item["radius"] * 2.5
				item["pos"].y = randf_range(20.0, vp_size.y - 80.0)
			if is_instance_valid(n):
				n.position = item["pos"]

		if is_instance_valid(nebula_center):
			nebula_center.position = Vector2(vp_size.x * 0.5 - 480.0, vp_size.y * 0.5 - 290.0)
			var s = 1.0 + 0.06 * sin(anim_time * 1.8)
			nebula_center.scale = Vector2(s, s)

	# Denyut Kedip Label Skip Hint
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.55 + 0.40 * abs(sin(anim_time * 2.8))

	var cursor = " |" if int(anim_time * 4.0) % 2 == 0 else ""

	# State Machine Lengkap
	match current_state:
		# ── TAHAP 1: INTRO KUTIPAN MURAKAMI ───────────────────────────
		State.TYPING_QUOTE:
			_start_typing_audio()
			typing_timer += delta
			if typing_timer >= TYPING_SPEED:
				typing_timer = 0.0
				if char_index < QUOTE_TEXT.length():
					char_index += 1
					quote_label.text = QUOTE_TEXT.substr(0, char_index) + cursor
				else:
					quote_label.text = QUOTE_TEXT
					_stop_typing_audio()
					current_state = State.WAIT_AUTHOR
					state_timer = 0.45

		State.WAIT_AUTHOR:
			_stop_typing_audio()
			state_timer -= delta
			if state_timer <= 0.0:
				current_state = State.TYPING_AUTHOR
				char_index = 0
				typing_timer = 0.0
				_start_typing_audio()

		State.TYPING_AUTHOR:
			_start_typing_audio()
			typing_timer += delta
			if typing_timer >= AUTHOR_SPEED:
				typing_timer = 0.0
				if char_index < AUTHOR_TEXT.length():
					char_index += 1
					author_label.text = AUTHOR_TEXT.substr(0, char_index) + cursor
				else:
					author_label.text = AUTHOR_TEXT
					_stop_typing_audio()
					current_state = State.HOLD_QUOTE
					state_timer = 3.2

		State.HOLD_QUOTE, State.HOLD:
			_stop_typing_audio()
			state_timer -= delta
			if state_timer <= 0.0:
				_transition_intro_to_black()

		# ── TAHAP 2: HITAM 2 DETIK ───────────────────────────────────
		State.BLACK_SCREEN_HOLD:
			state_timer -= delta
			if state_timer <= 0.0:
				_start_cutscene_slide_1()

		# ── TAHAP 3: CUTSCENE GAMBAR 1 (HEAVY BREATHING AGAK KECIL) ──
		State.CS_IMAGE_1:
			if is_instance_valid(cs_image_1) and cs_image_1.visible:
				cs_image_1.pivot_offset = vp_size * 0.5
				var s1 = 1.0 + 0.012 * sin(anim_time * 2.2)
				cs_image_1.scale = Vector2(s1, s1)

			state_timer -= delta
			if state_timer <= 0.0 and not is_dimming:
				_start_fade_dim()

		# ── TAHAP 4: MEREDUP ("terus meredup") ────────────────────────
		State.CS_FADE_DIM:
			state_timer -= delta
			if state_timer <= 0.0:
				_start_cutscene_slide_2()

		# ── TAHAP 5: CUTSCENE GAMBAR 2 (NAFAS MAKIN KENCANG) ─────────
		State.CS_IMAGE_2:
			if is_instance_valid(cs_image_2) and cs_image_2.visible:
				cs_image_2.pivot_offset = vp_size * 0.5
				var s2 = 1.0 + 0.020 * sin(anim_time * 3.4)
				cs_image_2.scale = Vector2(s2, s2)

			state_timer -= delta
			if state_timer <= 0.0:
				_change_to_main_scene(false)

	queue_redraw()

func _draw() -> void:
	if current_state in [State.TYPING_QUOTE, State.WAIT_AUTHOR, State.TYPING_AUTHOR, State.HOLD_QUOTE, State.HOLD]:
		var vp = get_viewport().get_visible_rect().size
		for s in stars:
			var sp = Vector2(s["pos"].x * vp.x, s["pos"].y * vp.y)
			var a = s["alpha_base"] * (0.6 + 0.4 * sin(anim_time * s["freq"] + s["phase"]))
			draw_circle(sp, s["size"], Color(0.85, 0.88, 1.0, a))

func _get_fresh_tween() -> Tween:
	if is_instance_valid(active_tween) and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	return active_tween

func _transition_intro_to_black() -> void:
	if current_state == State.FADE_TO_BLACK or current_state == State.BLACK_SCREEN_HOLD:
		return
	current_state = State.FADE_TO_BLACK
	_stop_typing_audio()

	# Fade intro ke layar hitam
	var tw = _get_fresh_tween()
	tw.tween_property(black_overlay, "color:a", 1.0, 0.45)
	tw.tween_callback(func():
		# Sembunyikan elemen intro
		nebula_center.visible = false
		fog_container.visible = false
		ui_center.visible = false

		# Masuk ke fase Hitam 2 Detik sesuai instruksi
		current_state = State.BLACK_SCREEN_HOLD
		state_timer = 2.0
		print("[OpeningCutscene] Layar hitam selama 2 detik...")
	)

func _start_cutscene_slide_1() -> void:
	current_state = State.CS_IMAGE_1
	state_timer = 4.5
	is_dimming = false

	# Tampilkan container cutscene & gambar 1
	cs_container.visible = true
	cs_image_1.visible = true
	cs_image_1.modulate.a = 1.0
	cs_image_2.visible = false

	# Putar suara napas heavy breathing (agak kecil, -12 dB)
	if is_instance_valid(breathing_player) and breathing_player.stream:
		breathing_player.volume_db = -12.0
		breathing_player.play()

	# Buka layar dari hitam ke Gambar 1
	var tw = _get_fresh_tween()
	tw.tween_property(black_overlay, "color:a", 0.0, 0.60)
	print("[OpeningCutscene] Masuk ke Gambar 1 (Heavy breathing lembut -12 dB)")

func _start_fade_dim() -> void:
	if is_dimming or is_transitioning:
		return
	is_dimming = true
	current_state = State.CS_FADE_DIM
	state_timer = 1.0

	# Meredupkan layar perlahan ("terus meredup")
	var tw = _get_fresh_tween()
	tw.set_parallel(true)
	tw.tween_property(black_overlay, "color:a", 1.0, 0.90)
	if is_instance_valid(breathing_player):
		tw.tween_property(breathing_player, "volume_db", -3.0, 0.90)
	print("[OpeningCutscene] Layar meredup...")

func _start_cutscene_slide_2() -> void:
	is_dimming = false
	current_state = State.CS_IMAGE_2
	state_timer = 4.5

	# Tampilkan gambar 2
	cs_image_1.visible = false
	cs_image_2.visible = true
	cs_image_2.modulate.a = 1.0

	# Suara napas makin kencang (+2 dB)
	if is_instance_valid(breathing_player):
		breathing_player.volume_db = 2.0
		if not breathing_player.playing:
			breathing_player.play()

	# Buka layar dari kegelapan ke Gambar 2
	var tw = _get_fresh_tween()
	tw.tween_property(black_overlay, "color:a", 0.0, 0.65)
	print("[OpeningCutscene] Masuk ke Gambar 2 (Heavy breathing makin kencang +2 dB)")

func _unhandled_input(event: InputEvent) -> void:
	_input(event)

func _input(event: InputEvent) -> void:
	if not is_inside_tree() or not is_visible_in_tree():
		return
	if is_transitioning:
		if event is InputEventKey or event is InputEventMouseButton:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_handle_user_skip(true)
		elif event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_F]:
			get_viewport().set_input_as_handled()
			_handle_user_skip(false)
	elif event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
		_handle_user_skip(false)

func _handle_user_skip(force_exit: bool = false) -> void:
	if is_transitioning:
		return

	if force_exit:
		_change_to_main_scene(true)
		return

	match current_state:
		State.TYPING_QUOTE, State.WAIT_AUTHOR:
			quote_label.text = QUOTE_TEXT
			current_state = State.TYPING_AUTHOR
			char_index = 0
			_start_typing_audio()

		State.TYPING_AUTHOR:
			author_label.text = AUTHOR_TEXT
			current_state = State.HOLD_QUOTE
			state_timer = 0.8
			_stop_typing_audio()

		State.HOLD_QUOTE, State.HOLD:
			_transition_intro_to_black()

		State.BLACK_SCREEN_HOLD, State.FADE_TO_BLACK:
			_start_cutscene_slide_1()

		State.CS_IMAGE_1:
			_start_fade_dim()

		State.CS_FADE_DIM:
			_start_cutscene_slide_2()

		State.CS_IMAGE_2:
			_change_to_main_scene(false)

		_:
			_change_to_main_scene(false)

func _change_to_main_scene(is_force: bool = false) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	current_state = State.FADE_OUT
	_stop_typing_audio()

	var fade_dur = 0.20 if is_force else 0.28
	var hold_dur = 0.20 if is_force else 1.0
	var tw = _get_fresh_tween()
	tw.set_parallel(true)
	tw.tween_property(black_overlay, "color:a", 1.0, fade_dur)
	if is_instance_valid(breathing_player):
		tw.tween_property(breathing_player, "volume_db", -36.0, fade_dur)

	tw.chain().tween_callback(func():
		if is_instance_valid(cs_image_1):
			cs_image_1.visible = false
		if is_instance_valid(cs_image_2):
			cs_image_2.visible = false
		if is_instance_valid(black_overlay):
			black_overlay.color = Color(0, 0, 0, 1.0)
	)
	tw.chain().tween_interval(hold_dur)
	tw.chain().tween_callback(func():
		if is_instance_valid(breathing_player):
			breathing_player.stop()
		print("[OpeningCutscene] Cutscene selesai -> Layar hitam 1 detik -> Muncul di pojok kiri atas!")
		cutscene_completed.emit()
		if get_tree().current_scene == self or get_parent() == get_tree().root:
			get_tree().change_scene_to_file(NEXT_SCENE_PATH)
		else:
			queue_free()
	)
