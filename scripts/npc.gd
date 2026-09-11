extends CharacterBody2D

enum NPCType { BOY, POLICE, GIRL, INSPECTOR_MARCUS }
@export var npc_type: NPCType = NPCType.BOY
@export var target_height_px: float = 38.0
@export var too_close_radius: float = 42.0
@export var eavesdrop_radius: float = 85.0
@export var panic_time_limit: float = 7.0
@export var run_speed: float = 380.0
@export var walk_speed: float = 52.0

enum State { IDLE, GO_TO_DESTINATION, EAVESDROP, AFRAID, PANIC_RUN, DESPAWNED }
var current_state: State = State.GO_TO_DESTINATION

var player_ref: CharacterBody2D = null
var panic_timer: float = 0.0
var run_timer: float = 0.0
var run_direction: Vector2 = Vector2.ZERO
var tremble_offset: Vector2 = Vector2.ZERO

var player_in_spook_radius_timer: float = 0.0
var spook_merinding_timer: float = 0.0
var is_spook_disabled: bool = false
const SPOOK_RADIUS: float = 70.0

const SHARED_DESTINATIONS = [
	Vector2(2088, 520),
	Vector2(1090, 435),
	Vector2(780, 830),
	Vector2(720, 480),
	Vector2(260, 250),
	Vector2(1280, 920),
	Vector2(1750, 480)
]

signal reached_station
signal npc_spook_fled(npc_node: CharacterBody2D)

const POLICE_PATROL_WAYPOINTS_DEFAULT = [
	Vector2(350, 865),
	Vector2(411, 880),
	Vector2(411, 1278),
	Vector2(950, 1278),
	Vector2(1880, 1278),
	Vector2(1880, 820),
	Vector2(2020, 820)
]

const POLICE_RETURN_WAYPOINTS_DEFAULT = [
	Vector2(2020, 820),
	Vector2(1880, 820),
	Vector2(1880, 1278),
	Vector2(950, 1278),
	Vector2(411, 1278),
	Vector2(411, 880),
	Vector2(280, 915)
]

static var _cached_route_config_loaded: bool = false
static var _cached_patrol_waypoints: Array[Vector2] = []
static var _cached_return_waypoints: Array[Vector2] = []
static var _cached_spook_grid_waypoints: Array[Vector2] = []
static var _cached_spook_follow_grid: bool = true

var police_patrol_waypoints: Array[Vector2] = []
var police_return_waypoints: Array[Vector2] = []
var spook_grid_waypoints: Array[Vector2] = []
var spook_follow_grid: bool = true

var panic_grid_path: Array[Vector2] = []
var panic_grid_idx: int = 0

var is_patrolling_to_station: bool = false
var patrol_formation_offset: Vector2 = Vector2.ZERO
var is_departing: bool = false

var target_destination: Vector2 = Vector2.ZERO
var current_patrol_idx: int = 0
var idle_hangout_timer: float = 0.0

var stuck_timer: float = 0.0
var last_check_pos: Vector2 = Vector2.ZERO
const STUCK_THRESHOLD: float = 0.7
const STUCK_DIST_MIN: float = 4.0

var social_cooldown: float = 0.0

# Warga sipil merinding dan gemetar karena Benedict sejatinya adalah arwah/orang mati (aktif setelah misi rumah selesai)
const SOCIAL_CHATS_CIVILIAN = [
	"...Hii! Tiba-tiba bulu kudukku meremang hebat...",
	"...Dingin sekali, rasanya seperti ada arwah orang mati berdiri di sebelahku...",
	"...Kenapa aku gemetar ketakutan ya? Padahal jalanan sepi...",
	"...Hawa dingin apa ini?! Seperti ada sosok yang menatapku tapi tak terlihat...",
	"...Aneh, kenapa bulu romaku berdiri semua? Aku harus cepat-cepat pergi dari sini!",
	"...Ih merinding! Jangan-jangan ada arwah korban pembunuhan yang berkeliaran..."
]

# Sapaan warga sipil di awal cerita sebelum misi rumah selesai (kondisi normal, santai & ramah)
const NORMAL_CHATS_CIVILIAN = [
	"Selamat pagi, Detektif Benedict. Hari yang berkabut ya?",
	"Semoga penyelidikanmu lancar hari ini, Pak Detektif.",
	"Jalanan kota terasa cukup sunyi dan tenang pagi ini.",
	"Pak Detektif sedang bertugas? Semoga harimu menyenangkan!",
	"Udara hari ini cukup sejuk dan segar, Benedict."
]

const SOCIAL_CHATS_POLICE = [
	"Marcus: Cepat! Kasus ini harus segera kita tuntaskan.",
	"Marcus: Saksi mata melihat korban terakhir menuju stasiun kereta api.",
	"Polisi: Jam di kota ini membeku di 16:04...",
	"Polisi: Korban berencana keluar kota untuk liburan sebelum tewas.",
	"Marcus: Jangan sampai terlambat, kita amankan bukti di peron!"
]

# Dialog polisi saat merinding hebat karena Benedict (arwah) berada terlalu dekat
const SPOOK_CHATS_POLICE = [
	"Marcus: Brrr... hawa dingin apa ini?! Bulu kudukku meremang hebat!",
	"Polisi: Kenapa tiba-tiba merinding begini? Seperti ada arwah orang mati di dekatku...",
	"Marcus: Dingin sekali... rasanya ada sosok tak kasat mata yang berdiri terlalu dekat!",
	"Polisi: Hii! Bulu romaku berdiri semua, hawa kematian apa ini?!",
	"Marcus: Jangan-jangan arwah korban pembunuhan itu ada di samping kita?!"
]

func _is_spook_active() -> bool:
	if is_spook_disabled or is_departing:
		return false

	# Polisi HANYA boleh merinding saat sudah mulai patroli dan sudah berada di jalan selatan
	if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
		# Belum mulai patroli / belum menguntit polisi -> jangan pernah merinding
		if not is_patrolling_to_station:
			return false
		# Belum sampai di jalan selatan (Y >= 1050 atau waypoint selatan) -> jangan merinding
		if global_position.y < 1050.0 and current_patrol_idx < 2:
			return false
		if is_inside_tree():
			var st_tree = get_tree()
			if is_instance_valid(st_tree) and is_instance_valid(st_tree.root):
				var main_n = st_tree.root.find_child("Main", true, false)
				if is_instance_valid(main_n):
					if main_n.get("station_arrival_cutscene_running") or main_n.get("station_arrival_cutscene_done"):
						return false
		return true

	var inv_mgr = null
	if is_inside_tree() and get_tree() and get_tree().root:
		inv_mgr = get_tree().root.get_node_or_null("InvestigationManager")
		if not is_instance_valid(inv_mgr):
			inv_mgr = get_tree().root.find_child("InvestigationManager", true, false)
	else:
		var main_loop = Engine.get_main_loop()
		if main_loop is SceneTree and is_instance_valid(main_loop.root):
			inv_mgr = main_loop.root.get_node_or_null("InvestigationManager")
			if not is_instance_valid(inv_mgr):
				inv_mgr = main_loop.root.find_child("InvestigationManager", true, false)

	if is_instance_valid(inv_mgr):
		return inv_mgr.current_phase >= inv_mgr.Phase.INVESTIGATION_1_POLICE or inv_mgr.is_clue_unlocked("victim_letter") or inv_mgr.has_tailgated_marcus or inv_mgr.has_cleared_station
	return false


var msg_display_timer: float = 0.0
var msg_cooldown_timer: float = 0.0
const MSG_DISPLAY_DURATION: float = 2.8
const MSG_COOLDOWN_DURATION: float = 1.2

var sprite_sets: Dictionary = {}

@onready var nav_agent: NavigationAgent2D = get_node_or_null("NavigationAgent2D")
var textbox_panel: PanelContainer
var textbox_label: Label
var textbox_pointer: Polygon2D
var textbox_pointer_outline: Line2D
var textbox_scale: float = 0.0
var is_textbox_visible: bool = false
var current_text_msg: String = ""
var last_clue_index: int = -1

var step_cycle: float = 0.0
var is_moving: bool = false
var body_bob_y: float = 0.0
var move_dir_facing: Vector2 = Vector2.DOWN

const CLUE_MESSAGES_CIVILIAN = [
	"Perasaanku tidak enak... hawa di sini dingin sekali...",
	"Jam dinding di ruangan itu... berhenti tepat jam dua.",
	"Mereka bilang... ada satu laporan investigasi yang belum selesai.",
	"Pakaianmu... rasanya aku pernah melihatnya di suatu tempat...",
	"Aneh... kenapa angin tidak menggerakkan pakaianmu sama sekali?",
	"Orang-orang di kota ini... tidak ada yang mau menjawabmu.",
	"Ada sesuatu tentang tempat ini... yang membuat bulu kuduk berdiri..."
]

const CLUE_MESSAGES_POLICE = [
	"Marcus: Saksi bilang korban terakhir terlihat berjalan ke arah stasiun kereta api...",
	"Polisi: Benar, katanya dia membawa koper dan amplop foto sebelum kematiannya.",
	"Marcus: Kita harus segera amankan barang bukti yang tertinggal di peron stasiun timur.",
	"Polisi: Siap, Inspektur. Ayo kita susuri rute jalan menuju peron stasiun sekarang.",
	"Marcus: Jangan sampai terlambat sebelum jadwal kereta malam tiba di stasiun!"
]

const PANIC_MESSAGES = [
	"PERGI!! JANGAN MENDEKATIKU!! ",
	"Tolong! Rasanya tempat ini membuatku tercekik!! ",
	"Tidak... aku harus pergi dari sini sekarang!! ",
	"Aku tidak tahan lagi... hawa ini terlalu pekat!! ",
	"Jangan sentuh aku!! "
]

func _ready() -> void:
	add_to_group("npcs")
	y_sort_enabled = true
	collision_layer = 4
	collision_mask = 1
	last_check_pos = global_position
	
	_load_police_route_config()
	_load_all_npc_sprite_sets()
	_build_growtopia_textbox()
	
	if is_instance_valid(nav_agent):
		nav_agent.path_desired_distance = 12.0
		nav_agent.target_desired_distance = 24.0
		nav_agent.radius = 14.0
		nav_agent.max_speed = walk_speed

	social_cooldown = randf_range(2.0, 6.0)
	
	if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
		current_state = State.IDLE
		idle_hangout_timer = 999999.0 # Tetap standby di depan kantor polisi sampai didatangi MC
		move_dir_facing = Vector2.RIGHT if global_position.x < 280.0 else Vector2.LEFT
		if npc_type == NPCType.INSPECTOR_MARCUS:
			show_chat_bubble("Marcus: Kita harus cepat ke stasiun!", 3.5)
		else:
			show_chat_bubble("Polisi: Siap, Inspektur Marcus!", 3.5)
	else:
		call_deferred("_pick_next_destination")
	queue_redraw()

func _load_police_route_config() -> void:
	if _cached_route_config_loaded:
		police_patrol_waypoints.clear()
		police_patrol_waypoints.append_array(_cached_patrol_waypoints)
		police_return_waypoints.clear()
		police_return_waypoints.append_array(_cached_return_waypoints)
		spook_grid_waypoints.clear()
		spook_grid_waypoints.append_array(_cached_spook_grid_waypoints)
		spook_follow_grid = _cached_spook_follow_grid
		return

	police_patrol_waypoints.clear()
	police_patrol_waypoints.append_array(POLICE_PATROL_WAYPOINTS_DEFAULT)
	police_return_waypoints.clear()
	police_return_waypoints.append_array(POLICE_RETURN_WAYPOINTS_DEFAULT)
	spook_grid_waypoints.clear()
	spook_follow_grid = true

	var path = "res://data/police_route_config.json"
	if not FileAccess.file_exists(path):
		_cached_patrol_waypoints.clear()
		_cached_patrol_waypoints.append_array(police_patrol_waypoints)
		_cached_return_waypoints.clear()
		_cached_return_waypoints.append_array(police_return_waypoints)
		_cached_spook_grid_waypoints.clear()
		_cached_spook_grid_waypoints.append_array(spook_grid_waypoints)
		_cached_spook_follow_grid = spook_follow_grid
		_cached_route_config_loaded = true
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_text) == OK and json.data is Dictionary:
		var data: Dictionary = json.data
		var cell_size: float = 32.0
		if data.has("grid_system") and data["grid_system"] is Dictionary:
			cell_size = float(data["grid_system"].get("cell_size", 32.0))

		var use_grid: bool = bool(data.get("use_grid_coordinates", false))

		# 1. Patrol waypoints
		var parsed_patrol: Array[Vector2] = []
		if use_grid and data.has("police_patrol_route_grid") and data["police_patrol_route_grid"] is Array:
			for pt in data["police_patrol_route_grid"]:
				if pt is Array and pt.size() >= 2:
					parsed_patrol.append(Vector2(float(pt[0]) * cell_size + cell_size * 0.5, float(pt[1]) * cell_size + cell_size * 0.5))
		elif data.has("police_patrol_route_pixels") and data["police_patrol_route_pixels"] is Array:
			for pt in data["police_patrol_route_pixels"]:
				if pt is Array and pt.size() >= 2:
					parsed_patrol.append(Vector2(float(pt[0]), float(pt[1])))
		if not parsed_patrol.is_empty():
			police_patrol_waypoints.clear()
			police_patrol_waypoints.append_array(parsed_patrol)

		# 2. Return waypoints
		var parsed_return: Array[Vector2] = []
		if use_grid and data.has("police_return_route_grid") and data["police_return_route_grid"] is Array:
			for pt in data["police_return_route_grid"]:
				if pt is Array and pt.size() >= 2:
					parsed_return.append(Vector2(float(pt[0]) * cell_size + cell_size * 0.5, float(pt[1]) * cell_size + cell_size * 0.5))
		elif data.has("police_return_route_pixels") and data["police_return_route_pixels"] is Array:
			for pt in data["police_return_route_pixels"]:
				if pt is Array and pt.size() >= 2:
					parsed_return.append(Vector2(float(pt[0]), float(pt[1])))
		if not parsed_return.is_empty():
			police_return_waypoints.clear()
			police_return_waypoints.append_array(parsed_return)

		# 3. Spook settings
		if data.has("spook_run_settings") and data["spook_run_settings"] is Dictionary:
			var spk: Dictionary = data["spook_run_settings"]
			spook_follow_grid = bool(spk.get("follow_grid", true))
			if spk.has("grid_waypoints") and spk["grid_waypoints"] is Array:
				for pt in spk["grid_waypoints"]:
					if pt is Array and pt.size() >= 2:
						spook_grid_waypoints.append(Vector2(float(pt[0]) * cell_size + cell_size * 0.5, float(pt[1]) * cell_size + cell_size * 0.5))

	_cached_patrol_waypoints.clear()
	_cached_patrol_waypoints.append_array(police_patrol_waypoints)
	_cached_return_waypoints.clear()
	_cached_return_waypoints.append_array(police_return_waypoints)
	_cached_spook_grid_waypoints.clear()
	_cached_spook_grid_waypoints.append_array(spook_grid_waypoints)
	_cached_spook_follow_grid = spook_follow_grid
	_cached_route_config_loaded = true

func _load_all_npc_sprite_sets() -> void:
	sprite_sets[NPCType.BOY]              = _load_sprites_from_folder("res://NPC_Boy/")
	sprite_sets[NPCType.POLICE]           = _load_sprites_from_folder("res://NPC_Police/")
	sprite_sets[NPCType.GIRL]             = _load_sprites_from_folder("res://NPC_Girl/")
	sprite_sets[NPCType.INSPECTOR_MARCUS] = _load_sprites_from_folder("res://NPC_Inspecture/")

func _load_sprites_from_folder(folder_path: String) -> Dictionary:
	var set_dict: Dictionary = {}
	set_dict["front"]       = load(folder_path + "front.png")
	set_dict["front_left"]  = load(folder_path + "front_left.png")
	set_dict["front_right"] = load(folder_path + "front_right.png")
	set_dict["back"]        = load(folder_path + "back.png")
	set_dict["back_left"]   = load(folder_path + "back_left.png")
	set_dict["back_right"]  = load(folder_path + "back_right.png")
	set_dict["left"]        = load(folder_path + "left.png")
	set_dict["left_left"]   = load(folder_path + "left_left.png")
	set_dict["left_right"]  = load(folder_path + "left_right.png")
	set_dict["right"]       = load(folder_path + "right.png")
	set_dict["right_left"]  = load(folder_path + "right_left.png")
	set_dict["right_right"] = load(folder_path + "right_right.png")
	return set_dict

func _build_growtopia_textbox() -> void:
	var root_box = Node2D.new()
	root_box.name = "TextboxRoot"
	root_box.position = Vector2(0, -42)
	root_box.z_index = 20
	add_child(root_box)

	textbox_panel = PanelContainer.new()
	textbox_panel.custom_minimum_size = Vector2(140, 28)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.98, 0.98, 0.98, 0.96)
	style_box.border_color = Color(0.08, 0.08, 0.12, 1.0)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(7)
	style_box.content_margin_left = 10.0
	style_box.content_margin_right = 10.0
	style_box.content_margin_top = 6.0
	style_box.content_margin_bottom = 6.0
	style_box.shadow_color = Color(0, 0, 0, 0.25)
	style_box.shadow_size = 3
	style_box.shadow_offset = Vector2(0, 2)

	textbox_panel.add_theme_stylebox_override("panel", style_box)
	root_box.add_child(textbox_panel)

	textbox_label = Label.new()
	textbox_label.text = ""
	textbox_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	textbox_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	textbox_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	textbox_label.custom_minimum_size = Vector2(130, 0)
	textbox_label.add_theme_color_override("font_color", Color(0.08, 0.08, 0.12))
	textbox_label.add_theme_font_size_override("font_size", 11)
	textbox_panel.add_child(textbox_label)

	# Ekor segitiga penunjuk bubble mengarah ke NPC di bawah bubble (100% di luar bubble)
	textbox_pointer = Polygon2D.new()
	textbox_pointer.polygon = PackedVector2Array([
		Vector2(-7, -8.5), Vector2(7, -8.5), Vector2(0, 0)
	])
	textbox_pointer.color = Color(0.98, 0.98, 0.98, 0.96)
	textbox_pointer.z_index = 1
	root_box.add_child(textbox_pointer)

	textbox_pointer_outline = Line2D.new()
	# Garis miring kiri dan kanan mengarah ke ujung bawah, tanpa garis horizontal atas (agar menyatu dengan bubble)
	textbox_pointer_outline.points = PackedVector2Array([
		Vector2(-7, -7.5), Vector2(0, 0), Vector2(7, -7.5)
	])
	textbox_pointer_outline.width = 2.0
	textbox_pointer_outline.default_color = Color(0.08, 0.08, 0.12, 1.0)
	textbox_pointer_outline.z_index = 2
	root_box.add_child(textbox_pointer_outline)

	textbox_panel.resized.connect(_on_textbox_panel_resized)
	_update_textbox_layout()

	root_box.scale = Vector2.ZERO

func _on_textbox_panel_resized() -> void:
	_update_textbox_layout()

func _update_textbox_layout() -> void:
	if not is_instance_valid(textbox_panel):
		return
	var min_sz = textbox_panel.get_combined_minimum_size()
	var w = maxf(min_sz.x, 140.0)
	var h = maxf(min_sz.y, 28.0)
	textbox_panel.size = Vector2(w, h)
	# Dasar panel selalu tepat berada di atas pangkal segitiga penunjuk (Y = -7.0)
	textbox_panel.position = Vector2(-w * 0.5, -7.0 - h)

func show_chat_bubble(msg: String, duration: float = 2.5) -> void:
	current_text_msg = msg
	if is_instance_valid(textbox_label):
		textbox_label.text = current_text_msg
	_update_textbox_layout()
	msg_display_timer = duration
	is_textbox_visible = true

func _trigger_new_clue_dialogue() -> void:
	var msg_pool: Array
	if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
		msg_pool = SPOOK_CHATS_POLICE if _is_spook_active() else CLUE_MESSAGES_POLICE
	else:
		msg_pool = (SOCIAL_CHATS_CIVILIAN + CLUE_MESSAGES_CIVILIAN) if _is_spook_active() else NORMAL_CHATS_CIVILIAN
	var next_idx = randi() % msg_pool.size()
	if next_idx == last_clue_index:
		next_idx = (next_idx + 1) % msg_pool.size()
	last_clue_index = next_idx

	show_chat_bubble(msg_pool[next_idx], MSG_DISPLAY_DURATION)

var player_stationary_timer: float = 0.0
var spook_freeze_timer: float = 0.0

func _pick_next_destination() -> void:
	if npc_type == NPCType.POLICE:
		if not police_patrol_waypoints.is_empty():
			current_patrol_idx = (current_patrol_idx + 1) % police_patrol_waypoints.size()
			target_destination = police_patrol_waypoints[current_patrol_idx]
	else:
		var candidates = SHARED_DESTINATIONS.duplicate()
		candidates.shuffle()
		for pos in candidates:
			if is_instance_valid(player_ref) and player_stationary_timer >= 3.0:
				if pos.distance_to(player_ref.global_position) < 180.0:
					continue
			if pos.distance_to(global_position) > 120.0:
				target_destination = pos + Vector2(randf_range(-15, 15), randf_range(-15, 15))
				break
		if target_destination == Vector2.ZERO:
			target_destination = candidates[0]

	current_state = State.GO_TO_DESTINATION
	stuck_timer = 0.0
	last_check_pos = global_position

	if is_instance_valid(nav_agent):
		nav_agent.target_position = target_destination

func _physics_process(delta: float) -> void:
	if current_state == State.DESPAWNED:
		return

	if social_cooldown > 0.0:
		social_cooldown -= delta

	if msg_display_timer > 0.0:
		msg_display_timer -= delta
		if msg_display_timer <= 0.0:
			is_textbox_visible = false

	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player_ref):
			player_ref = get_node_or_null("../Player")

	var dist_to_player = 9999.0
	if is_instance_valid(player_ref):
		dist_to_player = global_position.distance_to(player_ref.global_position)
		if player_ref.velocity.length() < 10.0:
			player_stationary_timer += delta
		else:
			player_stationary_timer = 0.0

	# Deteksi Merinding Spook: Pemain harus berada 0.8 detik secara kontinu dalam radius 70px
	if not is_spook_disabled and not is_departing and _is_spook_active() and current_state != State.AFRAID and current_state != State.PANIC_RUN and current_state != State.DESPAWNED:
		if dist_to_player <= SPOOK_RADIUS and social_cooldown <= 0.0:
			player_in_spook_radius_timer += delta
			if player_in_spook_radius_timer >= 0.8:
				# 0.8 detik terpenuhi -> mulai merinding selama 5.0 detik!
				current_state = State.AFRAID
				spook_merinding_timer = 5.0
				player_in_spook_radius_timer = 0.0
				velocity = Vector2.ZERO
				is_moving = false
				if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
					var spk_pool = SPOOK_CHATS_POLICE
					show_chat_bubble(spk_pool[randi() % spk_pool.size()], 4.5)
				else:
					_trigger_new_clue_dialogue()
		else:
			player_in_spook_radius_timer = 0.0

	match current_state:
		State.IDLE:
			_handle_idle_state(delta, dist_to_player)

		State.GO_TO_DESTINATION:
			_handle_travel_state(delta, dist_to_player)

		State.EAVESDROP:
			_handle_eavesdrop_state(delta, dist_to_player)

		State.AFRAID:
			_handle_afraid_state(delta, dist_to_player)

		State.PANIC_RUN:
			_handle_panic_run(delta)

	_animate_textbox_scale(delta)
	queue_redraw()

func _handle_travel_state(delta: float, dist_to_player: float) -> void:
	if is_patrolling_to_station:
		var dist_to_goal = global_position.distance_to(target_destination)
		if dist_to_goal < 38.0:
			current_patrol_idx += 1
			if current_patrol_idx < police_patrol_waypoints.size():
				target_destination = police_patrol_waypoints[current_patrol_idx] + patrol_formation_offset
				if is_instance_valid(nav_agent):
					nav_agent.target_position = target_destination
				if current_patrol_idx == 3 and npc_type == NPCType.INSPECTOR_MARCUS:
					show_chat_bubble("Marcus: Lewat jalan lingkar selatan, ayo bergegas!", 3.0)
				elif current_patrol_idx == 5 and npc_type == NPCType.INSPECTOR_MARCUS:
					show_chat_bubble("Marcus: Stasiun sudah dekat di depan!", 3.0)
			else:
				# Tiba di stasiun!
				is_patrolling_to_station = false
				current_state = State.IDLE
				velocity = Vector2.ZERO
				is_moving = false
				move_dir_facing = Vector2.UP
				if npc_type == NPCType.INSPECTOR_MARCUS:
					show_chat_bubble("Marcus: Kita sudah sampai di depan peron stasiun.", 3.5)
					reached_station.emit()
				return

		tremble_offset = Vector2.ZERO

		var move_dir = (target_destination - global_position).normalized()

		# Anti-stuck watchdog
		if global_position.distance_to(last_check_pos) < STUCK_DIST_MIN:
			stuck_timer += delta
			if stuck_timer > STUCK_THRESHOLD:
				if dist_to_goal < 65.0:
					current_patrol_idx += 1
				else:
					global_position += move_dir * 14.0 + Vector2(randf_range(2.0, 6.0), randf_range(-3.0, 3.0))
				stuck_timer = 0.0
		else:
			stuck_timer = 0.0
			last_check_pos = global_position

		move_dir_facing = move_dir
		is_moving = true
		step_cycle += delta * 4.5
		body_bob_y = abs(sin(step_cycle)) * -1.5
		velocity = move_dir * 78.0
		move_and_slide()
		return

	if is_departing:
		var dist_to_goal = global_position.distance_to(target_destination)
		if dist_to_goal < 38.0:
			current_patrol_idx += 1
			if current_patrol_idx < police_return_waypoints.size():
				target_destination = police_return_waypoints[current_patrol_idx] + patrol_formation_offset
				if is_instance_valid(nav_agent):
					nav_agent.target_position = target_destination
			else:
				is_departing = false
				current_state = State.IDLE
				velocity = Vector2.ZERO
				is_moving = false
				return

		tremble_offset = Vector2.ZERO

		var move_dir = (target_destination - global_position).normalized()

		# Anti-stuck watchdog saat kembali dari stasiun
		if global_position.distance_to(last_check_pos) < STUCK_DIST_MIN:
			stuck_timer += delta
			if stuck_timer > STUCK_THRESHOLD:
				if dist_to_goal < 65.0:
					current_patrol_idx += 1
				else:
					global_position += move_dir * 14.0 + Vector2(randf_range(-6.0, -2.0), randf_range(-3.0, 3.0))
				stuck_timer = 0.0
		else:
			stuck_timer = 0.0
			last_check_pos = global_position

		move_dir_facing = move_dir
		is_moving = true
		step_cycle += delta * 4.5
		body_bob_y = abs(sin(step_cycle)) * -1.5
		velocity = move_dir * 72.0
		move_and_slide()
		return

	var is_civilian: bool = (npc_type == NPCType.BOY or npc_type == NPCType.GIRL)

	if is_civilian and player_stationary_timer < 3.0 and social_cooldown <= 0.0:
		if not _is_spook_active():
			if dist_to_player <= 48.0:
				var normal_pool = NORMAL_CHATS_CIVILIAN
				show_chat_bubble(normal_pool[randi() % normal_pool.size()], 2.5)
				social_cooldown = 6.0

	if social_cooldown <= 0.0:
		_check_for_walking_greeting()

	var is_finished = false
	if is_instance_valid(nav_agent):
		is_finished = nav_agent.is_navigation_finished()
	
	var dist_to_goal = global_position.distance_to(target_destination)
	if is_finished or dist_to_goal < 28.0:
		current_state = State.IDLE
		idle_hangout_timer = randf_range(1.2, 2.5)
		velocity = Vector2.ZERO
		is_moving = false
		return

	var next_pos = target_destination
	if is_instance_valid(nav_agent):
		next_pos = nav_agent.get_next_path_position()

	var move_dir = (next_pos - global_position).normalized()
	if move_dir == Vector2.ZERO:
		move_dir = (target_destination - global_position).normalized()

	if is_instance_valid(player_ref):
		if player_stationary_timer >= 3.0 and dist_to_player < 140.0:
			var steer_away = (global_position - player_ref.global_position).normalized()
			var avoid_factor = clamp((140.0 - dist_to_player) / 140.0, 0.0, 1.0)
			move_dir = (move_dir * (1.0 - avoid_factor) + steer_away * (avoid_factor * 1.6)).normalized()
		elif dist_to_player <= too_close_radius:
			var push_away = (global_position - player_ref.global_position).normalized()
			move_dir = (move_dir * 0.4 + push_away * 0.6).normalized()

	var sep_force = Vector2.ZERO
	var npcs = get_tree().get_nodes_in_group("npcs")
	for other in npcs:
		if other != self and is_instance_valid(other):
			var d = global_position.distance_to(other.global_position)
			if d > 0.1 and d < 42.0:
				sep_force += (global_position - other.global_position).normalized() * (42.0 - d) * 1.5

	move_dir_facing = move_dir
	is_moving = true
	step_cycle += delta * 4.5
	body_bob_y = abs(sin(step_cycle)) * -1.5
	velocity = move_dir * walk_speed + sep_force
	move_and_slide()

	_check_stuck_watchdog(delta)

func _check_stuck_watchdog(delta: float) -> void:
	if is_moving and current_state == State.GO_TO_DESTINATION:
		var moved_dist = global_position.distance_to(last_check_pos)
		if moved_dist < STUCK_DIST_MIN:
			stuck_timer += delta
			if stuck_timer >= STUCK_THRESHOLD:
				_handle_stuck_recovery()
		else:
			stuck_timer = 0.0
			last_check_pos = global_position

func _handle_stuck_recovery() -> void:
	stuck_timer = 0.0
	_pick_next_destination()
	global_position += Vector2(randf_range(-10, 10), randf_range(-10, 10))

func start_patrol(is_partner: bool = false) -> void:
	is_patrolling_to_station = true
	is_departing = false
	current_state = State.GO_TO_DESTINATION
	idle_hangout_timer = 0.0
	current_patrol_idx = 0
	stuck_timer = 0.0
	last_check_pos = global_position
	
	if is_partner:
		patrol_formation_offset = Vector2(14.0, 16.0)
	else:
		patrol_formation_offset = Vector2.ZERO
		# Jika ini Marcus, ajak polisi rekannya (NPC1_Police) untuk ikut bersama
		if npc_type == NPCType.INSPECTOR_MARCUS:
			var partner_found: bool = false
			if is_inside_tree() and get_tree() != null:
				var npcs = get_tree().get_nodes_in_group("npcs")
				for other in npcs:
					if other != self and is_instance_valid(other) and other.get("npc_type") == NPCType.POLICE:
						if other.has_method("start_patrol"):
							other.start_patrol(true)
						partner_found = true
						break
			if not partner_found and get_parent() != null:
				for sibling in get_parent().get_children():
					if sibling != self and is_instance_valid(sibling) and sibling.get("npc_type") == NPCType.POLICE:
						if sibling.has_method("start_patrol"):
							sibling.start_patrol(true)
						break

	if not police_patrol_waypoints.is_empty():
		target_destination = police_patrol_waypoints[0] + patrol_formation_offset
	else:
		target_destination = POLICE_PATROL_WAYPOINTS_DEFAULT[0] + patrol_formation_offset
	if is_instance_valid(nav_agent):
		nav_agent.target_position = target_destination

	if npc_type == NPCType.INSPECTOR_MARCUS:
		show_chat_bubble("Marcus: Ayo bergegas, kita harus segera periksa peron stasiun kereta!", 3.5)
	else:
		show_chat_bubble("Polisi: Siap, Inspektur Marcus! Mengamankan rute stasiun!", 3.5)

func depart_from_station() -> void:
	is_patrolling_to_station = false
	is_departing = true
	is_spook_disabled = true
	spook_merinding_timer = 0.0
	current_state = State.GO_TO_DESTINATION
	current_patrol_idx = 0
	stuck_timer = 0.0
	last_check_pos = global_position

	if not police_return_waypoints.is_empty():
		target_destination = police_return_waypoints[0] + patrol_formation_offset
	else:
		target_destination = POLICE_RETURN_WAYPOINTS_DEFAULT[0] + patrol_formation_offset
	if npc_type == NPCType.INSPECTOR_MARCUS:
		show_chat_bubble("Marcus: Aku harus segera menyusun berkas di kantor.", 3.0)
	else:
		show_chat_bubble("Polisi: Saya akan kembali mengawal rute kantor polisi!", 3.0)

	if is_instance_valid(nav_agent):
		nav_agent.target_position = target_destination

func _handle_idle_state(delta: float, dist_to_player: float) -> void:
	if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
		if is_patrolling_to_station or is_departing:
			return

		tremble_offset = Vector2.ZERO
		velocity = Vector2.ZERO
		is_moving = false

		# Mengobrol berkala santai di depan kantor polisi jika belum patroli
		social_cooldown -= delta
		if social_cooldown <= 0.0:
			var pool = SPOOK_CHATS_POLICE if _is_spook_active() else CLUE_MESSAGES_POLICE
			show_chat_bubble(pool[randi() % pool.size()], 2.8)
			social_cooldown = randf_range(8.0, 14.0)
		return

	if not _is_spook_active():
		if dist_to_player <= 48.0 and social_cooldown <= 0.0 and player_stationary_timer < 3.0:
			var normal_pool = NORMAL_CHATS_CIVILIAN
			show_chat_bubble(normal_pool[randi() % normal_pool.size()], 2.5)
			social_cooldown = 6.0

	if dist_to_player <= too_close_radius:
		_pick_next_destination()
		return

	velocity = Vector2.ZERO
	is_moving = false
	body_bob_y = move_toward(body_bob_y, 0.0, delta * 10.0)
	tremble_offset = Vector2.ZERO

	idle_hangout_timer -= delta
	if idle_hangout_timer <= 0.0:
		_pick_next_destination()

func _check_for_walking_greeting() -> void:
	var npcs = get_tree().get_nodes_in_group("npcs")
	for other in npcs:
		if other != self and is_instance_valid(other):
			if other.current_state == State.GO_TO_DESTINATION:
				var dist = global_position.distance_to(other.global_position)
				if dist < 60.0 and other.social_cooldown <= 0.0:
					var pool: Array
					if npc_type == NPCType.POLICE:
						pool = SOCIAL_CHATS_POLICE
					else:
						pool = SOCIAL_CHATS_CIVILIAN if _is_spook_active() else NORMAL_CHATS_CIVILIAN
					var msg = pool[randi() % pool.size()]
					show_chat_bubble(msg, 2.5)
					social_cooldown = 16.0
					other.social_cooldown = 16.0
					break

func _handle_eavesdrop_state(delta: float, dist_to_player: float) -> void:
	velocity = Vector2.ZERO
	is_moving = false
	tremble_offset = Vector2(randf_range(-1.2, 1.2), randf_range(-1.2, 1.2))
	spook_freeze_timer -= delta
	if spook_freeze_timer <= 0.0 or player_stationary_timer >= 3.0 or dist_to_player > eavesdrop_radius + 20.0:
		current_state = State.GO_TO_DESTINATION
		tremble_offset = Vector2.ZERO
		_pick_next_destination()

func _handle_afraid_state(delta: float, dist_to_player: float) -> void:
	velocity = Vector2.ZERO
	is_moving = false

	# Jika saat mereka merinding pemain menjauh / lari (jarak melebihi radius merinding + toleransi),
	# NPC kembali tenang dan TIDAK JADI LARI!
	if dist_to_player > (SPOOK_RADIUS + 25.0):
		tremble_offset = Vector2.ZERO
		spook_merinding_timer = 0.0
		player_in_spook_radius_timer = 0.0
		social_cooldown = 5.0
		if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
			if is_patrolling_to_station:
				current_state = State.GO_TO_DESTINATION
				if npc_type == NPCType.INSPECTOR_MARCUS:
					show_chat_bubble("Marcus: ...Fyuuh, hawa dinginnya mereda. Ayo lanjut jalan!", 2.5)
				else:
					show_chat_bubble("Polisi: ...Hawa dinginnya menjauh. Ayo tetap waspada!", 2.5)
			else:
				current_state = State.IDLE
		else:
			current_state = State.GO_TO_DESTINATION
			show_chat_bubble("...Eh? Bulu kudukku normal lagi. Tadi ada apa ya?", 2.5)
			_pick_next_destination()
		return

	# Pemain masih menempel dekat: getaran merinding terus berjalan
	tremble_offset = Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	spook_merinding_timer -= delta

	if spook_merinding_timer <= 0.0:
		# Setelah merinding dan pemain tetap menempel terus sampai habis waktu, baru lari ketakutan!
		current_state = State.PANIC_RUN
		run_timer = 3.5
		current_text_msg = PANIC_MESSAGES[randi() % PANIC_MESSAGES.size()]
		show_chat_bubble(current_text_msg, 2.5)

		panic_grid_path.clear()
		panic_grid_idx = 0
		var p_pos = player_ref.global_position if is_instance_valid(player_ref) else global_position

		# Kumpulkan kandidat titik grid di sekitar NPC
		var candidates: Array[Vector2] = []
		candidates.append_array(spook_grid_waypoints)
		candidates.append_array(police_patrol_waypoints)
		candidates.append_array(police_return_waypoints)

		if spook_follow_grid and not candidates.is_empty():
			var nearby_pts: Array[Vector2] = []
			for pt in candidates:
				var d_npc = global_position.distance_to(pt)
				if d_npc > 14.0 and d_npc < 500.0:
					nearby_pts.append(pt)

			if not nearby_pts.is_empty():
				# Prioritaskan titik yang memaksimalkan jarak dari player (lari menjauh di sepanjang grid)
				nearby_pts.sort_custom(func(a: Vector2, b: Vector2) -> bool:
					var score_a = a.distance_to(p_pos) - global_position.distance_to(a) * 0.35
					var score_b = b.distance_to(p_pos) - global_position.distance_to(b) * 0.35
					return score_a > score_b
				)
				for i in range(mini(3, nearby_pts.size())):
					panic_grid_path.append(nearby_pts[i])

		if is_instance_valid(player_ref):
			run_direction = (global_position - player_ref.global_position).normalized()
			if run_direction == Vector2.ZERO:
				run_direction = Vector2.RIGHT
		else:
			run_direction = Vector2.RIGHT

		npc_spook_fled.emit(self)

func _handle_panic_run(delta: float) -> void:
	run_timer -= delta
	var fast_run_speed: float = 180.0
	var move_dir = run_direction

	# Navigasi menyusuri waypoint grid jalan kota jika tersedia
	if not panic_grid_path.is_empty() and panic_grid_idx < panic_grid_path.size():
		var target_pt = panic_grid_path[panic_grid_idx]
		if global_position.distance_to(target_pt) < 32.0:
			panic_grid_idx += 1
			if panic_grid_idx < panic_grid_path.size():
				target_pt = panic_grid_path[panic_grid_idx]
		var steer = (target_pt - global_position).normalized()
		if steer != Vector2.ZERO:
			move_dir = steer

	velocity = move_dir * fast_run_speed
	move_dir_facing = move_dir
	is_moving = true
	move_and_slide()
	step_cycle += delta * 14.0
	body_bob_y = abs(sin(step_cycle)) * -3.0
	tremble_offset = Vector2(randf_range(-1.2, 1.2), randf_range(-1.2, 1.2))

	if run_timer <= 0.0:
		# Tidak sampai hilang dari map! Lari menjauh lalu kembali tenang / jalan normal
		current_state = State.GO_TO_DESTINATION
		tremble_offset = Vector2.ZERO
		is_moving = false
		social_cooldown = 8.0
		player_in_spook_radius_timer = 0.0
		panic_grid_path.clear()
		_pick_next_destination()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode in [KEY_F, KEY_E, KEY_SPACE]:
			if not is_instance_valid(player_ref) or global_position.distance_to(player_ref.global_position) > 68.0:
				return

			if npc_type == NPCType.POLICE or npc_type == NPCType.INSPECTOR_MARCUS:
				if _is_spook_active():
					current_state = State.AFRAID
					spook_merinding_timer = 5.0
					player_in_spook_radius_timer = 0.0
					velocity = Vector2.ZERO
					is_moving = false
					var pool = SPOOK_CHATS_POLICE
					show_chat_bubble(pool[randi() % pool.size()], 4.5)
					social_cooldown = 6.0
				else:
					var pool = CLUE_MESSAGES_POLICE
					show_chat_bubble(pool[randi() % pool.size()], 2.8)
					social_cooldown = 4.0
				return

			# Civilian
			if _is_spook_active():
				current_state = State.AFRAID
				spook_merinding_timer = 5.0
				player_in_spook_radius_timer = 0.0
				velocity = Vector2.ZERO
				is_moving = false
				_trigger_new_clue_dialogue()
				social_cooldown = 6.0
			else:
				var normal_pool = NORMAL_CHATS_CIVILIAN
				show_chat_bubble(normal_pool[randi() % normal_pool.size()], 2.5)
				social_cooldown = 4.0

func _animate_textbox_scale(delta: float) -> void:
	var target_scale = 1.0 if is_textbox_visible else 0.0
	textbox_scale = move_toward(textbox_scale, target_scale, delta * 9.0)

	var tb_root = get_node_or_null("TextboxRoot")
	if is_instance_valid(tb_root):
		tb_root.scale = Vector2(textbox_scale, textbox_scale)

func _get_current_npc_sprite() -> Texture2D:
	var cur_set = sprite_sets.get(npc_type)
	if cur_set == null or cur_set.is_empty():
		return null

	var move_dir = velocity.normalized()
	if not is_moving or move_dir == Vector2.ZERO:
		move_dir = move_dir_facing.normalized()
	if move_dir == Vector2.ZERO:
		move_dir = Vector2.DOWN

	var is_horizontal = abs(move_dir.x) > abs(move_dir.y)
	var idle_key: String
	var step_l_key: String
	var step_r_key: String

	if is_horizontal:
		if move_dir.x < 0:
			idle_key   = "left"
			step_l_key = "left_left"
			step_r_key = "left_right"
		else:
			idle_key   = "right"
			step_l_key = "right_left"
			step_r_key = "right_right"
	else:
		if move_dir.y < 0:
			idle_key   = "back"
			step_l_key = "back_left"
			step_r_key = "back_right"
		else:
			idle_key   = "front"
			step_l_key = "front_left"
			step_r_key = "front_right"

	if not is_moving:
		return cur_set.get(idle_key)

	var anim_phase = fmod(step_cycle, 1.0)
	if anim_phase < 0.25:
		return cur_set.get(idle_key)
	elif anim_phase < 0.50:
		return cur_set.get(step_l_key)
	elif anim_phase < 0.75:
		return cur_set.get(idle_key)
	else:
		return cur_set.get(step_r_key)

func _draw() -> void:
	if current_state == State.DESPAWNED:
		return

	var draw_pos = tremble_offset

	draw_set_transform(draw_pos, 0.0, Vector2(1.0, 0.45))
	draw_circle(Vector2(0, 6), 7.5, Color(0, 0, 0, 0.32))
	draw_set_transform(draw_pos, 0.0, Vector2.ONE)

	var cur_tex = _get_current_npc_sprite()
	if is_instance_valid(cur_tex):
		var size = cur_tex.get_size()
		var calculated_scale = target_height_px / max(size.y, 1.0)
		
		draw_set_transform(draw_pos, 0.0, Vector2(calculated_scale, calculated_scale))
		var draw_offset = Vector2(-size.x / 2.0, -size.y + 8.0)
		draw_texture(cur_tex, draw_offset)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
