extends Node2D
class_name ExplorationHouseInterior

# ==============================================================================
# INTERIOR RUMAH IBU MEDELINE (RUMAH EKSPLORASI / RUMAH PALING SELATAN)
# Layout & proporsionalitas disesuaikan persis dengan rumah Benedict (460x300),
# dengan perabotan khas kenangan Ibu (Buku Resep, Jam Weker, Kalender, Foto Polaroid, Brankas).
# ==============================================================================

# Koordinat penempatan interior di world space
const ROOM_ORIGIN := Vector2(4600.0, 400.0)
const ROOM_SIZE := Vector2(460.0, 300.0)

# Titik-titik penting di dalam rumah Ibu
const ENTRANCE_POS := Vector2(4600.0 + 85.0, 400.0 + 245.0)
const EXIT_DOOR_POS := Vector2(4600.0 + 85.0, 400.0 + 280.0)

# --- In-Game Furniture Editor [F2] ---
var is_edit_mode: bool = false
var selected_furniture_id: String = ""
var is_dragging_furniture: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var is_dragging_panel: bool = false
var panel_drag_offset: Vector2 = Vector2.ZERO

var editor_layer: CanvasLayer
var edit_toggle_btn: Button
var editor_panel: PanelContainer
var item_dropdown: OptionButton
var restore_dropdown: OptionButton
var status_msg_label: Label

var slider_pos_x: HSlider
var spin_pos_x: SpinBox
var slider_pos_y: HSlider
var spin_pos_y: SpinBox
var slider_scale: HSlider
var spin_scale: SpinBox
var slider_rot: HSlider
var spin_rot: SpinBox
var btn_flip_x: Button
var btn_flip_y: Button

var default_furniture_config: Dictionary = {}
const CONFIG_FILE_PATH := "res://data/exploration_house_furniture_config.json"

var furniture_config: Dictionary = {
	# --- 1. RUANG TAMU ---
	"sofa_panjang": {
		"name": "Sofa Tamu Ibu",
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
		"name": "Meja Sudut Hias",
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

	# --- 2. RUANG TENGAH (KENANGAN KELUARGA & BRANKAS) ---
	"brankas": {
		"name": "Brankas Baja Keluarga",
		"type": "sprite",
		"tex": "tex_berangkas",
		"x": 150.0, "y": 52.0,
		"scale": 1.0,
		"base_w": 46.0,
		"has_col": true,
		"col_w": 44.0, "col_h": 38.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"meja_keluarga": {
		"name": "Meja Kayu Kenangan",
		"type": "sprite",
		"tex": "tex_meja_kayu",
		"x": 195.0, "y": 72.0,
		"scale": 1.0,
		"base_w": 75.0,
		"has_col": true,
		"col_w": 75.0, "col_h": 42.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"kursi_keluarga": {
		"name": "Kursi Kayu",
		"type": "drawn",
		"draw_type": "kursi",
		"x": 195.0, "y": 48.0,
		"scale": 1.0,
		"base_w": 24.0,
		"base_h": 8.0,
		"has_col": false,
		"z_idx": 0
	},
	"kalender_ibu": {
		"name": "Kalender Kenangan Tahun 1998",
		"type": "sprite",
		"tex": "tex_kalender",
		"x": 210.0, "y": 38.0,
		"scale": 1.0,
		"base_w": 20.0,
		"has_col": false,
		"z_idx": 1
	},

	# --- 3. KAMAR TIDUR IBU ---
	"bed": {
		"name": "Ranjang Tidur Ibu",
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
		"col_w": 28.0,
		"col_h": 26.0,
		"col_off_x": 0.0,
		"col_y_off": 6.0,
		"z_idx": 0
	},
	"jam_weker": {
		"name": "Jam Weker Tua (Pukul 16:04)",
		"type": "sprite",
		"tex": "tex_jam_weker",
		"x": 355.0, "y": 48.0,
		"scale": 1.0,
		"base_w": 16.0,
		"has_col": true,
		"col_w": 26.0,
		"col_h": 24.0,
		"col_off_x": 0.0,
		"col_y_off": 4.0,
		"z_idx": 1
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

	# --- 4. DAPUR IBU ---
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
	"meja_resep": {
		"name": "Meja Dapur & Buku Resep",
		"type": "sprite",
		"tex": "tex_meja_panjang",
		"x": 260.0, "y": 245.0,
		"scale": 1.0,
		"base_w": 46.0,
		"has_col": true,
		"col_w": 46.0, "col_h": 36.0,
		"col_off_x": 0.0, "col_y_off": 0.0,
		"z_idx": 0
	},
	"buku_resep": {
		"name": "Buku Resep Masakan Ibu",
		"type": "sprite",
		"tex": "tex_buku_resep",
		"x": 255.0, "y": 242.0,
		"scale": 1.0,
		"base_w": 18.0,
		"has_col": false,
		"z_idx": 1
	},
	"catatan_ibu": {
		"name": "Catatan Hari Ibu",
		"type": "sprite",
		"tex": "tex_surat",
		"x": 268.0, "y": 242.0,
		"scale": 1.0,
		"base_w": 14.0,
		"has_col": false,
		"z_idx": 1
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

var furniture_sprites: Dictionary = {}
var furniture_colliders: Dictionary = {}

# Aset Tekstur
var tex_sofa_panjang: Texture2D
var tex_sofa_kecil: Texture2D
var tex_meja_panjang: Texture2D
var tex_karpet: Texture2D
var tex_meja_kayu: Texture2D
var tex_set_masak: Texture2D
var tex_kulkas: Texture2D
var tex_bed: Texture2D
var tex_lemari: Texture2D
var tex_laci: Texture2D
var tex_karpet_kamar: Texture2D
var tex_berangkas: Texture2D
var tex_surat: Texture2D

# Aset Khusus Rumah Ibu
var tex_buku_resep: Texture2D
var tex_jam_weker: Texture2D
var tex_kalender: Texture2D
var tex_polaroid_ibu: Texture2D

var glow_timer: float = 0.0
var static_body: StaticBody2D

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_load_textures()
	_build_room_collisions()
	default_furniture_config = furniture_config.duplicate(true)
	_load_furniture_config()
	_setup_furniture_nodes()
	_setup_editor_ui()

func _load_textures() -> void:
	# 1. Perabotan Dasar
	tex_sofa_panjang = _safe_load("res://Environment/ruang tamu/sofaPanjang.png")
	tex_sofa_kecil = _safe_load("res://Environment/ruang tamu/sofaKecilSamping.png")
	tex_meja_panjang = _safe_load("res://Environment/ruang tamu/mejaPanjang.png")
	tex_karpet = _safe_load("res://Environment/ruang tamu/karpet.png")
	tex_meja_kayu = _safe_load("res://Environment/ruang tamu/meja_detektif.png")
	tex_set_masak = _safe_load("res://Environment/dapur/set_masak_unit.png")
	tex_kulkas = _safe_load("res://Environment/dapur/kulkas_unit.png")
	tex_bed = _safe_load("res://Environment/kamar/bed.png")
	tex_lemari = _safe_load("res://Environment/kamar/lemari.png")
	tex_laci = _safe_load("res://Environment/kamar/laci.png")
	tex_karpet_kamar = _safe_load("res://Environment/kamar/karpet.png")
	tex_berangkas = _safe_load("res://Environment/interactable assets/berangkas.png")
	tex_surat = _safe_load("res://Environment/interactable assets/surat.png")

	# 2. Barang Khusus Folder Rumah Ibu
	tex_buku_resep = _safe_load_multi([
		"res://Environment/RUMAH IBU/BUKU RESEP.png",
		"res://RUMAH IBU/BUKU RESEP.png"
	])
	tex_jam_weker = _safe_load_multi([
		"res://Environment/RUMAH IBU/jam weker.png",
		"res://RUMAH IBU/jam weker.png"
	])
	tex_kalender = _safe_load_multi([
		"res://Environment/RUMAH IBU/kalender.png",
		"res://RUMAH IBU/kalender.png"
	])
	tex_polaroid_ibu = _safe_load("res://UI/Polaroid/polaroidIbu.png")

func _safe_load(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _safe_load_multi(paths: Array[String]) -> Texture2D:
	for p in paths:
		if ResourceLoader.exists(p):
			return load(p) as Texture2D
	return null

func _get_texture_by_name(tex_name: String) -> Texture2D:
	match tex_name:
		"tex_sofa_panjang": return tex_sofa_panjang
		"tex_sofa_kecil": return tex_sofa_kecil
		"tex_meja_panjang": return tex_meja_panjang
		"tex_karpet": return tex_karpet
		"tex_meja_kayu": return tex_meja_kayu
		"tex_set_masak": return tex_set_masak
		"tex_kulkas": return tex_kulkas
		"tex_bed": return tex_bed
		"tex_lemari": return tex_lemari
		"tex_laci": return tex_laci
		"tex_karpet_kamar": return tex_karpet_kamar
		"tex_berangkas": return tex_berangkas
		"tex_surat": return tex_surat
		"tex_buku_resep": return tex_buku_resep
		"tex_jam_weker": return tex_jam_weker
		"tex_kalender": return tex_kalender
		"tex_polaroid_ibu": return tex_polaroid_ibu
	return null

func _build_room_collisions() -> void:
	static_body = StaticBody2D.new()
	static_body.name = "ExplorationInteriorCollisions"
	static_body.collision_layer = 1
	static_body.collision_mask = 0
	add_child(static_body)

	# 1. DINDING KELILING LUAR (OUTER WALLS)
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 32.0))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, ROOM_SIZE.x, 24.0))
	# Penghalang celah atas belakang ranjang & nakas jam weker (X=330..385, Y=32..46)
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 330.0, ROOM_ORIGIN.y + 32.0, 55.0, 14.0))

	# 2. DINDING SEKAT RUANG KELUARGA & KAMAR
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
				sp.name = "Expl_Furniture_" + id
				sp.texture = tex
				sp.z_index = data.get("z_idx", 0)
				add_child(sp)
				furniture_sprites[id] = sp

		if data.get("has_col", false):
			var col = CollisionShape2D.new()
			col.name = "Expl_Col_" + id
			var shape = RectangleShape2D.new()
			col.shape = shape
			static_body.add_child(col)
			furniture_colliders[id] = col

		_update_furniture_transform(id)

func _update_furniture_transform(id: String) -> void:
	if not furniture_config.has(id):
		return
	var data = furniture_config[id]
	var world_pos = ROOM_ORIGIN + Vector2(float(data.x), float(data.y))
	var s = float(data.get("scale", 1.0))

	if furniture_sprites.has(id):
		var sp = furniture_sprites[id]
		sp.position = world_pos
		var tex = sp.texture
		if tex and tex.get_width() > 0:
			var base_w = float(data.get("base_w", 40.0))
			var ratio = (base_w * s) / float(tex.get_width())
			var flip_x_sign: float = -1.0 if data.get("flip_x", false) else 1.0
			var flip_y_sign: float = -1.0 if data.get("flip_y", false) else 1.0
			sp.scale = Vector2(ratio * flip_x_sign, ratio * flip_y_sign)
		sp.rotation_degrees = float(data.get("rotation_deg", 0.0))

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
			col.rotation_degrees = float(data.get("rotation_deg", 0.0))

func _process(delta: float) -> void:
	glow_timer += delta * 3.2
	queue_redraw()

func _draw() -> void:
	# 1. LANTAI DASAR PARQUET KAYU HANGAT (NUANSA NOSTALGIA IBU)
	var floor_rect = Rect2(ROOM_ORIGIN.x + 16.0, ROOM_ORIGIN.y + 32.0, ROOM_SIZE.x - 32.0, ROOM_SIZE.y - 48.0)
	draw_rect(floor_rect, Color(0.23, 0.17, 0.13), true)

	var plank_h: float = 16.0
	var curr_y: float = floor_rect.position.y
	while curr_y < floor_rect.end.y:
		draw_line(Vector2(floor_rect.position.x, curr_y), Vector2(floor_rect.end.x, curr_y), Color(0.17, 0.12, 0.09, 0.45), 1.0)
		curr_y += plank_h

	# 2. LANTAI KERAMIK DAPUR IBU
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
			var tile_col = Color(0.27, 0.24, 0.21) if is_alt else Color(0.20, 0.18, 0.16)
			draw_rect(Rect2(tx, ty, tile_size, tile_size), tile_col, true)
			draw_rect(Rect2(tx, ty, tile_size, tile_size), Color(0.15, 0.13, 0.11), false, 0.8)
			ty += tile_size
		tx += tile_size

	# 3. DINDING LUAR BANGUNAN (WALLS)
	var wall_col = Color(0.13, 0.11, 0.14)
	var trim_col = Color(0.38, 0.28, 0.22)

	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 32.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + 32.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + 32.0), trim_col, 2.0)

	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + 16.0, ROOM_ORIGIN.y), Vector2(ROOM_ORIGIN.x + 16.0, ROOM_ORIGIN.y + ROOM_SIZE.y), trim_col, 2.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y, 16.0, ROOM_SIZE.y), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x - 16.0, ROOM_ORIGIN.y + ROOM_SIZE.y), trim_col, 2.0)

	# Dinding Bawah Solid Menyeluruh (Mencegah tembus ke area hitam)
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, ROOM_SIZE.x, 16.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0), trim_col, 2.0)

	# Pintu Kayu Masuk/Keluar di Dinding Bawah (Tepat di depan keset pintu)
	var door_rect = Rect2(ROOM_ORIGIN.x + 65.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 16.0, 40.0, 16.0)
	draw_rect(door_rect, Color(0.26, 0.17, 0.12), true)
	draw_rect(door_rect, Color(0.42, 0.28, 0.18), false, 1.5)
	draw_circle(Vector2(ROOM_ORIGIN.x + 98.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 8.0), 2.5, Color(0.85, 0.75, 0.35))


	# 4. DINDING SEKAT RUANGAN
	draw_rect(Rect2(ROOM_ORIGIN.x + 125.0, ROOM_ORIGIN.y + 32.0, 8.0, 85.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 125.0, ROOM_ORIGIN.y + 32.0, 8.0, 85.0), trim_col, false, 1.0)

	draw_rect(Rect2(ROOM_ORIGIN.x + 265.0, ROOM_ORIGIN.y + 32.0, 8.0, 140.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 265.0, ROOM_ORIGIN.y + 32.0, 8.0, 140.0), trim_col, false, 1.0)

	draw_rect(Rect2(ROOM_ORIGIN.x + 220.0, ROOM_ORIGIN.y + 195.0, 8.0, 85.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 220.0, ROOM_ORIGIN.y + 195.0, 8.0, 85.0), trim_col, false, 1.0)

	# 5. ELEMEN INTERIOR YANG DIGAMBAR LANGSUNG
	# a. Partisi Ruang Tamu
	if furniture_config.has("partisi_tamu"):
		var p_data = furniture_config["partisi_tamu"]
		var px = ROOM_ORIGIN.x + float(p_data.x)
		var py = ROOM_ORIGIN.y + float(p_data.y)
		var ps = float(p_data.get("scale", 1.0))
		var half_h = (45.0 * ps)
		draw_line(Vector2(px, py - half_h), Vector2(px, py + half_h), Color(0.42, 0.32, 0.24, 0.85), 3.0 * ps)
		draw_circle(Vector2(px, py - half_h), 3.0 * ps, Color(0.58, 0.44, 0.32))
		draw_circle(Vector2(px, py + half_h), 3.0 * ps, Color(0.58, 0.44, 0.32))

	# b. Kursi Meja Keluarga
	if furniture_config.has("kursi_keluarga"):
		var k_data = furniture_config["kursi_keluarga"]
		var kx = ROOM_ORIGIN.x + float(k_data.x)
		var ky = ROOM_ORIGIN.y + float(k_data.y)
		var ks = float(k_data.get("scale", 1.0))
		draw_circle(Vector2(kx, ky), 9.0 * ks, Color(0.35, 0.25, 0.18))
		draw_circle(Vector2(kx, ky), 7.0 * ks, Color(0.52, 0.38, 0.26))
		draw_arc(Vector2(kx, ky), 9.0 * ks, PI * 0.8, PI * 2.2, 8, Color(0.22, 0.16, 0.11), 2.0 * ks)

	# c. Keset Pintu Keluar
	if furniture_config.has("keset_pintu"):
		var m_data = furniture_config["keset_pintu"]
		var mx = ROOM_ORIGIN.x + float(m_data.x)
		var my = ROOM_ORIGIN.y + float(m_data.y)
		var mw = float(m_data.get("base_w", 40.0))
		var mh = float(m_data.get("base_h", 14.0))
		var m_rect = Rect2(mx - mw * 0.5, my - mh * 0.5, mw, mh)
		draw_rect(m_rect, Color(0.40, 0.15, 0.15), true)
		draw_rect(m_rect, Color(0.65, 0.25, 0.22), false, 1.5)

	# 6. GLOWING HIGHLIGHT INTERAKTIF PADA BUKTI & CLUE
	var pulse = 0.22 + 0.09 * sin(glow_timer)
	# Safe
	draw_circle(get_safe_pos(), 16.0, Color(0.35, 0.95, 0.65, pulse))
	# Clock (Hint 3)
	draw_circle(get_clock_pos(), 14.0, Color(1.0, 0.85, 0.40, pulse))
	# Calendar (Hint 1)
	draw_circle(get_calendar_pos(), 15.0, Color(0.45, 0.82, 1.0, pulse))
	# Recipe Book (Hint 4)
	draw_circle(get_recipe_pos(), 15.0, Color(1.0, 0.90, 0.50, pulse))

	# Selection Highlight Saat Mode Edit Aktif
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
# GETTER KOORDINAT POI INTERAKSI GAMEPLAY
# ==============================================================================
func get_entrance_pos() -> Vector2:
	return ENTRANCE_POS

func get_exit_door_pos() -> Vector2:
	return EXIT_DOOR_POS

func get_safe_pos() -> Vector2:
	if furniture_config.has("brankas"):
		var b = furniture_config["brankas"]
		return ROOM_ORIGIN + Vector2(float(b.x), float(b.y))
	return ROOM_ORIGIN + Vector2(150.0, 52.0)

func get_clock_pos() -> Vector2:
	if furniture_config.has("jam_weker"):
		var j = furniture_config["jam_weker"]
		return ROOM_ORIGIN + Vector2(float(j.x), float(j.y))
	return ROOM_ORIGIN + Vector2(355.0, 56.0)

func get_calendar_pos() -> Vector2:
	if furniture_config.has("kalender_ibu"):
		var k = furniture_config["kalender_ibu"]
		return ROOM_ORIGIN + Vector2(float(k.x), float(k.y))
	elif furniture_config.has("meja_keluarga"):
		var m = furniture_config["meja_keluarga"]
		return ROOM_ORIGIN + Vector2(float(m.x), float(m.y))
	return ROOM_ORIGIN + Vector2(210.0, 38.0)

func get_calendar_photo_pos() -> Vector2:
	return get_calendar_pos()

func get_recipe_pos() -> Vector2:
	if furniture_config.has("meja_resep"):
		var r = furniture_config["meja_resep"]
		return ROOM_ORIGIN + Vector2(float(r.x), float(r.y))
	return ROOM_ORIGIN + Vector2(260.0, 245.0)

# ==============================================================================
# IN-GAME FURNITURE EDITOR GUI & INTERACTION [F2] - RUMAH IBU
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
	editor_panel.custom_minimum_size = Vector2(400, 520)

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

	# 1. Header Drag Handle
	var header_bar = PanelContainer.new()
	var h_style = StyleBoxFlat.new()
	h_style.bg_color = Color(0.14, 0.24, 0.34, 0.95)
	h_style.border_color = Color(0.35, 0.85, 1.0, 0.8)
	h_style.set_border_width_all(1)
	h_style.set_corner_radius_all(6)
	h_style.content_margin_left = 12
	h_style.content_margin_right = 8
	h_style.content_margin_top = 8
	h_style.content_margin_bottom = 8
	header_bar.add_theme_stylebox_override("panel", h_style)
	header_bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	header_bar.gui_input.connect(_on_panel_header_gui_input)
	vb.add_child(header_bar)

	var h_box = HBoxContainer.new()
	header_bar.add_child(h_box)

	var title_lbl = Label.new()
	title_lbl.text = "✦ ATUR PERABOT RUMAH IBU [F2]"
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(0.3, 0.95, 1.0))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	h_box.add_child(title_lbl)

	var close_x_btn = Button.new()
	close_x_btn.text = " ✕ "
	close_x_btn.focus_mode = Control.FOCUS_NONE
	close_x_btn.pressed.connect(toggle_editor)
	h_box.add_child(close_x_btn)

	var subtitle = Label.new()
	subtitle.text = "Drag jendela ini atau drag perabot di ruangan:"
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color(0.75, 0.80, 0.85))
	vb.add_child(subtitle)

	# Dropdown Pilihan Barang
	item_dropdown = OptionButton.new()
	item_dropdown.focus_mode = Control.FOCUS_NONE
	item_dropdown.item_selected.connect(_on_dropdown_item_selected)
	vb.add_child(item_dropdown)
	_rebuild_dropdown()

	# Tombol Hapus Item Terpilih
	var item_act_hb = HBoxContainer.new()
	item_act_hb.add_theme_constant_override("separation", 8)

	var del_btn = Button.new()
	del_btn.text = "🗑 Hapus Item Terpilih"
	del_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	del_btn.custom_minimum_size = Vector2(0, 32)
	var del_style = StyleBoxFlat.new()
	del_style.bg_color = Color(0.55, 0.15, 0.15, 0.95)
	del_style.border_color = Color(0.95, 0.35, 0.35, 1.0)
	del_style.set_border_width_all(1)
	del_style.set_corner_radius_all(6)
	del_btn.add_theme_stylebox_override("normal", del_style)
	del_btn.pressed.connect(func():
		if not selected_furniture_id.is_empty():
			var it_name = furniture_config.get(selected_furniture_id, {}).get("name", selected_furniture_id)
			delete_furniture(selected_furniture_id)
			status_msg_label.text = "Item '%s' berhasil dihapus." % it_name
	)
	item_act_hb.add_child(del_btn)
	vb.add_child(item_act_hb)

	# Dropdown Pulihkan Item yang Telah Dihapus
	restore_dropdown = OptionButton.new()
	restore_dropdown.focus_mode = Control.FOCUS_NONE
	restore_dropdown.item_selected.connect(_on_restore_dropdown_selected)
	vb.add_child(restore_dropdown)
	_rebuild_restore_dropdown()

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

	# Kontrol Rotasi (Derajat 0 - 360)
	var hbox_rot = HBoxContainer.new()
	hbox_rot.add_theme_constant_override("separation", 8)

	var lbl_rot = Label.new()
	lbl_rot.text = "Rotasi:"
	lbl_rot.custom_minimum_size = Vector2(70, 0)
	hbox_rot.add_child(lbl_rot)

	slider_rot = HSlider.new()
	slider_rot.min_value = 0.0
	slider_rot.max_value = 360.0
	slider_rot.step = 1.0
	slider_rot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_rot.value_changed.connect(_on_ui_transform_changed)
	hbox_rot.add_child(slider_rot)

	spin_rot = SpinBox.new()
	spin_rot.min_value = 0.0
	spin_rot.max_value = 360.0
	spin_rot.step = 1.0
	spin_rot.value_changed.connect(_on_ui_transform_changed)
	hbox_rot.add_child(spin_rot)
	vb.add_child(hbox_rot)

	# Tombol Putar Cepat & Balik Sumbu
	var rot_act_hb = HBoxContainer.new()
	rot_act_hb.add_theme_constant_override("separation", 6)

	var btn_rot_cw = Button.new()
	btn_rot_cw.text = "⟳ +90°"
	btn_rot_cw.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_rot_cw.pressed.connect(func(): _rotate_selected(90.0))
	rot_act_hb.add_child(btn_rot_cw)

	var btn_rot_reset = Button.new()
	btn_rot_reset.text = "0° Reset"
	btn_rot_reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_rot_reset.pressed.connect(func(): _set_selected_rotation(0.0))
	rot_act_hb.add_child(btn_rot_reset)

	btn_flip_x = Button.new()
	btn_flip_x.text = "⇄ Balik X"
	btn_flip_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_flip_x.pressed.connect(func():
		if not selected_furniture_id.is_empty():
			var it = furniture_config[selected_furniture_id]
			it["flip_x"] = !it.get("flip_x", false)
			_update_furniture_transform(selected_furniture_id)
			save_furniture_config()
			queue_redraw()
	)
	rot_act_hb.add_child(btn_flip_x)

	btn_flip_y = Button.new()
	btn_flip_y.text = "⇅ Balik Y"
	btn_flip_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_flip_y.pressed.connect(func():
		if not selected_furniture_id.is_empty():
			var it = furniture_config[selected_furniture_id]
			it["flip_y"] = !it.get("flip_y", false)
			_update_furniture_transform(selected_furniture_id)
			save_furniture_config()
			queue_redraw()
	)
	rot_act_hb.add_child(btn_flip_y)
	vb.add_child(rot_act_hb)

	status_msg_label = Label.new()
	status_msg_label.text = "Gunakan Mouse Drag atau Panah Keyboard untuk geser perabot."
	status_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_msg_label.add_theme_font_size_override("font_size", 11)
	status_msg_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	vb.add_child(status_msg_label)

	# Tombol Simpan & Tutup
	var act_hb = HBoxContainer.new()
	act_hb.add_theme_constant_override("separation", 10)

	var save_btn = Button.new()
	save_btn.text = "💾 Simpan Posisi"
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.custom_minimum_size = Vector2(0, 36)
	var save_style = StyleBoxFlat.new()
	save_style.bg_color = Color(0.18, 0.45, 0.25, 0.95)
	save_style.border_color = Color(0.4, 0.9, 0.5, 1.0)
	save_style.set_border_width_all(1)
	save_style.set_corner_radius_all(6)
	save_btn.add_theme_stylebox_override("normal", save_style)
	save_btn.pressed.connect(func():
		save_furniture_config()
		status_msg_label.text = "✓ Posisi perabot berhasil disimpan!"
	)
	act_hb.add_child(save_btn)

	var close_btn = Button.new()
	close_btn.text = "Selesai / Tutup [F2]"
	close_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_btn.custom_minimum_size = Vector2(0, 36)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.25, 0.25, 0.35, 0.95)
	close_style.border_color = Color(0.6, 0.6, 0.8, 1.0)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.pressed.connect(toggle_editor)
	act_hb.add_child(close_btn)

	vb.add_child(act_hb)

	if not furniture_config.is_empty():
		_select_furniture(furniture_config.keys()[0])

func set_editor_available(avail: bool) -> void:
	if is_instance_valid(edit_toggle_btn):
		edit_toggle_btn.visible = avail
	if not avail and is_edit_mode:
		toggle_editor()

func toggle_editor() -> void:
	is_edit_mode = !is_edit_mode
	if is_instance_valid(editor_panel):
		editor_panel.visible = is_edit_mode
	if is_instance_valid(edit_toggle_btn):
		edit_toggle_btn.text = "Tutup Editor [F2]" if is_edit_mode else "Atur Perabot [F2]"

	if is_inside_tree() and get_tree() and get_tree().root:
		var player = get_tree().root.find_child("Player", true, false)
		if is_instance_valid(player):
			player.can_move = !is_edit_mode

	if is_edit_mode:
		if is_instance_valid(status_msg_label):
			status_msg_label.text = "Mode Atur Aktif. Klik & drag perabot di ruangan."
		if selected_furniture_id.is_empty() and not furniture_config.is_empty():
			_select_furniture(furniture_config.keys()[0])
	else:
		is_dragging_furniture = false

	queue_redraw()

func _select_furniture(id: String) -> void:
	if not furniture_config.has(id):
		return
	selected_furniture_id = id
	if is_instance_valid(item_dropdown):
		for i in range(item_dropdown.item_count):
			if item_dropdown.get_item_metadata(i) == id:
				item_dropdown.select(i)
				break
	_sync_ui_to_selected_item()
	queue_redraw()

func _on_panel_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging_panel = true
			panel_drag_offset = editor_panel.global_position - editor_panel.get_viewport().get_mouse_position()
		else:
			is_dragging_panel = false
	elif event is InputEventMouseMotion and is_dragging_panel:
		var mouse_pos = editor_panel.get_viewport().get_mouse_position()
		var new_pos = mouse_pos + panel_drag_offset
		var vp_size = editor_panel.get_viewport().get_visible_rect().size
		new_pos.x = clampf(new_pos.x, 0.0, vp_size.x - editor_panel.size.x)
		new_pos.y = clampf(new_pos.y, 0.0, vp_size.y - editor_panel.size.y)
		editor_panel.global_position = new_pos

func _rebuild_dropdown() -> void:
	if not is_instance_valid(item_dropdown):
		return
	item_dropdown.clear()
	var idx = 0
	for id in furniture_config.keys():
		var it = furniture_config[id]
		item_dropdown.add_item("%s" % it.get("name", id), idx)
		item_dropdown.set_item_metadata(idx, id)
		idx += 1

func _rebuild_restore_dropdown() -> void:
	if not is_instance_valid(restore_dropdown):
		return
	restore_dropdown.clear()
	restore_dropdown.add_item("➕ Pulihkan Item Terhapus...", 0)
	restore_dropdown.set_item_metadata(0, "")

	var idx = 1
	for id in default_furniture_config.keys():
		if not furniture_config.has(id):
			var def_item = default_furniture_config[id]
			restore_dropdown.add_item("Pulihkan: %s" % def_item.get("name", id), idx)
			restore_dropdown.set_item_metadata(idx, id)
			idx += 1

	restore_dropdown.visible = (idx > 1)

func _on_restore_dropdown_selected(index: int) -> void:
	if index == 0:
		return
	var id = str(restore_dropdown.get_item_metadata(index))
	if not id.is_empty():
		restore_furniture(id)

func _sync_ui_to_selected_item() -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		if is_instance_valid(slider_pos_x): slider_pos_x.editable = false
		if is_instance_valid(spin_pos_x): spin_pos_x.editable = false
		if is_instance_valid(slider_pos_y): slider_pos_y.editable = false
		if is_instance_valid(spin_pos_y): spin_pos_y.editable = false
		if is_instance_valid(slider_scale): slider_scale.editable = false
		if is_instance_valid(spin_scale): spin_scale.editable = false
		if is_instance_valid(slider_rot): slider_rot.editable = false
		if is_instance_valid(spin_rot): spin_rot.editable = false
		if is_instance_valid(btn_flip_x): btn_flip_x.disabled = true
		if is_instance_valid(btn_flip_y): btn_flip_y.disabled = true
		return

	if is_instance_valid(slider_pos_x): slider_pos_x.editable = true
	if is_instance_valid(spin_pos_x): spin_pos_x.editable = true
	if is_instance_valid(slider_pos_y): slider_pos_y.editable = true
	if is_instance_valid(spin_pos_y): spin_pos_y.editable = true
	if is_instance_valid(slider_scale): slider_scale.editable = true
	if is_instance_valid(spin_scale): spin_scale.editable = true
	if is_instance_valid(slider_rot): slider_rot.editable = true
	if is_instance_valid(spin_rot): spin_rot.editable = true
	if is_instance_valid(btn_flip_x): btn_flip_x.disabled = false
	if is_instance_valid(btn_flip_y): btn_flip_y.disabled = false

	var it = furniture_config[selected_furniture_id]
	var px = float(it.x)
	var py = float(it.y)
	var sc = float(it.scale)
	var rot = float(it.get("rotation_deg", 0.0))

	if is_instance_valid(slider_pos_x): slider_pos_x.set_value_no_signal(px)
	if is_instance_valid(spin_pos_x): spin_pos_x.set_value_no_signal(px)
	if is_instance_valid(slider_pos_y): slider_pos_y.set_value_no_signal(py)
	if is_instance_valid(spin_pos_y): spin_pos_y.set_value_no_signal(py)
	if is_instance_valid(slider_scale): slider_scale.set_value_no_signal(sc)
	if is_instance_valid(spin_scale): spin_scale.set_value_no_signal(sc)
	if is_instance_valid(slider_rot): slider_rot.set_value_no_signal(rot)
	if is_instance_valid(spin_rot): spin_rot.set_value_no_signal(rot)

func _on_dropdown_item_selected(index: int) -> void:
	var id = str(item_dropdown.get_item_metadata(index))
	_select_furniture(id)

func _on_ui_transform_changed(_val: float = 0.0) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var it = furniture_config[selected_furniture_id]
	it.x = spin_pos_x.value
	slider_pos_x.set_value_no_signal(it.x)
	it.y = spin_pos_y.value
	slider_pos_y.set_value_no_signal(it.y)
	it.scale = spin_scale.value
	slider_scale.set_value_no_signal(it.scale)
	it["rotation_deg"] = spin_rot.value
	slider_rot.set_value_no_signal(it["rotation_deg"])

	_update_furniture_transform(selected_furniture_id)
	save_furniture_config()
	queue_redraw()

func _rotate_selected(deg_delta: float) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var it = furniture_config[selected_furniture_id]
	var current_rot = float(it.get("rotation_deg", 0.0))
	var new_rot = fmod(current_rot + deg_delta, 360.0)
	if new_rot < 0.0: new_rot += 360.0
	_set_selected_rotation(new_rot)

func _set_selected_rotation(deg: float) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var it = furniture_config[selected_furniture_id]
	it["rotation_deg"] = deg
	_update_furniture_transform(selected_furniture_id)
	_sync_ui_to_selected_item()
	save_furniture_config()
	queue_redraw()

func _adjust_selected_scale(delta_scale: float) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var it = furniture_config[selected_furniture_id]
	var current_s = float(it.scale)
	_set_selected_scale(clampf(current_s + delta_scale, 0.2, 3.0))

func _set_selected_scale(new_scale: float) -> void:
	if selected_furniture_id.is_empty() or not furniture_config.has(selected_furniture_id):
		return
	var it = furniture_config[selected_furniture_id]
	it.scale = new_scale
	_update_furniture_transform(selected_furniture_id)
	_sync_ui_to_selected_item()
	save_furniture_config()
	queue_redraw()

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

func delete_furniture(id: String) -> void:
	if not furniture_config.has(id):
		return
	furniture_config.erase(id)

	if furniture_sprites.has(id):
		if is_instance_valid(furniture_sprites[id]):
			furniture_sprites[id].queue_free()
		furniture_sprites.erase(id)

	if furniture_colliders.has(id):
		if is_instance_valid(furniture_colliders[id]):
			furniture_colliders[id].queue_free()
		furniture_colliders.erase(id)

	save_furniture_config()
	_rebuild_dropdown()
	_rebuild_restore_dropdown()

	if selected_furniture_id == id:
		if not furniture_config.is_empty():
			_select_furniture(furniture_config.keys()[0])
		else:
			selected_furniture_id = ""
			_sync_ui_to_selected_item()

	queue_redraw()

func restore_furniture(id: String) -> void:
	if not default_furniture_config.has(id):
		return
	furniture_config[id] = default_furniture_config[id].duplicate(true)
	
	var data = furniture_config[id]
	var item_type = data.get("type", "sprite")
	if item_type == "sprite":
		var tex_name = data.get("tex", "")
		var tex = _get_texture_by_name(tex_name)
		if is_instance_valid(tex):
			var sp = Sprite2D.new()
			sp.name = "Expl_Furniture_" + id
			sp.texture = tex
			sp.z_index = data.get("z_idx", 0)
			add_child(sp)
			furniture_sprites[id] = sp

	if data.get("has_col", false) and is_instance_valid(static_body):
		var col = CollisionShape2D.new()
		col.name = "Expl_Col_" + id
		var shape = RectangleShape2D.new()
		col.shape = shape
		static_body.add_child(col)
		furniture_colliders[id] = col

	_update_furniture_transform(id)
	save_furniture_config()
	_rebuild_dropdown()
	_rebuild_restore_dropdown()
	_select_furniture(id)
	status_msg_label.text = "Item '%s' berhasil dipulihkan!" % data.get("name", id)

func save_furniture_config() -> void:
	var json_str = JSON.stringify(furniture_config, "\t")
	var f = FileAccess.open(CONFIG_FILE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(json_str)
		f.close()
		print("[ExplorationHouseInterior] Config perabot berhasil disimpan ke: ", CONFIG_FILE_PATH)

func _load_furniture_config() -> void:
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		return
	var f = FileAccess.open(CONFIG_FILE_PATH, FileAccess.READ)
	if not f:
		return
	var content = f.get_as_text()
	f.close()

	var parsed = JSON.parse_string(content)
	if parsed is Dictionary:
		for id in parsed.keys():
			if furniture_config.has(id):
				var saved_data = parsed[id]
				for k in saved_data.keys():
					furniture_config[id][k] = saved_data[k]
		print("[ExplorationHouseInterior] Config perabot berhasil dimuat dari: ", CONFIG_FILE_PATH)

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
					is_dragging_furniture = true
					var it = furniture_config[hit_id]
					drag_offset = (ROOM_ORIGIN + Vector2(float(it.x), float(it.y))) - world_mpos
					get_viewport().set_input_as_handled()
			else:
				if is_dragging_furniture:
					is_dragging_furniture = false
					save_furniture_config()
					get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and is_dragging_furniture:
		var world_mpos = get_global_mouse_position()
		if not selected_furniture_id.is_empty() and furniture_config.has(selected_furniture_id):
			var new_world_pos = world_mpos + drag_offset
			var local_pos = new_world_pos - ROOM_ORIGIN
			local_pos.x = clampf(local_pos.x, 10.0, ROOM_SIZE.x - 10.0)
			local_pos.y = clampf(local_pos.y, 10.0, ROOM_SIZE.y - 10.0)
			furniture_config[selected_furniture_id].x = local_pos.x
			furniture_config[selected_furniture_id].y = local_pos.y
			_update_furniture_transform(selected_furniture_id)
			_sync_ui_to_selected_item()
			queue_redraw()
			get_viewport().set_input_as_handled()
