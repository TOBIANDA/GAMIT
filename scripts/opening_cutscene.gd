extends Node2D

# ── Opening Cutscene v3 - Pixel Art Style & Sharper Fade ────────────────────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur: Pixel Art Font Styling + Outline, Durasi Lebih Cepat, Kejelasan Tinggi

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT  = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT = "— Haruki Murakami"

# Durasi Lebih Singkat & Responsif
const FADE_IN_DURATION  = 1.8  # Transisi masuk lebih cepat
const HOLD_DURATION     = 1.6  # Tahan di puncak kejelasan
const FADE_OUT_DURATION = 1.8  # Transisi keluar menghitam

# Referensi Node
var bg_rect: ColorRect
var center_glow: ColorRect
var fog_particles1: CPUParticles2D
var fog_particles2: CPUParticles2D
var fog_particles3: CPUParticles2D
var main_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label
var fade_overlay: ColorRect

# State Machine
enum State { FADE_IN, HOLD_VISIBLE, FADE_OUT, DONE }
var current_state: State = State.FADE_IN
var state_timer: float = 0.0
var current_alpha: float = 1.0

func _ready() -> void:
	_build_scene_nodes()
	_start_intro()

# ── Membangun UI & Pixel Art Styling ─────────────────────────────────────────
func _build_scene_nodes() -> void:
	# 1. Background Void Hitam Pezat
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.015, 0.01, 0.03, 1.0)
	bg_rect.size = Vector2(1280, 720)
	add_child(bg_rect)

	# 2. Glow Center Aura (Pusat Cahaya Ungu-Pixel)
	center_glow = ColorRect.new()
	center_glow.color = Color(0.2, 0.1, 0.35, 0.18)
	center_glow.position = Vector2(240, 160)
	center_glow.size = Vector2(800, 400)
	add_child(center_glow)

	# 3. Layer Kabut 1 (CPUParticles2D - Tebal & Jelas)
	fog_particles1 = CPUParticles2D.new()
	fog_particles1.position = Vector2(-150, 360)
	fog_particles1.amount = 90
	fog_particles1.lifetime = 10.0
	fog_particles1.preprocess = 5.0
	fog_particles1.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles1.emission_rect_extents = Vector2(60, 450)
	fog_particles1.gravity = Vector2(0, 0)
	fog_particles1.direction = Vector2(1, 0.1)
	fog_particles1.spread = 20.0
	fog_particles1.initial_velocity_min = 40.0
	fog_particles1.initial_velocity_max = 80.0
	fog_particles1.scale_amount_min = 120.0
	fog_particles1.scale_amount_max = 260.0
	fog_particles1.color = Color(0.45, 0.35, 0.65, 0.18)
	add_child(fog_particles1)

	# 4. Layer Kabut 2 (Melayang Berlawanan Arah)
	fog_particles2 = CPUParticles2D.new()
	fog_particles2.position = Vector2(1430, 400)
	fog_particles2.amount = 75
	fog_particles2.lifetime = 8.0
	fog_particles2.preprocess = 4.0
	fog_particles2.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles2.emission_rect_extents = Vector2(60, 380)
	fog_particles2.gravity = Vector2(0, 0)
	fog_particles2.direction = Vector2(-1, -0.1)
	fog_particles2.spread = 25.0
	fog_particles2.initial_velocity_min = 45.0
	fog_particles2.initial_velocity_max = 90.0
	fog_particles2.scale_amount_min = 130.0
	fog_particles2.scale_amount_max = 300.0
	fog_particles2.color = Color(0.3, 0.22, 0.45, 0.15)
	add_child(fog_particles2)

	# 5. Layer Kabut 3 (Foreground Low Floating Fog)
	fog_particles3 = CPUParticles2D.new()
	fog_particles3.position = Vector2(640, 750)
	fog_particles3.amount = 50
	fog_particles3.lifetime = 7.0
	fog_particles3.preprocess = 3.0
	fog_particles3.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles3.emission_rect_extents = Vector2(700, 40)
	fog_particles3.gravity = Vector2(0, -12)
	fog_particles3.direction = Vector2(0, -1)
	fog_particles3.spread = 35.0
	fog_particles3.initial_velocity_min = 20.0
	fog_particles3.initial_velocity_max = 45.0
	fog_particles3.scale_amount_min = 160.0
	fog_particles3.scale_amount_max = 340.0
	fog_particles3.color = Color(0.35, 0.28, 0.52, 0.14)
	add_child(fog_particles3)

	# 6. Container UI Utama Teks Quote
	main_container = VBoxContainer.new()
	main_container.position = Vector2(140, 230)
	main_container.size = Vector2(1000, 300)
	main_container.add_theme_constant_override("separation", 32)
	add_child(main_container)

	# 7. Label Quote - Pixel Art Styling (Besar & Kontras Tajam)
	quote_label = Label.new()
	quote_label.text = QUOTE_TEXT
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Warna putih tajam berbayang gelap gaya retro/pixel
	quote_label.add_theme_color_override("font_color", Color(1.0, 0.98, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.1, 0.05, 0.2, 0.9))
	quote_label.add_theme_constant_override("shadow_offset_x", 3)
	quote_label.add_theme_constant_override("shadow_offset_y", 3)
	quote_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	quote_label.add_theme_constant_override("outline_size", 6)
	quote_label.add_theme_font_size_override("font_size", 34) # Diperbesar agar jelas
	main_container.add_child(quote_label)

	# 8. Label Penulis (Haruki Murakami) - Pixel Style Accent
	author_label = Label.new()
	author_label.text = AUTHOR_TEXT
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.85, 0.72, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.04, 0.15, 0.9))
	author_label.add_theme_constant_override("shadow_offset_x", 2)
	author_label.add_theme_constant_override("shadow_offset_y", 2)
	author_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	author_label.add_theme_constant_override("outline_size", 5)
	author_label.add_theme_font_size_override("font_size", 24) # Diperbesar & Tajam
	main_container.add_child(author_label)

	# 9. Petunjuk Skip / Lanjut
	skip_hint_label = Label.new()
	skip_hint_label.text = "[ SPACE / Klik untuk skip ]"
	skip_hint_label.position = Vector2(440, 665)
	skip_hint_label.size = Vector2(400, 30)
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.65, 0.7))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 3)
	skip_hint_label.add_theme_font_size_override("font_size", 13)
	add_child(skip_hint_label)

	# 10. Overlay Transition Fade (Hitam)
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.size = Vector2(1280, 720)
	add_child(fade_overlay)

# ── Logika Animasi ───────────────────────────────────────────────────────────
func _start_intro() -> void:
	current_state = State.FADE_IN
	current_alpha = 1.0
	state_timer = 0.0
	fade_overlay.color.a = 1.0

func _process(delta: float) -> void:
	# Animasi kedip lembut hint skip
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.35 + 0.45 * sin(Time.get_ticks_msec() * 0.004)

	match current_state:
		State.FADE_IN:
			state_timer += delta
			var progress = clamp(state_timer / FADE_IN_DURATION, 0.0, 1.0)
			current_alpha = 1.0 - (progress * progress * (3.0 - 2.0 * progress))
			fade_overlay.color.a = current_alpha

			if progress >= 1.0:
				current_state = State.HOLD_VISIBLE
				state_timer = 0.0

		State.HOLD_VISIBLE:
			fade_overlay.color.a = 0.0
			state_timer += delta
			if state_timer >= HOLD_DURATION:
				current_state = State.FADE_OUT
				state_timer = 0.0

		State.FADE_OUT:
			state_timer += delta
			var progress = clamp(state_timer / FADE_OUT_DURATION, 0.0, 1.0)
			current_alpha = progress * progress * (3.0 - 2.0 * progress)
			fade_overlay.color.a = current_alpha

			if progress >= 1.0:
				current_state = State.DONE
				_change_to_main_scene()

# ── Input Handler ───────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_ESCAPE]:
			_handle_skip()
	elif event is InputEventMouseButton and event.pressed:
		_handle_skip()

func _handle_skip() -> void:
	if current_state != State.FADE_OUT and current_state != State.DONE:
		current_state = State.FADE_OUT
		state_timer = 0.0

func _change_to_main_scene() -> void:
	print("[OpeningCutscene] Transisi ke scene utama: ", NEXT_SCENE_PATH)
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)
