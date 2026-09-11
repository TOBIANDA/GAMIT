extends Node2D

# ==============================================================================
# INTERIOR RUMAH BENEDICT & SISTEM PENGATURAN PERABOT (FURNITURE SYSTEM)
# ==============================================================================

# Koordinat penempatan interior rumah di world space
const ROOM_ORIGIN := Vector2(3600.0, 400.0)
const ROOM_SIZE := Vector2(460.0, 300.0)

# Titik-titik penting di dalam rumah (Studio Detektif Kompak)
const ENTRANCE_POS := Vector2(3600.0 + 85.0, 400.0 + 245.0)
const EXIT_DOOR_POS := Vector2(3600.0 + 85.0, 400.0 + 280.0)
const STAIRS_POS := Vector2(3600.0 + 415.0, 400.0 + 215.0)

const CONFIG_FILE_PATH := "res://data/house_furniture.json"
const USER_CONFIG_FILE_PATH := "user://house_furniture.json"

# ==============================================================================
#  PENGATURAN DEFAULT POSISI & SKALA BARANG-BARANG (BISA DIEDIT DI SINI)
# Posisi (x, y) dihitung relatif dari sudut kiri-atas ruangan (0, 0) sampai (660, 420)
# ==============================================================================
var default_furniture_config: Dictionary = {
	# --- 1. RUANG TAMU ---
	"sofa_panjang": {
		"name": "Sofa Tamu Hijau",
		"type": "sprite",
		"tex": "tex_sofa_panjang",
		"x": 65.0, "y": 75.0,
		"scale": 1.0,
		"base_w": 65.0,
		"has_col": true,
		"col_w": 65.0, "col_h": 30.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"sofa_kecil": {
		"name": "Armchair Tamu",
		"type": "sprite",
		"tex": "tex_sofa_kecil",
		"x": 42.0, "y": 145.0,
		"scale": 1.0,
		"base_w": 24.0,
		"has_col": true,
		"col_w": 26.0, "col_h": 26.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"meja_panjang": {
		"name": "Meja Kopi Ruang Tamu",
		"type": "sprite",
		"tex": "tex_meja_panjang",
		"x": 65.0, "y": 110.0,
		"scale": 1.0,
		"base_w": 40.0,
		"has_col": true,
		"col_w": 40.0, "col_h": 24.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"karpet_tamu": {
		"name": "Karpet Ruang Tamu",
		"type": "sprite",
		"tex": "tex_karpet",
		"x": 65.0, "y": 110.0,
		"scale": 1.0,
		"base_w": 75.0,
		"has_col": false,
		"z_idx": -1
	},
	"meja_sudut_tamu": {
		"name": "Meja Hias / Vas Bunga",
		"type": "sprite",
		"tex": "tex_laci",
		"x": 32.0, "y": 48.0,
		"scale": 1.0,
		"base_w": 22.0,
		"has_col": true,
		"col_w": 22.0, "col_h": 22.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"partisi_tamu": {
		"name": "Partisi Garis Tiang",
		"type": "drawn",
		"draw_type": "partisi",
		"x": 125.0, "y": 110.0,
		"scale": 1.0,
		"base_w": 10.0,
		"base_h": 90.0,
		"has_col": true,
		"col_w": 10.0, "col_h": 90.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},

	# --- 2. RUANG KERJA ---
	"meja_detektif": {
		"name": "Meja Kerja Detektif",
		"type": "sprite",
		"tex": "tex_meja_detektif",
		"x": 195.0, "y": 72.0,
		"scale": 1.0,
		"base_w": 75.0,
		"has_col": true,
		"col_w": 75.0, "col_h": 42.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"kursi_detektif": {
		"name": "Kursi Kerja Detektif",
		"type": "drawn",
		"draw_type": "kursi",
		"x": 195.0, "y": 48.0,
		"scale": 1.0,
		"base_w": 24.0,
		"base_h": 8.0,
		"has_col": false,
		"z_idx": 0
	},
	"brankas": {
		"name": "Brankas Baja Keluarga",
		"type": "sprite",
		"tex": "tex_berangkas",
		"x": 150.0, "y": 52.0,
		"scale": 1.0,
		"base_w": 28.0,
		"has_col": true,
		"col_w": 28.0, "col_h": 28.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"surat": {
		"name": "Surat Penugasan di Meja",
		"type": "sprite",
		"tex": "tex_surat",
		"x": 195.0, "y": 72.0,
		"scale": 1.0,
		"base_w": 18.0,
		"has_col": false,
		"z_idx": 0
	},

	# --- 3. KAMAR TIDUR ---
	"bed": {
		"name": "Ranjang Tidur (Bed)",
		"type": "sprite",
		"tex": "tex_bed",
		"x": 310.0, "y": 72.0,
		"scale": 1.1,
		"base_w": 46.0,
		"has_col": true,
		"col_w": 46.0, "col_h": 52.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"nakas_kamar": {
		"name": "Nakas Samping Kasur",
		"type": "sprite",
		"tex": "tex_laci",
		"x": 355.0, "y": 56.0,
		"scale": 1.0,
		"base_w": 22.0,
		"has_col": true,
		"col_w": 22.0, "col_h": 22.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"lemari": {
		"name": "Lemari Pakaian Kayu",
		"type": "sprite",
		"tex": "tex_lemari",
		"x": 405.0, "y": 68.0,
		"scale": 1.2,
		"base_w": 44.0,
		"has_col": true,
		"col_w": 48.0, "col_h": 52.0,
		"col_off_x": 0.0, "col_y_off": 8.0,
		"z_idx": 0
	},
	"karpet_kamar": {
		"name": "Karpet Kamar Tidur",
		"type": "sprite",
		"tex": "tex_karpet_kamar",
		"x": 310.0, "y": 110.0,
		"scale": 1.0,
		"base_w": 50.0,
		"has_col": false,
		"z_idx": -1
	},

	# --- 4. DAPUR & LAB CUCI FOTO ---
	"set_masak": {
		"name": "Set Masak / Meja Dapur",
		"type": "sprite",
		"tex": "tex_set_masak",
		"x": 325.0, "y": 245.0,
		"scale": 1.0,
		"base_w": 65.0,
		"has_col": true,
		"col_w": 65.0, "col_h": 44.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"kulkas": {
		"name": "Kulkas Dapur",
		"type": "sprite",
		"tex": "tex_kulkas",
		"x": 368.0, "y": 245.0,
		"scale": 1.0,
		"base_w": 30.0,
		"has_col": true,
		"col_w": 30.0, "col_h": 44.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"meja_lab_foto": {
		"name": "Meja Lab Cuci Foto",
		"type": "sprite",
		"tex": "tex_meja_lab_foto",
		"x": 255.0, "y": 245.0,
		"scale": 1.0,
		"base_w": 48.0,
		"has_col": true,
		"col_w": 48.0, "col_h": 40.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"baskom_foto": {
		"name": "Baskom Cuci Foto",
		"type": "sprite",
		"tex": "tex_baskom",
		"x": 255.0, "y": 243.0,
		"scale": 1.0,
		"base_w": 26.0,
		"has_col": false,
		"z_idx": 0
	},

	# --- 5. LAIN-LAIN ---
	"keset_pintu": {
		"name": "Keset Pintu Keluar",
		"type": "drawn",
		"draw_type": "keset",
		"x": 85.0, "y": 280.0,
		"scale": 1.0,
		"base_w": 40.0,
		"base_h": 14.0,
		"has_col": false,
		"z_idx": 0
	}
}

var furniture_config: Dictionary = {}
var furniture_sprites: Dictionary = {}
var furniture_colliders: Dictionary = {}

# Aset Tekstur
var tex_sofa_panjang: Texture2D
var tex_sofa_kecil: Texture2D
var tex_meja_panjang: Texture2D
var tex_karpet: Texture2D
var tex_meja_detektif: Texture2D
var tex_kitchen_unit: Texture2D
var tex_set_masak: Texture2D
var tex_kulkas: Texture2D
var tex_meja_lab_foto: Texture2D
var tex_bed: Texture2D
var tex_lemari: Texture2D
var tex_laci: Texture2D
var tex_karpet_kamar: Texture2D
var tex_surat: Texture2D
var tex_berangkas: Texture2D
var tex_baskom: Texture2D

var letter_glow_time: float = 0.0
var sprite_letter: Sprite2D
var static_body: StaticBody2D

# State In-Game Furniture Editor
var is_edit_mode: bool = false
var selected_furniture_id: String = ""
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var editor_layer: CanvasLayer
var edit_toggle_btn: Button
var editor_panel: PanelContainer
var item_dropdown: OptionButton
var slider_pos_x: HSlider
var spin_pos_x: SpinBox
var slider_pos_y: HSlider
var spin_pos_y: SpinBox
var slider_scale: HSlider
var spin_scale: SpinBox
var status_msg_label: Label
var _is_updating_ui: bool = false

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_load_textures()
	_init_furniture_data()
	_build_room_collisions()
	_setup_furniture_nodes()
	_setup_editor_ui()

func _init_furniture_data() -> void:
	furniture_config = default_furniture_config.duplicate(true)
	_load_furniture_config()

func _load_textures() -> void:
	tex_sofa_panjang = load("res://Environment/ruang tamu/sofaPanjang.png")
	tex_sofa_kecil = load("res://Environment/ruang tamu/sofaKecilSamping.png")
	tex_meja_panjang = load("res://Environment/ruang tamu/mejaPanjang.png")
	tex_karpet = load("res://Environment/ruang tamu/karpet.png")
	tex_meja_detektif = load("res://Environment/ruang tamu/meja_detektif.png")
	tex_kitchen_unit = load("res://Environment/dapur/kitchen_unit.png")
	tex_set_masak = load("res://Environment/dapur/set_masak_unit.png")
	tex_kulkas = load("res://Environment/dapur/kulkas_unit.png")
	tex_meja_lab_foto = load("res://Environment/dapur/meja_lab_foto.png")
	tex_bed = load("res://Environment/kamar/bed.png")
	tex_lemari = load("res://Environment/kamar/lemari.png")
	tex_laci = load("res://Environment/kamar/laci.png")
	tex_karpet_kamar = load("res://Environment/kamar/karpet.png")
	tex_surat = load("res://Environment/interactable assets/surat.png")
	tex_berangkas = load("res://Environment/interactable assets/berangkas.png")
	tex_baskom = load("res://Environment/interactable assets/baskom cetak photo.png")

func _get_texture_by_name(tex_name: String) -> Texture2D:
	match tex_name:
		"tex_sofa_panjang": return tex_sofa_panjang
		"tex_sofa_kecil": return tex_sofa_kecil
		"tex_meja_panjang": return tex_meja_panjang
		"tex_karpet": return tex_karpet
		"tex_meja_detektif": return tex_meja_detektif
		"tex_kitchen_unit": return tex_kitchen_unit
		"tex_set_masak": return tex_set_masak
		"tex_kulkas": return tex_kulkas
		"tex_meja_lab_foto": return tex_meja_lab_foto
		"tex_bed": return tex_bed
		"tex_lemari": return tex_lemari
		"tex_laci": return tex_laci
		"tex_karpet_kamar": return tex_karpet_kamar
		"tex_surat": return tex_surat
		"tex_berangkas": return tex_berangkas
		"tex_baskom": return tex_baskom
	return null

func _build_room_collisions() -> void:
	static_body = StaticBody2D.new()
	static_body.name = "HouseInteriorCollisions"
	static_body.collision_layer = 1
	static_body.collision_mask = 0
	add_child(static_body)

	# 1. DINDING KELILING LUAR (OUTER WALLS)
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 32.0))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, 60.0, 16.0))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 115.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, ROOM_SIZE.x - 115.0, 16.0))

	# 2. DINDING SEKAT RUANG KERJA & KAMAR
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 125.0, ROOM_ORIGIN.y + 32.0, 10.0, 85.0))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 265.0, ROOM_ORIGIN.y + 32.0, 10.0, 140.0))

	# 3. DINDING SEKAT DAPUR
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 220.0, ROOM_ORIGIN.y + 195.0, 10.0, 85.0))

func _add_box_collider(body: StaticBody2D, rect: Rect2) -> CollisionShape2D:
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.position + rect.size * 0.5
	body.add_child(col)
	return col

func _setup_furniture_nodes() -> void:
	for id in furniture_config.keys():
		var data = furniture_config[id]
		var item_type = data.get("type", "sprite")

		if item_type == "sprite":
			var tex_name = data.get("tex", "")
			var tex = _get_texture_by_name(tex_name)
			if is_instance_valid(tex):
				var sp = Sprite2D.new()
				sp.name = "Furniture_" + id
				sp.texture = tex
				sp.z_index = data.get("z_idx", 0)
				add_child(sp)
				furniture_sprites[id] = sp
				if id == "surat":
					sprite_letter = sp

		if data.get("has_col", false):
			var col = CollisionShape2D.new()
			col.name = "Col_" + id
			var shape = RectangleShape2D.new()
			col.shape = shape
			static_body.add_child(col)
			furniture_colliders[id] = col

		update_furniture_transform(id)

func update_furniture_transform(id: String) -> void:
	if not furniture_config.has(id):
		return
	var data = furniture_config[id]
	var world_pos = ROOM_ORIGIN + Vector2(float(data.x), float(data.y))
	var s = float(data.scale)

	if furniture_sprites.has(id):
		var sp = furniture_sprites[id]
		sp.position = world_pos
		var tex = sp.texture
		if tex:
			var base_w = float(data.get("base_w", 40.0))
			var ratio = (base_w * s) / float(tex.get_width())
			sp.scale = Vector2(ratio, ratio)

	if furniture_colliders.has(id):
		var col = furniture_colliders[id]
		var shape = col.shape as RectangleShape2D
		if shape:
			var cw = float(data.get("col_w", 30.0)) * s
			var ch = float(data.get("col_h", 30.0)) * s
			shape.size = Vector2(cw, ch)
			var off_x = float(data.get("col_off_x", 0.0)) * s
			var off_y = float(data.get("col_y_off", 0.0)) * s
			col.position = world_pos + Vector2(off_x, off_y)

	queue_redraw()

func _load_furniture_config() -> void:
	var path_to_load = ""
	if FileAccess.file_exists(CONFIG_FILE_PATH):
		path_to_load = CONFIG_FILE_PATH
	elif FileAccess.file_exists(USER_CONFIG_FILE_PATH):
		path_to_load = USER_CONFIG_FILE_PATH

	if not path_to_load.is_empty():
		var file = FileAccess.open(path_to_load, FileAccess.READ)
		if file:
			var json_str = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(json_str)
			if parsed is Dictionary:
				_apply_config_dict(parsed)

	if FileAccess.file_exists(USER_CONFIG_FILE_PATH) and path_to_load != USER_CONFIG_FILE_PATH:
		var u_file = FileAccess.open(USER_CONFIG_FILE_PATH, FileAccess.READ)
		if u_file:
			var u_str = u_file.get_as_text()
			u_file.close()
			var u_parsed = JSON.parse_string(u_str)
			if u_parsed is Dictionary:
				_apply_config_dict(u_parsed)

func _apply_config_dict(parsed: Dictionary) -> void:
	# Migrasi kitchen_unit lama jika ada
	if parsed.has("kitchen_unit") and not parsed.has("set_masak"):
		var ku = parsed["kitchen_unit"]
		var kx = float(ku.get("x", 433.0))
		var ky = float(ku.get("y", 323.0))
		var ks = float(ku.get("scale", 1.0))
		if furniture_config.has("set_masak"):
			furniture_config["set_masak"]["x"] = kx - 21.0 * ks
			furniture_config["set_masak"]["y"] = ky
			furniture_config["set_masak"]["scale"] = ks
		if furniture_config.has("kulkas"):
			furniture_config["kulkas"]["x"] = kx + 25.0 * ks
			furniture_config["kulkas"]["y"] = ky
			furniture_config["kulkas"]["scale"] = ks

	for id in parsed.keys():
		if furniture_config.has(id):
			var item = parsed[id]
			if item.has("x"): furniture_config[id]["x"] = float(item["x"])
			if item.has("y"): furniture_config[id]["y"] = float(item["y"])
			if item.has("scale"): furniture_config[id]["scale"] = float(item["scale"])

func save_furniture_config() -> void:
	var save_dict: Dictionary = {}
	for id in furniture_config.keys():
		var item = furniture_config[id]
		save_dict[id] = {
			"name": item.get("name", id),
			"x": float(item["x"]),
			"y": float(item["y"]),
			"scale": float(item["scale"])
		}
	var json_str = JSON.stringify(save_dict, "\t")

	var dir = DirAccess.open("res://")
	if dir and not dir.dir_exists("data"):
		dir.make_dir("data")

	var file_res = FileAccess.open(CONFIG_FILE_PATH, FileAccess.WRITE)
	if file_res:
		file_res.store_string(json_str)
		file_res.close()

	var file_user = FileAccess.open(USER_CONFIG_FILE_PATH, FileAccess.WRITE)
	if file_user:
		file_user.store_string(json_str)
		file_user.close()

	print("\n=== [HouseInterior] Data Perabot Tersimpan ===")
	for id in furniture_config.keys():
		var it = furniture_config[id]
		print('\t"%s": { "x": %.1f, "y": %.1f, "scale": %.2f },' % [id, it.x, it.y, it.scale])
	print("================================================\n")

func reset_to_default_config() -> void:
	furniture_config = default_furniture_config.duplicate(true)
	for id in furniture_config.keys():
		update_furniture_transform(id)
	save_furniture_config()
	_sync_ui_to_selected_item()

# Getter posisi POI untuk interaksi gameplay
func get_desk_letter_pos() -> Vector2:
	if furniture_config.has("meja_detektif"):
		return ROOM_ORIGIN + Vector2(furniture_config["meja_detektif"].x, furniture_config["meja_detektif"].y)
	return ROOM_ORIGIN + Vector2(195.0, 72.0)

func get_safe_pos() -> Vector2:
	if furniture_config.has("brankas"):
		return ROOM_ORIGIN + Vector2(furniture_config["brankas"].x, furniture_config["brankas"].y)
	return ROOM_ORIGIN + Vector2(150.0, 52.0)

func get_photo_basin_pos() -> Vector2:
	if furniture_config.has("meja_lab_foto"):
		return ROOM_ORIGIN + Vector2(furniture_config["meja_lab_foto"].x, furniture_config["meja_lab_foto"].y)
	return ROOM_ORIGIN + Vector2(255.0, 245.0)

func get_stairs_pos() -> Vector2:
	return STAIRS_POS

func get_exit_door_pos() -> Vector2:
	return EXIT_DOOR_POS

func _process(delta: float) -> void:
	letter_glow_time += delta * 3.5
	if is_instance_valid(sprite_letter) and tex_surat and tex_meja_detektif:
		var s_data = furniture_config.get("surat", {})
		var base_s = float(s_data.get("scale", 1.0)) * (18.0 / tex_surat.get_width())
		var s = base_s * (1.0 + 0.05 * sin(letter_glow_time))
		sprite_letter.scale = Vector2(s, s)
	queue_redraw()

func _draw() -> void:
	# 1. LANTAI DASAR PARQUET KAYU
	var floor_rect = Rect2(ROOM_ORIGIN.x + 16.0, ROOM_ORIGIN.y + 32.0, ROOM_SIZE.x - 32.0, ROOM_SIZE.y - 48.0)
	draw_rect(floor_rect, Color(0.20, 0.16, 0.12), true)

	var plank_h: float = 16.0
	var curr_y: float = floor_rect.position.y
	while curr_y < floor_rect.end.y:
		draw_line(Vector2(floor_rect.position.x, curr_y), Vector2(floor_rect.end.x, curr_y), Color(0.15, 0.11, 0.08, 0.45), 1.0)
		curr_y += plank_h

	# 2. LANTAI KERAMIK DAPUR
	var tile_size: float = 16.0
	var kx_start = ROOM_ORIGIN.x + 225.0
	var kx_end = ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0
	var ky_start = ROOM_ORIGIN.y + 195.0
	var ky_end = ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0

	var tx = kx_start
	while tx < kx_end:
		var ty = ky_start
		while ty < ky_end:
			var is_alt = int(floor((tx - kx_start) / tile_size) + floor((ty - ky_start) / tile_size)) % 2 == 0
			var tile_col = Color(0.25, 0.23, 0.22) if is_alt else Color(0.19, 0.18, 0.17)
			draw_rect(Rect2(tx, ty, tile_size, tile_size), tile_col, true)
			draw_rect(Rect2(tx, ty, tile_size, tile_size), Color(0.14, 0.13, 0.12), false, 0.8)
			ty += tile_size
		tx += tile_size

	# 3. KOTAK ANAK TANGGA (Menuju loteng/ruang arsip)
	var st_rect = Rect2(ROOM_ORIGIN.x + 395.0, ROOM_ORIGIN.y + 185.0, 45.0, 75.0)
	draw_rect(st_rect, Color(0.16, 0.12, 0.09), true)

	var step_count = 6
	var step_h = st_rect.size.y / step_count
	for i in range(step_count):
		var sy = st_rect.position.y + i * step_h
		var step_col = Color(0.28 - i * 0.015, 0.20 - i * 0.01, 0.14 - i * 0.008)
		draw_rect(Rect2(st_rect.position.x, sy, st_rect.size.x, step_h), step_col, true)
		draw_line(Vector2(st_rect.position.x, sy), Vector2(st_rect.end.x, sy), Color(0.38, 0.28, 0.20), 1.5)
		draw_line(Vector2(st_rect.position.x, sy + step_h - 1), Vector2(st_rect.end.x, sy + step_h - 1), Color(0.10, 0.07, 0.05), 1.0)

	var x_center = Vector2(ROOM_ORIGIN.x + 417.0, ROOM_ORIGIN.y + 180.0)
	draw_line(x_center + Vector2(-5, -5), x_center + Vector2(5, 5), Color(0.9, 0.2, 0.2), 2.0)
	draw_line(x_center + Vector2(-5, 5), x_center + Vector2(5, -5), Color(0.9, 0.2, 0.2), 2.0)
	draw_line(Vector2(st_rect.position.x + 2, st_rect.position.y), Vector2(st_rect.position.x + 2, st_rect.end.y), Color(0.48, 0.35, 0.24), 2.0)

	# 4. DINDING LUAR BANGUNAN (WALLS)
	var wall_col = Color(0.12, 0.10, 0.14)
	var trim_col = Color(0.34, 0.26, 0.20)

	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 32.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + 32.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + 32.0), trim_col, 2.0)

	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + 16.0, ROOM_ORIGIN.y), Vector2(ROOM_ORIGIN.x + 16.0, ROOM_ORIGIN.y + ROOM_SIZE.y), trim_col, 2.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y + ROOM_SIZE.y), trim_col, 2.0)

	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, 60.0, 16.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0), Vector2(ROOM_ORIGIN.x + 60.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0), trim_col, 2.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + 115.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, ROOM_SIZE.x - 115.0, 16.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + 115.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0), trim_col, 2.0)

	# 5. DINDING SEKAT RUANGAN
	draw_rect(Rect2(ROOM_ORIGIN.x + 125.0, ROOM_ORIGIN.y + 32.0, 8.0, 85.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 125.0, ROOM_ORIGIN.y + 32.0, 8.0, 85.0), trim_col, false, 1.0)

	draw_rect(Rect2(ROOM_ORIGIN.x + 265.0, ROOM_ORIGIN.y + 32.0, 8.0, 140.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 265.0, ROOM_ORIGIN.y + 32.0, 8.0, 140.0), trim_col, false, 1.0)

	draw_rect(Rect2(ROOM_ORIGIN.x + 220.0, ROOM_ORIGIN.y + 195.0, 8.0, 85.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 220.0, ROOM_ORIGIN.y + 195.0, 8.0, 85.0), trim_col, false, 1.0)

	# 6. ELEMEN INTERIOR YANG DIGAMBAR SESUAI POSISI & SKALA DARI CONFIG
	# a. Partisi Garis Tiang Ruang Tamu
	if furniture_config.has("partisi_tamu"):
		var p_data = furniture_config["partisi_tamu"]
		var px = ROOM_ORIGIN.x + float(p_data.x)
		var py = ROOM_ORIGIN.y + float(p_data.y)
		var ps = float(p_data.scale)
		var half_h = (55.0 * ps)
		draw_line(Vector2(px, py - half_h), Vector2(px, py + half_h), Color(0.40, 0.30, 0.22, 0.8), 3.0 * ps)
		draw_circle(Vector2(px, py - half_h), 3.0 * ps, Color(0.55, 0.42, 0.30))
		draw_circle(Vector2(px, py + half_h), 3.0 * ps, Color(0.55, 0.42, 0.30))

	# b. Kursi Detektif
	if furniture_config.has("kursi_detektif"):
		var kd = furniture_config["kursi_detektif"]
		var kx = ROOM_ORIGIN.x + float(kd.x)
		var ky = ROOM_ORIGIN.y + float(kd.y)
		var ks = float(kd.scale)
		draw_rect(Rect2(kx - 12.0 * ks, ky - 4.0 * ks, 24.0 * ks, 8.0 * ks), Color(0.20, 0.13, 0.08), true)
		draw_rect(Rect2(kx - 12.0 * ks, ky - 4.0 * ks, 24.0 * ks, 8.0 * ks), Color(0.32, 0.20, 0.12), false, 1.0)

	# c. Keset Pintu Keluar
	if furniture_config.has("keset_pintu"):
		var kp = furniture_config["keset_pintu"]
		var kpx = ROOM_ORIGIN.x + float(kp.x)
		var kpy = ROOM_ORIGIN.y + float(kp.y)
		var kps = float(kp.scale)
		var mat_rect = Rect2(kpx - 25.0 * kps, kpy - 8.0 * kps, 50.0 * kps, 16.0 * kps)
		draw_rect(mat_rect, Color(0.50, 0.16, 0.16), true)
		draw_rect(mat_rect, Color(0.70, 0.26, 0.24), false, 1.5)

	# d. Efek Sorot Cahaya Meja Kerja Hangat di sekitar surat
	var desk_pos = get_desk_letter_pos()
	var desk_scale = float(furniture_config.get("meja_detektif", {}).get("scale", 1.0))
	var glow_alpha = 0.22 + 0.08 * sin(letter_glow_time)
	draw_circle(desk_pos, 18.0 * desk_scale, Color(1.0, 0.90, 0.45, glow_alpha))

	# 7. SELECTION HIGHLIGHT SAAT MODE EDIT AKTIF
	if is_edit_mode and not selected_furniture_id.is_empty() and furniture_config.has(selected_furniture_id):
		var item = furniture_config[selected_furniture_id]
		var ipos = ROOM_ORIGIN + Vector2(float(item.x), float(item.y))
		var iscale = float(item.scale)
		var iw = float(item.get("col_w", item.get("base_w", 40.0))) * iscale
		var ih = float(item.get("col_h", item.get("base_h", item.get("base_w", 40.0)))) * iscale
		var irect = Rect2(ipos.x - iw * 0.5 - 6, ipos.y - ih * 0.5 - 6, iw + 12, ih + 12)
		draw_rect(irect, Color(0.2, 0.95, 1.0, 0.85), false, 2.0)
		draw_circle(irect.position, 4.0, Color(0.2, 0.95, 1.0))
		draw_circle(Vector2(irect.end.x, irect.position.y), 4.0, Color(0.2, 0.95, 1.0))
		draw_circle(Vector2(irect.position.x, irect.end.y), 4.0, Color(0.2, 0.95, 1.0))
		draw_circle(irect.end, 4.0, Color(0.2, 0.95, 1.0))

# ==============================================================================
# IN-GAME FURNITURE EDITOR GUI & INTERACTION
# ==============================================================================
func _setup_editor_ui() -> void:
	editor_layer = CanvasLayer.new()
	editor_layer.layer = 15
	add_child(editor_layer)

	# Tombol Buka Mode Atur di Pojok Atas Kanan
	edit_toggle_btn = Button.new()
	edit_toggle_btn.text = "Atur Perabot [F2]"
	edit_toggle_btn.focus_mode = Control.FOCUS_NONE
	edit_toggle_btn.anchor_left = 1.0
	edit_toggle_btn.anchor_right = 1.0
	edit_toggle_btn.offset_left = -285.0
	edit_toggle_btn.offset_right = -115.0
	edit_toggle_btn.offset_top = 22.0
	edit_toggle_btn.offset_bottom = 58.0
	edit_toggle_btn.custom_minimum_size = Vector2(170, 36)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.12, 0.20, 0.28, 0.92)
	btn_style.border_color = Color(0.35, 0.75, 0.95, 1.0)
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(6)
	btn_style.content_margin_left = 12
	btn_style.content_margin_right = 12
	edit_toggle_btn.add_theme_stylebox_override("normal", btn_style)
	edit_toggle_btn.pressed.connect(toggle_editor)
	editor_layer.add_child(edit_toggle_btn)

	# Panel Pengaturan Utama (Sisi Kiri)
	editor_panel = PanelContainer.new()
	editor_panel.visible = false
	editor_panel.position = Vector2(30, 70)
	editor_panel.custom_minimum_size = Vector2(390, 460)

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.10, 0.14, 0.96)
	panel_style.border_color = Color(0.25, 0.80, 0.95, 0.9)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 18
	panel_style.content_margin_right = 18
	panel_style.content_margin_top = 16
	panel_style.content_margin_bottom = 16
	editor_panel.add_theme_stylebox_override("panel", panel_style)
	editor_layer.add_child(editor_panel)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	editor_panel.add_child(vb)

	var title_lbl = Label.new()
	title_lbl.text = "PENGATUR PERABOT RUMAH"
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(0.3, 0.95, 1.0))
	vb.add_child(title_lbl)

	var subtitle = Label.new()
	subtitle.text = "Klik perabot di layar untuk drag, atau pilih dari daftar:"
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color(0.75, 0.80, 0.85))
	vb.add_child(subtitle)

	# Dropdown Pilihan Barang
	item_dropdown = OptionButton.new()
	item_dropdown.focus_mode = Control.FOCUS_NONE
	var idx = 0
	for id in furniture_config.keys():
		var it = furniture_config[id]
		item_dropdown.add_item("%s" % it.get("name", id), idx)
		item_dropdown.set_item_metadata(idx, id)
		idx += 1
	item_dropdown.item_selected.connect(_on_dropdown_item_selected)
	vb.add_child(item_dropdown)

	# Separator
	vb.add_child(HSeparator.new())

	# Kontrol Posisi X
	var hbox_x = HBoxContainer.new()
	hbox_x.add_theme_constant_override("separation", 8)
	var lbl_x = Label.new()
	lbl_x.text = "Posisi X:"
	lbl_x.custom_minimum_size = Vector2(70, 0)
	hbox_x.add_child(lbl_x)

	slider_pos_x = HSlider.new()
	slider_pos_x.min_value = 10.0
	slider_pos_x.max_value = ROOM_SIZE.x - 10.0
	slider_pos_x.step = 1.0
	slider_pos_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_pos_x.value_changed.connect(_on_ui_transform_changed)
	hbox_x.add_child(slider_pos_x)

	spin_pos_x = SpinBox.new()
	spin_pos_x.min_value = 10.0
	spin_pos_x.max_value = ROOM_SIZE.x - 10.0
	spin_pos_x.step = 1.0
	spin_pos_x.value_changed.connect(_on_ui_transform_changed)
	hbox_x.add_child(spin_pos_x)
	vb.add_child(hbox_x)

	# Kontrol Posisi Y
	var hbox_y = HBoxContainer.new()
	hbox_y.add_theme_constant_override("separation", 8)
	var lbl_y = Label.new()
	lbl_y.text = "Posisi Y:"
	lbl_y.custom_minimum_size = Vector2(70, 0)
	hbox_y.add_child(lbl_y)

	slider_pos_y = HSlider.new()
	slider_pos_y.min_value = 10.0
	slider_pos_y.max_value = ROOM_SIZE.y - 10.0
	slider_pos_y.step = 1.0
	slider_pos_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_pos_y.value_changed.connect(_on_ui_transform_changed)
	hbox_y.add_child(slider_pos_y)

	spin_pos_y = SpinBox.new()
	spin_pos_y.min_value = 10.0
	spin_pos_y.max_value = ROOM_SIZE.y - 10.0
	spin_pos_y.step = 1.0
	spin_pos_y.value_changed.connect(_on_ui_transform_changed)
	hbox_y.add_child(spin_pos_y)
	vb.add_child(hbox_y)

	# Kontrol Skala
	var hbox_s = HBoxContainer.new()
	hbox_s.add_theme_constant_override("separation", 8)
	var lbl_s = Label.new()
	lbl_s.text = "Skala:"
	lbl_s.custom_minimum_size = Vector2(70, 0)
	hbox_s.add_child(lbl_s)

	slider_scale = HSlider.new()
	slider_scale.min_value = 0.2
	slider_scale.max_value = 3.0
	slider_scale.step = 0.05
	slider_scale.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_scale.value_changed.connect(_on_ui_transform_changed)
	hbox_s.add_child(slider_scale)

	spin_scale = SpinBox.new()
	spin_scale.min_value = 0.2
	spin_scale.max_value = 3.0
	spin_scale.step = 0.05
	spin_scale.value_changed.connect(_on_ui_transform_changed)
	hbox_s.add_child(spin_scale)
	vb.add_child(hbox_s)

	# Tombol Cepat Skala
	var quick_hb = HBoxContainer.new()
	quick_hb.add_theme_constant_override("separation", 6)
	var btn_s_down = Button.new()
	btn_s_down.text = "-0.1x"
	btn_s_down.pressed.connect(func(): _adjust_selected_scale(-0.1))
	quick_hb.add_child(btn_s_down)

	var btn_s_norm = Button.new()
	btn_s_norm.text = "1.0x Normal"
	btn_s_norm.pressed.connect(func(): _set_selected_scale(1.0))
	quick_hb.add_child(btn_s_norm)

	var btn_s_up = Button.new()
	btn_s_up.text = "+0.1x"
	btn_s_up.pressed.connect(func(): _adjust_selected_scale(0.1))
	quick_hb.add_child(btn_s_up)
	vb.add_child(quick_hb)

	# Status Label
	status_msg_label = Label.new()
	status_msg_label.text = "Perabot siap diatur."
	status_msg_label.add_theme_font_size_override("font_size", 12)
	status_msg_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	vb.add_child(status_msg_label)

	# Separator
	vb.add_child(HSeparator.new())

	# Tombol-tombol Aksi
	var save_btn = Button.new()
	save_btn.text = "SIMPAN PENGATURAN"
	save_btn.custom_minimum_size = Vector2(0, 36)
	var save_style = StyleBoxFlat.new()
	save_style.bg_color = Color(0.15, 0.40, 0.25, 1.0)
	save_style.border_color = Color(0.3, 0.85, 0.5, 1.0)
	save_style.set_border_width_all(1)
	save_style.set_corner_radius_all(6)
	save_btn.add_theme_stylebox_override("normal", save_style)
	save_btn.pressed.connect(func():
		save_furniture_config()
		status_msg_label.text = "Berhasil disimpan ke file & console!"
	)
	vb.add_child(save_btn)

	var reset_btn = Button.new()
	reset_btn.text = "Reset ke Posisi Awal"
	reset_btn.custom_minimum_size = Vector2(0, 30)
	reset_btn.pressed.connect(func():
		reset_to_default_config()
		status_msg_label.text = "Posisi dikembalikan ke awal."
	)
	vb.add_child(reset_btn)

	var close_btn = Button.new()
	close_btn.text = "Selesai / Tutup [F2]"
	close_btn.custom_minimum_size = Vector2(0, 32)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.4, 0.15, 0.18, 1.0)
	close_style.border_color = Color(0.9, 0.4, 0.4, 1.0)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.pressed.connect(toggle_editor)
	vb.add_child(close_btn)

	# Pilih barang pertama secara default
	if not furniture_config.is_empty():
		_select_furniture(furniture_config.keys()[0])

func set_editor_available(avail: bool) -> void:
	if is_instance_valid(edit_toggle_btn):
		edit_toggle_btn.visible = avail
	if not avail and is_edit_mode:
		toggle_editor()

func toggle_editor() -> void:
	is_edit_mode = !is_edit_mode
	editor_panel.visible = is_edit_mode
	edit_toggle_btn.text = "Tutup Editor [F2]" if is_edit_mode else "Atur Perabot [F2]"

	var player = get_tree().root.find_child("Player", true, false)
	if is_instance_valid(player):
		player.can_move = !is_edit_mode

	if is_edit_mode:
		status_msg_label.text = "Mode Atur Aktif. Klik & drag perabot."
		if selected_furniture_id.is_empty() and not furniture_config.is_empty():
			_select_furniture(furniture_config.keys()[0])
	else:
		is_dragging = false

	queue_redraw()

func _select_furniture(id: String) -> void:
	if not furniture_config.has(id):
		return
	selected_furniture_id = id
	for i in range(item_dropdown.item_count):
		if item_dropdown.get_item_metadata(i) == id:
			item_dropdown.select(i)
			break
	_sync_ui_to_selected_item()
	queue_redraw()

func _sync_ui_to_selected_item() -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var item = furniture_config[selected_furniture_id]
	_is_updating_ui = true
	slider_pos_x.value = float(item.x)
	spin_pos_x.value = float(item.x)
	slider_pos_y.value = float(item.y)
	spin_pos_y.value = float(item.y)
	slider_scale.value = float(item.scale)
	spin_scale.value = float(item.scale)
	_is_updating_ui = false

func _on_dropdown_item_selected(index: int) -> void:
	var id = str(item_dropdown.get_item_metadata(index))
	_select_furniture(id)

func _on_ui_transform_changed(_val: float) -> void:
	if _is_updating_ui or selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	_is_updating_ui = true
	var x = slider_pos_x.value
	var y = slider_pos_y.value
	var s = slider_scale.value
	spin_pos_x.value = x
	spin_pos_y.value = y
	spin_scale.value = s
	_is_updating_ui = false

	furniture_config[selected_furniture_id]["x"] = x
	furniture_config[selected_furniture_id]["y"] = y
	furniture_config[selected_furniture_id]["scale"] = s
	update_furniture_transform(selected_furniture_id)

func _adjust_selected_scale(delta_s: float) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var cur_s = float(furniture_config[selected_furniture_id].scale)
	_set_selected_scale(clampf(cur_s + delta_s, 0.2, 3.0))

func _set_selected_scale(new_s: float) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	furniture_config[selected_furniture_id]["scale"] = new_s
	_sync_ui_to_selected_item()
	update_furniture_transform(selected_furniture_id)

func _find_furniture_at_world_pos(world_pos: Vector2) -> String:
	var keys = furniture_config.keys()
	keys.reverse()
	for id in keys:
		var item = furniture_config[id]
		var item_pos = ROOM_ORIGIN + Vector2(float(item.x), float(item.y))
		var s = float(item.scale)
		var w = float(item.get("col_w", item.get("base_w", 40.0))) * s
		var h = float(item.get("col_h", item.get("base_h", item.get("base_w", 40.0)))) * s
		var rect = Rect2(item_pos.x - w * 0.5 - 6, item_pos.y - h * 0.5 - 6, w + 12, h + 12)
		if rect.has_point(world_pos):
			return id
	return ""

func _unhandled_input(event: InputEvent) -> void:
	if not is_edit_mode:
		if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_F2:
			toggle_editor()
			get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode in [KEY_F2, KEY_ESCAPE]:
			toggle_editor()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_BRACKETLEFT:
			_adjust_selected_scale(-0.05)
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_BRACKETRIGHT:
			_adjust_selected_scale(0.05)
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton:
		var world_mpos = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var hit_id = _find_furniture_at_world_pos(world_mpos)
				if not hit_id.is_empty():
					_select_furniture(hit_id)
					is_dragging = true
					var it = furniture_config[hit_id]
					var cur_pos = ROOM_ORIGIN + Vector2(float(it.x), float(it.y))
					drag_offset = cur_pos - world_mpos
					get_viewport().set_input_as_handled()
			else:
				if is_dragging:
					is_dragging = false
					get_viewport().set_input_as_handled()

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_adjust_selected_scale(0.05)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_adjust_selected_scale(-0.05)
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and is_dragging and not selected_furniture_id.is_empty():
		var world_mpos = get_global_mouse_position()
		var target_world = world_mpos + drag_offset
		var rel_pos = target_world - ROOM_ORIGIN
		var new_x = clampf(rel_pos.x, 10.0, ROOM_SIZE.x - 10.0)
		var new_y = clampf(rel_pos.y, 10.0, ROOM_SIZE.y - 10.0)

		furniture_config[selected_furniture_id]["x"] = round(new_x)
		furniture_config[selected_furniture_id]["y"] = round(new_y)
		update_furniture_transform(selected_furniture_id)
		_sync_ui_to_selected_item()
		get_viewport().set_input_as_handled()
