extends Node2D

# ── Opening Cutscene v2 - Dark Atmospheric Fade Intro ────────────────────────
# Quote: "Death is not the opposite of life, but a part of it." — Haruki Murakami
# Fitur: Teks muncul berbarengan (Fade In/Out), Kabut Tebal, Transition Gelap -> Terang -> Menghitam

const NEXT_SCENE_PATH = "res://scenes/main.tscn"

const QUOTE_TEXT  = '"Death is not the opposite of life, but a part of it."'
const AUTHOR_TEXT = "— Haruki Murakami"

# Durasi Fase (dalam detik)
const FADE_IN_DURATION  = 3.2  # Layar dari sangat gelap perlahan makin terang
const HOLD_DURATION     = 2.2  # Tahan saat terlihat terang penuh
const FADE_OUT_DURATION = 2.5  # Layar bertahap menghitam kembali

# Referensi Node
var bg_rect: ColorRect
var fog_particles1: CPUParticles2D
var fog_particles2: CPUParticles2D
var fog_particles3: CPUParticles2D
var main_container: VBoxContainer
var quote_label: Label
var author_label: Label
var skip_hint_label: Label
var fade_overlay: ColorRect

# State Control
enum State { FADE_IN, HOLD_VISIBLE, FADE_OUT, DONE }
var current_state: State = State.FADE_IN
var state_timer: float = 0.0
var current_alpha: float = 1.0  # 1.0 = Hitam pekat, 0.0 = Terang penuh

func _ready() -> void:
	_build_scene_nodes()
	_start_intro()

# ── Membangun Hierarki Node UI & Kabut Tebal ──────────────────────────────
func _build_scene_nodes() -> void:
	# 1. Background Hitam Void Pezat
	bg_rect = ColorRect.new()
	bg_rect.color = Color(0.02, 0.01, 0.04, 1.0)
	bg_rect.size = Vector2(1280, 720)
	add_child(bg_rect)

	# 2. Kabut Tebal Layer 1 (CPUParticles2D - Dasar Tebal Melayang ke Kanan)
	fog_particles1 = CPUParticles2D.new()
	fog_particles1.position = Vector2(-150, 360)
	fog_particles1.amount = 80
	fog_particles1.lifetime = 12.0
	fog_particles1.preprocess = 6.0
	fog_particles1.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles1.emission_rect_extents = Vector2(60, 450)
	fog_particles1.gravity = Vector2(0, 0)
	fog_particles1.direction = Vector2(1, 0.1)
	fog_particles1.spread = 20.0
	fog_particles1.initial_velocity_min = 30.0
	fog_particles1.initial_velocity_max = 65.0
	fog_particles1.scale_amount_min = 100.0
	fog_particles1.scale_amount_max = 240.0
	fog_particles1.color = Color(0.4, 0.32, 0.55, 0.14)
	add_child(fog_particles1)

	# 3. Kabut Tebal Layer 2 (Melayang ke Kiri - Densitas Tinggi)
	fog_particles2 = CPUParticles2D.new()
	fog_particles2.position = Vector2(1430, 400)
	fog_particles2.amount = 65
	fog_particles2.lifetime = 10.0
	fog_particles2.preprocess = 5.0
	fog_particles2.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles2.emission_rect_extents = Vector2(60, 380)
	fog_particles2.gravity = Vector2(0, 0)
	fog_particles2.direction = Vector2(-1, -0.1)
	fog_particles2.spread = 25.0
	fog_particles2.initial_velocity_min = 40.0
	fog_particles2.initial_velocity_max = 85.0
	fog_particles2.scale_amount_min = 120.0
	fog_particles2.scale_amount_max = 280.0
	fog_particles2.color = Color(0.25, 0.2, 0.38, 0.12)
	add_child(fog_particles2)

	# 4. Kabut Tebal Layer 3 (Kabut Depan / Foreground Mist Floating Low)
	fog_particles3 = CPUParticles2D.new()
	fog_particles3.position = Vector2(640, 750)
	fog_particles3.amount = 45
	fog_particles3.lifetime = 8.0
	fog_particles3.preprocess = 4.0
	fog_particles3.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog_particles3.emission_rect_extents = Vector2(700, 40)
	fog_particles3.gravity = Vector2(0, -10)
	fog_particles3.direction = Vector2(0, -1)
	fog_particles3.spread = 35.0
	fog_particles3.initial_velocity_min = 15.0
	fog_particles3.initial_velocity_max = 35.0
	fog_particles3.scale_amount_min = 140.0
	fog_particles3.scale_amount_max = 320.0
	fog_particles3.color = Color(0.3, 0.25, 0.45, 0.10)
	add_child(fog_particles3)

	# 5. UI Container Utama (Teks Quote & Penulis)
	main_container = VBoxContainer.new()
	main_container.position = Vector2(160, 250)
	main_container.size = Vector2(960, 280)
	main_container.add_theme_constant_override("separation", 28)
	add_child(main_container)

	# 6. Label Quote (Semua Tulisan Berbarengan)
	quote_label = Label.new()
	quote_label.text = QUOTE_TEXT
	quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote_label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.98))
	quote_label.add_theme_font_size_override("font_size", 30)
	main_container.add_child(quote_label)

	# 7. Label Penulis (Haruki Murakami)
	author_label = Label.new()
	author_label.text = AUTHOR_TEXT
	author_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	author_label.add_theme_color_override("font_color", Color(0.78, 0.68, 0.92))
	author_label.add_theme_font_size_override("font_size", 22)
	main_container.add_child(author_label)

	# 8. Petunjuk Skip / Lanjut
	skip_hint_label = Label.new()
	skip_hint_label.text = "[ Tekan SPACE / Klik untuk skip ]"
	skip_hint_label.position = Vector2(440, 665)
	skip_hint_label.size = Vector2(400, 30)
	skip_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skip_hint_label.add_theme_color_override("font_color", Color(0.45, 0.4, 0.6, 0.6))
	skip_hint_label.add_theme_font_size_override("font_size", 13)
	add_child(skip_hint_label)

	# 9. Overlay Transitions Fade (Awalnya Hitam Pekat)
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 1.0)
	fade_overlay.size = Vector2(1280, 720)
	add_child(fade_overlay)

# ── Logika Fase Animasi Gelap -> Terang -> Menghitam ────────────────────────
func _start_intro() -> void:
	current_state = State.FADE_IN
	current_alpha = 1.0
	state_timer = 0.0
	fade_overlay.color.a = 1.0

func _process(delta: float) -> void:
	# Animasi kedip halus tombol skip hint
	if is_instance_valid(skip_hint_label):
		skip_hint_label.modulate.a = 0.3 + 0.4 * sin(Time.get_ticks_msec() * 0.003)

	match current_state:
		State.FADE_IN:
			# Awalnya sangat gelap, perlahan makin terang sampai terlihat semua
			state_timer += delta
			var progress = clamp(state_timer / FADE_IN_DURATION, 0.0, 1.0)
			# Curve halus smoothstep
			current_alpha = 1.0 - (progress * progress * (3.0 - 2.0 * progress))
			fade_overlay.color.a = current_alpha

			if progress >= 1.0:
				current_state = State.HOLD_VISIBLE
				state_timer = 0.0

		State.HOLD_VISIBLE:
			# Layar terang penuh & semua terlihat jelas selama durasi HOLD
			fade_overlay.color.a = 0.0
			state_timer += delta
			if state_timer >= HOLD_DURATION:
				current_state = State.FADE_OUT
				state_timer = 0.0

		State.FADE_OUT:
			# Setelah terlihat semua, perlahan-lahan menghitam kembali
			state_timer += delta
			var progress = clamp(state_timer / FADE_OUT_DURATION, 0.0, 1.0)
			current_alpha = progress * progress * (3.0 - 2.0 * progress)
			fade_overlay.color.a = current_alpha

			if progress >= 1.0:
				current_state = State.DONE
				_change_to_main_scene()

# ── User Input (Skip) ───────────────────────────────────────────────────────
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
