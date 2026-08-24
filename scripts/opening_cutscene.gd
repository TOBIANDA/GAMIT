extends Node2D

# ── Opening Cutscene v4 - Full Responsive Ratio & Pixel Art Styling ─────────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur: Menggunakan CanvasLayer & Anchor UI dinamis sehingga 100% responsif di semua resolusi / rasio layar

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT  = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT = "— Haruki Murakami"

# Durasi
const FADE_IN_DURATION  = 1.8
const HOLD_DURATION     = 1.6
const FADE_OUT_DURATION = 1.8

# Referensi Node UI
var canvas_layer: CanvasLayer
var root_control: Control
var bg_rect: ColorRect
var center_glow: ColorRect
var fog_particles1: CPUParticles2D
var fog_particles2: CPUParticles2D
var fog_particles3: CPUParticles2D
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

# ── Membangun UI Responsif di CanvasLayer ────────────────────────────────────
func _build_scene_nodes() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 1
	add_child(canvas_layer)

	# Root Control memenuhi seluruh layar
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.anchor_right = 1.0
	root_control.anchor_bottom = 1.0
	canvas_layer.add_child(root_control)

	# 1. Background Void Hitam Pekat (Full Rect)
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.015, 0.01, 0.03, 1.0)
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_rect.anchor_right = 1.0
	bg_rect.anchor_bottom = 1.0
	root_control.add_child(bg_rect)

	# 2. Glow Center Aura (Pusat Cahaya Ungu-Pixel di tengah layar)
	center_glow = ColorRect.new()
	center_glow.color = Color(0.2, 0.1, 0.35, 0.22)
	center_glow.set_anchors_preset(Control.PRESET_CENTER)
	center_glow.anchor_left = 0.5
	center_glow.anchor_top = 0.5
	center_glow.anchor_right = 0.5
	center_glow.anchor_bottom = 0.5
	center_glow.offset_left = -450.0
	center_glow.offset_top = -220.0
	center_glow.offset_right = 450.0
	center_glow.offset_bottom = 220.0
	root_control.add_child(center_glow)

	# 3. Layer Kabut Mengambang (Diatur responsif terhadap ukuran layar)
	var vp_size = get_viewport_rect().size
	if vp_size.x <= 0: vp_size = Vector2(1600, 900)

	fog_particles1 = CPUParticles2D.new()
	fog_particles1.position = Vector2(0, vp_size.y * 0.5)
	fog_particles1.amount = 80
	fog_particles1.lifetime = 9.0
	fog_particles1.preprocess = 4.0
	fog_particles1.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles1.emission_rect_extents = Vector2(60, vp_size.y * 0.6)
	fog_particles1.gravity = Vector2(0, 0)
	fog_particles1.direction = Vector2(1, 0.05)
	fog_particles1.spread = 20.0
	fog_particles1.initial_velocity_min = 40.0
	fog_particles1.initial_velocity_max = 80.0
	fog_particles1.scale_amount_min = 140.0
	fog_particles1.scale_amount_max = 300.0
	fog_particles1.color = Color(0.45, 0.35, 0.65, 0.16)
	add_child(fog_particles1)

	fog_particles2 = CPUParticles2D.new()
	fog_particles2.position = Vector2(vp_size.x, vp_size.y * 0.5)
	fog_particles2.amount = 70
	fog_particles2.lifetime = 8.0
	fog_particles2.preprocess = 3.0
	fog_particles2.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles2.emission_rect_extents = Vector2(60, vp_size.y * 0.5)
	fog_particles2.gravity = Vector2(0, 0)
	fog_particles2.direction = Vector2(-1, -0.05)
	fog_particles2.spread = 25.0
	fog_particles2.initial_velocity_min = 45.0
	fog_particles2.initial_velocity_max = 90.0
	fog_particles2.scale_amount_min = 140.0
	fog_particles2.scale_amount_max = 320.0
	fog_particles2.color = Color(0.3, 0.22, 0.45, 0.14)
	add_child(fog_particles2)

	# 4. Center Container Teks Quote (Tepat di Tengah Layar pada Semua Resolusi)
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_container.anchor_right = 1.0
	center_container.anchor_bottom = 1.0
	root_control.add_child(center_container)

	var text_vbox = VBoxContainer.new()
	text_vbox.custom_minimum_size = Vector2(900, 0)
	text_vbox.add_theme_constant_override("separation", 24)
	center_container.add_child(text_vbox)

	# 5. Label Quote
	quote_label = Label.new()
	quote_label.text = QUOTE_TEXT
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(1.0, 0.98, 1.0))
	quote_label.add_theme_color_override("font_shadow_color", Color(0.1, 0.05, 0.2, 0.9))
	quote_label.add_theme_constant_override("shadow_offset_x", 3)
	quote_label.add_theme_constant_override("shadow_offset_y", 3)
	quote_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	quote_label.add_theme_constant_override("outline_size", 6)
	quote_label.add_theme_font_size_override("font_size", 30)
	text_vbox.add_child(quote_label)

	# 6. Label Penulis (Haruki Murakami)
	author_label = Label.new()
	author_label.text = AUTHOR_TEXT
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.85, 0.72, 1.0))
	author_label.add_theme_color_override("font_shadow_color", Color(0.08, 0.04, 0.15, 0.9))
	author_label.add_theme_constant_override("shadow_offset_x", 2)
	author_label.add_theme_constant_override("shadow_offset_y", 2)
	author_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	author_label.add_theme_constant_override("outline_size", 5)
	author_label.add_theme_font_size_override("font_size", 20)
	text_vbox.add_child(author_label)

	# 7. Petunjuk Skip di Bawah Tengah
	skip_hint_label = Label.new()
	skip_hint_label.text = "[ SPACE / Klik untuk skip ]"
	skip_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	skip_hint_label.anchor_left = 0.0
	skip_hint_label.anchor_top = 1.0
	skip_hint_label.anchor_right = 1.0
	skip_hint_label.anchor_bottom = 1.0
	skip_hint_label.offset_top = -55.0
	skip_hint_label.offset_bottom = -25.0
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.55, 0.50, 0.70, 0.75))
	skip_hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	skip_hint_label.add_theme_constant_override("outline_size", 3)
	skip_hint_label.add_theme_font_size_override("font_size", 13)
	root_control.add_child(skip_hint_label)

	# 8. Overlay Transition Fade (Full Rect)
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	root_control.add_child(fade_overlay)

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
