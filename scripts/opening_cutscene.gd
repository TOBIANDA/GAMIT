extends Node2D

# ── Opening Cutscene v4 - Perfectly Scaled 16:9 Cinematic & Responsive ─────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur: Layar Penuh Responsif (1600x900), Fog Partikel Merata, Font Tajam Terpusat

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT  = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT = "— Haruki Murakami"

# Durasi Transisi
const FADE_IN_DURATION  = 1.8
const HOLD_DURATION     = 1.8
const FADE_OUT_DURATION = 1.6

# Referensi Node
var canvas_layer: CanvasLayer
var bg_rect: ColorRect
var center_glow: ColorRect
var fog_particles1: CPUParticles2D
var fog_particles2: CPUParticles2D
var fog_particles3: CPUParticles2D
var center_box: CenterContainer
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

# ── Membangun UI Menggunakan CanvasLayer Responsif ─────────────────────────
func _build_scene_nodes() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 1
	add_child(canvas_layer)

	var vp_size = get_viewport_rect().size
	if vp_size == Vector2.ZERO:
		vp_size = Vector2(1600, 900)

	# 1. Background Void Hitam Pekat
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.015, 0.01, 0.03, 1.0)
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(bg_rect)

	# 2. Glow Center Aura (Pusat Cahaya Ungu Lembut)
	center_glow = ColorRect.new()
	center_glow.color = Color(0.25, 0.12, 0.40, 0.22)
	center_glow.anchor_left = 0.15
	center_glow.anchor_top = 0.20
	center_glow.anchor_right = 0.85
	center_glow.anchor_bottom = 0.80
	canvas_layer.add_child(center_glow)

	# 3. Layer Kabut 1 (CPUParticles2D - Sisi Kiri ke Kanan)
	fog_particles1 = CPUParticles2D.new()
	fog_particles1.position = Vector2(-100, vp_size.y * 0.45)
	fog_particles1.amount = 100
	fog_particles1.lifetime = 10.0
	fog_particles1.preprocess = 5.0
	fog_particles1.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles1.emission_rect_extents = Vector2(60, vp_size.y * 0.5)
	fog_particles1.gravity = Vector2(0, 0)
	fog_particles1.direction = Vector2(1, 0.05)
	fog_particles1.spread = 20.0
	fog_particles1.initial_velocity_min = 50.0
	fog_particles1.initial_velocity_max = 95.0
	fog_particles1.scale_amount_min = 140.0
	fog_particles1.scale_amount_max = 300.0
	fog_particles1.color = Color(0.45, 0.35, 0.65, 0.18)
	add_child(fog_particles1)

	# 4. Layer Kabut 2 (Sisi Kanan ke Kiri)
	fog_particles2 = CPUParticles2D.new()
	fog_particles2.position = Vector2(vp_size.x + 100, vp_size.y * 0.5)
	fog_particles2.amount = 85
	fog_particles2.lifetime = 9.0
	fog_particles2.preprocess = 4.0
	fog_particles2.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles2.emission_rect_extents = Vector2(60, vp_size.y * 0.45)
	fog_particles2.gravity = Vector2(0, 0)
	fog_particles2.direction = Vector2(-1, -0.05)
	fog_particles2.spread = 25.0
	fog_particles2.initial_velocity_min = 50.0
	fog_particles2.initial_velocity_max = 100.0
	fog_particles2.scale_amount_min = 150.0
	fog_particles2.scale_amount_max = 320.0
	fog_particles2.color = Color(0.3, 0.22, 0.45, 0.15)
	add_child(fog_particles2)

	# 5. Layer Kabut 3 (Bawah)
	fog_particles3 = CPUParticles2D.new()
	fog_particles3.position = Vector2(vp_size.x * 0.5, vp_size.y + 40)
	fog_particles3.amount = 60
	fog_particles3.lifetime = 8.0
	fog_particles3.preprocess = 3.0
	fog_particles3.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles3.emission_rect_extents = Vector2(vp_size.x * 0.55, 40)
	fog_particles3.gravity = Vector2(0, -15)
	fog_particles3.direction = Vector2(0, -1)
	fog_particles3.spread = 35.0
	fog_particles3.initial_velocity_min = 25.0
	fog_particles3.initial_velocity_max = 55.0
	fog_particles3.scale_amount_min = 180.0
	fog_particles3.scale_amount_max = 360.0
	fog_particles3.color = Color(0.35, 0.28, 0.52, 0.14)
	add_child(fog_particles3)

	# 6. Center Container Presisi Tengah Layar
	center_box = CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(center_box)

	main_container = VBoxContainer.new()
	main_container.custom_minimum_size = Vector2(1100, 0)
	main_container.add_theme_constant_override("separation", 32)
	center_box.add_child(main_container)

	# 7. Label Quote (Tajam, Elegan, Terpusat)
	quote_label = Label.new()
	quote_label.text = QUOTE_TEXT
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(1.0, 0.98, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.1, 0.05, 0.2, 0.95))
	quote_label.add_theme_constant_override("shadow_offset_x", 3)
	quote_label.add_theme_constant_override("shadow_offset_y", 3)
	quote_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	quote_label.add_theme_constant_override("outline_size", 6)
	quote_label.add_theme_font_size_override("font_size", 36)
	main_container.add_child(quote_label)

	# 8. Label Penulis (Haruki Murakami)
	author_label = Label.new()
	author_label.text = AUTHOR_TEXT
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.85, 0.72, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.04, 0.15, 0.95))
	author_label.add_theme_constant_override("shadow_offset_x", 2)
	author_label.add_theme_constant_override("shadow_offset_y", 2)
	author_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	author_label.add_theme_constant_override("outline_size", 5)
	author_label.add_theme_font_size_override("font_size", 24)
	main_container.add_child(author_label)

	# 9. Petunjuk Skip di Bagian Bawah Layar
	skip_hint_label = Label.new()
	skip_hint_label.text = "[ SPACE / Klik untuk skip ]"
	skip_hint_label.anchor_left = 0.0
	skip_hint_label.anchor_right = 1.0
	skip_hint_label.anchor_top = 0.90
	skip_hint_label.anchor_bottom = 0.95
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.55, 0.50, 0.70, 0.8))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 3)
	skip_hint_label.add_theme_font_size_override("font_size", 14)
	canvas_layer.add_child(skip_hint_label)

	# 10. Overlay Transition Fade (Hitam Full Screen)
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(fade_overlay)

# ── Logika Animasi ───────────────────────────────────────────────────────────
func _start_intro() -> void:
	current_state = State.FADE_IN
	current_alpha = 1.0
	state_timer = 0.0
	fade_overlay.color.a = 1.0

func _process(delta: float) -> void:
	# Animasi kedip lembut hint skip
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.40 + 0.50 * sin(Time.get_ticks_msec() * 0.004)

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
