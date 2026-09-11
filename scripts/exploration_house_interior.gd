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
		"base_w": 28.0,
		"has_col": true,
		"col_w": 28.0, "col_h": 28.0,
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
	"polaroid_ibu": {
		"name": "Foto Polaroid Kenangan Ibu",
		"type": "sprite",
		"tex": "tex_polaroid_ibu",
		"x": 188.0, "y": 70.0,
		"scale": 1.0,
		"base_w": 18.0,
		"has_col": false,
		"z_idx": 1
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
	_setup_furniture_nodes()

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
	# Clock
	draw_circle(get_clock_pos(), 14.0, Color(1.0, 0.85, 0.40, pulse))
	# Photo & Calendar
	draw_circle(get_calendar_photo_pos(), 15.0, Color(0.45, 0.82, 1.0, pulse))
	# Recipe Book
	draw_circle(get_recipe_pos(), 15.0, Color(1.0, 0.90, 0.50, pulse))

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

func get_calendar_photo_pos() -> Vector2:
	if furniture_config.has("meja_keluarga"):
		var m = furniture_config["meja_keluarga"]
		return ROOM_ORIGIN + Vector2(float(m.x), float(m.y))
	return ROOM_ORIGIN + Vector2(195.0, 72.0)

func get_recipe_pos() -> Vector2:
	if furniture_config.has("meja_resep"):
		var r = furniture_config["meja_resep"]
		return ROOM_ORIGIN + Vector2(float(r.x), float(r.y))
	return ROOM_ORIGIN + Vector2(260.0, 245.0)
