extends Node2D
class_name ExplorationHouseInterior

# ==============================================================================
# INTERIOR RUMAH EKSPLORASI (RUMAH IBU MEDELINE / RUMAH PALING SELATAN)
# ==============================================================================

# Koordinat penempatan interior di world space (terisolasi di kanan peta kota)
const ROOM_ORIGIN := Vector2(4600.0, 400.0)
const ROOM_SIZE := Vector2(640.0, 420.0)

# Titik-titik POI interaktif di dalam rumah eksplorasi
const ENTRANCE_POS := Vector2(4600.0 + 110.0, 400.0 + 330.0)
const EXIT_DOOR_POS := Vector2(4600.0 + 110.0, 400.0 + 400.0)
const SAFE_POS := Vector2(4600.0 + 280.0, 400.0 + 75.0)
const CLOCK_POS := Vector2(4600.0 + 60.0, 400.0 + 110.0)
const CALENDAR_PHOTO_POS := Vector2(4600.0 + 420.0, 400.0 + 75.0)
const RECIPE_POS := Vector2(4600.0 + 340.0, 400.0 + 260.0)

var static_body: StaticBody2D
var glow_timer: float = 0.0

# Texture references
var tex_buku_resep: Texture2D
var tex_jam_weker: Texture2D
var tex_kalender: Texture2D
var tex_berangkas: Texture2D
var tex_sofa_panjang: Texture2D
var tex_meja_panjang: Texture2D
var tex_karpet: Texture2D
var tex_bed: Texture2D
var tex_lemari: Texture2D
var tex_laci: Texture2D
var tex_surat: Texture2D

var sprites: Dictionary = {}

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_load_textures()
	_build_room_collisions()
	_setup_furniture_sprites()

func _load_textures() -> void:
	if ResourceLoader.exists("res://Environment/RUMAH IBU/BUKU RESEP.png"):
		tex_buku_resep = load("res://Environment/RUMAH IBU/BUKU RESEP.png")
	if ResourceLoader.exists("res://Environment/RUMAH IBU/jam weker.png"):
		tex_jam_weker = load("res://Environment/RUMAH IBU/jam weker.png")
	if ResourceLoader.exists("res://Environment/RUMAH IBU/kalender.png"):
		tex_kalender = load("res://Environment/RUMAH IBU/kalender.png")
	if ResourceLoader.exists("res://Environment/interactable assets/berangkas.png"):
		tex_berangkas = load("res://Environment/interactable assets/berangkas.png")
	if ResourceLoader.exists("res://Environment/interactable assets/surat.png"):
		tex_surat = load("res://Environment/interactable assets/surat.png")

	if ResourceLoader.exists("res://Environment/ruang tamu/sofaPanjang.png"):
		tex_sofa_panjang = load("res://Environment/ruang tamu/sofaPanjang.png")
	if ResourceLoader.exists("res://Environment/ruang tamu/mejaPanjang.png"):
		tex_meja_panjang = load("res://Environment/ruang tamu/mejaPanjang.png")
	if ResourceLoader.exists("res://Environment/ruang tamu/karpet.png"):
		tex_karpet = load("res://Environment/ruang tamu/karpet.png")
	if ResourceLoader.exists("res://Environment/kamar/bed.png"):
		tex_bed = load("res://Environment/kamar/bed.png")
	if ResourceLoader.exists("res://Environment/kamar/lemari.png"):
		tex_lemari = load("res://Environment/kamar/lemari.png")
	if ResourceLoader.exists("res://Environment/kamar/laci.png"):
		tex_laci = load("res://Environment/kamar/laci.png")

func _build_room_collisions() -> void:
	static_body = StaticBody2D.new()
	static_body.name = "ExplorationInteriorCollisions"
	static_body.collision_layer = 1
	static_body.collision_mask = 0
	add_child(static_body)

	# 1. Dinding Keliling Luar (Outer Walls)
	# Dinding Atas
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 36.0))
	# Dinding Kiri
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y))
	# Dinding Kanan
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y))
	# Dinding Bawah Kiri Pintu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, 80.0, 20.0))
	# Dinding Bawah Kanan Pintu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 140.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, ROOM_SIZE.x - 140.0, 20.0))

	# 2. Dinding Sekat Kamar & Ruang Tamu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 200.0, ROOM_ORIGIN.y + 36.0, 16.0, 120.0))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 380.0, ROOM_ORIGIN.y + 36.0, 16.0, 120.0))
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 200.0, ROOM_ORIGIN.y + 240.0, 16.0, 140.0))

	# 3. Collider Perabotan
	# Sofa Tamu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 75.0, ROOM_ORIGIN.y + 145.0, 70.0, 32.0))
	# Meja Tamu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 85.0, ROOM_ORIGIN.y + 200.0, 50.0, 26.0))
	# Ranjang Ibu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 450.0, ROOM_ORIGIN.y + 60.0, 65.0, 70.0))
	# Lemari Tua
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 550.0, ROOM_ORIGIN.y + 50.0, 55.0, 65.0))
	# Brankas Keluarga
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 265.0, ROOM_ORIGIN.y + 55.0, 32.0, 32.0))
	# Meja Dapur / Buku Resep
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 310.0, ROOM_ORIGIN.y + 245.0, 60.0, 35.0))

func _add_box_collider(body: StaticBody2D, rect: Rect2) -> CollisionShape2D:
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.position + rect.size * 0.5
	body.add_child(col)
	return col

func _setup_furniture_sprites() -> void:
	# 1. Karpet Ruang Tamu
	if tex_karpet:
		_create_sprite("karpet_tamu", tex_karpet, ROOM_ORIGIN + Vector2(110.0, 205.0), 100.0, -1)
		_create_sprite("karpet_kamar", tex_karpet, ROOM_ORIGIN + Vector2(480.0, 160.0), 90.0, -1)

	# 2. Sofa Tamu
	if tex_sofa_panjang:
		_create_sprite("sofa_tamu", tex_sofa_panjang, ROOM_ORIGIN + Vector2(110.0, 160.0), 70.0, 0)

	# 3. Meja Kopi Tamu
	if tex_meja_panjang:
		_create_sprite("meja_tamu", tex_meja_panjang, ROOM_ORIGIN + Vector2(110.0, 210.0), 50.0, 0)

	# 4. Nakas & Jam Weker (Jam Antik)
	if tex_laci:
		_create_sprite("laci_tamu", tex_laci, ROOM_ORIGIN + Vector2(60.0, 115.0), 24.0, 0)
	if tex_jam_weker:
		_create_sprite("jam_weker", tex_jam_weker, ROOM_ORIGIN + Vector2(60.0, 105.0), 18.0, 1)

	# 5. Brankas Baja Keluarga
	if tex_berangkas:
		_create_sprite("brankas_keluarga", tex_berangkas, ROOM_ORIGIN + Vector2(280.0, 75.0), 32.0, 0)

	# 6. Ranjang Ibu
	if tex_bed:
		_create_sprite("bed_ibu", tex_bed, ROOM_ORIGIN + Vector2(480.0, 95.0), 65.0, 0)

	# 7. Lemari Pakaian Kayu
	if tex_lemari:
		_create_sprite("lemari_kamar", tex_lemari, ROOM_ORIGIN + Vector2(575.0, 80.0), 55.0, 0)

	# 8. Nakas Kamar & Kalender / Foto Kenangan
	if tex_laci:
		_create_sprite("laci_kamar", tex_laci, ROOM_ORIGIN + Vector2(420.0, 75.0), 24.0, 0)
	if tex_kalender:
		_create_sprite("kalender_ibu", tex_kalender, ROOM_ORIGIN + Vector2(420.0, 60.0), 20.0, 1)

	# 9. Meja Resep & Buku Resep Ibu
	if tex_meja_panjang:
		_create_sprite("meja_resep", tex_meja_panjang, ROOM_ORIGIN + Vector2(340.0, 260.0), 60.0, 0)
	if tex_buku_resep:
		_create_sprite("buku_resep", tex_buku_resep, ROOM_ORIGIN + Vector2(335.0, 255.0), 20.0, 1)
	if tex_surat:
		_create_sprite("catatan_ibu", tex_surat, ROOM_ORIGIN + Vector2(358.0, 255.0), 16.0, 1)

func _create_sprite(id: String, tex: Texture2D, pos: Vector2, target_w: float = 40.0, z_idx: int = 0) -> Sprite2D:
	var sp = Sprite2D.new()
	sp.name = "Sprite_" + id
	sp.texture = tex
	sp.position = pos
	var ratio: float = 1.0
	if tex and tex.get_width() > 0:
		ratio = target_w / float(tex.get_width())
	sp.scale = Vector2(ratio, ratio)
	sp.z_index = z_idx
	add_child(sp)
	sprites[id] = sp
	return sp

func _process(delta: float) -> void:
	glow_timer += delta * 3.2
	queue_redraw()

func _draw() -> void:
	# 1. LANTAI DASAR PARQUET KAYU HANGAT
	var floor_rect = Rect2(ROOM_ORIGIN.x + 20.0, ROOM_ORIGIN.y + 36.0, ROOM_SIZE.x - 40.0, ROOM_SIZE.y - 56.0)
	draw_rect(floor_rect, Color(0.24, 0.18, 0.13), true)

	var plank_h: float = 16.0
	var curr_y: float = floor_rect.position.y
	while curr_y < floor_rect.end.y:
		draw_line(Vector2(floor_rect.position.x, curr_y), Vector2(floor_rect.end.x, curr_y), Color(0.18, 0.13, 0.09, 0.5), 1.0)
		curr_y += plank_h

	# Lantai Ruang Tengah / Dapur Ubin Vintage
	var tile_box = Rect2(ROOM_ORIGIN.x + 216.0, ROOM_ORIGIN.y + 200.0, 160.0, 180.0)
	draw_rect(tile_box, Color(0.22, 0.20, 0.18), true)
	for tx in range(int(tile_box.position.x), int(tile_box.end.x), 20):
		draw_line(Vector2(tx, tile_box.position.y), Vector2(tx, tile_box.end.y), Color(0.16, 0.14, 0.12), 1.0)
	for ty in range(int(tile_box.position.y), int(tile_box.end.y), 20):
		draw_line(Vector2(tile_box.position.x, ty), Vector2(tile_box.end.x, ty), Color(0.16, 0.14, 0.12), 1.0)

	# 2. DINDING LUAR BANGUNAN (WALLS)
	var wall_col = Color(0.14, 0.11, 0.13)
	var trim_col = Color(0.38, 0.28, 0.22)

	# Dinding Atas
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 36.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + 36.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + 36.0), trim_col, 2.5)

	# Dinding Kiri & Kanan
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + 20.0, ROOM_ORIGIN.y), Vector2(ROOM_ORIGIN.x + 20.0, ROOM_ORIGIN.y + ROOM_SIZE.y), trim_col, 2.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0, ROOM_ORIGIN.y), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0, ROOM_ORIGIN.y + ROOM_SIZE.y), trim_col, 2.0)

	# Dinding Bawah (dengan lubang pintu)
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, 80.0, 20.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + 80.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0), Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0), trim_col, 2.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + 140.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, ROOM_SIZE.x - 140.0, 20.0), wall_col, true)
	draw_line(Vector2(ROOM_ORIGIN.x + 140.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0), trim_col, 2.0)

	# 3. DINDING SEKAT RUANGAN
	draw_rect(Rect2(ROOM_ORIGIN.x + 200.0, ROOM_ORIGIN.y + 36.0, 12.0, 120.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 200.0, ROOM_ORIGIN.y + 36.0, 12.0, 120.0), trim_col, false, 1.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + 380.0, ROOM_ORIGIN.y + 36.0, 12.0, 120.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 380.0, ROOM_ORIGIN.y + 36.0, 12.0, 120.0), trim_col, false, 1.0)
	draw_rect(Rect2(ROOM_ORIGIN.x + 200.0, ROOM_ORIGIN.y + 240.0, 12.0, 140.0), wall_col, true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 200.0, ROOM_ORIGIN.y + 240.0, 12.0, 140.0), trim_col, false, 1.0)

	# Keset Pintu Keluar
	var mat_rect = Rect2(ROOM_ORIGIN.x + 85.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 28.0, 50.0, 16.0)
	draw_rect(mat_rect, Color(0.42, 0.16, 0.16), true)
	draw_rect(mat_rect, Color(0.65, 0.25, 0.22), false, 1.5)

	# 4. GLOWING HIGHLIGHT PADA TITIK-TITIK EKSPLORASI
	var pulse = 0.20 + 0.08 * sin(glow_timer)
	# Glow Brankas Baja
	draw_circle(SAFE_POS, 22.0, Color(0.3, 0.9, 0.6, pulse))
	# Glow Jam Weker
	draw_circle(CLOCK_POS, 18.0, Color(1.0, 0.85, 0.4, pulse))
	# Glow Kalender / Foto
	draw_circle(CALENDAR_PHOTO_POS, 18.0, Color(0.4, 0.8, 1.0, pulse))
	# Glow Buku Resep & Surat
	draw_circle(RECIPE_POS, 20.0, Color(1.0, 0.9, 0.5, pulse))

# ==============================================================================
# GETTER KOORDINAT POI INTERAKSI
# ==============================================================================
func get_exit_door_pos() -> Vector2:
	return EXIT_DOOR_POS

func get_safe_pos() -> Vector2:
	return SAFE_POS

func get_clock_pos() -> Vector2:
	return CLOCK_POS

func get_calendar_photo_pos() -> Vector2:
	return CALENDAR_PHOTO_POS

func get_recipe_pos() -> Vector2:
	return RECIPE_POS
