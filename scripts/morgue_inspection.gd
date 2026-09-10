extends CanvasLayer

signal morgue_completed

var is_active: bool = false
var has_revealed_corpse: bool = false

var bg: ColorRect
var center_container: CenterContainer
var title_label: Label
var subtitle_label: Label
var bed_rect: TextureRect
var action_btn: Button
var back_btn: Button
var status_label: Label

var tex_bed_covered: Texture2D
var tex_bed_corpse: Texture2D

var hospital_audio: AudioStreamPlayer
var shock_audio: AudioStreamPlayer
var breathing_audio: AudioStreamPlayer

func _ready() -> void:
	layer = 18
	_load_resources()
	_setup_audio()
	_build_ui()
	visible = false

func _load_resources() -> void:
	if ResourceLoader.exists("res://Environment/Ruang Mayat/kasurmayat.png"):
		tex_bed_covered = load("res://Environment/Ruang Mayat/kasurmayat.png")
	if ResourceLoader.exists("res://Environment/Ruang Mayat/kasurmayat-mayat.png"):
		tex_bed_corpse = load("res://Environment/Ruang Mayat/kasurmayat-mayat.png")

func _setup_audio() -> void:
	# 1. Hospital Ambient Tone
	hospital_audio = AudioStreamPlayer.new()
	hospital_audio.name = "HospitalAudioPlayer"
	if ResourceLoader.exists("res://sound/HOSPITAL.mp3"):
		hospital_audio.stream = load("res://sound/HOSPITAL.mp3")
		hospital_audio.volume_db = -6.0
	add_child(hospital_audio)

	# 2. Shock / Flashback SFX
	shock_audio = AudioStreamPlayer.new()
	shock_audio.name = "ShockAudioPlayer"
	if ResourceLoader.exists("res://sound/FLASHBACK.mp3"):
		shock_audio.stream = load("res://sound/FLASHBACK.mp3")
		shock_audio.volume_db = 0.0
	elif ResourceLoader.exists("res://sound/Suspense.mp3"):
		shock_audio.stream = load("res://sound/Suspense.mp3")
		shock_audio.volume_db = 0.0
	add_child(shock_audio)

	# 3. Heavy Breathing SFX
	breathing_audio = AudioStreamPlayer.new()
	breathing_audio.name = "BreathingAudioPlayer"
	if ResourceLoader.exists("res://sound/Heavy Breathing.mp3"):
		breathing_audio.stream = load("res://sound/Heavy Breathing.mp3")
		breathing_audio.volume_db = -2.0
	add_child(breathing_audio)

func _build_ui() -> void:
	bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.03, 0.05, 0.98)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vb)

	# Header Title
	title_label = Label.new()
	title_label.text = "KAMAR JENAZAH RUMAH SAKIT KOTA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(0.65, 0.82, 0.95))
	title_label.add_theme_font_size_override("font_size", 22)
	vb.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "Hawa dingin membekukan menusuk seluruh ruangan. Di tengah ruang, terbaring sesosok jasad."
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	subtitle_label.add_theme_font_size_override("font_size", 13)
	vb.add_child(subtitle_label)

	var sep = HSeparator.new()
	var sep_style = StyleBoxLine.new()
	sep_style.color = Color(0.3, 0.45, 0.6, 0.5)
	sep_style.thickness = 2
	sep.add_theme_stylebox_override("separator", sep_style)
	vb.add_child(sep)

	# Bed Container
	var bed_panel = PanelContainer.new()
	bed_panel.custom_minimum_size = Vector2(460, 260)
	bed_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var bp_style = StyleBoxFlat.new()
	bp_style.bg_color = Color(0.04, 0.06, 0.09, 0.9)
	bp_style.border_color = Color(0.3, 0.5, 0.7, 0.8)
	bp_style.set_border_width_all(2)
	bp_style.set_corner_radius_all(10)
	bed_panel.add_theme_stylebox_override("panel", bp_style)
	vb.add_child(bed_panel)

	bed_rect = TextureRect.new()
	if is_instance_valid(tex_bed_covered):
		bed_rect.texture = tex_bed_covered
	bed_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bed_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bed_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bed_panel.add_child(bed_rect)

	# Status / Monologue hint
	status_label = Label.new()
	status_label.text = "Kain putih menutupi seluruh tubuh korban... Hanya satu cara untuk memastikan siapa korban sebenarnya."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
	status_label.add_theme_font_size_override("font_size", 14)
	vb.add_child(status_label)

	# Action Buttons
	var btn_hb = HBoxContainer.new()
	btn_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hb.add_theme_constant_override("separation", 20)
	vb.add_child(btn_hb)

	action_btn = Button.new()
	action_btn.text = "SINGKAP KAIN PENUTUP MAYAT [Spasi / F]"
	action_btn.custom_minimum_size = Vector2(340, 48)
	var ab_style = StyleBoxFlat.new()
	ab_style.bg_color = Color(0.12, 0.28, 0.45, 0.95)
	ab_style.border_color = Color(0.4, 0.75, 1.0, 1.0)
	ab_style.set_border_width_all(2)
	ab_style.set_corner_radius_all(8)
	action_btn.add_theme_stylebox_override("normal", ab_style)
	action_btn.pressed.connect(_reveal_corpse)
	btn_hb.add_child(action_btn)

	back_btn = Button.new()
	back_btn.text = "Mundur [ESC]"
	back_btn.custom_minimum_size = Vector2(160, 48)
	var bb_style = StyleBoxFlat.new()
	bb_style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	bb_style.set_corner_radius_all(8)
	back_btn.add_theme_stylebox_override("normal", bb_style)
	back_btn.pressed.connect(close_morgue)
	btn_hb.add_child(back_btn)

func open_morgue() -> void:
	if not is_instance_valid(action_btn):
		_build_ui()
	is_active = true
	has_revealed_corpse = false
	visible = true
	if is_instance_valid(bed_rect) and is_instance_valid(tex_bed_covered):
		bed_rect.texture = tex_bed_covered
	action_btn.visible = true
	action_btn.disabled = false
	back_btn.visible = true
	status_label.text = "Kain putih menutupi seluruh tubuh korban... Hanya satu cara untuk memastikan siapa korban sebenarnya."
	status_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

	if is_instance_valid(hospital_audio) and hospital_audio.stream:
		hospital_audio.play()

func close_morgue() -> void:
	if not is_active:
		return
	is_active = false
	visible = false
	if is_instance_valid(hospital_audio) and hospital_audio.playing:
		hospital_audio.stop()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			close_morgue()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_SPACE, KEY_ENTER, KEY_F, KEY_E]:
			if not has_revealed_corpse:
				_reveal_corpse()
				get_viewport().set_input_as_handled()

func _reveal_corpse() -> void:
	if has_revealed_corpse:
		return
	has_revealed_corpse = true
	action_btn.disabled = true
	action_btn.visible = false
	back_btn.visible = false

	# Play revelation sounds: Shock followed by Heavy Breathing
	if is_instance_valid(shock_audio) and shock_audio.stream:
		shock_audio.play()
	if is_instance_valid(breathing_audio) and breathing_audio.stream:
		breathing_audio.play()

	# Switch image to uncovered corpse
	if is_instance_valid(bed_rect) and is_instance_valid(tex_bed_corpse):
		bed_rect.texture = tex_bed_corpse

	# ── EFEK GLITCH VISUAL & DISTORSI REALITAS (Sesuai Cerita) ──
	_play_glitch_sequence(1.8, func():
		status_label.text = "KAIN DISINGKAP... WAJAH MAYAT INI ADALAH DIRIMU SENDIRI, BENEDICT!!"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))

		var inv_mgr = get_node_or_null("/root/InvestigationManager")
		if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
			inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
		if is_instance_valid(inv_mgr):
			inv_mgr.unlock_clue("autopsy_corpse")
			inv_mgr.has_inspected_morgue = true
			inv_mgr.set_phase(inv_mgr.Phase.FINAL_DEATH_GOD)

		# Launch Monologue Sequence via DialogBox
		var main_node = get_parent()
		var dlg = null
		if is_instance_valid(main_node):
			dlg = main_node.get_node_or_null("DialogBox")

		var monologue_lines: Array[String] = [
			"T-tidak... TIDAK MUNGKIN!!",
			"Wajah ini... luka di pelipis ini... mantel yang kukenakan ini...",
			"JASAD YANG TERBARING KAKU DI ATAS RANJANG INI... ADALAH DIRIKU SENDIRI?!",
			"Jam yang terhenti di 16:04... orang-orang di jalan yang bergidik saat menyapaku... foto di peron stasiun...",
			"Aku bukan sedang menyelidiki kematian orang lain. Aku... aku sudah tewas sejak awal...",
			"Udara bergetar hebat... ruang dan waktu di sekitarku mulai retak dan hancur..."
		]

		if is_instance_valid(dlg) and dlg.has_method("start_monologue"):
			dlg.start_monologue(monologue_lines, "Benedict", "[ FAKTA MENGERIKAN ]", "res://karakter/MC_Kaget.png")
			dlg.monologue_finished.connect(func():
				_trigger_pull_to_death_god()
			, CONNECT_ONE_SHOT)
		else:
			if is_inside_tree() and get_tree():
				await get_tree().create_timer(4.0).timeout
			_trigger_pull_to_death_god()
	)

func _play_glitch_sequence(duration: float, callback: Callable) -> void:
	var glitch_overlay = Control.new()
	glitch_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glitch_overlay)

	var orig_bed_pos = bed_rect.position if is_instance_valid(bed_rect) else Vector2.ZERO
	var orig_status_pos = status_label.position if is_instance_valid(status_label) else Vector2.ZERO
	var glitch_colors: Array[Color] = [
		Color(0.0, 0.95, 1.0, 0.8),
		Color(1.0, 0.05, 0.65, 0.8),
		Color(1.0, 0.15, 0.15, 0.85),
		Color(0.05, 0.05, 0.08, 0.9),
		Color(1.0, 1.0, 1.0, 0.95)
	]

	var corrupted_strings: Array[String] = [
		"ERR_0R: J@S@D 404... B-BENED!CT?!",
		"W@J@H M@Y@T... MENGAPA ADALAH DIRIKU?!",
		"DETEKTIF... K@U SUDAH M@TI SEJAK AW@L...",
		"16:04... WAKTU KEMATIANMU T!D@K BISA DIULANG..."
	]

	var tw = create_tween()
	tw.tween_method(func(_progress: float):
		# Screen shake pada ranjang dan teks status
		if is_instance_valid(bed_rect):
			bed_rect.position = orig_bed_pos + Vector2(randf_range(-14, 14), randf_range(-8, 8))
		if is_instance_valid(status_label):
			status_label.position = orig_status_pos + Vector2(randf_range(-8, 8), randf_range(-4, 4))
			if randf() < 0.35:
				status_label.text = corrupted_strings[randi() % corrupted_strings.size()]
				status_label.add_theme_color_override("font_color", glitch_colors[randi() % glitch_colors.size()])

		# Bersihkan strip glitch frame sebelumnya
		for child in glitch_overlay.get_children():
			child.queue_free()

		# Buat strip glitch horizontal acak
		var num_slices = randi_range(4, 9)
		var view_sz = glitch_overlay.get_viewport_rect().size
		for i in range(num_slices):
			var slice = ColorRect.new()
			var sy = randf_range(0.0, view_sz.y)
			var sh = randf_range(3.0, 32.0)
			var sx = randf_range(-30.0, 30.0)
			slice.position = Vector2(sx, sy)
			slice.size = Vector2(view_sz.x + 60.0, sh)
			slice.color = glitch_colors[randi() % glitch_colors.size()]
			glitch_overlay.add_child(slice)
	, 0.0, 1.0, duration)

	tw.tween_callback(func():
		if is_instance_valid(bed_rect):
			bed_rect.position = orig_bed_pos
		if is_instance_valid(status_label):
			status_label.position = orig_status_pos
		if is_instance_valid(glitch_overlay):
			glitch_overlay.queue_free()
		if callback.is_valid():
			callback.call()
	)

func _trigger_pull_to_death_god() -> void:
	# Glitch penutup dan transisi langsung ke Dewa Kematian
	_play_glitch_sequence(1.2, func():
		var pull_overlay = ColorRect.new()
		pull_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		pull_overlay.color = Color(0.04, 0.02, 0.08, 0.0)
		pull_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pull_overlay)

		var tw = create_tween()
		tw.tween_property(pull_overlay, "color:a", 1.0, 1.0)
		tw.tween_callback(func():
			close_morgue()
			morgue_completed.emit()
		)
	)
