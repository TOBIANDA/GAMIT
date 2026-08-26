@tool
extends Node2D

const COLOR_VOID            = Color(0.12, 0.13, 0.15, 1.0)

const COLOR_ASPHALT         = Color(0.22, 0.23, 0.25, 1.0)
const COLOR_ASPHALT_DARK    = Color(0.18, 0.19, 0.21, 1.0)
const COLOR_CURB_LINE       = Color(0.55, 0.58, 0.62, 0.85)
const COLOR_LANE_DASH       = Color(0.85, 0.88, 0.92, 0.80)
const COLOR_SIDEWALK        = Color(0.42, 0.44, 0.47, 1.0)
const COLOR_SIDEWALK_BEVEL  = Color(0.28, 0.30, 0.33, 1.0)

const COLOR_ROOM_STONE_A    = Color(0.76, 0.74, 0.69, 1.0)
const COLOR_ROOM_STONE_B    = Color(0.68, 0.67, 0.64, 1.0)
const COLOR_ROOM_OCHRE      = Color(0.74, 0.58, 0.42, 1.0)
const COLOR_ROOM_DARK       = Color(0.16, 0.17, 0.20, 1.0)
const COLOR_ROOM_RUG        = Color(0.28, 0.16, 0.24, 1.0)

const COLOR_PARQUET_WOOD    = Color(0.56, 0.38, 0.24, 1.0)
const COLOR_PARQUET_DARK    = Color(0.44, 0.28, 0.18, 1.0)
const COLOR_RUG_RED         = Color(0.62, 0.15, 0.18, 1.0)
const COLOR_RUG_GOLD        = Color(0.88, 0.72, 0.28, 1.0)
const COLOR_CORKBOARD       = Color(0.76, 0.60, 0.42, 1.0)

const COLOR_HOSPITAL_TILE   = Color(0.88, 0.94, 0.96, 1.0)
const COLOR_HOSPITAL_GROUT  = Color(0.65, 0.76, 0.82, 0.70)
const COLOR_MED_RED         = Color(0.85, 0.20, 0.20, 1.0)
const COLOR_STEEL_LIGHT     = Color(0.78, 0.82, 0.86, 1.0)
const COLOR_STEEL_DARK      = Color(0.48, 0.52, 0.58, 1.0)
const COLOR_ECG_GREEN       = Color(0.20, 0.95, 0.45, 1.0)
const COLOR_DARKROOM_RED    = Color(0.95, 0.15, 0.15, 0.35)

const COLOR_PLAZA_TILES     = Color(0.72, 0.70, 0.65, 1.0)
const COLOR_PLAZA_TILE_LINE = Color(0.58, 0.56, 0.52, 0.60)
const COLOR_GRASS           = Color(0.45, 0.55, 0.22, 1.0)
const COLOR_TREE_DARK       = Color(0.24, 0.32, 0.14, 1.0)
const COLOR_TREE_LIGHT      = Color(0.38, 0.48, 0.20, 1.0)
const COLOR_HELIPAD_RING    = Color(0.92, 0.78, 0.22, 1.0)

const COLOR_DESK_WOOD       = Color(0.52, 0.44, 0.36, 1.0)
const COLOR_DESK_RIM        = Color(0.24, 0.20, 0.16, 1.0)
const COLOR_WALL_LINE       = Color(0.10, 0.11, 0.13, 1.0)

const COLOR_TRACK_BALLAST   = Color(0.20, 0.21, 0.23, 1.0)
const COLOR_TRACK_RAIL      = Color(0.70, 0.74, 0.80, 1.0)
const COLOR_TRACK_TIE       = Color(0.38, 0.33, 0.28, 1.0)

const WT = 6.0
var tex_hospital: Texture2D
var tex_police: Texture2D
var tex_rumah_mc: Texture2D
var tex_rumah_depan: Texture2D
var tex_rumah_belakang: Texture2D
var tex_rumah_samping: Texture2D
var tex_pagar: Texture2D
var tex_pagar_samping: Texture2D
var tex_pintu_pagar: Texture2D
var tex_telepon: Texture2D

@export_group("1. Pagar Depan Kiri")
@export var pagar_kiri_geser_x: float = 0.0:
	set(val):
		pagar_kiri_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kiri_geser_y: float = 0.0:
	set(val):
		pagar_kiri_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kiri_lebar: float = 62.0:
	set(val):
		pagar_kiri_lebar = 62.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_kiri_skala: float = 1.0:
	set(val):
		pagar_kiri_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("2. Pintu Pagar Tengah")
@export var pintu_pagar_geser_x: float = 0.0:
	set(val):
		pintu_pagar_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pintu_pagar_geser_y: float = 0.0:
	set(val):
		pintu_pagar_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pintu_pagar_lebar: float = 32.0:
	set(val):
		pintu_pagar_lebar = 32.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pintu_pagar_skala: float = 1.0:
	set(val):
		pintu_pagar_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("3. Pagar Depan Kanan")
@export var pagar_kanan_geser_x: float = 0.0:
	set(val):
		pagar_kanan_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kanan_geser_y: float = 0.0:
	set(val):
		pagar_kanan_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kanan_lebar: float = 62.0:
	set(val):
		pagar_kanan_lebar = 62.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_kanan_skala: float = 1.0:
	set(val):
		pagar_kanan_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("4. Pagar Belakang (Atas)")
@export var pagar_belakang_geser_x: float = 0.0:
	set(val):
		pagar_belakang_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_belakang_geser_y: float = 0.0:
	set(val):
		pagar_belakang_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_belakang_gap_panel: float = 0.0:
	set(val):
		pagar_belakang_gap_panel = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_belakang_panel_lebar: float = 52.0:
	set(val):
		pagar_belakang_panel_lebar = 52.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_belakang_skala: float = 1.0:
	set(val):
		pagar_belakang_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("5. Pagar Samping (Vertikal) & Gap Sudut")
@export var pagar_samping_kiri_geser_x: float = 0.0:
	set(val):
		pagar_samping_kiri_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_kanan_geser_x: float = 0.0:
	set(val):
		pagar_samping_kanan_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_geser_y: float = 0.0:
	set(val):
		pagar_samping_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var gap_sudut_atas_samping: float = 0.0:
	set(val):
		gap_sudut_atas_samping = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_tinggi: float = 130.0:
	set(val):
		pagar_samping_tinggi = 130.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_samping_lebar: float = 16.0:
	set(val):
		pagar_samping_lebar = 16.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_samping_skala: float = 1.0:
	set(val):
		pagar_samping_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

var tex_bed: Texture2D
var tex_karpet: Texture2D
var tex_laci: Texture2D
var tex_lemari: Texture2D

var tex_baskom: Texture2D
var tex_surat: Texture2D
var collision_bodies: Array[StaticBody2D] = []
var nav_region: NavigationRegion2D

func _ready() -> void:
	z_index = -1
	_load_textures()
	if not Engine.is_editor_hint():
		_build_all_colliders()
		_setup_navigation_region()
	queue_redraw()

func _load_textures() -> void:
	tex_hospital = load("res://Bangunan/Hospital.png")
	tex_police = load("res://Bangunan/police.png")
	tex_rumah_mc = load("res://Bangunan/rumahMC.png")
	tex_rumah_depan = load("res://Bangunan/rumahTampakDepan.png")
	tex_rumah_belakang = load("res://Bangunan/rumahTampakBelakang.png")
	tex_rumah_samping = load("res://Bangunan/rumahTampakSamping.png")
	tex_pagar = load("res://Bangunan/pagar.png")
	tex_pagar_samping = load("res://Bangunan/pagar samping.png")
	tex_pintu_pagar = load("res://Bangunan/pintuPagar.png")
	tex_telepon = load("res://Bangunan/stasiun telepon.png")

	tex_bed = load("res://kamar/bed.png")
	tex_karpet = load("res://kamar/karpet.png")
	tex_laci = load("res://kamar/laci.png")
	tex_lemari = load("res://kamar/lemari.png")

	tex_baskom = load("res://interactable assets/baskom cetak photo.png")
	tex_surat = load("res://interactable assets/surat.png")

func _draw_texture_fit(tex: Texture2D, target_rect: Rect2) -> void:
	if not is_instance_valid(tex):
		return
	var src_size = tex.get_size()
	if src_size.x <= 0 or src_size.y <= 0:
		return
	var scale_factor = min(target_rect.size.x / src_size.x, target_rect.size.y / src_size.y)
	var draw_size = src_size * scale_factor
	var draw_pos = target_rect.position + (target_rect.size - draw_size) * 0.5
	draw_texture_rect(tex, Rect2(draw_pos, draw_size), false)

func _draw_texture_flipped(tex: Texture2D, rect: Rect2, flip_h: bool = false, flip_v: bool = false) -> void:
	if not is_instance_valid(tex):
		return
	if not flip_h and not flip_v:
		draw_texture_rect(tex, rect, false)
		return
	var scale_vec = Vector2(-1.0 if flip_h else 1.0, -1.0 if flip_v else 1.0)
	var origin_x = rect.position.x + (rect.size.x if flip_h else 0.0)
	var origin_y = rect.position.y + (rect.size.y if flip_v else 0.0)
	draw_set_transform(Vector2(origin_x, origin_y), 0.0, scale_vec)
	draw_texture_rect(tex, Rect2(0, 0, rect.size.x, rect.size.y), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _setup_navigation_region() -> void:
	nav_region = NavigationRegion2D.new()
	nav_region.name = "NavigationRegion2D"
	var nav_poly = NavigationPolygon.new()

	var outer_boundary = PackedVector2Array([
		Vector2(0, 192),
		Vector2(2160, 192),
		Vector2(2160, 1311),
		Vector2(0, 1311)
	])
	nav_poly.add_outline(outer_boundary)

	nav_poly.add_outline(PackedVector2Array([
		Vector2(10, 334), Vector2(506, 334), Vector2(506, 776),
		Vector2(202, 776), Vector2(202, 923), Vector2(10, 923)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(10, 961), Vector2(347, 961), Vector2(347, 1301), Vector2(10, 1301)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(649, 334), Vector2(1526, 334), Vector2(1526, 704),
		Vector2(1168, 704), Vector2(1168, 559), Vector2(649, 559)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(649, 700), Vector2(1040, 700), Vector2(1040, 1235),
		Vector2(475, 1235), Vector2(475, 955), Vector2(649, 955)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(1636, 334), Vector2(2006, 334), Vector2(2006, 704), Vector2(1636, 704)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(1591, 859), Vector2(2006, 859), Vector2(2006, 1259), Vector2(1591, 1259)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(1168, 850), Vector2(1418, 850), Vector2(1418, 1040), Vector2(1168, 1040)
	]))

	nav_poly.make_polygons_from_outlines()
	nav_region.navigation_polygon = nav_poly
	add_child(nav_region)

func _draw() -> void:
	draw_rect(Rect2(-200, -200, 2800, 1800), COLOR_VOID, true)

	draw_rect(Rect2(0, 0, 2160, 1311), COLOR_SIDEWALK, true)

	for gx in range(40, 2160, 40):
		draw_line(Vector2(gx, 0), Vector2(gx, 1311), Color(0, 0, 0, 0.08), 1.0)
	for gy in range(40, 1311, 40):
		draw_line(Vector2(0, gy), Vector2(2160, gy), Color(0, 0, 0, 0.08), 1.0)

	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		var r_rect = Rect2(sq_x, 36, 156, 156)
		
		draw_rect(r_rect, Color(0.35, 0.52, 0.22), true)
		draw_rect(Rect2(sq_x + 64, 130, 28, 62), Color(0.70, 0.68, 0.62), true)

		if i == 6:
			_draw_detective_house(r_rect)
		else:
			_draw_texture_fit(tex_rumah_depan, Rect2(sq_x + 12, 42, 132, 116))

			var sk_kiri = 1.0 if (pagar_kiri_skala == null or pagar_kiri_skala <= 0.0) else float(pagar_kiri_skala)
			var sk_pintu = 1.0 if (pintu_pagar_skala == null or pintu_pagar_skala <= 0.0) else float(pintu_pagar_skala)
			var sk_kanan = 1.0 if (pagar_kanan_skala == null or pagar_kanan_skala <= 0.0) else float(pagar_kanan_skala)
			var sk_belakang = 1.0 if (pagar_belakang_skala == null or pagar_belakang_skala <= 0.0) else float(pagar_belakang_skala)
			var sk_samping = 1.0 if (pagar_samping_skala == null or pagar_samping_skala <= 0.0) else float(pagar_samping_skala)

			var pw = pagar_belakang_panel_lebar * sk_belakang
			var pg = pagar_belakang_gap_panel
			# Pagar Belakang (3 panel dengan pengaturan lebar dan gap)
			draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_belakang_geser_x, 32 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
			draw_texture_rect(tex_pagar, Rect2(sq_x + pw + pg + pagar_belakang_geser_x, 32 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
			draw_texture_rect(tex_pagar, Rect2(sq_x + (pw + pg) * 2.0 + pagar_belakang_geser_x, 32 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)

			# Pagar Samping Kiri & Kanan (Aset Pagar Samping Vertikal dengan Gap Sudut Atas)
			var side_y = 36 + pagar_samping_geser_y + gap_sudut_atas_samping
			var side_w = pagar_samping_lebar * sk_samping
			var side_h = pagar_samping_tinggi * sk_samping
			_draw_texture_fit(tex_pagar_samping, Rect2(sq_x - 10 + pagar_samping_kiri_geser_x, side_y, side_w, side_h))
			_draw_texture_flipped(tex_pagar_samping, Rect2(sq_x + 150 + pagar_samping_kanan_geser_x, side_y, side_w, side_h), true, false)

			# Pagar Depan Kiri
			draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_kiri_geser_x, 166 + pagar_kiri_geser_y, pagar_kiri_lebar * sk_kiri, 26 * sk_kiri), false)
			# Pintu Pagar Tengah (Jalan Masuk)
			draw_texture_rect(tex_pintu_pagar, Rect2(sq_x + 62 + pintu_pagar_geser_x, 162 + pintu_pagar_geser_y, pintu_pagar_lebar * sk_pintu, 30 * sk_pintu), false)
			# Pagar Depan Kanan (di-rotate/mirror horizontal)
			_draw_texture_flipped(tex_pagar, Rect2(sq_x + 94 + pagar_kanan_geser_x, 166 + pagar_kanan_geser_y, pagar_kanan_lebar * sk_kanan, 26 * sk_kanan), true, false)

	# ── Stasiun Telepon Umum Kota ─────────────────────────────────────────────
	var phone_spots = [
		Vector2(480, 240),
		Vector2(1040, 560),
		Vector2(1980, 240),
		Vector2(1460, 1220)
	]
	for p_pos in phone_spots:
		_draw_texture_fit(tex_telepon, Rect2(p_pos.x, p_pos.y, 28, 42))

	var l_pts = PackedVector2Array([
		Vector2(0, 324), Vector2(516, 324), Vector2(516, 786),
		Vector2(192, 786), Vector2(192, 933), Vector2(0, 933)
	])
	draw_colored_polygon(l_pts, COLOR_ROOM_STONE_A)
	_draw_tile_pattern(Rect2(0, 324, 516, 462), COLOR_PLAZA_TILE_LINE)

	_draw_desk(Rect2(9, 324, 156, 156))
	_draw_desk(Rect2(195, 324, 156, 156))
	_draw_desk(Rect2(411, 324, 105, 156))
	_draw_desk(Rect2(411, 495, 105, 156))
	_draw_desk(Rect2(411, 666, 105, 120))
	_draw_desk(Rect2(25, 800, 140, 100))

	_draw_room_pavement(Rect2(0, 951, 357, 360), COLOR_ROOM_STONE_B)
	_draw_texture_fit(tex_police, Rect2(40, 965, 270, 190))
	_draw_texture_fit(tex_lemari, Rect2(20, 1180, 50, 60))
	_draw_texture_fit(tex_laci, Rect2(80, 1180, 30, 40))
	_draw_texture_fit(tex_surat, Rect2(170, 1040, 32, 32))

	var top_complex_pts = PackedVector2Array([
		Vector2(639, 324), Vector2(1536, 324), Vector2(1536, 714),
		Vector2(1158, 714), Vector2(1158, 549), Vector2(639, 549)
	])
	draw_colored_polygon(top_complex_pts, COLOR_ROOM_STONE_A)
	_draw_tile_pattern(Rect2(639, 324, 897, 225), COLOR_PLAZA_TILE_LINE)

	_draw_hospital_morgue(Rect2(639, 324, 380, 225))

	_draw_courtyard_garden(Vector2(1090, 435), 55.0)
	_draw_desk(Rect2(1191, 354, 120, 120))
	_draw_desk(Rect2(1341, 354, 120, 120))
	_draw_desk(Rect2(1191, 585, 120, 120))
	_draw_desk(Rect2(1341, 585, 120, 120))

	var bot_complex_pts = PackedVector2Array([
		Vector2(639, 690), Vector2(1050, 690), Vector2(1050, 1245),
		Vector2(465, 1245), Vector2(465, 945), Vector2(639, 945)
	])
	draw_colored_polygon(bot_complex_pts, COLOR_ROOM_STONE_B)
	_draw_tile_pattern(Rect2(465, 945, 585, 300), COLOR_PLAZA_TILE_LINE)

	_draw_desk(Rect2(672, 730, 340, 170))
	_draw_desk(Rect2(510, 990, 490, 100))
	_draw_desk(Rect2(510, 1120, 490, 100))
	_draw_courtyard_garden(Vector2(780, 830), 40.0)

	_draw_room_pavement(Rect2(1158, 840, 270, 210), COLOR_ROOM_OCHRE)
	_draw_texture_fit(tex_rumah_belakang, Rect2(1180, 860, 220, 170))

	_draw_room_pavement(Rect2(1626, 324, 390, 390), COLOR_ROOM_STONE_A)
	_draw_texture_fit(tex_rumah_samping, Rect2(1650, 340, 340, 350))

	draw_rect(Rect2(1581, 849, 504, 420), COLOR_ROOM_DARK, true)
	draw_rect(Rect2(1640, 900, 385, 310), COLOR_ROOM_RUG, true)
	draw_circle(Vector2(1833, 1059), 110.0, Color(0.85, 0.72, 0.25, 0.35))
	draw_circle(Vector2(1833, 1059), 85.0, Color(0.12, 0.13, 0.16, 1.0))
	draw_circle(Vector2(1833, 1059), 80.0, Color(0.85, 0.72, 0.25, 0.8))
	draw_circle(Vector2(1833, 1059), 74.0, Color(0.12, 0.13, 0.16, 1.0))
	draw_rect(Rect2(1530, 1000, 60, 120), COLOR_ROOM_RUG, true)
	draw_rect(Rect2(1770, 810, 125, 60), COLOR_ROOM_RUG, true)

	_draw_asphalt_strip(Rect2(0, 192, 2160, 132), true, 2)

	_draw_asphalt_strip(Rect2(516, 192, 123, 594), false, 1)
	_draw_asphalt_strip(Rect2(192, 786, 447, 159), true, 2)
	_draw_asphalt_strip(Rect2(357, 945, 108, 366), false, 1)

	_draw_asphalt_strip(Rect2(639, 549, 519, 141), true, 2)
	_draw_asphalt_strip(Rect2(1050, 714, 576, 126), true, 2)

	_draw_asphalt_strip(Rect2(1536, 192, 90, 522), false, 1)

	_draw_asphalt_strip(Rect2(2016, 192, 144, 1119), false, 2)

	_draw_asphalt_strip(Rect2(357, 1245, 1803, 66), true, 1)

	draw_rect(Rect2(2160, 0, 162, 1311), COLOR_TRACK_BALLAST, true)
	draw_line(Vector2(2185, 0), Vector2(2185, 1311), COLOR_TRACK_RAIL, 4.5)
	draw_line(Vector2(2295, 0), Vector2(2295, 1311), COLOR_TRACK_RAIL, 4.5)
	for ty in range(12, 1311, 16):
		draw_line(Vector2(2170, ty), Vector2(2310, ty), COLOR_TRACK_TIE, 3.5)

	draw_line(Vector2(0, 324), Vector2(516, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 324), Vector2(516, 510), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 570), Vector2(516, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 786), Vector2(380, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(320, 786), Vector2(192, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(192, 786), Vector2(192, 933), COLOR_WALL_LINE, WT)
	draw_line(Vector2(192, 933), Vector2(0, 933), COLOR_WALL_LINE, WT)

	draw_line(Vector2(0, 951), Vector2(357, 951), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 951), Vector2(357, 1080), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 1150), Vector2(357, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 1311), Vector2(0, 1311), COLOR_WALL_LINE, WT)

	draw_line(Vector2(639, 324), Vector2(1000, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1060, 324), Vector2(1536, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 324), Vector2(1536, 480), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 540), Vector2(1536, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 714), Vector2(1158, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 714), Vector2(1158, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 549), Vector2(639, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 549), Vector2(639, 440), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 380), Vector2(639, 324), COLOR_WALL_LINE, WT)

	draw_line(Vector2(639, 690), Vector2(1050, 690), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 690), Vector2(1050, 900), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 960), Vector2(1050, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 1245), Vector2(465, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 1245), Vector2(465, 945), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 945), Vector2(639, 945), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 945), Vector2(639, 810), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 750), Vector2(639, 690), COLOR_WALL_LINE, WT)

	draw_line(Vector2(1158, 840), Vector2(1260, 840), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1320, 840), Vector2(1428, 840), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 840), Vector2(1428, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 1050), Vector2(1158, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 1050), Vector2(1158, 840), COLOR_WALL_LINE, WT)

	draw_line(Vector2(1626, 324), Vector2(2016, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 324), Vector2(2016, 480), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 540), Vector2(2016, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 714), Vector2(1626, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1626, 714), Vector2(1626, 540), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1626, 480), Vector2(1626, 324), COLOR_WALL_LINE, WT)

	draw_line(Vector2(1581, 849), Vector2(1770, 849), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1890, 849), Vector2(2085, 849), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2085, 849), Vector2(2085, 1269), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2085, 1269), Vector2(1581, 1269), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1581, 1269), Vector2(1581, 1120), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1581, 1000), Vector2(1581, 849), COLOR_WALL_LINE, WT)

	draw_line(Vector2(2160, 0), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	_draw_poi_badge(Vector2(1170, 270), "Rumah Detektif", Color(0.35, 0.65, 0.95))
	_draw_poi_badge(Vector2(350, 258),  "Kantor Polisi",  Color(0.25, 0.50, 0.85))
	_draw_poi_badge(Vector2(2088, 550), "Stasiun Kereta", Color(0.95, 0.70, 0.20))
	_draw_poi_badge(Vector2(594, 550),  "Kamar Jenazah",  Color(0.85, 0.35, 0.35))
	_draw_poi_badge(Vector2(180, 1050), "Brankas Ibu",    Color(0.80, 0.50, 0.90))
	_draw_poi_badge(Vector2(1833, 1059),"Altar Dewa",     Color(0.70, 0.25, 0.95))

func _draw_detective_house(rect: Rect2) -> void:
	draw_rect(rect, COLOR_PARQUET_WOOD, true)
	for py in range(int(rect.position.y) + 12, int(rect.end.y), 14):
		draw_line(Vector2(rect.position.x, py), Vector2(rect.end.x, py), COLOR_PARQUET_DARK, 1.0)

	_draw_texture_fit(tex_karpet, Rect2(rect.position.x + 28, rect.position.y + 40, 96, 75))

	_draw_texture_fit(tex_bed, Rect2(rect.position.x + 8, rect.position.y + 10, 46, 56))

	_draw_texture_fit(tex_lemari, Rect2(rect.position.x + 102, rect.position.y + 8, 44, 52))

	var cork_rect = Rect2(rect.position.x + 56, rect.position.y + 4, 44, 20)
	draw_rect(cork_rect, COLOR_CORKBOARD, true)
	draw_rect(cork_rect, Color(0.35, 0.22, 0.12), false, 1.5)
	draw_rect(Rect2(cork_rect.position.x + 4, cork_rect.position.y + 3, 10, 10), Color(0.95, 0.95, 0.90), true)
	draw_rect(Rect2(cork_rect.position.x + 18, cork_rect.position.y + 3, 12, 9), Color(0.90, 0.88, 0.80), true)
	draw_line(Vector2(cork_rect.position.x + 9, cork_rect.position.y + 8), Vector2(cork_rect.position.x + 24, cork_rect.position.y + 7), Color(0.9, 0.15, 0.15), 1.5)

	var desk_rect = Rect2(rect.position.x + 32, rect.position.y + 76, 88, 48)
	draw_rect(Rect2(desk_rect.position + Vector2(3, 3), desk_rect.size), Color(0, 0, 0, 0.35), true)
	draw_rect(desk_rect, Color(0.36, 0.20, 0.12), true)
	draw_rect(desk_rect, Color(0.55, 0.35, 0.20), false, 2.0)

	_draw_texture_fit(tex_laci, Rect2(rect.position.x + 8, rect.position.y + 76, 22, 26))

	_draw_texture_fit(tex_surat, Rect2(desk_rect.position.x + 10, desk_rect.position.y + 12, 22, 22))

	draw_rect(Rect2(desk_rect.position.x + 36, desk_rect.position.y + 10, 22, 18), Color(0.12, 0.12, 0.15), true)
	draw_rect(Rect2(desk_rect.position.x + 40, desk_rect.position.y + 5, 14, 5), Color(0.95, 0.95, 0.95), true)
	draw_circle(Vector2(desk_rect.position.x + 72, desk_rect.position.y + 18), 14.0, Color(1.0, 0.92, 0.45, 0.28))
	draw_circle(Vector2(desk_rect.position.x + 72, desk_rect.position.y + 18), 4.5, Color(0.18, 0.52, 0.28))

func _draw_hospital_morgue(rect: Rect2) -> void:
	draw_rect(rect, COLOR_HOSPITAL_TILE, true)
	for tx in range(int(rect.position.x) + 24, int(rect.end.y), 24):
		draw_line(Vector2(tx, rect.position.y), Vector2(tx, rect.end.y), COLOR_HOSPITAL_GROUT, 1.0)
	for ty in range(int(rect.position.y) + 24, int(rect.end.y), 24):
		draw_line(Vector2(rect.position.x, ty), Vector2(rect.end.x, ty), COLOR_HOSPITAL_GROUT, 1.0)

	_draw_texture_fit(tex_hospital, Rect2(rect.position.x + 12, rect.position.y + 10, 150, 110))

	var center_m = Vector2(rect.position.x + 190, rect.position.y + 110)
	draw_circle(center_m, 26.0, Color(1, 1, 1, 0.95))
	draw_circle(center_m, 26.0, COLOR_HOSPITAL_GROUT, false, 2.0)
	draw_rect(Rect2(center_m.x - 5, center_m.y - 16, 10, 32), COLOR_MED_RED, true)
	draw_rect(Rect2(center_m.x - 16, center_m.y - 5, 32, 10), COLOR_MED_RED, true)

	var table_rect = Rect2(rect.position.x + 50, rect.position.y + 140, 140, 65)
	draw_rect(Rect2(table_rect.position + Vector2(3, 3), table_rect.size), Color(0, 0, 0, 0.28), true)
	draw_rect(table_rect, COLOR_STEEL_LIGHT, true)
	draw_rect(table_rect, COLOR_STEEL_DARK, false, 2.5)
	draw_rect(Rect2(table_rect.position + Vector2(6, 6), table_rect.size - Vector2(12, 12)), Color(0.68, 0.74, 0.78), true)
	draw_circle(table_rect.get_center(), 48.0, Color(1.0, 1.0, 1.0, 0.22))
	draw_circle(table_rect.get_center(), 14.0, Color(0.95, 0.98, 1.0, 0.85))

	var darkroom_rect = Rect2(rect.position.x + 230, rect.position.y + 35, 135, 80)
	draw_rect(darkroom_rect, Color(0.12, 0.13, 0.15), true)
	draw_rect(darkroom_rect, Color(0.4, 0.15, 0.15), false, 2.0)
	draw_circle(Vector2(darkroom_rect.position.x + 68, darkroom_rect.position.y + 40), 45.0, COLOR_DARKROOM_RED)

	_draw_texture_fit(tex_baskom, Rect2(darkroom_rect.position.x + 15, darkroom_rect.position.y + 12, 105, 55))

	draw_line(Vector2(darkroom_rect.position.x + 8, darkroom_rect.position.y + 68), Vector2(darkroom_rect.end.x - 8, darkroom_rect.position.y + 68), Color(0.9, 0.9, 0.9), 1.0)
	draw_rect(Rect2(darkroom_rect.position.x + 35, darkroom_rect.position.y + 62, 12, 10), Color(0.95, 0.95, 0.95), true)

	var ecg_rect = Rect2(rect.position.x + 225, rect.position.y + 135, 60, 45)
	draw_rect(ecg_rect, Color(0.08, 0.09, 0.11), true)
	draw_rect(ecg_rect, Color(0.40, 0.45, 0.50), false, 2.0)
	var ecg_pts = PackedVector2Array([
		Vector2(ecg_rect.position.x + 4, ecg_rect.position.y + 22),
		Vector2(ecg_rect.position.x + 18, ecg_rect.position.y + 22),
		Vector2(ecg_rect.position.x + 24, ecg_rect.position.y + 8),
		Vector2(ecg_rect.position.x + 30, ecg_rect.position.y + 36),
		Vector2(ecg_rect.position.x + 36, ecg_rect.position.y + 22),
		Vector2(ecg_rect.position.x + 56, ecg_rect.position.y + 22)
	])
	draw_polyline(ecg_pts, COLOR_ECG_GREEN, 2.0)

	var freezer_rect = Rect2(rect.position.x + 10, rect.position.y + 10, 85, 30)
	draw_rect(freezer_rect, COLOR_STEEL_DARK, true)
	draw_rect(freezer_rect, Color(0.2, 0.22, 0.25), false, 1.5)
	for fi in range(3):
		var fx = freezer_rect.position.x + 4 + fi * 27
		draw_rect(Rect2(fx, freezer_rect.position.y + 4, 23, 22), COLOR_STEEL_LIGHT, true)
		draw_rect(Rect2(fx + 6, freezer_rect.position.y + 12, 11, 4), Color(0.2, 0.2, 0.2), true)

	var med_cab = Rect2(rect.position.x + 295, rect.position.y + 135, 65, 75)
	draw_rect(med_cab, Color(0.85, 0.90, 0.94), true)
	draw_rect(med_cab, Color(0.40, 0.50, 0.60), false, 2.0)
	draw_line(Vector2(med_cab.position.x + 32, med_cab.position.y), Vector2(med_cab.position.x + 32, med_cab.end.y), Color(0.40, 0.50, 0.60), 1.5)
	for my in range(int(med_cab.position.y) + 15, int(med_cab.end.y) - 10, 20):
		draw_circle(Vector2(med_cab.position.x + 16, my), 4.0, Color(0.9, 0.3, 0.3))
		draw_circle(Vector2(med_cab.position.x + 48, my), 4.0, Color(0.3, 0.6, 0.9))

func _draw_asphalt_strip(rect: Rect2, is_horizontal: bool, num_lanes: int) -> void:
	draw_rect(Rect2(rect.position - Vector2(2, 2), rect.size + Vector2(4, 4)), COLOR_SIDEWALK_BEVEL, true)
	draw_rect(rect, COLOR_ASPHALT, true)

	if is_horizontal:
		draw_line(Vector2(rect.position.x, rect.position.y + 4), Vector2(rect.end.x, rect.position.y + 4), COLOR_CURB_LINE, 2.0)
		draw_line(Vector2(rect.position.x, rect.end.y - 4), Vector2(rect.end.x, rect.end.y - 4), COLOR_CURB_LINE, 2.0)
		
		var cy = rect.position.y + rect.size.y * 0.5
		if num_lanes == 2:
			for dx in range(int(rect.position.x) + 10, int(rect.end.x) - 10, 36):
				draw_line(Vector2(dx, cy), Vector2(dx + 20, cy), COLOR_LANE_DASH, 2.0)
		elif num_lanes == 1:
			for dx in range(int(rect.position.x) + 10, int(rect.end.x) - 10, 48):
				draw_line(Vector2(dx, cy), Vector2(dx + 16, cy), Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.45), 1.5)
	else:
		draw_line(Vector2(rect.position.x + 4, rect.position.y), Vector2(rect.position.x + 4, rect.end.y), COLOR_CURB_LINE, 2.0)
		draw_line(Vector2(rect.end.x - 4, rect.position.y), Vector2(rect.end.x - 4, rect.end.y), COLOR_CURB_LINE, 2.0)
		
		var cx = rect.position.x + rect.size.x * 0.5
		if num_lanes == 2:
			for dy in range(int(rect.position.y) + 10, int(rect.end.y) - 10, 36):
				draw_line(Vector2(cx, dy), Vector2(cx, dy + 20), COLOR_LANE_DASH, 2.0)
		elif num_lanes == 1:
			for dy in range(int(rect.position.y) + 10, int(rect.end.y) - 10, 48):
				draw_line(Vector2(cx, dy), Vector2(cx, dy + 16), Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.45), 1.5)

func _draw_courtyard_garden(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, COLOR_GRASS)
	draw_arc(center, radius, 0, TAU, 24, COLOR_SIDEWALK_BEVEL, 2.0)
	draw_circle(center + Vector2(-8, -6), radius * 0.45, COLOR_TREE_DARK)
	draw_circle(center + Vector2(-10, -8), radius * 0.35, COLOR_TREE_LIGHT)
	draw_circle(center + Vector2(10, 8), radius * 0.38, COLOR_TREE_DARK)
	draw_circle(center + Vector2(8, 6), radius * 0.28, COLOR_TREE_LIGHT)

func _draw_room_pavement(rect: Rect2, color: Color) -> void:
	draw_rect(rect, color, true)
	_draw_tile_pattern(rect, COLOR_PLAZA_TILE_LINE)

func _draw_tile_pattern(rect: Rect2, color: Color) -> void:
	for x in range(int(rect.position.x) + 30, int(rect.end.x), 30):
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), color, 0.8)
	for y in range(int(rect.position.y) + 30, int(rect.end.y), 30):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), color, 0.8)

func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color(0, 0, 0, 0.25), true)
	draw_rect(rect, COLOR_DESK_WOOD, true)
	draw_rect(rect, COLOR_DESK_RIM, false, 2.0)
	if rect.size.x > rect.size.y:
		draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + 2),
				  Vector2(rect.position.x + rect.size.x * 0.5, rect.end.y - 2), COLOR_DESK_RIM, 1.5)

func _draw_poi_badge(pos: Vector2, _label: String, color: Color) -> void:
	var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004)
	draw_circle(pos, 20.0 + pulse * 4.0, Color(color.r, color.g, color.b, 0.25))
	draw_circle(pos, 9.0, color)
	draw_circle(pos, 5.0, Color(1, 1, 1, 0.95))

func _build_all_colliders() -> void:
	for body in collision_bodies:
		if is_instance_valid(body):
			body.queue_free()
	collision_bodies.clear()

	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		_create_segment_collider(Vector2(sq_x, 192), Vector2(sq_x, 36))
		_create_segment_collider(Vector2(sq_x, 36), Vector2(sq_x + 156, 36))
		_create_segment_collider(Vector2(sq_x + 156, 36), Vector2(sq_x + 156, 192))
		_create_box_collider(Rect2(sq_x + 30, 70, 96, 75))

	_create_segment_collider(Vector2(0, 192), Vector2(2160, 192))

	_create_segment_collider(Vector2(0, 324), Vector2(516, 324))
	_create_segment_collider(Vector2(516, 324), Vector2(516, 510))
	_create_segment_collider(Vector2(516, 570), Vector2(516, 786))
	_create_segment_collider(Vector2(516, 786), Vector2(380, 786))
	_create_segment_collider(Vector2(320, 786), Vector2(192, 786))
	_create_segment_collider(Vector2(192, 786), Vector2(192, 933))
	_create_segment_collider(Vector2(192, 933), Vector2(0, 933))

	_create_box_collider(Rect2(9, 324, 156, 156))
	_create_box_collider(Rect2(195, 324, 156, 156))
	_create_box_collider(Rect2(411, 324, 105, 156))
	_create_box_collider(Rect2(411, 495, 105, 156))
	_create_box_collider(Rect2(411, 666, 105, 120))
	_create_box_collider(Rect2(25, 800, 140, 100))

	_create_segment_collider(Vector2(0, 951), Vector2(357, 951))
	_create_segment_collider(Vector2(357, 951), Vector2(357, 1080))
	_create_segment_collider(Vector2(357, 1150), Vector2(357, 1311))
	_create_segment_collider(Vector2(357, 1311), Vector2(0, 1311))
	_create_box_collider(Rect2(40, 1000, 270, 120))
	_create_box_collider(Rect2(40, 1160, 270, 120))

	_create_segment_collider(Vector2(639, 324), Vector2(1000, 324))
	_create_segment_collider(Vector2(1060, 324), Vector2(1536, 324))
	_create_segment_collider(Vector2(1536, 324), Vector2(1536, 480))
	_create_segment_collider(Vector2(1536, 540), Vector2(1536, 714))
	_create_segment_collider(Vector2(1536, 714), Vector2(1158, 714))
	_create_segment_collider(Vector2(1158, 714), Vector2(1158, 549))
	_create_segment_collider(Vector2(1158, 549), Vector2(639, 549))
	_create_segment_collider(Vector2(639, 549), Vector2(639, 440))
	_create_segment_collider(Vector2(639, 380), Vector2(639, 324))

	_create_box_collider(Rect2(672, 360, 378, 150))
	_create_box_collider(Rect2(1191, 354, 120, 120))
	_create_box_collider(Rect2(1341, 354, 120, 120))
	_create_box_collider(Rect2(1191, 585, 120, 120))
	_create_box_collider(Rect2(1341, 585, 120, 120))

	_create_segment_collider(Vector2(639, 690), Vector2(1050, 690))
	_create_segment_collider(Vector2(1050, 690), Vector2(1050, 900))
	_create_segment_collider(Vector2(1050, 960), Vector2(1050, 1245))
	_create_segment_collider(Vector2(1050, 1245), Vector2(465, 1245))
	_create_segment_collider(Vector2(465, 1245), Vector2(465, 945))
	_create_segment_collider(Vector2(465, 945), Vector2(639, 945))
	_create_segment_collider(Vector2(639, 945), Vector2(639, 810))
	_create_segment_collider(Vector2(639, 750), Vector2(639, 690))

	_create_box_collider(Rect2(672, 730, 340, 170))
	_create_box_collider(Rect2(510, 990, 490, 100))
	_create_box_collider(Rect2(510, 1120, 490, 100))

	_create_segment_collider(Vector2(1158, 840), Vector2(1260, 840))
	_create_segment_collider(Vector2(1320, 840), Vector2(1428, 840))
	_create_segment_collider(Vector2(1428, 840), Vector2(1428, 1050))
	_create_segment_collider(Vector2(1428, 1050), Vector2(1158, 1050))
	_create_segment_collider(Vector2(1158, 1050), Vector2(1158, 840))
	_create_box_collider(Rect2(1190, 880, 205, 120))

	_create_segment_collider(Vector2(1626, 324), Vector2(2016, 324))
	_create_segment_collider(Vector2(2016, 324), Vector2(2016, 480))
	_create_segment_collider(Vector2(2016, 540), Vector2(2016, 714))
	_create_segment_collider(Vector2(2016, 714), Vector2(1626, 714))
	_create_segment_collider(Vector2(1626, 714), Vector2(1626, 540))
	_create_segment_collider(Vector2(1626, 480), Vector2(1626, 324))

	_create_box_collider(Rect2(1656, 354, 120, 120))
	_create_box_collider(Rect2(1812, 354, 120, 120))
	_create_box_collider(Rect2(1656, 585, 120, 120))
	_create_box_collider(Rect2(1812, 585, 120, 120))

	_create_segment_collider(Vector2(1581, 849), Vector2(1770, 849))
	_create_segment_collider(Vector2(1890, 849), Vector2(2085, 849))
	_create_segment_collider(Vector2(2085, 849), Vector2(2085, 1269))
	_create_segment_collider(Vector2(2085, 1269), Vector2(1581, 1269))
	_create_segment_collider(Vector2(1581, 1269), Vector2(1581, 1120))
	_create_segment_collider(Vector2(1581, 1000), Vector2(1581, 849))

	_create_segment_collider(Vector2(2160, 0), Vector2(2160, 1311))

	_create_segment_collider(Vector2(0, 0), Vector2(2160, 0))
	_create_segment_collider(Vector2(0, 0), Vector2(0, 1311))
	_create_segment_collider(Vector2(0, 1311), Vector2(2160, 1311))

	for p_pos in [Vector2(480, 240), Vector2(1040, 560), Vector2(1980, 240), Vector2(1460, 1220)]:
		_create_box_collider(Rect2(p_pos.x + 2, p_pos.y + 12, 24, 28))

func _create_box_collider(rect: Rect2) -> void:
	var body = StaticBody2D.new()
	body.name = "DeskCol_" + str(rect.position.x) + "_" + str(rect.position.y)
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.position + rect.size / 2.0
	body.add_child(col)
	add_child(body)
	collision_bodies.append(body)

func _create_segment_collider(a: Vector2, b: Vector2) -> void:
	var body = StaticBody2D.new()
	body.name = "WallCol_" + str(a.x) + "_" + str(a.y)
	var col = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = a
	shape.b = b
	col.shape = shape
	body.add_child(col)
	add_child(body)
	collision_bodies.append(body)
