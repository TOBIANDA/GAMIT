extends Node2D

@onready var player: CharacterBody2D = $Player
var shrine: Node2D = null
@onready var dialog_box: CanvasLayer = $DialogBox
@onready var hud_speed_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var hud_pos_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/PosLabel
@onready var hud_zoom_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/ZoomLabel
@onready var hud_objective_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/ObjectiveLabel

var server_pid: int = -1

var inv_mgr: Node
var world_shader: CanvasLayer
var clue_journal: CanvasLayer
var minigame_tailgate: CanvasLayer
var minigame_hidden_objects: CanvasLayer
var minigame_photo_wash: CanvasLayer
var minigame_safe: CanvasLayer
var death_god_layer: CanvasLayer
var summoned_grim: Node2D = null
var morgue_inspection: CanvasLayer
var paper_sfx_player: AudioStreamPlayer
var hospital_status_reception_rejected: bool = false

var main_menu_layer: CanvasLayer
var pause_menu_layer: CanvasLayer
var detective_hud_panel: PanelContainer
var hud_avatar_rect: TextureRect
var hud_objective_text: Label
var hud_phase_badge: Label

var interact_prompt: Button
var fullscreen_btn: Button
var toast_banner: PanelContainer
var toast_label: Label
var toast_timer: float = 0.0
var input_grace_timer: float = 0.35

var active_poi_id: String = ""

var house_interior: Node2D
var is_inside_house: bool = false
var exploration_house_interior: Node2D
var is_inside_exploration_house: bool = false
var transition_overlay: ColorRect
var transition_layer: CanvasLayer

const POI_LOCATIONS = {
	"desk": {"name": "Masuk ke Rumah Korban", "pos": Vector2(1170, 230), "radius": 150.0},
	"south_house": {"name": "Masuk ke Rumah Eksplorasi (Rumah Selatan)", "pos": Vector2(1714, 1170), "radius": 75.0},
	"street_clock": {"name": "Jam Jalan (Berhenti di 16:04)", "pos": Vector2(480, 220), "radius": 120.0},
	"police": {"name": "Kantor Polisi & Marcus (Minigame Menguntit)", "pos": Vector2(280, 915), "radius": 220.0},
	"station": {"name": "Stasiun Kereta Api (Minigame Cari Bukti)", "pos": Vector2(2020, 930), "radius": 320.0},
	"hospital": {"name": "Rumah Sakit & Kamar Jenazah", "pos": Vector2(750, 1095), "radius": 160.0},
	"phone": {"name": "Bilik Telepon Umum (Peron Stasiun)", "pos": Vector2(2018, 1269), "radius": 75.0}
}

var bgm_player: AudioStreamPlayer
var afterlife_audio_player: AudioStreamPlayer
var click_sfx_player: AudioStreamPlayer
var door_sfx_player: AudioStreamPlayer

var cutscene_layer: CanvasLayer
static var cutscene_played: bool = false
@export var show_intro_cutscene: bool = true
var auto_police_escort_triggered: bool = false

func _ready() -> void:
	print("[Main] Menginisialisasi Sistem Lengkap Sesuai GDD...")

	# Pastikan game berjalan dalam true fullscreen responsif di seluruh monitor/laptop
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	_setup_audio_system()
	_setup_dialog_box()
	_setup_death_god_shrine()
	_setup_transition_overlay()
	_setup_house_interior()
	_setup_exploration_house_interior()
	_setup_investigation_manager()
	_setup_world_shader()
	_setup_clue_journal()
	_setup_minigames()
	_setup_letter_viewer()
	_setup_main_menu()
	_setup_pause_menu()
	_setup_hud_prompts()
	_start_ai_server()

	_update_hud_objective()

	if is_instance_valid(main_menu_layer):
		main_menu_layer.open_menu()
		if is_instance_valid(player):
			player.can_move = false
			player.set_physics_process(false)

func _setup_dialog_box() -> void:
	if not is_instance_valid(dialog_box):
		dialog_box = get_node_or_null("DialogBox")
	if not is_instance_valid(dialog_box):
		var dlg_scene = load("res://scenes/dialog_box.tscn")
		if dlg_scene:
			dialog_box = dlg_scene.instantiate()
			dialog_box.name = "DialogBox"
			add_child(dialog_box)
	if is_instance_valid(dialog_box):
		if not dialog_box.dialog_opened.is_connected(_on_dialog_opened):
			dialog_box.dialog_opened.connect(_on_dialog_opened)
		if not dialog_box.dialog_closed.is_connected(_on_dialog_closed):
			dialog_box.dialog_closed.connect(_on_dialog_closed)

func _setup_death_god_shrine() -> void:
	# Altar fisik Dewa Kematian di map dihilangkan, pemanggilan Dewa Kematian dilakukan via shortcut [X]
	var old_shrine = get_node_or_null("DeathGodShrine")
	if is_instance_valid(old_shrine):
		old_shrine.queue_free()
	shrine = null

func _on_shrine_interaction() -> void:
	_summon_death_god()

func _setup_audio_system() -> void:
	# 1. Background Music Player (BGM.mp3)
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	var bgm_stream = load("res://sound/BGM.mp3")
	if bgm_stream:
		bgm_player.stream = bgm_stream
		bgm_player.volume_db = -10.0
		bgm_player.finished.connect(func(): if is_instance_valid(bgm_player): bgm_player.play())
	add_child(bgm_player)
	if bgm_stream and (not show_intro_cutscene or cutscene_played or _is_test_run()):
		bgm_player.play()

	# 2. Global Click SFX Player (Click sound.mp3)
	click_sfx_player = AudioStreamPlayer.new()
	click_sfx_player.name = "ClickSFXPlayer"
	var click_stream = load("res://sound/Click sound.mp3")
	if click_stream:
		click_sfx_player.stream = click_stream
		click_sfx_player.volume_db = -4.0
	add_child(click_sfx_player)

	# 3. Door SFX Player (Door Open.mp3)
	door_sfx_player = AudioStreamPlayer.new()
	door_sfx_player.name = "DoorSFXPlayer"
	var door_stream = load("res://sound/Door Open.mp3")
	if door_stream:
		door_sfx_player.stream = door_stream
		door_sfx_player.volume_db = -3.0
	add_child(door_sfx_player)

	# 4. Afterlife Music Player (Afterlife.mp3) saat bertemu Dewa Kematian
	afterlife_audio_player = AudioStreamPlayer.new()
	afterlife_audio_player.name = "AfterlifeAudioPlayer"
	var afterlife_stream: AudioStream = null
	if ResourceLoader.exists("res://sound/Afterlife.mp3"):
		afterlife_stream = load("res://sound/Afterlife.mp3")
	elif ResourceLoader.exists("res://Afterlife.mp3"):
		afterlife_stream = load("res://Afterlife.mp3")
	if afterlife_stream:
		afterlife_audio_player.stream = afterlife_stream
		afterlife_audio_player.volume_db = -6.0
		afterlife_audio_player.finished.connect(func(): if is_instance_valid(afterlife_audio_player) and afterlife_audio_player.playing: afterlife_audio_player.play())
	add_child(afterlife_audio_player)

	# 5. Paper SFX Player (Paper.mp3)
	paper_sfx_player = AudioStreamPlayer.new()
	paper_sfx_player.name = "PaperSFXPlayer"
	var p_stream = load("res://sound/Paper.mp3")
	if p_stream:
		paper_sfx_player.stream = p_stream
		paper_sfx_player.volume_db = -2.0
	add_child(paper_sfx_player)

func _is_test_run() -> bool:
	for arg in OS.get_cmdline_args():
		if arg == "-s" or arg == "--script" or arg.ends_with(".gd"):
			return true
	return false

func _check_and_launch_intro_cutscene(force: bool = false) -> void:
	if not force and (not show_intro_cutscene or cutscene_played or _is_test_run()):
		if is_instance_valid(bgm_player) and not bgm_player.playing:
			bgm_player.play()
		return

	cutscene_played = true

	# Matikan BGM selama cutscene agar audio ketikan intro jelas
	if is_instance_valid(bgm_player) and bgm_player.playing:
		bgm_player.stop()

	if not is_instance_valid(player):
		player = get_node_or_null("Player")
	if is_instance_valid(player):
		player.can_move = false
		player.set_physics_process(false)
	var hud_node = get_node_or_null("HUD")
	if is_instance_valid(hud_node):
		hud_node.visible = false

	cutscene_layer = CanvasLayer.new()
	cutscene_layer.name = "IntroCutsceneLayer"
	cutscene_layer.layer = 125
	add_child(cutscene_layer)

	var cutscene_res = load("res://scenes/opening_cutscene.tscn")
	if cutscene_res:
		var cutscene_inst = cutscene_res.instantiate()
		cutscene_inst.name = "OpeningCutscene"
		cutscene_layer.add_child(cutscene_inst)
		if cutscene_inst.has_signal("cutscene_completed"):
			cutscene_inst.cutscene_completed.connect(_on_intro_cutscene_finished)
	else:
		_on_intro_cutscene_finished()

func _on_intro_cutscene_finished() -> void:
	if is_instance_valid(cutscene_layer):
		cutscene_layer.queue_free()
		cutscene_layer = null

	var hud_node = get_node_or_null("HUD")
	if is_instance_valid(hud_node):
		hud_node.visible = true

	if is_instance_valid(player):
		player.global_position = Vector2(100.0, 225.0)
		player.velocity = Vector2.ZERO
		player.can_move = true
		player.set_physics_process(true)
		var cam = player.get_node_or_null("Camera2D")
		if is_instance_valid(cam):
			cam.global_position = player.global_position
			cam.reset_smoothing()

	input_grace_timer = 0.35

	if is_instance_valid(bgm_player) and not bgm_player.playing:
		bgm_player.play()

	if is_instance_valid(transition_overlay):
		transition_overlay.color = Color(0, 0, 0, 1.0)
		var tw = create_tween()
		tw.tween_property(transition_overlay, "color:a", 0.0, 0.45)
		tw.tween_callback(func():
			if not police_letter_shown:
				_open_police_letter()
		)


func play_click_sfx() -> void:
	if is_instance_valid(click_sfx_player) and click_sfx_player.stream:
		click_sfx_player.play()

func play_door_sfx() -> void:
	if is_instance_valid(door_sfx_player) and door_sfx_player.stream:
		door_sfx_player.play()

func play_paper_sfx() -> void:
	if is_instance_valid(paper_sfx_player) and paper_sfx_player.stream:
		paper_sfx_player.play()

func play_afterlife_music() -> void:
	if not is_instance_valid(afterlife_audio_player) or not afterlife_audio_player.stream:
		return
	if afterlife_audio_player.playing:
		return
	print("[Audio] Memutar lagu Afterlife saat berhadapan dengan Dewa Kematian...")
	# Meredam BGM eksplorasi secara halus
	if is_instance_valid(bgm_player) and bgm_player.playing:
		var tw_bgm = create_tween()
		tw_bgm.tween_property(bgm_player, "volume_db", -40.0, 0.6)
		tw_bgm.tween_callback(func():
			if is_instance_valid(bgm_player):
				bgm_player.stop()
				bgm_player.volume_db = -10.0
		)
	# Memulai pemutaran Afterlife.mp3 dengan transisi fade-in
	afterlife_audio_player.volume_db = -24.0
	afterlife_audio_player.play()
	var tw_aft = create_tween()
	tw_aft.tween_property(afterlife_audio_player, "volume_db", -5.0, 0.8)

func stop_afterlife_music() -> void:
	if not is_instance_valid(afterlife_audio_player) or not afterlife_audio_player.playing:
		return
	print("[Audio] Menghentikan lagu Afterlife, memulihkan BGM eksplorasi...")
	var tw_aft = create_tween()
	tw_aft.tween_property(afterlife_audio_player, "volume_db", -40.0, 0.6)
	tw_aft.tween_callback(func():
		if is_instance_valid(afterlife_audio_player):
			afterlife_audio_player.stop()
			afterlife_audio_player.volume_db = -6.0
	)
	# Pulihkan BGM eksplorasi
	if is_instance_valid(bgm_player) and not bgm_player.playing:
		bgm_player.volume_db = -24.0
		bgm_player.play()
		var tw_bgm = create_tween()
		tw_bgm.tween_property(bgm_player, "volume_db", -10.0, 0.8)

func _setup_transition_overlay() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.name = "TransitionLayer"
	transition_layer.layer = 25
	add_child(transition_layer)

	transition_overlay = ColorRect.new()
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color(0, 0, 0, 0.0)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(transition_overlay)

func _setup_house_interior() -> void:
	var hi_script = load("res://scripts/house_interior.gd")
	if hi_script:
		house_interior = Node2D.new()
		house_interior.name = "HouseInterior"
		house_interior.set_script(hi_script)
		add_child(house_interior)
		if house_interior.has_method("set_editor_available"):
			house_interior.set_editor_available(is_inside_house)

func _enter_house() -> void:
	if not is_instance_valid(player):
		return
	player.can_move = false
	input_grace_timer = 0.35
	play_door_sfx()

	var tw = create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.20)
	tw.tween_callback(func():
		is_inside_house = true
		player.global_position = Vector2(3600.0 + 110.0, 400.0 + 310.0)
		if player.has_method("setup_camera_limits"):
			player.setup_camera_limits(3600, 400, 4400, 1000)
		if player.has_method("reset_camera_smoothing"):
			player.reset_camera_smoothing()
		_show_toast("Masuk ke Dalam Rumah Benedict.")
		if is_instance_valid(house_interior) and house_interior.has_method("set_editor_available"):
			house_interior.set_editor_available(true)
	)
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		player.can_move = true
		input_grace_timer = 0.35
	)

func _exit_house() -> void:
	if not is_instance_valid(player):
		return
	player.can_move = false
	input_grace_timer = 0.35
	play_door_sfx()

	var tw = create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.20)
	tw.tween_callback(func():
		is_inside_house = false
		player.global_position = Vector2(1170.0, 260.0)
		if player.has_method("setup_camera_limits"):
			player.setup_camera_limits(0, 0, 2400, 1450)
		if player.has_method("reset_camera_smoothing"):
			player.reset_camera_smoothing()
		_show_toast("Keluar ke Jalan Kota.")
		if is_instance_valid(house_interior) and house_interior.has_method("set_editor_available"):
			house_interior.set_editor_available(false)
	)
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		player.can_move = true
		input_grace_timer = 0.35
	)

func _setup_exploration_house_interior() -> void:
	var ehi_script = load("res://scripts/exploration_house_interior.gd")
	if ehi_script:
		exploration_house_interior = Node2D.new()
		exploration_house_interior.name = "ExplorationHouseInterior"
		exploration_house_interior.set_script(ehi_script)
		add_child(exploration_house_interior)

func _enter_exploration_house() -> void:
	if not is_instance_valid(player):
		return
	player.can_move = false
	input_grace_timer = 0.35
	play_door_sfx()

	var tw = create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.20)
	tw.tween_callback(func():
		is_inside_exploration_house = true
		player.global_position = Vector2(4600.0 + 110.0, 400.0 + 330.0)
		if player.has_method("setup_camera_limits"):
			player.setup_camera_limits(4580, 380, 5260, 840)
		if player.has_method("reset_camera_smoothing"):
			player.reset_camera_smoothing()
		_show_toast("Masuk ke Rumah Eksplorasi (Rumah Kenangan).")
	)
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		player.can_move = true
		input_grace_timer = 0.35
	)

func _exit_exploration_house() -> void:
	if not is_instance_valid(player):
		return
	player.can_move = false
	input_grace_timer = 0.35
	play_door_sfx()

	var tw = create_tween()
	tw.tween_property(transition_overlay, "color:a", 1.0, 0.20)
	tw.tween_callback(func():
		is_inside_exploration_house = false
		player.global_position = Vector2(1714.0, 1200.0)
		if player.has_method("setup_camera_limits"):
			player.setup_camera_limits(0, 0, 2400, 1450)
		if player.has_method("reset_camera_smoothing"):
			player.reset_camera_smoothing()
		_show_toast("Keluar ke Jalan Kota Selatan.")
	)
	tw.tween_property(transition_overlay, "color:a", 0.0, 0.25)
	tw.tween_callback(func():
		player.can_move = true
		input_grace_timer = 0.35
	)

func _trigger_indoor_letter_monologue() -> void:
	if is_instance_valid(inv_mgr) and inv_mgr.is_clue_unlocked("victim_letter"):
		_open_victim_letter()
		return

	if not is_instance_valid(dialog_box):
		_open_victim_letter()
		return

	var monologue_lines: Array[String] = [
		"Aku mencari ke sekeliling rumah korban... Di atas meja ini ada selembar surat tergeletak.",
		"Kertasnya agak lusuh, dan tulisan tangannya tampak tergesa-gesa dan gemetar...",
		"Coba kubaca apa yang tertulis di dalam surat ini..."
	]
	if is_instance_valid(player):
		player.can_move = false

	dialog_box.start_monologue(monologue_lines, "Detektif Benedict", "[ Penyelidikan Rumah ]", "res://karakter/MC_Bingung.png")
	dialog_box.monologue_finished.connect(func():
		_open_victim_letter()
	, CONNECT_ONE_SHOT)

func _setup_investigation_manager() -> void:
	inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr):
		var mgr_script = load("res://scripts/investigation_manager.gd")
		if mgr_script:
			inv_mgr = Node.new()
			inv_mgr.name = "InvestigationManager"
			inv_mgr.set_script(mgr_script)
			add_child(inv_mgr)
	if is_instance_valid(inv_mgr):
		if not inv_mgr.phase_changed.is_connected(_on_phase_changed):
			inv_mgr.phase_changed.connect(_on_phase_changed)
		if not inv_mgr.notification_displayed.is_connected(_show_toast):
			inv_mgr.notification_displayed.connect(_show_toast)

func _setup_world_shader() -> void:
	var ws_script = load("res://scripts/world_shader.gd")
	if ws_script:
		world_shader = CanvasLayer.new()
		world_shader.name = "WorldShader"
		world_shader.set_script(ws_script)
		add_child(world_shader)

func _setup_clue_journal() -> void:
	var cj_script = load("res://scripts/clue_journal.gd")
	if cj_script:
		clue_journal = CanvasLayer.new()
		clue_journal.name = "ClueJournal"
		clue_journal.set_script(cj_script)
		add_child(clue_journal)
		clue_journal.journal_opened.connect(func(): if is_instance_valid(player): player.can_move = false)
		clue_journal.journal_closed.connect(func(): if is_instance_valid(player): player.can_move = true)

func _setup_minigames() -> void:
	var mg1_script = load("res://scripts/minigame_tailgate.gd")
	if mg1_script:
		minigame_tailgate = CanvasLayer.new()
		minigame_tailgate.name = "MinigameTailgate"
		minigame_tailgate.set_script(mg1_script)
		minigame_tailgate.minigame_completed.connect(_on_tailgate_completed)

	var mg2_script = load("res://scripts/minigame_hidden_objects.gd")
	if mg2_script:
		minigame_hidden_objects = CanvasLayer.new()
		minigame_hidden_objects.name = "MinigameHiddenObjects"
		minigame_hidden_objects.set_script(mg2_script)
		add_child(minigame_hidden_objects)
		minigame_hidden_objects.minigame_completed.connect(func(_ok): _on_minigame_ended())

	var mg3_script = load("res://scripts/minigame_photo_wash.gd")
	if mg3_script:
		minigame_photo_wash = CanvasLayer.new()
		minigame_photo_wash.name = "MinigamePhotoWash"
		minigame_photo_wash.set_script(mg3_script)
		add_child(minigame_photo_wash)
		minigame_photo_wash.minigame_completed.connect(func(_ok): _on_minigame_ended())

	var safe_script = load("res://scripts/minigame_safe.gd")
	if safe_script:
		minigame_safe = CanvasLayer.new()
		minigame_safe.name = "MinigameSafe"
		minigame_safe.set_script(safe_script)
		add_child(minigame_safe)
		minigame_safe.safe_opened.connect(func(_ok): _on_minigame_ended())

	var dg_script = load("res://scripts/death_god.gd")
	if dg_script:
		death_god_layer = CanvasLayer.new()
		death_god_layer.name = "DeathGodLayer"
		death_god_layer.set_script(dg_script)
		add_child(death_god_layer)
		death_god_layer.death_god_closed.connect(func(): _on_minigame_ended())

	var mi_script = load("res://scripts/morgue_inspection.gd")
	if mi_script:
		morgue_inspection = CanvasLayer.new()
		morgue_inspection.name = "MorgueInspection"
		morgue_inspection.set_script(mi_script)
		add_child(morgue_inspection)
		morgue_inspection.morgue_completed.connect(_on_morgue_completed)

func _on_morgue_completed() -> void:
	if is_instance_valid(player):
		player.can_move = false
	_show_toast("✦ Jiwamu Ditarik Menuju Pengadilan Dewa Kematian... ✦")
	play_afterlife_music()
	var tw = create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(func():
		if is_instance_valid(death_god_layer) and death_god_layer.has_method("open_interface"):
			death_god_layer.open_interface()
	)

func _on_minigame_ended() -> void:
	if is_instance_valid(player):
		player.can_move = true
	_update_hud_objective()

func _on_tailgate_completed(success: bool) -> void:
	if not success:
		auto_police_escort_triggered = false
		if is_instance_valid(player):
			player.can_move = true
		_update_hud_objective()
		return

	# Scene Paksaan setibanya di stasiun:
	# 1. Posisi Detektif Benedict bersembunyi di dekat peron
	if is_instance_valid(player):
		player.can_move = false
		player.global_position = Vector2(1950.0, 720.0)
		var cam = player.get_node_or_null("Camera2D")
		if is_instance_valid(cam):
			cam.global_position = Vector2(2020.0, 700.0)
			if player.has_method("reset_camera_smoothing"):
				player.reset_camera_smoothing()

	# 2. Posisi kedua polisi di peron stasiun
	var marcus_npc = find_child("NPC_Police_Marcus", true, false)
	var police_npc = find_child("NPC1_Police", true, false)
	if is_instance_valid(marcus_npc):
		marcus_npc.global_position = Vector2(2088.0, 690.0)
	if is_instance_valid(police_npc):
		police_npc.global_position = Vector2(2058.0, 705.0)

	_trigger_station_eavesdrop_sequence(marcus_npc, police_npc)

func _trigger_station_eavesdrop_sequence(marcus_npc: Node, police_npc: Node) -> void:
	if is_instance_valid(dialog_box):
		# Dialog Pembicaraan Kedua Polisi di Peron
		var police_dialogue_lines: Array[String] = [
			"Inspektur Marcus: 'Pastikan peron stasiun ini tetap steril. Jangan biarkan siapapun mendekati area bangku tunggu peron!'",
			"Polisi Rekan: 'Siap, Inspektur Marcus! Bagaimana dengan barang bukti korban yang tertinggal?'",
			"Inspektur Marcus: 'Ada rol film foto penting yang terjatuh di sekitar peron stasiun sebelum korban tewas. Jasadnya sendiri sudah dibawa ke Kamar Jenazah Rumah Sakit.'",
			"Polisi Rekan: 'Baik, saya akan segera kembali ke pos jaga kota sekarang untuk melanjutkan patroli luar.'",
			"Inspektur Marcus: 'Bagus. Aku juga harus segera kembali ke kantor polisi untuk mengurus berkas kasus. Bergerak sekarang!'"
		]
		dialog_box.start_monologue(police_dialogue_lines, "Obrolan Rahasia Polisi", "[ Menguping Peron ]", "res://NPC_Inspecture/jalan-depan-1.png")
		dialog_box.monologue_finished.connect(func():
			# Kedua polisi kembali ke urusan masing-masing (meninggalkan peron)
			if is_instance_valid(marcus_npc) and marcus_npc.has_method("depart_from_station"):
				marcus_npc.depart_from_station()
			if is_instance_valid(police_npc) and police_npc.has_method("depart_from_station"):
				police_npc.depart_from_station()

			_show_toast("Kedua polisi meninggalkan stasiun. Peron kini sepi!")

			# Monolog batin Detektif Benedict setelah mendengarkan pembicaraan
			var mc_lines: Array[String] = [
				"Mereka membicarakan rol film foto penting yang tertinggal di peron stasiun dan jasad korban di Rumah Sakit...",
				"Sekarang kedua polisi itu sudah pergi ke urusan masing-masing dan peron stasiun kosong.",
				"Ini kesempatan terbaikku. Aku harus segera masuk memeriksa peron stasiun dan mencari barang bukti korban!"
			]
			dialog_box.start_monologue(mc_lines, "Detektif Benedict", "[ Menyelidiki Stasiun ]", "res://karakter/MC_Bingung.png")
			dialog_box.monologue_finished.connect(func():
				# Benedict langsung masuk ke peron stasiun
				if is_instance_valid(minigame_hidden_objects):
					player.can_move = false
					minigame_hidden_objects.start_minigame()
					_show_toast("Menyelinap ke Peron Stasiun: Cari Objek Bukti Tersembunyi!")
				else:
					if is_instance_valid(player):
						player.can_move = true
			, CONNECT_ONE_SHOT)
		, CONNECT_ONE_SHOT)
	else:
		if is_instance_valid(minigame_hidden_objects):
			player.can_move = false
			minigame_hidden_objects.start_minigame()
			_show_toast("Menyelinap ke Peron Stasiun: Cari Objek Bukti Tersembunyi!")

func _setup_main_menu() -> void:
	var mm_script = load("res://scripts/main_menu_ui.gd")
	if mm_script:
		main_menu_layer = CanvasLayer.new()
		main_menu_layer.name = "MainMenuLayer"
		main_menu_layer.set_script(mm_script)
		add_child(main_menu_layer)
		main_menu_layer.play_requested.connect(_on_main_menu_play_requested)

func _setup_pause_menu() -> void:
	var pm_script = load("res://scripts/pause_menu_ui.gd")
	if pm_script:
		pause_menu_layer = CanvasLayer.new()
		pause_menu_layer.name = "PauseMenuLayer"
		pause_menu_layer.set_script(pm_script)
		add_child(pause_menu_layer)
		pause_menu_layer.resumed.connect(func():
			if is_instance_valid(player):
				player.can_move = true
		)
		pause_menu_layer.journal_requested.connect(func():
			if is_instance_valid(clue_journal):
				clue_journal.open_journal()
		)
		pause_menu_layer.main_menu_requested.connect(_on_return_to_main_menu)

func _on_main_menu_play_requested() -> void:
	if not cutscene_played:
		_check_and_launch_intro_cutscene(true)
	else:
		if is_instance_valid(player):
			player.can_move = true
			player.set_physics_process(true)
		if is_instance_valid(bgm_player) and not bgm_player.playing:
			bgm_player.play()
		if not police_letter_shown:
			var tw = create_tween()
			tw.tween_interval(0.35)
			tw.tween_callback(func():
				_open_police_letter()
			)
	_update_hud_objective()
	if is_instance_valid(pause_menu_layer) and pause_menu_layer.has_method("set_hud_button_visible"):
		pause_menu_layer.set_hud_button_visible(true)

func _on_return_to_main_menu() -> void:
	if is_instance_valid(player):
		player.can_move = false
		player.set_physics_process(false)
	if is_instance_valid(bgm_player) and bgm_player.playing:
		bgm_player.stop()
	if is_instance_valid(pause_menu_layer) and pause_menu_layer.has_method("set_hud_button_visible"):
		pause_menu_layer.set_hud_button_visible(false)
	if is_instance_valid(main_menu_layer):
		main_menu_layer.open_menu()

func toggle_pause_menu() -> void:
	if not is_instance_valid(pause_menu_layer):
		return
	if is_instance_valid(main_menu_layer) and main_menu_layer.is_active:
		return
	if pause_menu_layer.is_paused:
		pause_menu_layer.resume_game()
		if is_instance_valid(player):
			player.can_move = true
	else:
		if is_instance_valid(player):
			player.can_move = false
		pause_menu_layer.open_pause()

var letter_layer: CanvasLayer
var letter_root_control: Control
var letter_header_lbl: Label
var letter_sub_lbl: Label
var letter_body_lbl: Label
var letter_close_btn: Button
var letter_current_type: String = ""
var police_letter_shown: bool = false
var font_vintage: FontFile
var font_vintage_bold: FontFile
var font_typewriter: FontFile
var font_anaktoria: FontFile
var font_riwaya_informal: FontFile

func _load_letter_fonts() -> void:
	if not font_vintage:
		font_vintage = FontFile.new()
		font_vintage.load_dynamic_font("res://fonts/vintage_letter.ttf")
	if not font_vintage_bold:
		font_vintage_bold = FontFile.new()
		font_vintage_bold.load_dynamic_font("res://fonts/vintage_letter_bold.ttf")
	if not font_typewriter:
		font_typewriter = FontFile.new()
		font_typewriter.load_dynamic_font("res://fonts/typewriter.ttf")

	# Pemuatan Font Anaktoria
	if not font_anaktoria:
		var anaktoria_candidates = [
			"res://fonts/anaktoria.ttf",
			"res://fonts/Anaktoria.ttf",
			"res://fonts/Anaktoria_hint.ttf",
			"res://fonts/anaktoria.otf",
			"res://fonts/Anaktoria.otf"
		]
		for p in anaktoria_candidates:
			if FileAccess.file_exists(p):
				var ff = FontFile.new()
				if ff.load_dynamic_font(p) == OK:
					font_anaktoria = ff
					print("[LetterViewer] Font Anaktoria berhasil dimuat dari: ", p)
					break

	# Pemuatan Font 29LT Riwaya Informal
	if not font_riwaya_informal:
		var riwaya_candidates = [
			"res://fonts/29LT Riwaya Informal.ttf",
			"res://fonts/29LT Riwaya Informal.otf",
			"res://fonts/29lt_riwaya_informal.ttf",
			"res://fonts/29lt_riwaya_informal.otf",
			"res://fonts/riwaya_informal.ttf",
			"res://fonts/riwaya_informal.otf",
			"res://fonts/riwaya.ttf",
			"res://fonts/riwaya.otf"
		]
		for p in riwaya_candidates:
			if FileAccess.file_exists(p):
				var ff = FontFile.new()
				if ff.load_dynamic_font(p) == OK:
					font_riwaya_informal = ff
					print("[LetterViewer] Font 29LT Riwaya Informal berhasil dimuat dari: ", p)
					break

func _setup_letter_viewer() -> void:
	_load_letter_fonts()

	letter_layer = CanvasLayer.new()
	letter_layer.name = "LetterViewer"
	letter_layer.layer = 15
	add_child(letter_layer)

	letter_root_control = Control.new()
	letter_root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter_layer.add_child(letter_root_control)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.04, 0.92)
	bg.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			_close_letter_viewer()
	)
	letter_root_control.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter_root_control.add_child(center)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vb)

	# Wadah lembaran kertas surat asli (surat close up.png)
	var paper_container = Control.new()
	paper_container.custom_minimum_size = Vector2(640, 650)
	paper_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	paper_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vb.add_child(paper_container)

	# Tekstur kertas surat asli
	var paper_texture_rect = TextureRect.new()
	paper_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	var tex_paper = load("res://Environment/interactable assets/surat close up.png")
	if is_instance_valid(tex_paper):
		paper_texture_rect.texture = tex_paper
	paper_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	paper_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	paper_container.add_child(paper_texture_rect)

	# Margin teks agar pas di dalam area lembaran kertas surat
	var paper_margin = MarginContainer.new()
	paper_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	paper_margin.add_theme_constant_override("margin_left", 60)
	paper_margin.add_theme_constant_override("margin_right", 60)
	paper_margin.add_theme_constant_override("margin_top", 34)
	paper_margin.add_theme_constant_override("margin_bottom", 28)
	paper_container.add_child(paper_margin)

	var card_vb = VBoxContainer.new()
	card_vb.add_theme_constant_override("separation", 6)
	paper_margin.add_child(card_vb)

	# Header Dokumen (Anaktoria Font / Vintage Bold)
	letter_header_lbl = Label.new()
	letter_header_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter_header_lbl.add_theme_color_override("font_color", Color(0.18, 0.12, 0.08))
	if font_anaktoria:
		letter_header_lbl.add_theme_font_override("font", font_anaktoria)
		letter_header_lbl.add_theme_font_size_override("font_size", 21)
	elif font_vintage_bold:
		letter_header_lbl.add_theme_font_override("font", font_vintage_bold)
		letter_header_lbl.add_theme_font_size_override("font_size", 19)
	letter_header_lbl.add_theme_constant_override("line_spacing", 2)
	card_vb.add_child(letter_header_lbl)

	# Subtitle Dokumen
	letter_sub_lbl = Label.new()
	letter_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter_sub_lbl.add_theme_color_override("font_color", Color(0.42, 0.32, 0.20))
	if font_anaktoria:
		letter_sub_lbl.add_theme_font_override("font", font_anaktoria)
		letter_sub_lbl.add_theme_font_size_override("font_size", 14.5)
	elif font_vintage:
		letter_sub_lbl.add_theme_font_override("font", font_vintage)
		letter_sub_lbl.add_theme_font_size_override("font_size", 13)
	card_vb.add_child(letter_sub_lbl)

	var sep = HSeparator.new()
	var sep_style = StyleBoxLine.new()
	sep_style.color = Color(0.45, 0.34, 0.22, 0.45)
	sep_style.thickness = 1
	sep.add_theme_stylebox_override("separator", sep_style)
	card_vb.add_child(sep)

	# Scroll Container Teks Surat
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(512, 480)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card_vb.add_child(scroll)

	# Margin teks agar tidak mentok di kiri dan kanan kertas
	var text_margin = MarginContainer.new()
	text_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_margin.add_theme_constant_override("margin_left", 28)
	text_margin.add_theme_constant_override("margin_right", 28)
	text_margin.add_theme_constant_override("margin_top", 6)
	text_margin.add_theme_constant_override("margin_bottom", 12)
	scroll.add_child(text_margin)

	letter_body_lbl = Label.new()
	letter_body_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	letter_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	letter_body_lbl.add_theme_color_override("font_color", Color(0.14, 0.10, 0.06))
	if font_anaktoria:
		letter_body_lbl.add_theme_font_override("font", font_anaktoria)
	elif font_vintage:
		letter_body_lbl.add_theme_font_override("font", font_vintage)
	letter_body_lbl.add_theme_font_size_override("font_size", 17.5)
	letter_body_lbl.add_theme_constant_override("line_spacing", 6)
	text_margin.add_child(letter_body_lbl)

	# Tombol Tutup / Aksi (Gaya vintage noir dengan tulisan standar bersih biasa)
	letter_close_btn = Button.new()
	letter_close_btn.focus_mode = Control.FOCUS_NONE
	letter_close_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	letter_close_btn.custom_minimum_size = Vector2(512, 44)
	letter_close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var lcb_style = StyleBoxFlat.new()
	lcb_style.bg_color = Color(0.16, 0.13, 0.11, 0.95)
	lcb_style.border_color = Color(0.70, 0.55, 0.32, 1.0)
	lcb_style.set_border_width_all(2)
	lcb_style.set_corner_radius_all(6)
	letter_close_btn.add_theme_stylebox_override("normal", lcb_style)
	var lcb_hov = lcb_style.duplicate()
	lcb_hov.bg_color = Color(0.24, 0.19, 0.15, 0.98)
	lcb_hov.border_color = Color(0.92, 0.78, 0.42, 1.0)
	letter_close_btn.add_theme_stylebox_override("hover", lcb_hov)
	letter_close_btn.add_theme_stylebox_override("pressed", lcb_hov)
	letter_close_btn.add_theme_color_override("font_color", Color(0.95, 0.88, 0.75))
	# Tulisan di tombol biasa aja (font standar, bukan kaligrafi Anaktoria)
	letter_close_btn.add_theme_font_size_override("font_size", 14.0)
	letter_close_btn.pressed.connect(_close_letter_viewer)
	vb.add_child(letter_close_btn)

	letter_root_control.visible = false

func _open_police_letter() -> void:
	police_letter_shown = true
	letter_current_type = "police"
	play_paper_sfx()

	if is_instance_valid(letter_header_lbl):
		letter_header_lbl.text = "BERKAS PENUGASAN KEPOLISIAN\n(KASUS #404)"
	if is_instance_valid(letter_sub_lbl):
		letter_sub_lbl.text = "Departemen Kepolisian Kota • Ditujukan kepada: Detektif Benedict"

	var police_text = "Sesosok jenazah telah ditemukan di gang sempit dekat area kota. Hingga saat ini belum ada yang berhasil mengungkap siapa dia sebenarnya, apa yang terjadi padanya, atau mengapa semuanya terasa begitu janggal sejak kematian itu terjadi. Aku dengar kau terkenal sebagai orang yang tidak pernah puas dengan jawaban di permukaan, orang yang selalu menggali lebih dalam ketika orang lain sudah berhenti mencari. Kami percaya, dari semua orang, Andalah yang paling memahami kasus ini.\n\n" + \
		"Carilah bantuan, mungkin kau bisa mulai dari menemui orang yang paling sering berurusan dengan kasus semacam ini, seseorang yang duduk di balik meja penuh berkas di gedung tempat hukum ditegakkan. Dialah yang paling mungkin tahu ke mana korban terakhir kali melangkah. Ikuti jejaknya, dengarkan apa yang tidak ia katakan secara langsung, dan biarkan satu petunjuk membawamu ke petunjuk berikutnya. Semakin dalam kau menggali, semakin banyak yang akan terungkap.\n\n" + \
		"Selesaikan semua ini sebelum semuanya benar-benar terlambat. Jangan lupa untuk mengingat apa yang telah kau pelajari."

	if is_instance_valid(letter_body_lbl):
		letter_body_lbl.text = police_text
		if font_anaktoria:
			letter_body_lbl.add_theme_font_override("font", font_anaktoria)
			letter_body_lbl.add_theme_font_size_override("font_size", 17.5)
		elif font_typewriter:
			letter_body_lbl.add_theme_font_override("font", font_typewriter)
			letter_body_lbl.add_theme_font_size_override("font_size", 16.5)

	if is_instance_valid(letter_close_btn):
		letter_close_btn.text = "TERIMA TUGAS & MULAI PENYELIDIKAN [ESC / SPASI]"

	if is_instance_valid(player):
		player.can_move = false
		player.set_physics_process(false)

	if is_instance_valid(letter_root_control):
		letter_root_control.visible = true

func _open_victim_letter() -> void:
	letter_current_type = "victim"
	play_paper_sfx()

	if is_instance_valid(letter_header_lbl):
		letter_header_lbl.text = "SURAT PRIBADI KORBAN"
	if is_instance_valid(letter_sub_lbl):
		letter_sub_lbl.text = "Ditemukan di Meja Kerja Rumah Korban • Tulisan Tangan Gemetar"

	var victim_text = "Aku tidak tahu harus bilang ke siapa lagi soal ini. Sudah beberapa hari aku merasa terus diawasi. Bukan cuma perasaan biasa, namun beberapa kali aku yakin melihat orang yang sama berdiri di seberang jalan, terlalu lama untuk sekadar kebetulan. Tadi malam pun seseorang mengetuk pintu larut sekali, dan saat kubuka, tidak ada siapa-siapa. Hanya jejak sepatu basah di depan teras, padahal tidak hujan.\n\n" + \
		"Aku sudah coba cerita ke Marcus soal ini. Dia cuma bilang aku terlalu capek dan butuh istirahat. Tapi tiap kali aku coba tanya lebih jauh, kenapa dia terlihat tergesa-gesa mengganti topik dan tidak mau menatapku lama-lama? Aku jadi curiga dia tahu sesuatu yang tidak dia katakan padaku.\n\n" + \
		"Kalau memang terjadi sesuatu padaku, tolong periksa Marcus lebih dulu."

	if is_instance_valid(letter_body_lbl):
		letter_body_lbl.text = victim_text
		if font_riwaya_informal:
			letter_body_lbl.add_theme_font_override("font", font_riwaya_informal)
			letter_body_lbl.add_theme_font_size_override("font_size", 18.0)
		elif font_anaktoria:
			letter_body_lbl.add_theme_font_override("font", font_anaktoria)
			letter_body_lbl.add_theme_font_size_override("font_size", 18.0)
		elif font_vintage:
			letter_body_lbl.add_theme_font_override("font", font_vintage)
			letter_body_lbl.add_theme_font_size_override("font_size", 17.0)

	if is_instance_valid(letter_close_btn):
		letter_close_btn.text = "SIMPAN SURAT & CARI INSPEKTUR MARCUS [ESC / SPASI]"

	if is_instance_valid(player):
		player.can_move = false
		player.set_physics_process(false)

	if is_instance_valid(letter_root_control):
		letter_root_control.visible = true

func _open_letter_closeup() -> void:
	_open_victim_letter()

func _close_letter_viewer() -> void:
	play_paper_sfx()
	input_grace_timer = 0.35
	if is_instance_valid(letter_root_control):
		letter_root_control.visible = false
	if is_instance_valid(player):
		player.can_move = true
		player.set_physics_process(true)

	if letter_current_type == "police":
		var already_unlocked = is_instance_valid(inv_mgr) and inv_mgr.is_clue_unlocked("police_letter")
		if is_instance_valid(inv_mgr):
			inv_mgr.unlock_clue("police_letter")
		_show_toast("Tugas Diterima: Periksa rumah korban di ujung timur!")
		if not already_unlocked and is_instance_valid(dialog_box):
			var p_lines: Array[String] = [
				"Surat penugasan kasus jenazah tanpa identitas...",
				"Pengirim memintaku mencari bantuan pada orang di gedung penegakan hukum (Kantor Polisi).",
				"Namun sebelum ke kantor polisi, aku harus memeriksa rumah korban di ujung timur terlebih dahulu untuk mencari petunjuk awal!"
			]
			dialog_box.start_monologue(p_lines, "Detektif Benedict", "[ Surat Penugasan ]", "res://karakter/MC_Bingung.png")

	elif letter_current_type == "victim":
		var already_unlocked = is_instance_valid(inv_mgr) and inv_mgr.is_clue_unlocked("victim_letter")
		if is_instance_valid(inv_mgr):
			inv_mgr.unlock_clue("victim_letter")
			inv_mgr.unlock_clue("mother_photo_riddle")
			if inv_mgr.current_phase == inv_mgr.Phase.PROLOGUE_HOME:
				inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_1_POLICE)
		_show_toast("Marcus dicurigai! Segera temui Marcus di Kantor Polisi!")
		if not already_unlocked and is_instance_valid(dialog_box):
			var v_lines: Array[String] = [
				"Surat wasiat ini... korban merasa terus diawasi selama berhari-hari sebelum kematiannya!",
				"Dan pesan terakhirnya sangat jelas: 'Kalau memang terjadi sesuatu padaku, tolong periksa Marcus lebih dulu.'",
				"Inspektur Marcus?! Kenapa korban mencurigai polisi yang bertugas menangani kasus ini?!",
				"Marcus pasti menyembunyikan sesuatu. Aku harus segera ke Kantor Polisi untuk menginterogasi dan mengawasi gerak-gerik Marcus!"
			]
			dialog_box.start_monologue(v_lines, "Detektif Benedict", "[ Wasiat Korban ]", "res://karakter/MC_Bingung.png")


func _setup_hud_prompts() -> void:
	var hud_layer = $HUD
	if not is_instance_valid(hud_layer):
		return

	interact_prompt = Button.new()
	interact_prompt.text = "[ F / E / Spasi ] KLIK UNTUK INTERAKSI"
	interact_prompt.custom_minimum_size = Vector2(460, 52)
	interact_prompt.focus_mode = Control.FOCUS_NONE
	interact_prompt.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	interact_prompt.add_theme_font_size_override("font_size", 15)

	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.06, 0.08, 0.16, 0.92)
	btn_normal.border_color = Color(1.0, 0.85, 0.3, 1.0)
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(10)
	btn_normal.content_margin_left = 18
	btn_normal.content_margin_right = 18
	btn_normal.content_margin_top = 8
	btn_normal.content_margin_bottom = 8
	interact_prompt.add_theme_stylebox_override("normal", btn_normal)

	var btn_hover = btn_normal.duplicate()
	btn_hover.bg_color = Color(0.16, 0.22, 0.36, 0.96)
	btn_hover.border_color = Color(1.0, 1.0, 0.5, 1.0)
	interact_prompt.add_theme_stylebox_override("hover", btn_hover)
	interact_prompt.add_theme_stylebox_override("pressed", btn_hover)

	interact_prompt.add_theme_color_override("font_color", Color(1.0, 0.92, 0.4))
	interact_prompt.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.8))

	interact_prompt.pressed.connect(func():
		play_click_sfx()
		if not active_poi_id.is_empty():
			_trigger_poi_interaction(active_poi_id)
	)
	interact_prompt.visible = false
	hud_layer.add_child(interact_prompt)

	toast_banner = PanelContainer.new()
	toast_banner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	toast_banner.position = Vector2(0, 15)
	var t_style = StyleBoxFlat.new()
	t_style.bg_color = Color(0.06, 0.08, 0.14, 0.95)
	t_style.border_color = Color(0.9, 0.7, 0.3, 0.9)
	t_style.set_border_width_all(2)
	t_style.set_corner_radius_all(8)
	t_style.content_margin_left = 24
	t_style.content_margin_right = 24
	t_style.content_margin_top = 8
	t_style.content_margin_bottom = 8
	toast_banner.add_theme_stylebox_override("panel", t_style)
	toast_banner.visible = false
	hud_layer.add_child(toast_banner)

	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	toast_label.add_theme_font_size_override("font_size", 14)
	toast_banner.add_child(toast_label)

	# Tombol Fullscreen di pojok kanan atas HUD
	fullscreen_btn = Button.new()
	fullscreen_btn.text = "Fullscreen [F11]"
	fullscreen_btn.custom_minimum_size = Vector2(165, 40)
	fullscreen_btn.focus_mode = Control.FOCUS_NONE
	fullscreen_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	fullscreen_btn.add_theme_font_size_override("font_size", 13)

	var fb_normal = StyleBoxFlat.new()
	fb_normal.bg_color = Color(0.06, 0.08, 0.16, 0.88)
	fb_normal.border_color = Color(0.3, 0.6, 0.9, 0.75)
	fb_normal.set_border_width_all(1)
	fb_normal.set_corner_radius_all(8)
	fb_normal.content_margin_left = 12
	fb_normal.content_margin_right = 12
	fb_normal.content_margin_top = 6
	fb_normal.content_margin_bottom = 6
	fullscreen_btn.add_theme_stylebox_override("normal", fb_normal)

	var fb_hover = fb_normal.duplicate()
	fb_hover.bg_color = Color(0.14, 0.24, 0.42, 0.96)
	fb_hover.border_color = Color(0.6, 0.85, 1.0, 1.0)
	fullscreen_btn.add_theme_stylebox_override("hover", fb_hover)
	fullscreen_btn.add_theme_stylebox_override("pressed", fb_hover)

	fullscreen_btn.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	fullscreen_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))

	fullscreen_btn.anchor_left = 1.0
	fullscreen_btn.anchor_right = 1.0
	fullscreen_btn.anchor_top = 0.0
	fullscreen_btn.anchor_bottom = 0.0
	fullscreen_btn.offset_left = -240
	fullscreen_btn.offset_top = 16
	fullscreen_btn.offset_right = -72
	fullscreen_btn.offset_bottom = 56

	fullscreen_btn.pressed.connect(func():
		toggle_fullscreen()
	)
	hud_layer.add_child(fullscreen_btn)
	_update_fullscreen_button_text(_is_fullscreen_now())

	# Detective Case Status HUD Card (Pojok Kiri Atas)
	detective_hud_panel = PanelContainer.new()
	detective_hud_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	detective_hud_panel.position = Vector2(20, 20)
	detective_hud_panel.custom_minimum_size = Vector2(430, 80)
	
	var dh_style = StyleBoxFlat.new()
	dh_style.bg_color = Color(0.06, 0.08, 0.12, 0.94)
	dh_style.border_color = Color(0.85, 0.70, 0.35, 0.9)
	dh_style.set_border_width_all(2)
	dh_style.set_corner_radius_all(10)
	dh_style.content_margin_left = 12
	dh_style.content_margin_right = 14
	dh_style.content_margin_top = 8
	dh_style.content_margin_bottom = 8
	dh_style.shadow_color = Color(0, 0, 0, 0.45)
	dh_style.shadow_size = 6
	detective_hud_panel.add_theme_stylebox_override("panel", dh_style)
	hud_layer.add_child(detective_hud_panel)

	var hud_hb = HBoxContainer.new()
	hud_hb.add_theme_constant_override("separation", 12)
	detective_hud_panel.add_child(hud_hb)

	hud_avatar_rect = TextureRect.new()
	var mc_tex = load("res://UI/mc_portrait.png")
	if mc_tex:
		hud_avatar_rect.texture = mc_tex
	hud_avatar_rect.custom_minimum_size = Vector2(56, 56)
	hud_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hud_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hud_hb.add_child(hud_avatar_rect)

	var info_vb = VBoxContainer.new()
	info_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vb.add_theme_constant_override("separation", 3)
	hud_hb.add_child(info_vb)

	var name_hb = HBoxContainer.new()
	info_vb.add_child(name_hb)

	var name_lbl = Label.new()
	name_lbl.text = "Detektif Benedict"
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_hb.add_child(name_lbl)

	hud_phase_badge = Label.new()
	hud_phase_badge.text = "[ Prolog ]"
	hud_phase_badge.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	hud_phase_badge.add_theme_font_size_override("font_size", 11)
	name_hb.add_child(hud_phase_badge)

	hud_objective_text = Label.new()
	hud_objective_text.text = "Target: Periksa Meja Kerja"
	hud_objective_text.add_theme_color_override("font_color", Color(0.92, 0.94, 0.98))
	hud_objective_text.add_theme_font_size_override("font_size", 12)
	hud_objective_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vb.add_child(hud_objective_text)

	var btns_hb = HBoxContainer.new()
	btns_hb.add_theme_constant_override("separation", 6)
	info_vb.add_child(btns_hb)

	var j_btn = Button.new()
	j_btn.text = "Jurnal [J]"
	j_btn.focus_mode = Control.FOCUS_NONE
	j_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	j_btn.add_theme_font_size_override("font_size", 11)
	j_btn.pressed.connect(func():
		play_click_sfx()
		if is_instance_valid(clue_journal):
			clue_journal.toggle_journal()
	)
	btns_hb.add_child(j_btn)

	var p_btn = Button.new()
	p_btn.text = "Menu [ESC]"
	p_btn.focus_mode = Control.FOCUS_NONE
	p_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	p_btn.add_theme_font_size_override("font_size", 11)
	p_btn.pressed.connect(func():
		play_click_sfx()
		toggle_pause_menu()
	)
	btns_hb.add_child(p_btn)

	var beta_lbl = Label.new()
	beta_lbl.text = "Beta: [X] Dewa Maut  [Y] Bypass"
	beta_lbl.add_theme_color_override("font_color", Color(0.82, 0.74, 1.0))
	beta_lbl.add_theme_font_size_override("font_size", 11)
	btns_hb.add_child(beta_lbl)

func _is_fullscreen_now() -> bool:
	var mode = DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func toggle_fullscreen() -> void:
	play_click_sfx()
	if _is_fullscreen_now():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_update_fullscreen_button_text(false)
		_show_toast("Mode Jendela (Windowed)")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_update_fullscreen_button_text(true)
		_show_toast("Mode Layar Penuh (Fullscreen)")

func _update_fullscreen_button_text(is_fullscreen: bool) -> void:
	if is_instance_valid(fullscreen_btn):
		if is_fullscreen:
			fullscreen_btn.text = "Windowed [F11]"
		else:
			fullscreen_btn.text = "Fullscreen [F11]"

func _show_toast(msg: String) -> void:
	if is_instance_valid(toast_label) and is_instance_valid(toast_banner):
		toast_label.text = msg
		toast_banner.visible = true
		toast_timer = 3.5

func _process(delta: float) -> void:
	if is_instance_valid(cutscene_layer):
		return

	if input_grace_timer > 0.0:
		input_grace_timer -= delta

	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_banner.visible = false

	if is_instance_valid(player):
		if is_instance_valid(hud_speed_label):
			var spd = player.velocity.length()
			var mode_str = " (Lari/Shift)" if player.is_sprinting else " (Jalan)"
			var st_str = " [LELAH]" if ("is_exhausted" in player and player.is_exhausted) else ""
			var st_val = player.stamina if "stamina" in player else 100.0
			hud_speed_label.text = "Kecepatan: %.0f px/s%s | Energi: %.0f%%%s" % [spd, mode_str if spd > 10.0 else "", st_val, st_str]
		if is_instance_valid(hud_pos_label):
			hud_pos_label.text = "Posisi: (X: %.0f, Y: %.0f)" % [player.global_position.x, player.global_position.y]
		if is_instance_valid(hud_zoom_label) and player.has_method("get_zoom_level"):
			hud_zoom_label.text = "Penglihatan (Zoom): %.1fx" % player.get_zoom_level()

		if is_instance_valid(summoned_grim) and summoned_grim.visible:
			var sprite = summoned_grim.get_node_or_null("ChibiSprite")
			if is_instance_valid(sprite):
				sprite.position.y = sin(Time.get_ticks_msec() * 0.003) * 4.0

		_check_poi_proximity()

func _check_poi_proximity() -> void:
	if not is_instance_valid(player):
		return

	var p_pos = player.global_position

	if is_inside_house:
		var desk_letter_pos = house_interior.get_desk_letter_pos() if is_instance_valid(house_interior) and house_interior.has_method("get_desk_letter_pos") else Vector2(3600.0 + 295.0, 400.0 + 95.0)
		var safe_pos = house_interior.get_safe_pos() if is_instance_valid(house_interior) and house_interior.has_method("get_safe_pos") else Vector2(3600.0 + 235.0, 400.0 + 65.0)
		var photo_basin_pos = house_interior.get_photo_basin_pos() if is_instance_valid(house_interior) and house_interior.has_method("get_photo_basin_pos") else Vector2(3600.0 + 250.0, 400.0 + 360.0)
		var stairs_pos = house_interior.get_stairs_pos() if is_instance_valid(house_interior) and house_interior.has_method("get_stairs_pos") else Vector2(3600.0 + 575.0, 400.0 + 305.0)
		var exit_door_pos = house_interior.get_exit_door_pos() if is_instance_valid(house_interior) and house_interior.has_method("get_exit_door_pos") else Vector2(3600.0 + 110.0, 400.0 + 400.0)

		if p_pos.distance_to(desk_letter_pos) <= 52.0:
			active_poi_id = "indoor_letter"
		elif p_pos.distance_to(safe_pos) <= 42.0:
			active_poi_id = "indoor_safe"
		elif p_pos.distance_to(photo_basin_pos) <= 42.0:
			active_poi_id = "indoor_photo_basin"
		elif p_pos.distance_to(stairs_pos) <= 45.0:
			active_poi_id = "indoor_stairs"
		elif p_pos.distance_to(exit_door_pos) <= 30.0 or (p_pos.y >= (400.0 + 382.0) and abs(p_pos.x - (3600.0 + 110.0)) <= 30.0):
			active_poi_id = "indoor_exit"
		else:
			active_poi_id = ""

		if active_poi_id.is_empty():
			if is_instance_valid(interact_prompt):
				interact_prompt.visible = false
		else:
			if is_instance_valid(interact_prompt):
				match active_poi_id:
					"indoor_letter":
						interact_prompt.text = "[ F / E / Spasi ] BACA SURAT DI ATAS MEJA"
					"indoor_safe":
						interact_prompt.text = "[ F / E / Spasi ] BUKA BRANKAS BAJA KELUARGA\n[Y] BYPASS CERITA (FITUR BETA)"
					"indoor_photo_basin":
						if inv_mgr.is_clue_unlocked("photo_envelope"):
							interact_prompt.text = "[ F / E / Spasi ] KAMAR GELAP: CUCI ROL FOTO STASIUN\n[Y] BYPASS CERITA (FITUR BETA)"
						else:
							interact_prompt.text = "[ F / E / Spasi ] BASKOM FOTO (BELUM ADA ROL FOTO)\n[Y] BYPASS CERITA (FITUR BETA)"
					"indoor_stairs":
						interact_prompt.text = "[ F / E / Spasi ] TANGGA: MENUJU LANTAI ATAS"
					"indoor_exit":
						interact_prompt.text = "[ F / E / Spasi ] KELUAR KE KOTA"
				var vp = get_viewport().get_visible_rect().size
				interact_prompt.custom_minimum_size = Vector2(520, 56)
				interact_prompt.position = Vector2(vp.x * 0.5 - 260, vp.y - 95)
				interact_prompt.visible = true
		return

	elif is_inside_exploration_house:
		var expl_exit_pos = exploration_house_interior.get_exit_door_pos() if is_instance_valid(exploration_house_interior) and exploration_house_interior.has_method("get_exit_door_pos") else Vector2(4600.0 + 110.0, 400.0 + 400.0)
		var expl_safe_pos = exploration_house_interior.get_safe_pos() if is_instance_valid(exploration_house_interior) and exploration_house_interior.has_method("get_safe_pos") else Vector2(4600.0 + 280.0, 400.0 + 75.0)
		var expl_clock_pos = exploration_house_interior.get_clock_pos() if is_instance_valid(exploration_house_interior) and exploration_house_interior.has_method("get_clock_pos") else Vector2(4600.0 + 60.0, 400.0 + 110.0)
		var expl_photo_pos = exploration_house_interior.get_calendar_photo_pos() if is_instance_valid(exploration_house_interior) and exploration_house_interior.has_method("get_calendar_photo_pos") else Vector2(4600.0 + 420.0, 400.0 + 75.0)
		var expl_recipe_pos = exploration_house_interior.get_recipe_pos() if is_instance_valid(exploration_house_interior) and exploration_house_interior.has_method("get_recipe_pos") else Vector2(4600.0 + 340.0, 400.0 + 260.0)

		if p_pos.distance_to(expl_safe_pos) <= 52.0:
			active_poi_id = "indoor_expl_safe"
		elif p_pos.distance_to(expl_photo_pos) <= 50.0:
			active_poi_id = "indoor_expl_photo"
		elif p_pos.distance_to(expl_recipe_pos) <= 50.0:
			active_poi_id = "indoor_expl_recipe"
		elif p_pos.distance_to(expl_clock_pos) <= 50.0:
			active_poi_id = "indoor_expl_clock"
		elif p_pos.distance_to(expl_exit_pos) <= 32.0 or (p_pos.y >= (400.0 + 382.0) and abs(p_pos.x - (4600.0 + 110.0)) <= 32.0):
			active_poi_id = "indoor_expl_exit"
		else:
			active_poi_id = ""

		if active_poi_id.is_empty():
			if is_instance_valid(interact_prompt):
				interact_prompt.visible = false
		else:
			if is_instance_valid(interact_prompt):
				match active_poi_id:
					"indoor_expl_safe":
						interact_prompt.text = "[ F / E / Spasi ] BUKA BRANKAS KELUARGA (LIONTIN IBU)\n[Y] BYPASS CERITA (FITUR BETA)"
					"indoor_expl_photo":
						interact_prompt.text = "[ F / E / Spasi ] LIHAT FOTO & KALENDER KENANGAN IBU"
					"indoor_expl_recipe":
						interact_prompt.text = "[ F / E / Spasi ] BACA BUKU RESEP & CATATAN HARI IBU"
					"indoor_expl_clock":
						interact_prompt.text = "[ F / E / Spasi ] PERIKSA JAM WEKER TUA (PETUNJUK WAKTU)"
					"indoor_expl_exit":
						interact_prompt.text = "[ F / E / Spasi ] KELUAR KE JALAN KOTA"
				var vp = get_viewport().get_visible_rect().size
				interact_prompt.custom_minimum_size = Vector2(520, 56)
				interact_prompt.position = Vector2(vp.x * 0.5 - 260, vp.y - 95)
				interact_prompt.visible = true
		return

	var closest_dist: float = 999999.0
	var best_poi: String = ""

	# Check dedicated POIs with priority (e.g. Bilik Telepon di Peron Stasiun)
	var phone_dist = p_pos.distance_to(POI_LOCATIONS["phone"]["pos"])
	if phone_dist <= POI_LOCATIONS["phone"]["radius"]:
		best_poi = "phone"
		closest_dist = phone_dist
	# 1. Stasiun Kereta Api (seluruh gedung, parkiran, peron, dan rel: x 1850..2350, y 670..1310)
	elif p_pos.x >= 1850.0 and p_pos.x <= 2350.0 and p_pos.y >= 670.0 and p_pos.y <= 1310.0:
		best_poi = "station"
		closest_dist = 0.0
	# 2. Pintu Masuk Rumah Benedict (pintu beranda depan)
	elif not is_inside_house and not is_inside_exploration_house and p_pos.distance_to(Vector2(1170.0, 230.0)) <= 65.0:
		best_poi = "desk"
		closest_dist = p_pos.distance_to(Vector2(1170.0, 230.0))
	# 3. Pintu Masuk Rumah Selatan (Rumah Eksplorasi)
	elif not is_inside_house and not is_inside_exploration_house and p_pos.distance_to(Vector2(1714.0, 1170.0)) <= 70.0:
		best_poi = "south_house"
		closest_dist = p_pos.distance_to(Vector2(1714.0, 1170.0))
	else:
		for poi_key in POI_LOCATIONS.keys():
			var poi = POI_LOCATIONS[poi_key]
			var dist = p_pos.distance_to(poi["pos"])
			if dist <= poi["radius"] and dist < closest_dist:
				closest_dist = dist
				best_poi = poi_key

	active_poi_id = best_poi

	if active_poi_id.is_empty():
		if is_instance_valid(interact_prompt):
			interact_prompt.visible = false
	else:
		if is_instance_valid(interact_prompt):
			var poi_info = POI_LOCATIONS[active_poi_id]
			var custom_text = "[ F / E / Spasi ] KLIK / TEKAN: " + poi_info["name"]
			if active_poi_id == "police":
				# Otomatisasi: Pas keluar dari rumah korban, ketika dalam radius tertentu disekitar polisi,
				# langsung ikuti polisi pergi ke stasiun tanpa harus menekan tombol apa pun!
				if not auto_police_escort_triggered and inv_mgr.is_clue_unlocked("victim_letter") and not inv_mgr.has_tailgated_marcus:
					auto_police_escort_triggered = true
					if is_instance_valid(interact_prompt):
						interact_prompt.visible = false
					_trigger_poi_interaction("police", false)
					return

				if inv_mgr.current_phase == inv_mgr.Phase.PROLOGUE_HOME and not inv_mgr.is_clue_unlocked("victim_letter"):
					custom_text = "[ F / E / Spasi ] KANTOR POLISI (PERIKSA RUMAH DULU)"
				elif inv_mgr.current_phase == inv_mgr.Phase.INVESTIGATION_1_POLICE:
					custom_text = "[ F / E / Spasi ] TEMUI & KUNTIT INSPEKTUR MARCUS"
				elif inv_mgr.is_clue_unlocked("photo_envelope") and not inv_mgr.has_developed_photos:
					custom_text = "[ F / E / Spasi ] LAB POLISI: CUCI ROL FOTO STASIUN"
				elif inv_mgr.has_developed_photos:
					custom_text = "[ F / E / Spasi ] BICARA DENGAN PETUGAS POLISI"
			elif active_poi_id == "station":
				if not inv_mgr.has_tailgated_marcus:
					custom_text = "[ F / E / Spasi ] STASIUN KERETA (KUNTIT MARCUS DULU)"
				else:
					custom_text = "[ F / E / Spasi ] STASIUN KERETA: CARI BUKTI"
			elif active_poi_id == "hospital":
				if not inv_mgr.is_clue_unlocked("developed_photos"):
					custom_text = "[ F / E / Spasi ] RUMAH SAKIT (BUTUH FOTO FORENSIK)"
				else:
					custom_text = "[ F / E / Spasi ] MENYELINAP KE KAMAR MAYAT RS"
			
			if active_poi_id in ["police", "station", "hospital", "safe"]:
				interact_prompt.text = custom_text + "\n[Y] BYPASS CERITA (FITUR BETA)"
			else:
				interact_prompt.text = custom_text

			var vp = get_viewport().get_visible_rect().size
			interact_prompt.custom_minimum_size = Vector2(520, 56)
			interact_prompt.position = Vector2(vp.x * 0.5 - 260, vp.y - 95)
			interact_prompt.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_F11 or (event.alt_pressed and event.keycode == KEY_ENTER):
			toggle_fullscreen()
			get_viewport().set_input_as_handled()
			return

		# Shortcut Fitur Versi Beta: Panggil Dewa Kematian
		if event.keycode == KEY_X:
			if is_instance_valid(dialog_box) and dialog_box.is_active:
				dialog_box.close_dialog()
			_trigger_death_god()
			get_viewport().set_input_as_handled()
			return

		# Shortcut Fitur Versi Beta: Bypass Pembatas Cerita & Paksa Main Minigame
		if event.keycode == KEY_Y:
			if is_instance_valid(dialog_box) and dialog_box.is_active:
				dialog_box.close_dialog()
			_trigger_beta_bypass_interaction()
			get_viewport().set_input_as_handled()
			return

	if is_instance_valid(cutscene_layer):
		return
	if input_grace_timer > 0.0:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if is_instance_valid(letter_root_control) and letter_root_control.visible:
			if event.keycode in [KEY_ESCAPE, KEY_SPACE, KEY_ENTER, KEY_F, KEY_E]:
				_close_letter_viewer()
				get_viewport().set_input_as_handled()
				return

		# Jika dialog/monolog sedang aktif, delegasikan penekanan tombol langsung ke dialog_box
		if is_instance_valid(dialog_box) and dialog_box.is_active:
			if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_F]:
				if dialog_box.is_monologue_mode:
					dialog_box.advance_monologue()
					get_viewport().set_input_as_handled()
					return
			elif event.keycode == KEY_ESCAPE:
				dialog_box.close_dialog()
				get_viewport().set_input_as_handled()
				return
			return

		# Pintasan cepat tombol angka untuk langsung uji coba semua minigame kapan saja:
		if event.keycode == KEY_1:
			_trigger_poi_interaction("police", true)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_2:
			_trigger_poi_interaction("station", true)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_3:
			_trigger_poi_interaction("indoor_photo_basin", true)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_4:
			_trigger_poi_interaction("indoor_expl_safe" if is_inside_exploration_house else ("indoor_safe" if is_inside_house else "safe"), true)
			get_viewport().set_input_as_handled()
			return

		if event.keycode in [KEY_F, KEY_E, KEY_SPACE, KEY_ENTER]:
			if not active_poi_id.is_empty():
				_trigger_poi_interaction(active_poi_id, false)
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_J:
			if is_instance_valid(clue_journal):
				clue_journal.toggle_journal()
				get_viewport().set_input_as_handled()
				return
		elif event.keycode in [KEY_ESCAPE, KEY_P]:
			if is_instance_valid(clue_journal) and clue_journal.is_open:
				clue_journal.close_journal()
				get_viewport().set_input_as_handled()
				return
			if is_instance_valid(pause_menu_layer):
				toggle_pause_menu()
				get_viewport().set_input_as_handled()
				return

func _trigger_beta_bypass_interaction() -> void:
	# Fitur Versi Beta: Membuka paksa minigame/interaksi pada lokasi saat ini mengabaikan batasan cerita
	var target_poi = active_poi_id
	if target_poi.is_empty():
		var p_pos = player.global_position if is_instance_valid(player) else Vector2.ZERO
		var closest_dist = 320.0
		if is_inside_house:
			var house_pois = {
				"indoor_letter": Vector2(3600.0 + 110.0, 400.0 - 20.0),
				"indoor_safe": Vector2(3600.0 + 350.0, 400.0 - 80.0),
				"indoor_photo_basin": Vector2(3600.0 + 260.0, 400.0 + 250.0)
			}
			for k in house_pois.keys():
				var d = p_pos.distance_to(house_pois[k])
				if d < closest_dist:
					closest_dist = d
					target_poi = k
		elif is_inside_exploration_house:
			var expl_pois = {
				"indoor_expl_safe": Vector2(4600.0 + 280.0, 400.0 + 75.0),
				"indoor_expl_photo": Vector2(4600.0 + 420.0, 400.0 + 75.0),
				"indoor_expl_recipe": Vector2(4600.0 + 340.0, 400.0 + 260.0),
				"indoor_expl_clock": Vector2(4600.0 + 60.0, 400.0 + 110.0)
			}
			for k in expl_pois.keys():
				var d = p_pos.distance_to(expl_pois[k])
				if d < closest_dist:
					closest_dist = d
					target_poi = k
		else:
			for k in POI_LOCATIONS.keys():
				var d = p_pos.distance_to(POI_LOCATIONS[k]["pos"])
				if d < closest_dist:
					closest_dist = d
					target_poi = k

	if target_poi.is_empty():
		_show_toast("[Fitur Versi Beta] Berdirilah di dekat lokasi minigame (Polisi, Stasiun, Kamar Mayat, Baskom Foto, atau Brankas) lalu tekan [Y]!")
		return

	_show_toast("[Fitur Versi Beta] Bypass Cerita [Y] Aktif: " + target_poi.to_upper())
	_trigger_poi_interaction(target_poi, true)

func _trigger_poi_interaction(poi_id: String, bypass_story: bool = false) -> void:
	if not is_instance_valid(inv_mgr):
		return

	match poi_id:
		"desk":
			_enter_house()

		"south_house":
			_enter_exploration_house()

		"indoor_expl_exit":
			_exit_exploration_house()

		"indoor_expl_safe":
			if is_instance_valid(minigame_safe):
				player.can_move = false
				minigame_safe.start_minigame()
				_show_toast("Membuka Brankas Baja Keluarga!" if not bypass_story else "[Fitur Beta] Bypass: Membuka Brankas Baja Keluarga!")

		"indoor_expl_clock":
			if is_instance_valid(dialog_box):
				var clk_lines: Array[String] = [
					"Sebuah jam weker kuno di atas nakas...",
					"Anehnya, jarum jam ini juga terhenti kaku tepat di pukul 16:04, sama persis seperti jam jalanan kota.",
					"Di balik jam ini tergores angka samar: '1 - 6 - 4'. Jam yang berhenti saat petaka terjadi."
				]
				dialog_box.start_monologue(clk_lines, "Detektif Benedict", "[ Jam Weker Kenangan ]", "res://karakter/MC_Bingung.png")

		"indoor_expl_photo":
			if is_instance_valid(inv_mgr):
				inv_mgr.unlock_clue("mother_photo_riddle")
			if is_instance_valid(dialog_box):
				var photo_lines: Array[String] = [
					"Sebuah kalender tua dan foto berbingkai perak... Ini foto Ibu Medeline menggendongku sewaktu masih kecil.",
					"Di balik bingkai foto ada tulisan tangan ibu yang lembut:",
					"'Untuk anakku tersayang Benedict, jika dunia terasa dingin dan membingungkan, ingatlah rumah ini selalu menunggumu pulang.'",
					"'Kombinasi brankas keluarga tersimpan pada detik saat waktu kita membeku (1-6-4).'"
				]
				dialog_box.start_monologue(photo_lines, "Detektif Benedict", "[ Kenangan Ibu Medeline ]", "res://karakter/MC_Kaget.png")

		"indoor_expl_recipe":
			if is_instance_valid(dialog_box):
				var recipe_lines: Array[String] = [
					"Buku resep masakan tua bersampul kain dan selembar catatan tulisan tangan...",
					"Halaman buku ini terbuka di menu sup hangat kesukaanku.",
					"Catatan di sampingnya berbunyi: 'Ibu selalu menyisihkan sepiring hangat untuk Benedict sepulang bertugas.'",
					"Dadaku terasa sesak... Kenangan hangat ini begitu nyata, meski ragaku terasa begitu dingin."
				]
				dialog_box.start_monologue(recipe_lines, "Detektif Benedict", "[ Buku Resep Ibu ]", "res://karakter/MC_Bingung.png")

		"indoor_letter":
			_trigger_indoor_letter_monologue()

		"indoor_safe", "safe":
			if is_instance_valid(minigame_safe):
				player.can_move = false
				minigame_safe.start_minigame()
				_show_toast("Membuka Brankas Baja Keluarga!" if not bypass_story else "[Fitur Beta] Bypass: Membuka Brankas Baja Keluarga!")

		"indoor_photo_basin":
			if not bypass_story and not inv_mgr.is_clue_unlocked("photo_envelope"):
				_show_toast("Alur Cerita Terkunci: Belum ada rol foto dari stasiun! (Tekan [Y] untuk bypass fitur beta)")
				if is_instance_valid(dialog_box):
					var lines: Array[String] = [
						"Baskom larutan kimia kamar gelap ini masih kosong.",
						"Aku belum menemukan rol film foto ataupun bukti kasus di stasiun.",
						"Aku harus menyelidiki kasus dan mencari bukti di stasiun terlebih dahulu."
					]
					dialog_box.start_monologue(lines, "Detektif Benedict", "[ Kamar Gelap ]", "res://karakter/MC_Bingung.png")
				return
			if is_instance_valid(minigame_photo_wash):
				if bypass_story and not inv_mgr.is_clue_unlocked("photo_envelope"):
					inv_mgr.unlock_clue("photo_envelope")
				player.can_move = false
				minigame_photo_wash.start_minigame()
				_show_toast("Masuk ke Kamar Gelap: Cuci Foto Polaroid!" if not bypass_story else "[Fitur Beta] Bypass: Masuk ke Kamar Gelap Cuci Foto!")

		"indoor_stairs":
			_show_toast("Tangga: Menuju ruang arsip & loteng lantai atas (terkunci).")

		"indoor_exit":
			_exit_house()

		"street_clock":
			if is_instance_valid(dialog_box):
				var clock_lines: Array[String] = [
					"Jam jalan ini... jarumnya berhenti membeku tepat di pukul 16:04.",
					"Aneh sekali... padahal suasana kota masih terang dan lalu lalang orang tampak berjalan.",
					"Ada firasat aneh dan dingin yang menusuk tengkukku..."
				]
				dialog_box.start_monologue(clock_lines, "Detektif Benedict", "[ Jam Membeku ]", "res://karakter/MC_Bingung.png")
			inv_mgr.unlock_clue("street_clock_freeze")
			_show_toast("Jam Kota Terhenti di Pukul 16:04!")

		"police":
			if not bypass_story and (inv_mgr.current_phase == inv_mgr.Phase.PROLOGUE_HOME or not inv_mgr.is_clue_unlocked("victim_letter")):
				_show_toast("Alur Cerita Terkunci: Selidiki rumah korban di timur terlebih dahulu! (Tekan [Y] untuk bypass fitur beta)")
				if is_instance_valid(dialog_box):
					var p_lines: Array[String] = [
						"Petugas Polisi: 'Selamat bertugas, Detektif Benedict.'",
						"Petugas Polisi: 'Inspektur Marcus meminta Anda memeriksa TKP rumah korban di ujung timur terlebih dahulu untuk mencari berkas atau petunjuk awal.'"
					]
					dialog_box.start_monologue(p_lines, "Kantor Polisi", "[ Instruksi Tugas ]", "res://NPC_Police/front.png")
				return

			if not bypass_story and inv_mgr.is_clue_unlocked("photo_envelope") and not inv_mgr.has_developed_photos:
				# Cuci foto di lab forensik kantor polisi
				if is_instance_valid(minigame_photo_wash):
					player.can_move = false
					minigame_photo_wash.start_minigame()
					_show_toast("Masuk ke Kamar Gelap Lab Forensik Kepolisian!")
					return

			var marcus_npc = find_child("NPC_Police_Marcus", true, false)
			if not is_instance_valid(marcus_npc):
				marcus_npc = find_child("NPC1_Police", true, false)
			if not is_instance_valid(marcus_npc):
				for n in get_tree().get_nodes_in_group("npcs"):
					if n.get("npc_type") == 1 or n.get("npc_type") == 3:
						marcus_npc = n
						break

			if bypass_story:
				_show_toast("[Fitur Beta] Bypass: Memulai Minigame Menguntit Marcus!")
				_start_marcus_tailgate(marcus_npc)
				return

			if is_instance_valid(dialog_box) and not inv_mgr.has_tailgated_marcus:
				var marcus_lines: Array[String] = [
					"Detektif Benedict! Maaf, aku sedang sangat terburu-buru!",
					"Ada urusan darurat terkait kasus kematian di stasiun, aku harus keluar sekarang!"
				]
				dialog_box.start_monologue(marcus_lines, "Inspektur Marcus", "[ Terburu-buru ]", "res://NPC_Inspecture/front.png")
				dialog_box.monologue_finished.connect(func():
					_start_marcus_tailgate(marcus_npc)
				, CONNECT_ONE_SHOT)
			else:
				if inv_mgr.has_tailgated_marcus:
					_show_toast("Petugas Polisi: 'Inspektur Marcus sedang berpatroli ke arah stasiun.'")
				else:
					_start_marcus_tailgate(marcus_npc)

		"station":
			if not bypass_story and not inv_mgr.has_tailgated_marcus:
				_show_toast("Alur Cerita Terkunci: Kuntit Marcus di Kantor Polisi terlebih dahulu! (Tekan [Y] untuk bypass fitur beta)")
				if is_instance_valid(dialog_box):
					var st_lines: Array[String] = [
						"Peron stasiun kereta api tampak sepi dan hening...",
						"Aku belum tahu apa keterkaitan stasiun ini dengan kasus kematian 404.",
						"Aku harus menemui dan mencari tahu petunjuk dari Inspektur Marcus di Kantor Polisi terlebih dahulu."
					]
					dialog_box.start_monologue(st_lines, "Detektif Benedict", "[ Stasiun Kereta ]", "res://karakter/MC_Bingung.png")
				return

			if is_instance_valid(minigame_hidden_objects):
				player.can_move = false
				minigame_hidden_objects.start_minigame()
				_show_toast("Minigame Stasiun: Cari 3 Objek Bukti Tersembunyi!" if not bypass_story else "[Fitur Beta] Bypass: Minigame Stasiun Dimulai!")
			else:
				_show_toast("Peron Stasiun Kereta Api Timur. Angin dingin berhembus sunyi.")

		"hospital":
			if not bypass_story and not inv_mgr.is_clue_unlocked("developed_photos"):
				_show_toast("Alur Cerita Terkunci: Butuh identifikasi foto forensik korban! (Tekan [Y] untuk bypass fitur beta)")
				if is_instance_valid(dialog_box):
					var rej_lines: Array[String] = [
						"Resepsionis RS: 'Mohon maaf, Detektif. Kamar mayat steril ditutup rapat.'",
						"Resepsionis RS: 'Kami membutuhkan hasil identifikasi foto forensik resmi dari kepolisian sebelum membuka akses berkas jasad korban.'"
					]
					dialog_box.start_monologue(rej_lines, "Rumah Sakit", "[ Akses Ditolak ]", "res://karakter/MC_Bingung.png")
				return

			if not bypass_story and not hospital_status_reception_rejected and not inv_mgr.has_inspected_morgue:
				hospital_status_reception_rejected = true
				if is_instance_valid(dialog_box):
					var recep_lines: Array[String] = [
						"Resepsionis RS: 'Selamat siang, Detektif Benedict.'",
						"Resepsionis RS: 'Mohon maaf, salinan berkas hasil autopsi jenazah belum bisa kami serahkan karena dokumennya belum resmi ditandatangani.'",
						"Resepsionis RS: 'Dokter forensik yang memeriksa korban pun sedang tidak berada di tempat dan sama sekali tidak dapat dihubungi.'",
						"Benedict: 'Dokter tidak bisa dihubungi dan laporan resmi ditahan...? Aku tidak bisa menunggu birokrasi berhari-hari.'",
						"Benedict: 'Satu-satunya jalan adalah menyelinap langsung ke Kamar Jenazah (Ruang Mayat) di lorong bawah tanah!'"
					]
					dialog_box.start_monologue(recep_lines, "Penyelidikan RS", "[ Akses Ditolak ]", "res://karakter/MC_Bingung.png")
					_show_toast("Akses Resmi Ditolak: Menyelinap ke Kamar Jenazah!")
			else:
				if is_instance_valid(morgue_inspection):
					if is_inside_house:
						_exit_house()
					if is_inside_exploration_house:
						_exit_exploration_house()
					player.can_move = false
					morgue_inspection.open_morgue()
					_show_toast("Menyelinap ke Kamar Jenazah..." if not bypass_story else "[Fitur Beta] Bypass: Menyelinap ke Kamar Jenazah RS!")
				else:
					_show_toast("Kamar jenazah rumah sakit terkunci rapat.")

		"safe":
			if is_instance_valid(minigame_safe):
				player.can_move = false
				minigame_safe.start_minigame()
				_show_toast("Membuka Brankas Baja Rumah Ibu!")

		"phone":
			_show_toast("Gagang telepon berdering hening... 'Waktu kematian tidak dapat diulang...'")

func _start_marcus_tailgate(marcus_npc: Node) -> void:
	if is_instance_valid(minigame_tailgate) and is_instance_valid(marcus_npc):
		player.can_move = true
		if is_inside_house:
			_exit_house()
		if is_inside_exploration_house:
			_exit_exploration_house()
		if player.global_position.distance_to(marcus_npc.global_position) > 280.0:
			player.global_position = marcus_npc.global_position + Vector2(-120, 10)
		if marcus_npc.has_method("start_patrol"):
			marcus_npc.start_patrol()
		if marcus_npc.has_signal("reached_station") and not marcus_npc.reached_station.is_connected(_on_police_reached_station):
			marcus_npc.reached_station.connect(_on_police_reached_station)
		minigame_tailgate.start_minigame(player, marcus_npc)
		_show_toast("Marcus & rekannya bergegas pergi! Ikuti dari kejauhan dan jaga jarak aman!")
	else:
		_show_toast("Kantor Polisi: 'Detektif, kami sedang menangani penyelidikan kasus 404.'")

func _on_police_reached_station() -> void:
	if is_instance_valid(minigame_tailgate) and minigame_tailgate.is_active:
		minigame_tailgate.is_active = false
		minigame_tailgate.visible = false
	_on_tailgate_completed(true)

func _trigger_death_god() -> void:
	if is_instance_valid(player):
		player.can_move = false
	_summon_death_god()

func _summon_death_god() -> void:
	if not is_instance_valid(dialog_box):
		return

	if is_instance_valid(player):
		player.can_move = false

	# Munculkan wujud Dewa Kematian Chibi di dunia game tepat di depan Benedict
	if is_instance_valid(player):
		_spawn_summoned_chibi_grim()

	var prompt = ""
	if is_instance_valid(inv_mgr):
		if inv_mgr.has_emotional_item() and inv_mgr.is_clue_unlocked("autopsy_corpse"):
			prompt = "✦ SANG DEWA KEMATIAN MUNCUL DI HADAPANMU ✦\n\nWahai jiwa Benedict... Kamu telah memanggilku. Di dalam genggaman jiwamu, tersimpan liontin kasih sayang Ibu Medeline yang belum tuntas.\n\nKatakan padaku apa yang kau rasakan sekarang untuk melangkah ke peristirahatan abadi..."
		elif inv_mgr.is_clue_unlocked("autopsy_corpse"):
			prompt = "✦ SANG DEWA KEMATIAN MUNCUL DI HADAPANMU ✦\n\nWahai Benedict... Kamu telah memanggilku dan mengetahui fakta bahwa kamu telah tiada. Katakan padaku apa yang telah kau pelajari tentang takdirmu..."
		else:
			prompt = "✦ SANG DEWA KEMATIAN MUNCUL DI HADAPANMU ✦\n\nWahai pengelana fana... Mengapa kamu memanggilku? Katakan padaku apa yang kau cari dalam keheningan ini..."
	
	dialog_box.open_dialog(prompt)

func _spawn_summoned_chibi_grim() -> void:
	if not is_instance_valid(summoned_grim):
		summoned_grim = Node2D.new()
		summoned_grim.name = "SummonedChibiGrim"
		summoned_grim.y_sort_enabled = true

		var aura = ColorRect.new()
		aura.name = "Aura"
		aura.position = Vector2(-36, -46)
		aura.size = Vector2(72, 82)
		aura.color = Color(0.45, 0.15, 0.85, 0.35)
		summoned_grim.add_child(aura)

		var sprite = Sprite2D.new()
		sprite.name = "ChibiSprite"
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		sprite.scale = Vector2(0.045, 0.045)
		var dep = load("res://grimChibi/depan.png")
		if dep:
			sprite.texture = dep
		summoned_grim.add_child(sprite)

		add_child(summoned_grim)

	var offset_dist = 65.0
	var spawn_pos = player.global_position
	var facing = Vector2.DOWN
	if "facing_direction" in player:
		facing = player.facing_direction

	if abs(facing.x) > abs(facing.y):
		if facing.x > 0:
			spawn_pos += Vector2(offset_dist, 0)
			_set_summoned_grim_tex("kiri")
		else:
			spawn_pos += Vector2(-offset_dist, 0)
			_set_summoned_grim_tex("kanan")
	else:
		if facing.y > 0:
			spawn_pos += Vector2(0, offset_dist)
			_set_summoned_grim_tex("belakang")
		else:
			spawn_pos += Vector2(0, -offset_dist)
			_set_summoned_grim_tex("depan")

	summoned_grim.global_position = spawn_pos
	summoned_grim.visible = true
	summoned_grim.modulate.a = 0.0

	var tw = create_tween()
	tw.tween_property(summoned_grim, "modulate:a", 1.0, 0.35)

func _set_summoned_grim_tex(dir_name: String) -> void:
	if not is_instance_valid(summoned_grim):
		return
	var sprite = summoned_grim.get_node_or_null("ChibiSprite") as Sprite2D
	if is_instance_valid(sprite):
		var tex_path = "res://grimChibi/" + dir_name + ".png"
		var t = load(tex_path)
		if t:
			sprite.texture = t

func _on_dialog_opened() -> void:
	if is_instance_valid(player):
		player.can_move = false
	if is_instance_valid(shrine) and shrine.has_method("set_dialog_active"):
		shrine.set_dialog_active(true)
	play_afterlife_music()

func _on_dialog_closed() -> void:
	input_grace_timer = 0.35
	if is_instance_valid(player):
		player.can_move = true
	if is_instance_valid(shrine) and shrine.has_method("set_dialog_active"):
		shrine.set_dialog_active(false)
	stop_afterlife_music()
	if is_instance_valid(summoned_grim) and summoned_grim.visible:
		var tw = create_tween()
		tw.tween_property(summoned_grim, "modulate:a", 0.0, 0.4)
		tw.tween_callback(func():
			if is_instance_valid(summoned_grim):
				summoned_grim.visible = false
		)

func _on_phase_changed(_p: int, _title: String) -> void:
	_update_hud_objective()

func _update_hud_objective() -> void:
	var title_str = "Menyelidiki Kasus..."
	if is_instance_valid(inv_mgr) and inv_mgr.has_method("get_current_objective_title"):
		title_str = inv_mgr.get_current_objective_title()
	if is_instance_valid(hud_objective_label):
		hud_objective_label.text = "Target: " + title_str
	if is_instance_valid(hud_objective_text):
		hud_objective_text.text = "Target: " + title_str
	if is_instance_valid(hud_phase_badge) and is_instance_valid(inv_mgr):
		match inv_mgr.current_phase:
			inv_mgr.Phase.PROLOGUE_HOME:
				hud_phase_badge.text = "[ Prolog: Rumah ]"
			inv_mgr.Phase.INVESTIGATION_1_POLICE:
				hud_phase_badge.text = "[ Kasus 1: Polisi ]"
			inv_mgr.Phase.INVESTIGATION_2_STATION:
				hud_phase_badge.text = "[ Kasus 2: Stasiun ]"
			inv_mgr.Phase.INVESTIGATION_3_PHOTO:
				hud_phase_badge.text = "[ Kasus 3: Forensik ]"
			inv_mgr.Phase.INVESTIGATION_4_HOSPITAL:
				hud_phase_badge.text = "[ Kasus 4: Mayat ]"
			inv_mgr.Phase.FINAL_DEATH_GOD:
				hud_phase_badge.text = "[ Altar Dewa Maut ]"

func _on_journal_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(clue_journal):
		clue_journal.toggle_journal()

func _on_reset_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player):
		player.global_position = Vector2(100.0, 225.0)
		player.velocity = Vector2.ZERO

func _on_zoom_in_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player) and player.has_method("zoom_in"):
		player.zoom_in()

func _on_zoom_out_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player) and player.has_method("zoom_out"):
		player.zoom_out()

func _on_zoom_reset_btn_pressed() -> void:
	play_click_sfx()
	if is_instance_valid(player) and player.has_method("reset_zoom"):
		player.reset_zoom()

func _start_ai_server() -> void:
	if server_pid != -1:
		return
	var exe_path = OS.get_executable_path().get_base_dir() + "/ai_server.exe"
	if FileAccess.file_exists(exe_path):
		server_pid = OS.create_process(exe_path, [])
		print("[Main] Server AI dimulai dari .exe (PID: %d)" % server_pid)
		return

	var dev_path = ProjectSettings.globalize_path("res://ai_server/main.py")
	if FileAccess.file_exists(dev_path):
		server_pid = OS.create_process("python", [dev_path])
		if server_pid != -1:
			print("[Main] Server AI Python development dimulai (PID: %d)" % server_pid)
		else:
			server_pid = OS.create_process("py", [dev_path])
			print("[Main] Server AI 'py' dimulai (PID: %d)" % server_pid)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if server_pid != -1:
			OS.kill(server_pid)
			print("[Main] Server AI dihentikan.")
		get_tree().quit()
