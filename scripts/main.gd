extends Node2D

# ── Main Game Controller - Full GDD Feature Integration ────────────────────
# Mengintegrasikan seluruh alur investigasi kasus, minigame 1, 2, 3,
# side quest brankas ibu, desaturasi bertahap, jurnal bukti (J), dan Dewa Kematian.

# ── Referensi Node Inti ───────────────────────────────────────────────────
@onready var player: CharacterBody2D = $Player
@onready var shrine: Node2D = $DeathGodShrine
@onready var dialog_box: CanvasLayer = $DialogBox
@onready var hud_speed_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/SpeedLabel
@onready var hud_pos_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/PosLabel
@onready var hud_zoom_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/ZoomLabel
@onready var hud_objective_label: Label = $HUD/MarginContainer/PanelContainer/VBoxContainer/ObjectiveLabel

var server_pid: int = -1

# Manager & Sub-Sistem
var inv_mgr: Node
var world_shader: CanvasLayer
var clue_journal: CanvasLayer
var minigame_tailgate: CanvasLayer
var minigame_hidden_objects: CanvasLayer
var minigame_photo_wash: CanvasLayer
var minigame_safe: CanvasLayer

# UI Prompts
var interact_prompt: Label
var toast_banner: PanelContainer
var toast_label: Label
var toast_timer: float = 0.0

# POI (Points of Interest) Interaktif
var active_poi_id: String = ""

# Koordinat Lokasi Utama
const POI_LOCATIONS = {
	"desk": {"name": "Meja Kerja & Foto Ibu", "pos": Vector2(1170, 270), "radius": 75.0},
	"police": {"name": "Kantor Polisi & Marcus", "pos": Vector2(350, 430), "radius": 90.0},
	"station": {"name": "Peron Stasiun Kereta", "pos": Vector2(2080, 520), "radius": 100.0},
	"hospital": {"name": "Kamar Mayat Rumah Sakit", "pos": Vector2(850, 1000), "radius": 90.0},
	"safe": {"name": "Brankas Rumah Ibu Medeline", "pos": Vector2(180, 1050), "radius": 80.0},
	"shrine": {"name": "Altar Dewa Kematian", "pos": Vector2(1833, 1059), "radius": 110.0}
}

func _ready() -> void:
	print("[Main] Menginisialisasi Sistem Lengkap Sesuai GDD...")

	_setup_investigation_manager()
	_setup_world_shader()
	_setup_clue_journal()
	_setup_minigames()
	_setup_letter_viewer()
	_setup_hud_prompts()
	_start_ai_server()

	# Hubungkan shrine
	if not is_instance_valid(shrine):
		shrine = find_child("DeathGodShrine", true, false)
	if is_instance_valid(shrine):
		if not shrine.interaction_triggered.is_connected(_on_shrine_interacted):
			shrine.interaction_triggered.connect(_on_shrine_interacted)

	# Hubungkan dialog box
	if is_instance_valid(dialog_box):
		if not dialog_box.dialog_opened.is_connected(_on_dialog_opened):
			dialog_box.dialog_opened.connect(_on_dialog_opened)
		if not dialog_box.dialog_closed.is_connected(_on_dialog_closed):
			dialog_box.dialog_closed.connect(_on_dialog_closed)

	# Update display awal
	_update_hud_objective()

# ── Setup Manager & Sub-Sistem ──────────────────────────────────────────────
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
	# Minigame 1: Tailgating Marcus
	var mg1_script = load("res://scripts/minigame_tailgate.gd")
	if mg1_script:
		minigame_tailgate = CanvasLayer.new()
		minigame_tailgate.name = "MinigameTailgate"
		minigame_tailgate.set_script(mg1_script)
		add_child(minigame_tailgate)
		minigame_tailgate.minigame_completed.connect(func(_ok): _on_minigame_ended())

	# Minigame 2: Hidden Objects
	var mg2_script = load("res://scripts/minigame_hidden_objects.gd")
	if mg2_script:
		minigame_hidden_objects = CanvasLayer.new()
		minigame_hidden_objects.name = "MinigameHiddenObjects"
		minigame_hidden_objects.set_script(mg2_script)
		add_child(minigame_hidden_objects)
		minigame_hidden_objects.minigame_completed.connect(func(_ok): _on_minigame_ended())

	# Minigame 3: Forensic Cleaning
	var mg3_script = load("res://scripts/minigame_photo_wash.gd")
	if mg3_script:
		minigame_photo_wash = CanvasLayer.new()
		minigame_photo_wash.name = "MinigamePhotoWash"
		minigame_photo_wash.set_script(mg3_script)
		add_child(minigame_photo_wash)
		minigame_photo_wash.minigame_completed.connect(func(_ok): _on_minigame_ended())

	# Side Quest: Safe Puzzle
	var safe_script = load("res://scripts/minigame_safe.gd")
	if safe_script:
		minigame_safe = CanvasLayer.new()
		minigame_safe.name = "MinigameSafe"
		minigame_safe.set_script(safe_script)
		add_child(minigame_safe)
		minigame_safe.safe_opened.connect(func(_ok): _on_minigame_ended())

func _on_minigame_ended() -> void:
	if is_instance_valid(player):
		player.can_move = true
	_update_hud_objective()

# ── ✉️ Viewer Surat Petunjuk Kasus (Close-Up UI) ─────────────────────────────
var letter_layer: CanvasLayer
var letter_rect: TextureRect
var letter_close_btn: Button

func _setup_letter_viewer() -> void:
	letter_layer = CanvasLayer.new()
	letter_layer.name = "LetterViewer"
	letter_layer.layer = 15
	add_child(letter_layer)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.05, 0.08, 0.85)
	letter_layer.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter_layer.add_child(center)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	center.add_child(vb)

	letter_rect = TextureRect.new()
	var tex_close = load("res://interactable assets/surat close up.png")
	if is_instance_valid(tex_close):
		letter_rect.texture = tex_close
	letter_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	letter_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	letter_rect.custom_minimum_size = Vector2(460, 480)
	vb.add_child(letter_rect)

	letter_close_btn = Button.new()
	letter_close_btn.text = "✔ Simpan ke Jurnal & Lanjutkan Investigasi [ESC / Spasi]"
	letter_close_btn.custom_minimum_size = Vector2(320, 40)
	letter_close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	letter_close_btn.pressed.connect(_close_letter_viewer)
	vb.add_child(letter_close_btn)

	letter_layer.visible = false

func _open_letter_closeup() -> void:
	if is_instance_valid(letter_layer):
		letter_layer.visible = true
		if is_instance_valid(player):
			player.can_move = false

func _close_letter_viewer() -> void:
	if is_instance_valid(letter_layer):
		letter_layer.visible = false
	if is_instance_valid(player):
		player.can_move = true
	if is_instance_valid(inv_mgr):
		if inv_mgr.current_phase == inv_mgr.Phase.PROLOGUE_HOME:
			_show_toast("✉️ Surat Tugas: Temui Inspektur Marcus di Kantor Polisi!")
			inv_mgr.set_phase(inv_mgr.Phase.INVESTIGATION_1_POLICE)

# ── HUD & Interaksi POI ─────────────────────────────────────────────────────
func _setup_hud_prompts() -> void:
	var hud_layer = $HUD
	if not is_instance_valid(hud_layer):
		return

	# Floating Interaction Prompt
	interact_prompt = Label.new()
	interact_prompt.text = "[ F / E ] Interaksi"
	interact_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_prompt.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	interact_prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	interact_prompt.add_theme_constant_override("outline_size", 4)
	interact_prompt.add_theme_font_size_override("font_size", 15)
	interact_prompt.visible = false
	hud_layer.add_child(interact_prompt)

	# Toast Banner
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

func _show_toast(msg: String) -> void:
	if is_instance_valid(toast_label) and is_instance_valid(toast_banner):
		toast_label.text = msg
		toast_banner.visible = true
		toast_timer = 3.5

# ── Process & Interaksi ─────────────────────────────────────────────────────
func _process(delta: float) -> void:
	# Update Toast
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_banner.visible = false

	# Update HUD telemetry
	if is_instance_valid(player):
		if is_instance_valid(hud_speed_label):
			var spd = player.velocity.length()
			var mode_str = " (Lari/Shift)" if player.is_sprinting else " (Jalan)"
			hud_speed_label.text = "Kecepatan: %.0f px/s%s" % [spd, mode_str if spd > 10.0 else ""]
		if is_instance_valid(hud_pos_label):
			hud_pos_label.text = "Posisi: (X: %.0f, Y: %.0f)" % [player.global_position.x, player.global_position.y]
		if is_instance_valid(hud_zoom_label) and player.has_method("get_zoom_level"):
			hud_zoom_label.text = "Penglihatan (Zoom): %.1fx" % player.get_zoom_level()

		_check_poi_proximity()

func _check_poi_proximity() -> void:
	if not is_instance_valid(player):
		return

	var p_pos = player.global_position
	active_poi_id = ""

	for poi_key in POI_LOCATIONS.keys():
		var poi = POI_LOCATIONS[poi_key]
		var dist = p_pos.distance_to(poi["pos"])
		if dist <= poi["radius"]:
			active_poi_id = poi_key
			break

	if active_poi_id.is_empty():
		if is_instance_valid(interact_prompt):
			interact_prompt.visible = false
	else:
		if is_instance_valid(interact_prompt):
			var poi_info = POI_LOCATIONS[active_poi_id]
			interact_prompt.text = "👉 [ F / E / Spasi ] Interaksi: " + poi_info["name"]
			var vp = get_viewport().get_visible_rect().size
			interact_prompt.position = Vector2(vp.x * 0.5 - 180, vp.y - 75)
			interact_prompt.visible = true

func _unhandled_input(event: InputEvent) -> void:
	# Cek tombol interaksi: F (GDD), E, atau Space
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode in [KEY_F, KEY_E, KEY_SPACE]:
			if not active_poi_id.is_empty():
				_trigger_poi_interaction(active_poi_id)
				get_viewport().set_input_as_handled()
		elif event.keycode == KEY_J:
			if is_instance_valid(clue_journal):
				clue_journal.toggle_journal()
				get_viewport().set_input_as_handled()

func _trigger_poi_interaction(poi_id: String) -> void:
	if not is_instance_valid(inv_mgr):
		return

	match poi_id:
		"desk":
			if inv_mgr.current_phase == inv_mgr.Phase.PROLOGUE_HOME:
				_open_letter_closeup()
			elif inv_mgr.current_phase == inv_mgr.Phase.INVESTIGATION_3_PHOTO:
				# Buka Minigame 3: Cuci Foto
				if is_instance_valid(minigame_photo_wash):
					player.can_move = false
					minigame_photo_wash.start_minigame()
			else:
				_show_toast("Meja kerja detektif. Buka Jurnal [J] untuk meninjau petunjuk.")

		"police":
			if inv_mgr.current_phase == inv_mgr.Phase.INVESTIGATION_1_POLICE:
				# Buka Minigame 1: Tailgate Marcus
				var marcus_npc = find_child("NPC4", true, false)
				if not is_instance_valid(marcus_npc):
					marcus_npc = find_child("NPC1", true, false)
				if is_instance_valid(minigame_tailgate) and is_instance_valid(marcus_npc):
					minigame_tailgate.start_minigame(player, marcus_npc)
					_show_toast("🕵️ Minigame Menguntit Marcus dimulai! Jaga jarak aman!")
			else:
				_show_toast("Kantor Polisi: 'Detektif, kami sedang menangani penyelidikan kasus 404.'")

		"station":
			if inv_mgr.current_phase == inv_mgr.Phase.INVESTIGATION_2_STATION:
				# Buka Minigame 2: Hidden Objects
				if is_instance_valid(minigame_hidden_objects):
					player.can_move = false
					minigame_hidden_objects.start_minigame()
			else:
				_show_toast("Peron Stasiun Kereta Api Timur. Angin dingin berhembus sunyi.")

		"hospital":
			if inv_mgr.current_phase >= inv_mgr.Phase.INVESTIGATION_4_HOSPITAL:
				inv_mgr.unlock_clue("autopsy_corpse")
				inv_mgr.set_phase(inv_mgr.Phase.FINAL_DEATH_GOD)
				_show_toast("🩺 Kamar Mayat: Kamu melihat jasad dirimu sendiri... Kamu telah tiada!")
				if is_instance_valid(dialog_box):
					dialog_box.open_dialog("...Detektif Benedict. Tataplah tubuh yang terbaring kaku itu. Kamu bukan lagi detektif yang bernafas... kamu adalah arwah yang mencari kebenaran tentang kematianmu sendiri. Datanglah ke altarku di kuil suci...")
			else:
				_show_toast("Rumah Sakit: 'Pemeriksaan jasad korban sedang dijaga ketat oleh dokter.'")

		"safe":
			# Buka Minigame Brankas Ibu
			if is_instance_valid(minigame_safe):
				player.can_move = false
				minigame_safe.start_minigame()

		"shrine":
			_on_shrine_interacted()

# ── Alur Dewa Kematian & True Ending ─────────────────────────────────────────
func _on_shrine_interacted() -> void:
	if is_instance_valid(dialog_box):
		var prompt = ""
		if is_instance_valid(inv_mgr):
			if inv_mgr.has_emotional_item() and inv_mgr.is_clue_unlocked("autopsy_corpse"):
				prompt = "✦ SANG DEWA MENATAPMU PENUH PENCERAHAN ✦\n\nWahai jiwa Benedict... Kamu telah menyadari bahwa kamu telah mati, dan di dalam genggaman jiwamu, tersimpan liontin kasih sayang Ibu Medeline yang belum tuntas.\n\nKatakan padaku apa yang kau rasakan sekarang untuk melangkah ke peristirahatan abadi..."
			elif inv_mgr.is_clue_unlocked("autopsy_corpse"):
				prompt = "Wahai Benedict... Kamu telah mengetahui fakta bahwa kamu telah mati di stasiun itu. Katakan padaku apa yang telah kau pelajari tentang takdirmu..."
			else:
				prompt = "Wahai pengelana fana... Setelah melintasi ruang hampa ini, katakan padaku apa yang telah kau pelajari tentang takdirmu?"
		
		dialog_box.open_dialog(prompt)

func _on_dialog_opened() -> void:
	if is_instance_valid(player):
		player.can_move = false
	if is_instance_valid(shrine) and shrine.has_method("set_dialog_active"):
		shrine.set_dialog_active(true)

func _on_dialog_closed() -> void:
	if is_instance_valid(player):
		player.can_move = true
	if is_instance_valid(shrine) and shrine.has_method("set_dialog_active"):
		shrine.set_dialog_active(false)

func _on_phase_changed(_p: int, _title: String) -> void:
	_update_hud_objective()

func _update_hud_objective() -> void:
	if is_instance_valid(hud_objective_label) and is_instance_valid(inv_mgr):
		hud_objective_label.text = "🎯 Target: " + inv_mgr.get_current_objective_title()

# ── UI Buttons Handlers ────────────────────────────────────────────────────
func _on_journal_btn_pressed() -> void:
	if is_instance_valid(clue_journal):
		clue_journal.toggle_journal()

func _on_reset_btn_pressed() -> void:
	if is_instance_valid(player):
		player.global_position = Vector2(1170, 270)
		player.velocity = Vector2.ZERO

func _on_zoom_in_btn_pressed() -> void:
	if is_instance_valid(player) and player.has_method("zoom_in"):
		player.zoom_in()

func _on_zoom_out_btn_pressed() -> void:
	if is_instance_valid(player) and player.has_method("zoom_out"):
		player.zoom_out()

func _on_zoom_reset_btn_pressed() -> void:
	if is_instance_valid(player) and player.has_method("reset_zoom"):
		player.reset_zoom()

# ── Otomatis Jalankan Server AI ──────────────────────────────────────────
func _start_ai_server() -> void:
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
