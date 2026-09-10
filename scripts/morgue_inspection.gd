extends CanvasLayer

signal morgue_completed

var is_active: bool = false
var has_revealed_corpse: bool = false
var is_walking_in: bool = false
var walk_anim_timer: float = 0.0

var root_control: Control
var room_viewport: Control
var title_label: Label
var subtitle_label: Label
var action_btn: Button
var back_btn: Button
var status_label: Label

# Elemen Ruang Mayat
var morgue_bg: TextureRect
var bed_rect: TextureRect
var benedict_actor: TextureRect
var neon_light_strip: ColorRect
var bw_glitch_overlay: Control
var black_fade_rect: ColorRect

# Tekstur
var tex_bed_covered: Texture2D
var tex_bed_corpse: Texture2D
var tex_floor_tile: Texture2D
var mc_sprites_right: Array[Texture2D] = []

# Audio
var hospital_audio: AudioStreamPlayer
var shock_audio: AudioStreamPlayer
var breathing_audio: AudioStreamPlayer
var footsteps_audio: AudioStreamPlayer

const STAGE_W := 1280.0
const STAGE_H := 720.0
const BENEDICT_START_X := 120.0
const BENEDICT_TARGET_X := 480.0
const BENEDICT_Y := 410.0

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
	if ResourceLoader.exists("res://Environment/RS/FloorTile/FloorTileDiffuse.png"):
		tex_floor_tile = load("res://Environment/RS/FloorTile/FloorTileDiffuse.png")

	# Muat sprite berjalan Benedict ke arah kanan
	var f1 = load("res://posisi mc/right_left.png")
	var f2 = load("res://posisi mc/right.png")
	var f3 = load("res://posisi mc/right_right.png")
	if f1: mc_sprites_right.append(f1)
	if f2: mc_sprites_right.append(f2)
	if f3: mc_sprites_right.append(f3)

func _setup_audio() -> void:
	# Ambient Rumah Sakit
	hospital_audio = AudioStreamPlayer.new()
	hospital_audio.name = "HospitalAudioPlayer"
	if ResourceLoader.exists("res://sound/HOSPITAL.mp3"):
		hospital_audio.stream = load("res://sound/HOSPITAL.mp3")
		hospital_audio.volume_db = -5.0
	add_child(hospital_audio)

	# Suara Langkah Kaki Benedict
	footsteps_audio = AudioStreamPlayer.new()
	footsteps_audio.name = "MorgueFootstepsPlayer"
	if ResourceLoader.exists("res://sound/Footsteps.mp3"):
		footsteps_audio.stream = load("res://sound/Footsteps.mp3")
		footsteps_audio.volume_db = -4.0
	add_child(footsteps_audio)

	# Audio Kejutan / Terungkap
	shock_audio = AudioStreamPlayer.new()
	shock_audio.name = "ShockAudioPlayer"
	if ResourceLoader.exists("res://sound/FLASHBACK.mp3"):
		shock_audio.stream = load("res://sound/FLASHBACK.mp3")
		shock_audio.volume_db = 0.0
	elif ResourceLoader.exists("res://sound/Suspense.mp3"):
		shock_audio.stream = load("res://sound/Suspense.mp3")
		shock_audio.volume_db = 0.0
	add_child(shock_audio)

	# Suara Nafas Berat Horor
	breathing_audio = AudioStreamPlayer.new()
	breathing_audio.name = "BreathingAudioPlayer"
	if ResourceLoader.exists("res://sound/Heavy Breathing.mp3"):
		breathing_audio.stream = load("res://sound/Heavy Breathing.mp3")
		breathing_audio.volume_db = -2.0
	add_child(breathing_audio)

func open_morgue() -> void:
	if tex_bed_covered == null:
		_load_resources()
	if not is_instance_valid(action_btn):
		_build_ui()
	is_active = true
	has_revealed_corpse = false
	visible = true

	# Reset visual
	if is_instance_valid(black_fade_rect):
		black_fade_rect.color = Color(0, 0, 0, 0)
	if is_instance_valid(bw_glitch_overlay):
		bw_glitch_overlay.visible = false
	if is_instance_valid(bed_rect) and is_instance_valid(tex_bed_covered):
		bed_rect.texture = tex_bed_covered
		bed_rect.scale = Vector2.ONE
		bed_rect.position = Vector2(490, 240)

	action_btn.visible = false
	back_btn.visible = true
	status_label.text = "Benedict melangkah menyusuri lorong dingin kamar jenazah..."
	status_label.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))

	if is_instance_valid(hospital_audio) and hospital_audio.is_inside_tree() and hospital_audio.stream:
		hospital_audio.play()

	_start_benedict_walk_in_animation()

func close_morgue() -> void:
	if not is_active:
		return
	is_active = false
	visible = false
	is_walking_in = false
	if is_instance_valid(hospital_audio) and hospital_audio.playing:
		hospital_audio.stop()
	if is_instance_valid(footsteps_audio) and footsteps_audio.playing:
		footsteps_audio.stop()
	if is_instance_valid(breathing_audio) and breathing_audio.playing:
		breathing_audio.stop()

func _start_benedict_walk_in_animation() -> void:
	if not is_instance_valid(benedict_actor):
		_on_benedict_reached_bed()
		return

	is_walking_in = true
	walk_anim_timer = 0.0
	benedict_actor.visible = true
	benedict_actor.position = Vector2(BENEDICT_START_X, BENEDICT_Y)

	if is_instance_valid(footsteps_audio) and footsteps_audio.is_inside_tree() and footsteps_audio.stream:
		footsteps_audio.play()

	# Animasi Tween Benedict berjalan dari pintu kiri ke kasur mayat
	var walk_duration = 3.2
	var tw = create_tween()
	tw.tween_property(benedict_actor, "position:x", BENEDICT_TARGET_X, walk_duration)
	tw.tween_callback(func():
		is_walking_in = false
		if is_instance_valid(footsteps_audio) and footsteps_audio.playing:
			footsteps_audio.stop()
		_on_benedict_reached_bed()
	)

func _process(delta: float) -> void:
	if not is_active:
		return

	# Animasi langkah kaki Benedict saat berjalan masuk
	if is_walking_in and is_instance_valid(benedict_actor) and not mc_sprites_right.is_empty():
		walk_anim_timer += delta * 6.0
		var frame_idx = int(walk_anim_timer) % mc_sprites_right.size()
		benedict_actor.texture = mc_sprites_right[frame_idx]
		# Bobbing naik-turun saat melangkah
		var bob = abs(sin(walk_anim_timer * 2.0)) * -4.0
		benedict_actor.position.y = BENEDICT_Y + bob

	# Efek kedipan lembut lampu neon fluorescent kamar mayat
	if is_instance_valid(neon_light_strip):
		var flicker = 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.015)
		if randf() < 0.03:
			flicker = randf_range(0.3, 0.7)
		neon_light_strip.color = Color(0.7, 0.9, 1.0, 0.22 * flicker)

func _on_benedict_reached_bed() -> void:
	if is_instance_valid(benedict_actor) and not mc_sprites_right.is_empty():
		benedict_actor.texture = mc_sprites_right[1] # Frame diam
		benedict_actor.position.y = BENEDICT_Y

	status_label.text = "Di depanmu, terbaring sesosok mayat yang ditutupi kain putih. Hanya satu cara untuk mengungkap kebenarannya..."
	status_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	action_btn.visible = true
	action_btn.disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			close_morgue()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_SPACE, KEY_ENTER, KEY_F, KEY_E]:
			if not has_revealed_corpse and not is_walking_in:
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
	if is_instance_valid(shock_audio) and shock_audio.is_inside_tree() and shock_audio.stream:
		shock_audio.play()
	if is_instance_valid(breathing_audio) and breathing_audio.is_inside_tree() and breathing_audio.stream:
		breathing_audio.play()

	# Buka kain kasur mayat
	if is_instance_valid(bed_rect) and is_instance_valid(tex_bed_corpse):
		bed_rect.texture = tex_bed_corpse

	# Zoom-in dramatis ke arah kasur mayat
	var tw_zoom = create_tween()
	tw_zoom.tween_property(bed_rect, "scale", Vector2(1.18, 1.18), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_zoom.parallel().tween_property(bed_rect, "position", Vector2(430, 210), 0.8)

	status_label.text = "KAIN DISINGKAP... WAJAH MAYAT DI ATAS KASUR INI ADALAH WAJAHMU SENDIRI, BENEDICT!!"
	status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	var inv_mgr = null
	if is_inside_tree():
		inv_mgr = get_node_or_null("/root/InvestigationManager")
		if not is_instance_valid(inv_mgr) and get_tree() and get_tree().root:
			inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	if is_instance_valid(inv_mgr):
		inv_mgr.unlock_clue("autopsy_corpse")
		inv_mgr.has_inspected_morgue = true
		inv_mgr.set_phase(inv_mgr.Phase.FINAL_DEATH_GOD)

	# Dialog syok batin Benedict
	var main_node = get_parent()
	var dlg = null
	if is_instance_valid(main_node):
		dlg = main_node.get_node_or_null("DialogBox")

	var monologue_lines: Array[String] = [
		"T-tidak... TIDAK MUNGKIN!!",
		"Wajah yang membeku pucat di ranjang ini... luka di pelipis ini... dasi dan kemeja ini...",
		"MAYAT YANG TERBARING DI KAMAR JENAZAH INI... ADALAH DIRIKU SENDIRI?!",
		"Jam dinding kota yang terhenti di 16:04... tatapan ngeri orang-orang di jalan... rol foto di stasiun...",
		"Aku bukan sedang menyelidiki kasus pembunuhan orang lain... AKU TELAH MATI SEJAK AWAL!!",
		"Udara di sekitarku bergetar hebat... Realitas dan kesadaranku mulai hancur lebur..."
	]

	if is_instance_valid(dlg) and dlg.has_method("start_monologue"):
		dlg.start_monologue(monologue_lines, "Detektif Benedict", "[ KEBENARAN MENGERIKAN ]", "res://karakter/MC_Kaget.png")
		dlg.monologue_finished.connect(func():
			_trigger_bw_glitch_and_fade_to_black()
		, CONNECT_ONE_SHOT)
	else:
		if is_inside_tree() and get_tree():
			await get_tree().create_timer(3.5).timeout
		_trigger_bw_glitch_and_fade_to_black()

# ── GLITCH HITAM PUTIH, LAYAR MENGHITAM, LALU KETEMU DEWA KEMATIAN ──
func _trigger_bw_glitch_and_fade_to_black() -> void:
	if not is_instance_valid(bw_glitch_overlay):
		_finish_to_death_god()
		return

	bw_glitch_overlay.visible = true

	var corrupted_messages = [
		"ERROR 404: SUBJEK TELAH TEWAS",
		"WAKTU KEMATIAN: 16:04:00",
		"BENEDICT... KAU SUDAH TIADA",
		"MENGHUBUNGKAN KE ALAM DEWA KEMATIAN..."
	]

	# Glitch Hitam Putih selama 2.6 detik
	var glitch_duration = 2.6
	var tw_glitch = create_tween()
	tw_glitch.tween_method(func(_prog: float):
		# Screen shake monokrom
		if is_instance_valid(room_viewport):
			room_viewport.position = Vector2(randf_range(-18, 18), randf_range(-10, 10))

		# Teks glitch
		if is_instance_valid(status_label):
			if randf() < 0.4:
				status_label.text = corrupted_messages[randi() % corrupted_messages.size()]
				status_label.add_theme_color_override("font_color", Color.WHITE if randf() < 0.5 else Color(0.7, 0.7, 0.7))

		# Bersihkan strip glitch frame sebelumnya
		for c in bw_glitch_overlay.get_children():
			c.queue_free()

		# Buat strip hitam putih acak
		var num_slices = randi_range(6, 12)
		var view_sz = bw_glitch_overlay.get_viewport_rect().size
		var bw_palette = [Color.WHITE, Color.BLACK, Color(0.2, 0.2, 0.2), Color(0.8, 0.8, 0.8)]

		for i in range(num_slices):
			var slice = ColorRect.new()
			var sy = randf_range(0.0, view_sz.y)
			var sh = randf_range(4.0, 38.0)
			slice.position = Vector2(0.0, sy)
			slice.size = Vector2(view_sz.x, sh)
			slice.color = bw_palette[randi() % bw_palette.size()]
			slice.color.a = randf_range(0.6, 0.95)
			bw_glitch_overlay.add_child(slice)
	, 0.0, 1.0, glitch_duration)

	# Setelah Glitch Hitam Putih -> Layar Perlahan Menghitam Pekat (Fade to Black)
	tw_glitch.tween_callback(func():
		if is_instance_valid(room_viewport):
			room_viewport.position = Vector2.ZERO
		if is_instance_valid(bw_glitch_overlay):
			for c in bw_glitch_overlay.get_children():
				c.queue_free()
			bw_glitch_overlay.visible = false

		_fade_to_black_and_meet_death_god()
	)

func _fade_to_black_and_meet_death_god() -> void:
	if is_instance_valid(status_label):
		status_label.text = "Kesadaranmu memudar ke dalam kegelapan abadi..."
		status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	if is_instance_valid(black_fade_rect):
		var tw_black = create_tween()
		tw_black.tween_property(black_fade_rect, "color:a", 1.0, 1.4)
		tw_black.tween_interval(1.0) # Jeda hening di kegelapan total
		tw_black.tween_callback(func():
			_finish_to_death_god()
		)
	else:
		_finish_to_death_god()

func _finish_to_death_god() -> void:
	close_morgue()
	morgue_completed.emit()

func _build_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_control)

	var bg_black = ColorRect.new()
	bg_black.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_black.color = Color(0.01, 0.02, 0.03, 1.0)
	root_control.add_child(bg_black)

	# Wadah viewport panggung ruang mayat
	room_viewport = Control.new()
	room_viewport.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(room_viewport)

	# --- 1. DINDING KAMAR MAYAT (Ubin Klinis Rumah Sakit Dingin) ---
	var wall = ColorRect.new()
	wall.position = Vector2.ZERO
	wall.size = Vector2(1920, 420)
	wall.color = Color(0.09, 0.14, 0.16, 1.0) # Hijau tosca kelabu dingin
	room_viewport.add_child(wall)

	# Garis-garis pola ubin dinding rumah sakit
	for y in range(0, 420, 35):
		var tile_h_line = ColorRect.new()
		tile_h_line.position = Vector2(0, y)
		tile_h_line.size = Vector2(1920, 1.5)
		tile_h_line.color = Color(0.06, 0.09, 0.11, 0.75)
		room_viewport.add_child(tile_h_line)

	for x in range(0, 1920, 70):
		var tile_v_line = ColorRect.new()
		tile_v_line.position = Vector2(x, 0)
		tile_v_line.size = Vector2(1.5, 420)
		tile_v_line.color = Color(0.06, 0.09, 0.11, 0.75)
		room_viewport.add_child(tile_v_line)

	# --- 2. LEMARI PENDINGIN JENAZAH (MORGUE BODY DRAWERS) DI DINDING ---
	var freezer_panel = PanelContainer.new()
	freezer_panel.position = Vector2(620, 80)
	freezer_panel.size = Vector2(580, 240)
	var fp_style = StyleBoxFlat.new()
	fp_style.bg_color = Color(0.18, 0.22, 0.25, 0.95) # Baja stainless steel
	fp_style.border_color = Color(0.35, 0.45, 0.52, 1.0)
	fp_style.set_border_width_all(3)
	fp_style.set_corner_radius_all(6)
	fp_style.content_margin_left = 12
	fp_style.content_margin_right = 12
	fp_style.content_margin_top = 10
	fp_style.content_margin_bottom = 10
	freezer_panel.add_theme_stylebox_override("panel", fp_style)
	room_viewport.add_child(freezer_panel)

	var freezer_grid = GridContainer.new()
	freezer_grid.columns = 3
	freezer_grid.add_theme_constant_override("h_separation", 14)
	freezer_grid.add_theme_constant_override("v_separation", 14)
	freezer_panel.add_child(freezer_grid)

	var drawer_labels = ["#01", "#02", "#03", "#04", "#404 (TKP)", "#06"]
	for i in range(6):
		var drawer_box = PanelContainer.new()
		drawer_box.custom_minimum_size = Vector2(170, 95)
		var db_style = StyleBoxFlat.new()
		db_style.bg_color = Color(0.24, 0.28, 0.32, 1.0)
		db_style.border_color = Color(1.0, 0.3, 0.3, 1.0) if i == 4 else Color(0.4, 0.5, 0.6, 0.8)
		db_style.set_border_width_all(2 if i == 4 else 1)
		db_style.set_corner_radius_all(4)
		drawer_box.add_theme_stylebox_override("panel", db_style)
		freezer_grid.add_child(drawer_box)

		var dw_vb = VBoxContainer.new()
		dw_vb.alignment = BoxContainer.ALIGNMENT_CENTER
		drawer_box.add_child(dw_vb)

		var d_lbl = Label.new()
		d_lbl.text = "LACI JENAZAH " + drawer_labels[i]
		d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		d_lbl.add_theme_font_size_override("font_size", 11)
		d_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4) if i == 4 else Color(0.8, 0.9, 1.0))
		dw_vb.add_child(d_lbl)

		# Pegangan pintu besi krom
		var handle = ColorRect.new()
		handle.custom_minimum_size = Vector2(70, 8)
		handle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		handle.color = Color(0.7, 0.8, 0.9, 0.9)
		dw_vb.add_child(handle)

	# Pintu Masuk Besi di Kiri
	var door = PanelContainer.new()
	door.position = Vector2(40, 110)
	door.size = Vector2(140, 310)
	var door_style = StyleBoxFlat.new()
	door_style.bg_color = Color(0.12, 0.16, 0.18, 1.0)
	door_style.border_color = Color(0.3, 0.4, 0.45, 1.0)
	door_style.set_border_width_all(2)
	door.add_theme_stylebox_override("panel", door_style)
	room_viewport.add_child(door)

	var door_window = ColorRect.new()
	door_window.position = Vector2(25, 35)
	door_window.size = Vector2(90, 80)
	door_window.color = Color(0.35, 0.55, 0.6, 0.4)
	door.add_child(door_window)

	var door_lbl = Label.new()
	door_lbl.text = "PINTU\nMASUK"
	door_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	door_lbl.position = Vector2(0, 140)
	door_lbl.size = Vector2(140, 40)
	door_lbl.add_theme_font_size_override("font_size", 12)
	door_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	door.add_child(door_lbl)

	# --- 3. LANTAI RUMAH SAKIT DINGIN ---
	var floor_rect = ColorRect.new()
	floor_rect.position = Vector2(0, 420)
	floor_rect.size = Vector2(1920, 500)
	floor_rect.color = Color(0.07, 0.10, 0.12, 1.0)
	room_viewport.add_child(floor_rect)

	# Pola Ubin Lantai
	for y in range(420, 920, 50):
		var fl_h = ColorRect.new()
		fl_h.position = Vector2(0, y)
		fl_h.size = Vector2(1920, 1.5)
		fl_h.color = Color(0.12, 0.18, 0.22, 0.6)
		room_viewport.add_child(fl_h)

	for x in range(0, 1920, 90):
		var fl_v = ColorRect.new()
		fl_v.position = Vector2(x, 420)
		fl_v.size = Vector2(1.5, 500)
		fl_v.color = Color(0.12, 0.18, 0.22, 0.6)
		room_viewport.add_child(fl_v)

	# Cahaya Pantulan Lampu Neon di Lantai
	neon_light_strip = ColorRect.new()
	neon_light_strip.position = Vector2(250, 430)
	neon_light_strip.size = Vector2(780, 180)
	neon_light_strip.color = Color(0.7, 0.9, 1.0, 0.18)
	room_viewport.add_child(neon_light_strip)

	# Lampu Neon di Plafon
	var neon_tube = ColorRect.new()
	neon_tube.position = Vector2(460, 20)
	neon_tube.size = Vector2(360, 10)
	neon_tube.color = Color(0.85, 0.95, 1.0, 0.9)
	room_viewport.add_child(neon_tube)

	# --- 4. RANJANG AUTOPISI / KASUR MAYAT DI TENGAH RUANGAN ---
	bed_rect = TextureRect.new()
	if is_instance_valid(tex_bed_covered):
		bed_rect.texture = tex_bed_covered
	bed_rect.position = Vector2(490, 240)
	bed_rect.size = Vector2(500, 360)
	bed_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bed_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	room_viewport.add_child(bed_rect)

	# --- 5. BENEDICT ACTOR (ANIMASI BERJALAN MASUK) ---
	benedict_actor = TextureRect.new()
	if not mc_sprites_right.is_empty():
		benedict_actor.texture = mc_sprites_right[0]
	benedict_actor.position = Vector2(BENEDICT_START_X, BENEDICT_Y)
	benedict_actor.size = Vector2(90, 140)
	benedict_actor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	benedict_actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	benedict_actor.visible = false
	room_viewport.add_child(benedict_actor)

	# --- 6. OVERLAY HUD HEADER & DIALOG ---
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(margin)

	var vb = VBoxContainer.new()
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vb)

	# Header Bar
	var hb = HBoxContainer.new()
	vb.add_child(hb)

	title_label = Label.new()
	title_label.text = "KAMAR JENAZAH RUMAH SAKIT KOTA (LOKASI STERIL)"
	title_label.add_theme_color_override("font_color", Color(0.75, 0.9, 1.0))
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(title_label)

	back_btn = Button.new()
	back_btn.text = "Keluar [ESC]"
	back_btn.focus_mode = Control.FOCUS_NONE
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_btn.pressed.connect(close_morgue)
	hb.add_child(back_btn)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(spacer)

	# Status & Monologue Bar Bawah
	var bottom_card = PanelContainer.new()
	var bc_style = StyleBoxFlat.new()
	bc_style.bg_color = Color(0.04, 0.06, 0.08, 0.92)
	bc_style.border_color = Color(0.3, 0.5, 0.7, 0.8)
	bc_style.set_border_width_all(2)
	bc_style.set_corner_radius_all(10)
	bc_style.content_margin_left = 24
	bc_style.content_margin_right = 24
	bc_style.content_margin_top = 12
	bc_style.content_margin_bottom = 12
	bottom_card.add_theme_stylebox_override("panel", bc_style)
	vb.add_child(bottom_card)

	var b_vb = VBoxContainer.new()
	b_vb.add_theme_constant_override("separation", 10)
	bottom_card.add_child(b_vb)

	status_label = Label.new()
	status_label.text = "Benedict melangkah perlahan ke dalam kamar jenazah..."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	b_vb.add_child(status_label)

	action_btn = Button.new()
	action_btn.text = "SINGKAP KAIN PENUTUP MAYAT [ SPASI / F / KLIK ]"
	action_btn.custom_minimum_size = Vector2(420, 46)
	action_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	action_btn.focus_mode = Control.FOCUS_NONE
	action_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var ab_style = StyleBoxFlat.new()
	ab_style.bg_color = Color(0.12, 0.32, 0.52, 0.95)
	ab_style.border_color = Color(0.45, 0.8, 1.0, 1.0)
	ab_style.set_border_width_all(2)
	ab_style.set_corner_radius_all(8)
	action_btn.add_theme_stylebox_override("normal", ab_style)
	action_btn.pressed.connect(_reveal_corpse)
	action_btn.visible = false
	b_vb.add_child(action_btn)

	# --- 7. OVERLAY GLITCH HITAM PUTIH ---
	bw_glitch_overlay = Control.new()
	bw_glitch_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	bw_glitch_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bw_glitch_overlay.visible = false
	root_control.add_child(bw_glitch_overlay)

	# --- 8. FADE TO BLACK OVERLAY ---
	black_fade_rect = ColorRect.new()
	black_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	black_fade_rect.color = Color(0, 0, 0, 0)
	black_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(black_fade_rect)
