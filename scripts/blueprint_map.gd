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
@export var pagar_samping_tinggi: float = 146.0:
	set(val):
		pagar_samping_tinggi = 146.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_samping_lebar: float = 12.0:
	set(val):
		pagar_samping_lebar = 12.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_samping_jumlah_panel: int = 2:
	set(val):
		pagar_samping_jumlah_panel = 2 if (val == null or val <= 0) else int(val)
		queue_redraw()
@export var pagar_samping_gap_panel: float = 0.0:
	set(val):
		pagar_samping_gap_panel = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_skala: float = 1.0:
	set(val):
		pagar_samping_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("6. Stasiun Telepon Umum")
@export var telepon_lebar: float = 48.0:
	set(val):
		telepon_lebar = 48.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var telepon_tinggi: float = 72.0:
	set(val):
		telepon_tinggi = 72.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var telepon_skala: float = 1.0:
	set(val):
		telepon_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("7. Kantor Polisi (Police Station)")
@export var polisi_geser_x: float = 0.0:
	set(val):
		polisi_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var polisi_geser_y: float = 0.0:
	set(val):
		polisi_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var polisi_lebar: float = 341.0:
	set(val):
		polisi_lebar = 341.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var polisi_tinggi: float = 350.0:
	set(val):
		polisi_tinggi = 350.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var polisi_skala: float = 1.0:
	set(val):
		polisi_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("8. Rumah Sakit (Hospital)")
@export var rs_geser_x: float = 0.0:
	set(val):
		rs_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var rs_geser_y: float = 0.0:
	set(val):
		rs_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var rs_lebar: float = 585.0:
	set(val):
		rs_lebar = 585.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rs_tinggi: float = 300.0:
	set(val):
		rs_tinggi = 300.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rs_skala: float = 1.0:
	set(val):
		rs_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("9. Stasiun Kereta (Train Station)")
@export var stasiun_geser_x: float = 0.0:
	set(val):
		stasiun_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var stasiun_geser_y: float = 0.0:
	set(val):
		stasiun_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var stasiun_lebar: float = 300.0:
	set(val):
		stasiun_lebar = 300.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var stasiun_tinggi: float = 621.0:
	set(val):
		stasiun_tinggi = 621.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var stasiun_skala: float = 1.0:
	set(val):
		stasiun_skala = 1.0 if (val == null or val <= 0.0) else float(val)
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

func _draw_side_fence(rect: Rect2, flip_h: bool = false) -> void:
	if not is_instance_valid(tex_pagar_samping):
		return
	var src_region = Rect2(19, 24, 31, 329)
	if not flip_h:
		draw_texture_rect_region(tex_pagar_samping, rect, src_region)
	else:
		draw_set_transform(Vector2(rect.position.x + rect.size.x, rect.position.y), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect_region(tex_pagar_samping, Rect2(0, 0, rect.size.x, rect.size.y), src_region)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_phone_booth(rect: Rect2) -> void:
	if not is_instance_valid(tex_telepon):
		return
	var src_region = Rect2(359, 138, 286, 606)
	draw_texture_rect_region(tex_telepon, rect, src_region)

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
		Vector2(649, 334), Vector2(1526, 334), Vector2(1526, 539), Vector2(649, 539)
	]))

	nav_poly.add_outline(PackedVector2Array([
		Vector2(1636, 334), Vector2(2006, 334), Vector2(2006, 539), Vector2(1636, 539)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(649, 700), Vector2(1040, 700), Vector2(1040, 1235),
		Vector2(475, 1235), Vector2(475, 955), Vector2(649, 955)
	]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(1168, 740), Vector2(1418, 740), Vector2(1418, 940), Vector2(1168, 940)
	]))

	# Tiga Rumah Warga Tenggara
	for hy in [705.0, 880.0, 1055.0]:
		nav_poly.add_outline(PackedVector2Array([
			Vector2(1636, hy), Vector2(1792, hy), Vector2(1792, hy + 156), Vector2(1636, hy + 156)
		]))

	nav_poly.add_outline(PackedVector2Array([
		Vector2(1880, 715), Vector2(2150, 715), Vector2(2150, 995), Vector2(1880, 995)
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
		
		if i == 6:
			draw_rect(r_rect, Color(0.35, 0.52, 0.22), true)
			draw_rect(Rect2(sq_x + 64, 130, 28, 62), Color(0.70, 0.68, 0.62), true)
			_draw_detective_house(r_rect)
			_draw_fences_for_house(sq_x, 36)
		else:
			_draw_civilian_fenced_house(Vector2(sq_x, 36), tex_rumah_depan)

	# ── Ruang Gedung Barat Laut (North-West Complex) ─────────────────────────
	var l_pts = PackedVector2Array([
		Vector2(0, 324), Vector2(516, 324), Vector2(516, 786),
		Vector2(192, 786), Vector2(192, 933), Vector2(0, 933)
	])
	draw_colored_polygon(l_pts, COLOR_ROOM_STONE_A)
	_draw_tile_pattern(Rect2(0, 324, 516, 462), COLOR_PLAZA_TILE_LINE)
	_draw_tile_pattern(Rect2(0, 786, 192, 147), COLOR_PLAZA_TILE_LINE)

	_draw_desk(Rect2(9, 324, 156, 156))
	_draw_desk(Rect2(195, 324, 156, 156))
	_draw_desk(Rect2(411, 324, 105, 156))
	_draw_desk(Rect2(411, 495, 105, 156))
	_draw_desk(Rect2(411, 666, 105, 120))
	_draw_desk(Rect2(25, 800, 140, 100))

	# Kompleks Rumah Sakit Atas (Kamar Jenazah & Plaza)
	var top_complex_pts = PackedVector2Array([
		Vector2(639, 324), Vector2(1536, 324), Vector2(1536, 549), Vector2(639, 549)
	])
	draw_colored_polygon(top_complex_pts, COLOR_ROOM_STONE_A)
	_draw_tile_pattern(Rect2(639, 324, 897, 225), COLOR_PLAZA_TILE_LINE)
	_draw_hospital_morgue(Rect2(639, 324, 380, 225))
	_draw_courtyard_garden(Vector2(1090, 435), 50.0)
	_draw_desk(Rect2(1180, 350, 110, 75))
	_draw_desk(Rect2(1330, 350, 110, 75))
	_draw_desk(Rect2(1180, 445, 110, 75))
	_draw_desk(Rect2(1330, 445, 110, 75))

	# Kompleks Rumah Sakit Bawah (Taman & Gedung RS)
	var bot_complex_pts = PackedVector2Array([
		Vector2(639, 690), Vector2(1050, 690), Vector2(1050, 1245),
		Vector2(465, 1245), Vector2(465, 945), Vector2(639, 945)
	])
	draw_colored_polygon(bot_complex_pts, COLOR_ROOM_STONE_B)
	_draw_tile_pattern(Rect2(639, 690, 411, 255), COLOR_PLAZA_TILE_LINE)
	_draw_desk(Rect2(672, 730, 340, 170))
	_draw_courtyard_garden(Vector2(780, 830), 40.0)

	# Bangunan Rumah Lainnya
	_draw_room_pavement(Rect2(1158, 730, 270, 210), COLOR_ROOM_OCHRE)
	_draw_texture_fit(tex_rumah_belakang, Rect2(1180, 745, 220, 175))
	_draw_room_pavement(Rect2(1626, 324, 390, 225), COLOR_ROOM_STONE_A)
	_draw_texture_fit(tex_rumah_samping, Rect2(1650, 335, 340, 205))

	# Presisi Kantor Polisi
	_draw_room_pavement(Rect2(0, 951, 357, 360), COLOR_ROOM_STONE_B)

	# ── Jaringan Jalan Raya Kota (Digambar Di Atas Lantai & Tanah) ────────────
	_draw_city_road_network()

	# ── Stasiun Telepon Umum Kota ─────────────────────────────────────────────
	var phone_spots = [
		Vector2(480, 225),
		Vector2(1040, 545),
		Vector2(1980, 225),
		Vector2(1460, 1195)
	]
	var tw = telepon_lebar * (1.0 if (telepon_skala == null or telepon_skala <= 0.0) else float(telepon_skala))
	var th = telepon_tinggi * (1.0 if (telepon_skala == null or telepon_skala <= 0.0) else float(telepon_skala))
	for p_pos in phone_spots:
		_draw_phone_booth(Rect2(p_pos.x, p_pos.y, tw, th))

	# ── Gedung Utama (Sprites) ────────────────────────────────────────────────
	var pol_sk = 1.0 if (polisi_skala == null or polisi_skala <= 0.0) else float(polisi_skala)
	var pol_w = (polisi_lebar if (polisi_lebar != null and polisi_lebar > 0.0) else 341.0) * pol_sk
	var pol_h = (polisi_tinggi if (polisi_tinggi != null and polisi_tinggi > 0.0) else 350.0) * pol_sk
	_draw_texture_fit(tex_police, Rect2(8 + polisi_geser_x, 955 + polisi_geser_y, pol_w, pol_h))

	# Gedung Utama Rumah Sakit (Dapat diatur lewat Inspector)
	var r_sk = 1.0 if (rs_skala == null or rs_skala <= 0.0) else float(rs_skala)
	var r_w = (rs_lebar if (rs_lebar != null and rs_lebar > 0.0) else 585.0) * r_sk
	var r_h = (rs_tinggi if (rs_tinggi != null and rs_tinggi > 0.0) else 300.0) * r_sk
	_draw_hospital_main_building(Rect2(465 + rs_geser_x, 945 + rs_geser_y, r_w, r_h))

	# ── Area Tenggara: Tiga Rumah Warga, Gang Kecil, dan Stasiun Kereta ───────
	# 1. Tiga Rumah Warga Seberang Stasiun (Lengkap rumput & pagar sama persis seperti rumah atas)
	_draw_civilian_fenced_house(Vector2(1636, 705), tex_rumah_depan)
	_draw_civilian_fenced_house(Vector2(1636, 880), tex_rumah_depan)
	_draw_civilian_fenced_house(Vector2(1636, 1055), tex_rumah_depan)

	# 2. Gang Kecil Penghubung Jalan Tengah & Jalan Selatan
	draw_rect(Rect2(1792, 690, 68, 621), COLOR_SIDEWALK, true)
	_draw_tile_pattern(Rect2(1792, 690, 68, 621), COLOR_PLAZA_TILE_LINE)

	# 3. Stasiun Kereta Api Timur (Nempel langsung ke rel kereta tanpa dipisahkan jalan)
	_draw_train_station(Rect2(1860, 690, 300, 621))

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
	draw_line(Vector2(1536, 324), Vector2(1536, 420), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 480), Vector2(1536, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 549), Vector2(639, 549), COLOR_WALL_LINE, WT)
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

	draw_line(Vector2(1158, 730), Vector2(1260, 730), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1320, 730), Vector2(1428, 730), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 730), Vector2(1428, 940), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 940), Vector2(1158, 940), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 940), Vector2(1158, 730), COLOR_WALL_LINE, WT)

	draw_line(Vector2(1626, 324), Vector2(2016, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 324), Vector2(2016, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 549), Vector2(1626, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1626, 549), Vector2(1626, 480), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1626, 420), Vector2(1626, 324), COLOR_WALL_LINE, WT)

	# Dinding Tiga Rumah Warga Tenggara
	for hy in [705.0, 880.0, 1055.0]:
		draw_line(Vector2(1636, hy), Vector2(1792, hy), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1636, hy), Vector2(1636, hy + 156), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1792, hy), Vector2(1792, hy + 156), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1636, hy + 156), Vector2(1696, hy + 156), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1732, hy + 156), Vector2(1792, hy + 156), COLOR_WALL_LINE, WT)

	# Batas Gang & Stasiun Kereta
	draw_line(Vector2(1792, 690), Vector2(1792, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1860, 690), Vector2(1860, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1860, 690), Vector2(2160, 690), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1860, 1311), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	draw_line(Vector2(2160, 0), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	_draw_poi_badge(Vector2(1170, 270), "Rumah Detektif", Color(0.35, 0.65, 0.95))
	_draw_poi_badge(Vector2(350, 258),  "Kantor Polisi",  Color(0.25, 0.50, 0.85))
	_draw_poi_badge(Vector2(2020, 960), "Stasiun Kereta", Color(0.95, 0.70, 0.20))
	_draw_poi_badge(Vector2(594, 550),  "Kamar Jenazah",  Color(0.85, 0.35, 0.35))
	_draw_poi_badge(Vector2(750, 1095), "Rumah Sakit",    Color(0.85, 0.25, 0.25))
	_draw_poi_badge(Vector2(180, 1050), "Brankas Ibu",    Color(0.80, 0.50, 0.90))

func _draw_civilian_fenced_house(pos: Vector2, house_tex: Texture2D = null) -> void:
	var sq_x = pos.x
	var sq_y = pos.y
	var r_rect = Rect2(sq_x, sq_y, 156, 156)

	draw_rect(r_rect, Color(0.35, 0.52, 0.22), true)
	draw_rect(Rect2(sq_x + 64, sq_y + 94, 28, 62), Color(0.70, 0.68, 0.62), true)

	var h_tex = tex_rumah_depan if house_tex == null else house_tex
	_draw_texture_fit(h_tex, Rect2(sq_x + 12, sq_y + 6, 132, 116))

	_draw_fences_for_house(sq_x, sq_y)

func _draw_fences_for_house(sq_x: float, sq_y: float) -> void:
	var sk_kiri = 1.0 if (pagar_kiri_skala == null or pagar_kiri_skala <= 0.0) else float(pagar_kiri_skala)
	var sk_pintu = 1.0 if (pintu_pagar_skala == null or pintu_pagar_skala <= 0.0) else float(pintu_pagar_skala)
	var sk_kanan = 1.0 if (pagar_kanan_skala == null or pagar_kanan_skala <= 0.0) else float(pagar_kanan_skala)
	var sk_belakang = 1.0 if (pagar_belakang_skala == null or pagar_belakang_skala <= 0.0) else float(pagar_belakang_skala)
	var pw = pagar_belakang_panel_lebar * sk_belakang
	var pg = pagar_belakang_gap_panel

	# Pagar Belakang (3 panel)
	draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_belakang_geser_x, sq_y - 4 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
	draw_texture_rect(tex_pagar, Rect2(sq_x + pw + pg + pagar_belakang_geser_x, sq_y - 4 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
	draw_texture_rect(tex_pagar, Rect2(sq_x + (pw + pg) * 2.0 + pagar_belakang_geser_x, sq_y - 4 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)

	# Pagar Samping (2 panel tumpang tindih)
	var side_y = sq_y - 6 + pagar_samping_geser_y + gap_sudut_atas_samping
	var side_w = (pagar_samping_lebar if (pagar_samping_lebar != null and pagar_samping_lebar > 0.0) else 12.0)
	var side_total_h = (pagar_samping_tinggi if (pagar_samping_tinggi != null and pagar_samping_tinggi > 0.0) else 148.0)
	var n_panels = max(1, 2 if (pagar_samping_jumlah_panel == null or pagar_samping_jumlah_panel <= 0) else int(pagar_samping_jumlah_panel))
	var overlap_px = 16.0
	var panel_h = (side_total_h + (n_panels - 1) * overlap_px) / float(n_panels)
	var step_y = panel_h - overlap_px + (0.0 if pagar_samping_gap_panel == null else float(pagar_samping_gap_panel))

	for p in range(n_panels):
		var py = side_y + p * step_y
		_draw_side_fence(Rect2(sq_x - 3 + pagar_samping_kiri_geser_x, py, side_w, panel_h), true)
	# Pagar Depan Kiri
	draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_kiri_geser_x, sq_y + 130 + pagar_kiri_geser_y, pagar_kiri_lebar * sk_kiri, 26 * sk_kiri), false)
	# Pintu Pagar Tengah
	draw_texture_rect(tex_pintu_pagar, Rect2(sq_x + 62 + pintu_pagar_geser_x, sq_y + 126 + pintu_pagar_geser_y, pintu_pagar_lebar * sk_pintu, 30 * sk_pintu), false)
	# Pagar Depan Kanan
	_draw_texture_flipped(tex_pagar, Rect2(sq_x + 94 + pagar_kanan_geser_x, sq_y + 130 + pagar_kanan_geser_y, pagar_kanan_lebar * sk_kanan, 26 * sk_kanan), true, false)

func _draw_station_bench(pos: Vector2, w: float = 80.0, h: float = 24.0) -> void:
	draw_rect(Rect2(pos.x, pos.y, w, h), Color(0.48, 0.32, 0.18), true)
	draw_rect(Rect2(pos.x, pos.y, w, h), Color(0.25, 0.16, 0.08), false, 1.5)
	draw_line(Vector2(pos.x + 4, pos.y + 6), Vector2(pos.x + w - 4, pos.y + 6), Color(0.60, 0.42, 0.25), 1.0)
	draw_line(Vector2(pos.x + 4, pos.y + 16), Vector2(pos.x + w - 4, pos.y + 16), Color(0.60, 0.42, 0.25), 1.0)

func _draw_train_station(rect: Rect2) -> void:
	var x  := rect.position.x
	var y  := rect.position.y
	var rw := rect.size.x   # 300
	var rh := rect.size.y   # 621

	# ═══════════════════════════════════════════════════════════════════════════
	# 1. LANTAI DASAR PERON (Warm Light Stone Tile Floor)
	# ═══════════════════════════════════════════════════════════════════════════
	draw_rect(rect, Color(0.80, 0.78, 0.74), true)
	
	# Pola keramik ubin peron
	for tx in range(int(x), int(x + rw), 20):
		draw_line(Vector2(tx, y), Vector2(tx, y + rh), Color(0.66, 0.64, 0.60, 0.55), 1.0)
	for ty in range(int(y), int(y + rh), 20):
		draw_line(Vector2(x, ty), Vector2(x + rw, ty), Color(0.66, 0.64, 0.60, 0.55), 1.0)

	# Jalur ubin pemandu tuna netra (Tactile Walkway) dari pintu masuk ke peron
	var guide_x := x + 64.0
	draw_rect(Rect2(guide_x, y + 175, 12, rh - 185), Color(0.95, 0.82, 0.18, 0.85), true)
	for gy in range(int(y) + 180, int(y + rh) - 10, 8):
		draw_line(Vector2(guide_x + 2, gy), Vector2(guide_x + 10, gy), Color(0.78, 0.65, 0.10), 1.0)

	# ═══════════════════════════════════════════════════════════════════════════
	# 2. GEDUNG UTAMA STASIUN (Bagian Atas: y = y .. y + 175)
	# ═══════════════════════════════════════════════════════════════════════════
	var b_w := rw - 65.0 # Sisakan ruang untuk jalur keselamatan kanan
	var b_h := 175.0
	var b_rect := Rect2(x, y, b_w, b_h)

	# Fasad Dinding Bawah Gedung (Tampak Depan Pintu Masuk: y + 100 .. y + 175)
	var facade_y := y + 100.0
	var facade_h := 75.0
	draw_rect(Rect2(x, facade_y, b_w, facade_h), Color(0.90, 0.87, 0.82), true) # Dinding krem
	draw_rect(Rect2(x, facade_y + facade_h - 10, b_w, 10), Color(0.55, 0.42, 0.32), true) # Plinth kayu bawah

	# Pintu Utama Stasiun (Entrance Archway / Portal)
	var door_x := x + 84.0
	var door_w := 42.0
	var door_h := 50.0
	var door_y := facade_y + 25.0
	draw_rect(Rect2(door_x - 3, door_y - 3, door_w + 6, door_h + 3), Color(0.40, 0.30, 0.22), true) # Kusen
	draw_rect(Rect2(door_x, door_y, door_w, door_h), Color(0.12, 0.12, 0.15), true) # Lorong dalam gelap
	# Lantai lorong pintu masuk
	draw_rect(Rect2(door_x + 4, door_y + 12, door_w - 8, door_h - 12), Color(0.25, 0.24, 0.22), true)

	# Papan Nama "STATION ENTRY"
	var sign_x := door_x - 6.0
	var sign_w := door_w + 12.0
	var sign_y := door_y - 18.0
	draw_rect(Rect2(sign_x, sign_y, sign_w, 14), Color(0.15, 0.22, 0.30), true)
	draw_rect(Rect2(sign_x, sign_y, sign_w, 14), Color(0.85, 0.85, 0.85), false, 1.5)
	draw_line(Vector2(sign_x + 4, sign_y + 7), Vector2(sign_x + sign_w - 4, sign_y + 7), Color(0.98, 0.95, 0.80), 2.0)

	# Pintu Kaca & Jendela Samping Kanan
	var rdoor_x := x + 162.0
	var rdoor_y := facade_y + 25.0
	draw_rect(Rect2(rdoor_x, rdoor_y, 32, 45), Color(0.35, 0.48, 0.62), true)
	draw_rect(Rect2(rdoor_x, rdoor_y, 32, 45), Color(0.20, 0.28, 0.38), false, 2.0)
	draw_line(Vector2(rdoor_x + 16, rdoor_y), Vector2(rdoor_x + 16, rdoor_y + 45), Color(0.20, 0.28, 0.38), 1.5)
	# Gagang pintu emas
	draw_circle(Vector2(rdoor_x + 13, rdoor_y + 24), 2.0, Color(0.95, 0.80, 0.20))
	draw_circle(Vector2(rdoor_x + 19, rdoor_y + 24), 2.0, Color(0.95, 0.80, 0.20))

	# Pintu Kayu Samping Kiri
	var ldoor_x := x + 28.0
	draw_rect(Rect2(ldoor_x, rdoor_y + 4, 24, 41), Color(0.52, 0.36, 0.22), true)
	draw_rect(Rect2(ldoor_x, rdoor_y + 4, 24, 41), Color(0.28, 0.18, 0.10), false, 2.0)
	draw_circle(Vector2(ldoor_x + 19, rdoor_y + 24), 2.0, Color(0.95, 0.80, 0.20))

	# Jam Dinding Stasiun Bundar di Fasad
	draw_circle(Vector2(x + 204, facade_y + 25), 7.0, Color(0.95, 0.95, 0.95))
	draw_circle(Vector2(x + 204, facade_y + 25), 7.0, Color(0.20, 0.20, 0.25), false, 1.5)
	draw_line(Vector2(x + 204, facade_y + 25), Vector2(x + 204, facade_y + 21), Color(0.10, 0.10, 0.10), 1.2)
	draw_line(Vector2(x + 204, facade_y + 25), Vector2(x + 207, facade_y + 25), Color(0.10, 0.10, 0.10), 1.2)

	# Simbol Bus/Transit Sign
	draw_rect(Rect2(x + 218, facade_y + 18, 14, 14), Color(0.15, 0.35, 0.65), true)
	draw_rect(Rect2(x + 221, facade_y + 22, 8, 6), Color(0.95, 0.95, 0.95), true)

	# Tanaman Pot Hijau di Samping Pintu Utama
	for px_offset in [door_x - 14, door_x + door_w + 4]:
		draw_rect(Rect2(px_offset, facade_y + 42, 10, 10), Color(0.68, 0.38, 0.22), true)
		draw_circle(Vector2(px_offset + 5, facade_y + 40), 7.0, Color(0.22, 0.58, 0.20))
		draw_circle(Vector2(px_offset + 5, facade_y + 40), 5.0, Color(0.35, 0.72, 0.25))

	# ── Atap Utama Genteng Terakota (Tampak Atas: y .. y + 105) ─────────────
	var roof_h := 105.0
	draw_rect(Rect2(x, y, b_w, roof_h), Color(0.78, 0.42, 0.24), true) # Terrakotta cerah
	# Shading atap sisi bawah
	draw_rect(Rect2(x, y + roof_h * 0.55, b_w, roof_h * 0.45), Color(0.62, 0.30, 0.16), true)
	# Bubungan tengah atap (Ridge Cap)
	draw_rect(Rect2(x, y + roof_h * 0.52, b_w, 5), Color(0.42, 0.18, 0.08), true)

	# Tekstur genteng berulang
	for ry in range(int(y) + 6, int(y + roof_h), 8):
		draw_line(Vector2(x + 2, ry), Vector2(x + b_w - 2, ry), Color(0.35, 0.14, 0.06, 0.65), 1.0)

	# 4 Jendela Skylight / Loteng Kaca Biru di Atap
	var skylights := [
		Rect2(x + 28,  y + 18, 22, 32),
		Rect2(x + 72,  y + 24, 20, 26),
		Rect2(x + 115, y + 24, 20, 26),
		Rect2(x + 158, y + 18, 22, 32)
	]
	for sl in skylights:
		draw_rect(sl, Color(0.20, 0.22, 0.28), true) # Frame gelap
		draw_rect(Rect2(sl.position.x + 2, sl.position.y + 2, sl.size.x - 4, sl.size.y - 4), Color(0.38, 0.65, 0.88), true) # Kaca biru
		draw_line(Vector2(sl.position.x + 4, sl.position.y + 6), Vector2(sl.end.x - 6, sl.end.y - 6), Color(0.90, 0.96, 1.0, 0.75), 1.5) # Refleksi

	# Gable Atap Segitiga di Atas Pintu Masuk
	var gable_pts := PackedVector2Array([
		Vector2(door_x - 10, y + roof_h + 4),
		Vector2(door_x + door_w * 0.5, y + 45),
		Vector2(door_x + door_w + 10, y + roof_h + 4)
	])
	draw_colored_polygon(gable_pts, Color(0.82, 0.44, 0.25))
	draw_polyline(gable_pts, Color(0.32, 0.14, 0.06), 2.5)

	# Border atap gedung stasiun
	draw_rect(Rect2(x, y, b_w, roof_h), Color(0.25, 0.10, 0.05), false, 2.5)

	# ═══════════════════════════════════════════════════════════════════════════
	# 3. KANOPI KEMBAR PERON (Twin Platform Canopies: Kiri & Kanan)
	# ═══════════════════════════════════════════════════════════════════════════
	var c_y  := y + 185.0
	var c_h  := rh - 195.0
	var c_w  := 48.0
	var lc_x := x + 6.0
	var rc_x := x + 164.0

	for cx_pos in [lc_x, rc_x]:
		var c_rect := Rect2(cx_pos, c_y, c_w, c_h)
		# Bayangan kanopi
		draw_rect(Rect2(cx_pos - 4, c_y + 6, c_w + 8, c_h), Color(0.15, 0.16, 0.18, 0.22), true)
		# Atap kanopi seng bergelombang (Abu-abu kebiruan)
		draw_rect(c_rect, Color(0.46, 0.52, 0.58), true)
		draw_rect(Rect2(cx_pos + c_w * 0.45, c_y, c_w * 0.15, c_h), Color(0.32, 0.36, 0.42), true) # Ridge tengah
		draw_rect(c_rect, Color(0.22, 0.25, 0.30), false, 2.0) # Border

		# Garis-garis seng bergelombang
		for cy_pos in range(int(c_y) + 8, int(c_y + c_h), 12):
			draw_line(Vector2(cx_pos + 2, cy_pos), Vector2(cx_pos + c_w - 2, cy_pos), Color(0.30, 0.35, 0.42, 0.50), 1.0)

		# Tiang penyangga baja silinder & lampu
		for pi in range(4):
			var py_pos := c_y + 35.0 + pi * (c_h - 60.0) / 3.0
			draw_circle(Vector2(cx_pos + c_w * 0.5, py_pos), 5.5, Color(0.32, 0.35, 0.40))
			draw_circle(Vector2(cx_pos + c_w * 0.5, py_pos), 3.5, Color(0.18, 0.20, 0.24))
			# Lampu bulat kuning
			draw_circle(Vector2(cx_pos + c_w * 0.5, py_pos + 8), 3.0, Color(0.98, 0.92, 0.55))

	# Rangka Baja Penghubung (Truss Beams) antara Kanopi Kiri & Kanan
	var truss_y1 := c_y + 15.0
	var truss_y2 := c_y + 155.0
	for ty_pos in [truss_y1, truss_y2]:
		draw_line(Vector2(lc_x + c_w, ty_pos), Vector2(rc_x, ty_pos), Color(0.25, 0.28, 0.34), 3.0)
		draw_line(Vector2(lc_x + c_w, ty_pos + 8), Vector2(rc_x, ty_pos + 8), Color(0.25, 0.28, 0.34), 3.0)
		# Rangka silang zig-zag
		for zx in range(int(lc_x + c_w), int(rc_x) - 15, 20):
			draw_line(Vector2(zx, ty_pos), Vector2(zx + 10, ty_pos + 8), Color(0.35, 0.38, 0.45), 1.5)
			draw_line(Vector2(zx + 10, ty_pos + 8), Vector2(zx + 20, ty_pos), Color(0.35, 0.38, 0.45), 1.5)

	# ═══════════════════════════════════════════════════════════════════════════
	# 4. AMENITAS & FASILITAS PERON TENGAH (Central Walkway: x+54 .. x+164)
	# ═══════════════════════════════════════════════════════════════════════════

	# A. Peta Transit & Jam Gantung di Dinding Atas Walkway
	var map_x := x + 68.0
	var map_y := c_y + 15.0
	draw_rect(Rect2(map_x, map_y, 32, 22), Color(0.92, 0.90, 0.85), true) # Kertas peta
	draw_rect(Rect2(map_x, map_y, 32, 22), Color(0.30, 0.32, 0.36), false, 1.5)
	# Garis rute peta (hijau & biru)
	draw_line(Vector2(map_x + 4, map_y + 8), Vector2(map_x + 28, map_y + 14), Color(0.25, 0.65, 0.30), 2.0)
	draw_line(Vector2(map_x + 8, map_y + 16), Vector2(map_x + 26, map_y + 6), Color(0.20, 0.50, 0.85), 2.0)

	# Jam stasiun tiang gantung
	var clock_x := x + 114.0
	draw_circle(Vector2(clock_x, map_y + 11), 8.0, Color(0.95, 0.95, 0.95))
	draw_circle(Vector2(clock_x, map_y + 11), 8.0, Color(0.18, 0.20, 0.24), false, 2.0)
	draw_line(Vector2(clock_x, map_y + 11), Vector2(clock_x, map_y + 6), Color(0.10, 0.10, 0.10), 1.5)
	draw_line(Vector2(clock_x, map_y + 11), Vector2(clock_x + 4, map_y + 11), Color(0.10, 0.10, 0.10), 1.5)

	# B. Mesin Minuman Otomatis (Red Vending Machine)
	var vm_x := x + 130.0
	var vm_y := c_y + 10.0
	draw_rect(Rect2(vm_x, vm_y, 28, 42), Color(0.85, 0.20, 0.18), true) # Merah mencolok
	draw_rect(Rect2(vm_x, vm_y, 28, 42), Color(0.20, 0.15, 0.15), false, 2.0)
	# Display kaca minuman
	draw_rect(Rect2(vm_x + 3, vm_y + 4, 22, 20), Color(0.10, 0.12, 0.16), true)
	# Kaleng minuman warna-warni
	for vi in range(3):
		draw_rect(Rect2(vm_x + 5 + vi * 6, vm_y + 6, 4, 7), Color(0.20, 0.80, 0.40) if vi==0 else (Color(0.20, 0.60, 0.95) if vi==1 else Color(0.95, 0.80, 0.20)), true)
		draw_rect(Rect2(vm_x + 5 + vi * 6, vm_y + 15, 4, 7), Color(0.95, 0.40, 0.20) if vi==0 else (Color(0.80, 0.30, 0.80) if vi==1 else Color(0.95, 0.95, 0.95)), true)
	# Slot pengeluaran minuman
	draw_rect(Rect2(vm_x + 4, vm_y + 28, 20, 10), Color(0.25, 0.25, 0.28), true)

	# C. Papan Jadwal Digital Gantung LED (PIDS Board - "NEXT TRAINS")
	var pids_x := x + 72.0
	var pids_y := c_y + 55.0
	var pids_w := 74.0
	var pids_h := 36.0
	draw_rect(Rect2(pids_x, pids_y, pids_w, pids_h), Color(0.08, 0.10, 0.14), true)
	draw_rect(Rect2(pids_x, pids_y, pids_w, pids_h), Color(0.30, 0.70, 0.95), false, 2.0)
	# Header cyan
	draw_line(Vector2(pids_x + 4, pids_y + 8), Vector2(pids_x + pids_w - 4, pids_y + 8), Color(0.30, 0.85, 0.95), 2.0)
	# Baris jadwal amber/kuning
	draw_line(Vector2(pids_x + 4, pids_y + 16), Vector2(pids_x + pids_w - 8, pids_y + 16), Color(0.98, 0.75, 0.15), 1.8)
	draw_line(Vector2(pids_x + 4, pids_y + 23), Vector2(pids_x + pids_w - 12, pids_y + 23), Color(0.98, 0.75, 0.15), 1.8)
	draw_line(Vector2(pids_x + 4, pids_y + 30), Vector2(pids_x + pids_w - 6, pids_y + 30), Color(0.30, 0.85, 0.95), 1.8)

	# D. Bangku Tunggu Kayu & Penumpang Santai (Benches & Passengers)
	# Set Bangku 1: y + 330
	var b1_y := y + 335.0
	_draw_station_bench(Vector2(x + 88, b1_y), 42.0, 18.0)
	_draw_station_bench(Vector2(x + 88, b1_y + 28), 42.0, 18.0)
	# Penumpang mini (top-down heads & torso)
	draw_circle(Vector2(x + 98, b1_y + 8), 4.0, Color(0.85, 0.65, 0.45)) # Kepala
	draw_circle(Vector2(x + 98, b1_y + 6), 4.0, Color(0.35, 0.20, 0.12)) # Rambut
	draw_rect(Rect2(x + 94, b1_y + 10, 8, 7), Color(0.25, 0.45, 0.75), true) # Baju biru

	# Set Bangku 2: y + 440
	var b2_y := y + 445.0
	_draw_station_bench(Vector2(x + 88, b2_y), 42.0, 18.0)
	_draw_station_bench(Vector2(x + 88, b2_y + 28), 42.0, 18.0)
	# Penumpang mini 2
	draw_circle(Vector2(x + 118, b2_y + 8), 4.0, Color(0.85, 0.65, 0.45))
	draw_circle(Vector2(x + 118, b2_y + 6), 4.0, Color(0.18, 0.18, 0.20))
	draw_rect(Rect2(x + 114, b2_y + 10, 8, 7), Color(0.75, 0.25, 0.35), true) # Baju merah

	# E. Tanaman Hias Pot Tengah (Central Planter)
	var pl_y := y + 395.0
	draw_rect(Rect2(x + 98, pl_y, 22, 22), Color(0.58, 0.36, 0.22), true) # Pot terrakotta
	draw_rect(Rect2(x + 98, pl_y, 22, 22), Color(0.30, 0.18, 0.10), false, 1.5)
	draw_circle(Vector2(x + 109, pl_y + 11), 12.0, Color(0.20, 0.55, 0.18)) # Daun rimbun
	draw_circle(Vector2(x + 109, pl_y + 11), 8.0, Color(0.32, 0.72, 0.24))

	# F. Mesin Tiket Otomatis (TVM Kiosk) & Tempat Sampah di Bagian Bawah
	var tvm_x := x + 102.0
	var tvm_y := y + 535.0
	draw_rect(Rect2(tvm_x, tvm_y, 16, 26), Color(0.75, 0.78, 0.82), true) # Body abu-abu
	draw_rect(Rect2(tvm_x, tvm_y, 16, 26), Color(0.25, 0.28, 0.32), false, 1.5)
	draw_rect(Rect2(tvm_x + 2, tvm_y + 3, 12, 10), Color(0.20, 0.55, 0.85), true) # Layar biru
	draw_rect(Rect2(tvm_x + 2, tvm_y + 18, 12, 6), Color(0.85, 0.20, 0.20), true) # Panel bawah merah

	# Tempat Sampah Terpilah (Bawah Kanopi)
	draw_rect(Rect2(x + 36, y + 540, 10, 14), Color(0.22, 0.65, 0.32), true) # Hijau
	draw_rect(Rect2(x + 36, y + 540, 10, 14), Color(0.12, 0.35, 0.18), false, 1.5)
	draw_rect(Rect2(x + 172, y + 540, 10, 14), Color(0.25, 0.50, 0.85), true) # Biru
	draw_rect(Rect2(x + 172, y + 540, 10, 14), Color(0.12, 0.25, 0.45), false, 1.5)

	# ═══════════════════════════════════════════════════════════════════════════
	# 5. ZONA KESELAMATAN & TEPI REL KERETA (Sisi Kanan: x+220 .. x+300)
	# ═══════════════════════════════════════════════════════════════════════════
	var track_edge_x := rect.end.x # 2160

	# Garis Kuning Keselamatan / Tactile Warning Strip (Lebar 24px)
	var warn_w := 24.0
	var warn_x := track_edge_x - warn_w - 38.0
	draw_rect(Rect2(warn_x, y, warn_w, rh), Color(0.96, 0.84, 0.10), true) # Kuning cerah

	# Pola titik timbul tactile studs (Grid titik-titik kecil)
	for ty in range(int(y) + 4, int(y + rh), 8):
		for tx_offset in [4.0, 12.0, 20.0]:
			draw_circle(Vector2(warn_x + tx_offset, ty), 1.4, Color(0.72, 0.60, 0.05))

	# Tepi peron platform edge line
	draw_line(Vector2(warn_x + warn_w, y), Vector2(warn_x + warn_w, y + rh), Color(0.15, 0.16, 0.18), 3.0)

	# Area Rel Kereta Api Sisi Kanan Stasiun (Ballast & Rel)
	var rail_area_x := warn_x + warn_w + 3.0
	var rail_area_w := track_edge_x - rail_area_x
	draw_rect(Rect2(rail_area_x, y, rail_area_w, rh), Color(0.22, 0.23, 0.25), true) # Ballast kerikil gelap

	# Batang Rel Baja & Bantalan Kayu
	var rail_x1 := rail_area_x + 6.0
	var rail_x2 := rail_area_x + rail_area_w - 6.0
	for ry_pos in range(int(y) + 6, int(y + rh), 14):
		draw_line(Vector2(rail_area_x + 2, ry_pos), Vector2(rail_area_x + rail_area_w - 2, ry_pos), Color(0.38, 0.32, 0.26), 3.0) # Bantalan
	draw_line(Vector2(rail_x1, y), Vector2(rail_x1, y + rh), Color(0.75, 0.78, 0.82), 3.5) # Rel baja 1
	draw_line(Vector2(rail_x2, y), Vector2(rail_x2, y + rh), Color(0.75, 0.78, 0.82), 3.5) # Rel baja 2

	# ═══════════════════════════════════════════════════════════════════════════
	# 6. BORDER DINDING PEMBATAS BLOK STASIUN
	# ═══════════════════════════════════════════════════════════════════════════
	draw_rect(rect, Color(0.15, 0.16, 0.19), false, 3.0)


func _draw_hospital_main_building(rect: Rect2) -> void:
	_draw_texture_fit(tex_hospital, Rect2(rect.position.x + 4, rect.position.y + 4, rect.size.x - 8, rect.size.y - 8))

func _draw_detective_house(rect: Rect2) -> void:
	draw_rect(rect, COLOR_PARQUET_WOOD, true)
	for py in range(int(rect.position.y) + 12, int(rect.end.y), 14):
		draw_line(Vector2(rect.position.x, py), Vector2(rect.end.x, py), COLOR_PARQUET_DARK, 1.0)

	_draw_texture_fit(tex_karpet, Rect2(rect.position.x + 28, rect.position.y + 40, 96, 75))
	_draw_texture_fit(tex_bed, Rect2(rect.position.x + 10, rect.position.y + 8, 48, 80))
	_draw_texture_fit(tex_lemari, Rect2(rect.position.x + 95, rect.position.y + 8, 52, 38))
	_draw_texture_fit(tex_laci, Rect2(rect.position.x + 10, rect.position.y + 96, 36, 42))

	draw_rect(Rect2(rect.position.x + 60, rect.position.y + 48, 42, 28), COLOR_CORKBOARD, true)
	draw_rect(Rect2(rect.position.x + 60, rect.position.y + 48, 42, 28), COLOR_DESK_RIM, false, 1.5)

	_draw_texture_fit(tex_surat, Rect2(rect.position.x + 64, rect.position.y + 52, 14, 10))
	_draw_texture_fit(tex_surat, Rect2(rect.position.x + 82, rect.position.y + 52, 14, 10))
	_draw_texture_fit(tex_surat, Rect2(rect.position.x + 72, rect.position.y + 64, 16, 10))

	draw_line(Vector2(rect.position.x + 71, rect.position.y + 57), Vector2(rect.position.x + 80, rect.position.y + 69), Color(0.9, 0.2, 0.2), 1.2)
	draw_line(Vector2(rect.position.x + 89, rect.position.y + 57), Vector2(rect.position.x + 80, rect.position.y + 69), Color(0.9, 0.2, 0.2), 1.2)

func _draw_hospital_morgue(rect: Rect2) -> void:
	draw_rect(rect, COLOR_HOSPITAL_TILE, true)
	for tx in range(int(rect.position.x), int(rect.end.x), 24):
		draw_line(Vector2(tx, rect.position.y), Vector2(tx, rect.end.y), COLOR_HOSPITAL_GROUT, 1.0)
	for ty in range(int(rect.position.y), int(rect.end.y), 24):
		draw_line(Vector2(rect.position.x, ty), Vector2(rect.end.x, ty), COLOR_HOSPITAL_GROUT, 1.0)

	var darkroom_rect = Rect2(rect.position.x + 10, rect.position.y + 115, 135, 95)
	draw_rect(darkroom_rect, Color(0.12, 0.04, 0.04), true)
	draw_rect(darkroom_rect, Color(0.40, 0.10, 0.10), false, 2.0)
	draw_rect(darkroom_rect, COLOR_DARKROOM_RED, true)

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

func _draw_city_road_network() -> void:
	# ── 1. Trotoar & Lapisan Dasar Aspal (Seamless Asphalt Base) ─────────────
	var road_polys = [
		Rect2(-2,   190, 2164, 136),  # North Blvd
		Rect2(514,  190,  127, 598),  # West Vertical Road (y=190..788)
		Rect2(190,  784,  451, 169),  # Mid-West Plaza Road in front of Police (x=190..641, y=784..953)
		Rect2(355,  949,  112, 364),  # South-West Street between Police & Hospital (x=355..467, y=949..1313)
		Rect2(514,  547, 1504, 145),  # Central Blvd (x=514..2018, y=547..692)
		Rect2(1534, 190,   94, 1057), # East Vertical Avenue
		Rect2(2014, 190,  148, 502),  # Far-East Highway
		Rect2(-2,   1243, 1864, 70),  # South Ring Road
	]
	for r in road_polys:
		draw_rect(r, COLOR_SIDEWALK_BEVEL, true)

	var asphalts: Array[Rect2] = [
		Rect2(0,    192,  2160, 132),  # North Blvd         (y=192..324)
		Rect2(516,  192,   123, 594),  # West Vertical       (x=516..639, y=192..786)
		Rect2(192,  786,   447, 165),  # Mid-West Plaza Road in front of Police (x=192..639, y=786..951)
		Rect2(357,  951,   108, 360),  # SW Street Polisi-RS (x=357..465, y=951..1311)
		Rect2(516,  549,  1500, 141),  # Central Blvd        (x=516..2016, y=549..690)
		Rect2(1536, 192,    90, 1053), # East Vertical Avenue (x=1536..1626, y=192..1245)
		Rect2(2016, 192,   144, 498),  # Far-East Highway    (x=2016..2160, y=192..690)
		Rect2(0,    1245, 1860, 66),   # South Ring Road     (x=0..1860, y=1245..1311)
	]
	for r in asphalts:
		draw_rect(r, COLOR_ASPHALT, true)

	# ── 2. Garis Batas Tepi Jalan / Bahu Jalan (Curbs - Hanya di Dinding) ────
	# North Boulevard
	draw_line(Vector2(0, 196), Vector2(2160, 196), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(0, 320), Vector2(516, 320), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(639, 320), Vector2(1536, 320), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1626, 320), Vector2(2016, 320), COLOR_CURB_LINE, 2.0)

	# Central Boulevard
	draw_line(Vector2(516, 553), Vector2(2016, 553), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(639, 686), Vector2(1536, 686), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1626, 686), Vector2(1792, 686), COLOR_CURB_LINE, 2.0)

	# West Vertical Road
	draw_line(Vector2(520, 324), Vector2(520, 786), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(635, 324), Vector2(635, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(635, 690), Vector2(635, 947), COLOR_CURB_LINE, 2.0)

	# East Vertical Avenue
	draw_line(Vector2(1540, 324), Vector2(1540, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1622, 324), Vector2(1622, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1540, 690), Vector2(1540, 1245), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1622, 690), Vector2(1622, 849), COLOR_CURB_LINE, 2.0)

	# Mid-West Street & South-West Street (Jalan Depan & Samping Kantor Polisi / RS)
	draw_line(Vector2(192, 790), Vector2(516, 790), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(192, 947), Vector2(357, 947), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(361, 951), Vector2(361, 1080), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(361, 1150), Vector2(361, 1245), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(461, 947), Vector2(461, 1245), COLOR_CURB_LINE, 2.0)

	# South Ring Road Bottom
	draw_line(Vector2(0, 1307), Vector2(1860, 1307), COLOR_CURB_LINE, 2.0)

	# ── 3. Garis Putus-Putus Jalur (Berhenti Rapi Sebelum Persimpangan) ───────
	# North Boulevard (y = 258)
	_draw_lane_dashes(Vector2(20, 258), Vector2(496, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(659, 258), Vector2(1516, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1646, 258), Vector2(1996, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(2036, 258), Vector2(2140, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# Central Boulevard (y = 619)
	_draw_lane_dashes(Vector2(659, 619), Vector2(1516, 619), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1646, 619), Vector2(1996, 619), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# West Vertical Road (x = 577)
	_draw_lane_dashes(Vector2(577, 344), Vector2(577, 529), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(577, 710), Vector2(577, 766), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# Mid-West Street (y = 865 di depan Kantor Polisi)
	_draw_lane_dashes(Vector2(212, 865), Vector2(337, 865), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(485, 865), Vector2(619, 865), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# South-West Street (x = 411 antara Polisi & RS)
	_draw_lane_dashes(Vector2(411, 965), Vector2(411, 1225), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# East Vertical Avenue (x = 1581)
	_draw_lane_dashes(Vector2(1581, 344), Vector2(1581, 529), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(1581, 710), Vector2(1581, 1225), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# Far-East Highway (x = 2088)
	_draw_lane_dashes(Vector2(2088, 344), Vector2(2088, 529), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# South Ring Road (y = 1278)
	_draw_lane_dashes(Vector2(20, 1278), Vector2(337, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(485, 1278), Vector2(1516, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(1646, 1278), Vector2(1840, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# ── 4. Garis Berhenti / Stop Bar di Setiap Persimpangan ──────────────────
	# Persimpangan North Blvd & West Vertical
	_draw_stop_bar(Vector2(522, 328), Vector2(633, 328))
	_draw_stop_bar(Vector2(512, 200), Vector2(512, 316))
	_draw_stop_bar(Vector2(643, 200), Vector2(643, 316))

	# Persimpangan North Blvd & East Vertical
	_draw_stop_bar(Vector2(1542, 328), Vector2(1620, 328))
	_draw_stop_bar(Vector2(1532, 200), Vector2(1532, 316))
	_draw_stop_bar(Vector2(1630, 200), Vector2(1630, 316))

	# Persimpangan Central Blvd & West Vertical
	_draw_stop_bar(Vector2(522, 545), Vector2(633, 545))
	_draw_stop_bar(Vector2(643, 557), Vector2(643, 682))

	# Persimpangan Central Blvd & East Vertical (Perempatan Pusat)
	_draw_stop_bar(Vector2(1542, 545), Vector2(1620, 545))
	_draw_stop_bar(Vector2(1542, 694), Vector2(1620, 694))
	_draw_stop_bar(Vector2(1532, 557), Vector2(1532, 682))
	_draw_stop_bar(Vector2(1630, 557), Vector2(1630, 682))

	# Persimpangan Jalan Polisi & Rumah Sakit (South-West Street)
	_draw_stop_bar(Vector2(361, 947), Vector2(461, 947))
	_draw_stop_bar(Vector2(361, 1243), Vector2(461, 1243))
	_draw_stop_bar(Vector2(512, 790), Vector2(512, 947))

	# Persimpangan Far-East Highway
	_draw_stop_bar(Vector2(2012, 200), Vector2(2012, 316))
	_draw_stop_bar(Vector2(2012, 557), Vector2(2012, 682))

func _draw_lane_dashes(p1: Vector2, p2: Vector2, dash_len: float = 24.0, gap_len: float = 16.0, color: Color = COLOR_LANE_DASH, width: float = 2.0) -> void:
	var total_dist = p1.distance_to(p2)
	if total_dist <= dash_len:
		return
	var dir = (p2 - p1).normalized()
	var cur_dist = 0.0
	while cur_dist + dash_len <= total_dist:
		var start_pt = p1 + dir * cur_dist
		var end_pt = p1 + dir * (cur_dist + dash_len)
		draw_line(start_pt, end_pt, color, width)
		cur_dist += dash_len + gap_len

func _draw_stop_bar(p1: Vector2, p2: Vector2) -> void:
	draw_line(p1, p2, Color(1, 1, 1, 0.85), 3.0)

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
	_create_box_collider(Rect2(8, 955, 341, 350))

	_create_segment_collider(Vector2(639, 324), Vector2(1000, 324))
	_create_segment_collider(Vector2(1060, 324), Vector2(1536, 324))
	_create_segment_collider(Vector2(1536, 324), Vector2(1536, 420))
	_create_segment_collider(Vector2(1536, 480), Vector2(1536, 549))
	_create_segment_collider(Vector2(1536, 549), Vector2(639, 549))
	_create_segment_collider(Vector2(639, 549), Vector2(639, 440))
	_create_segment_collider(Vector2(639, 380), Vector2(639, 324))

	_create_box_collider(Rect2(672, 360, 340, 150))
	_create_box_collider(Rect2(1180, 350, 110, 75))
	_create_box_collider(Rect2(1330, 350, 110, 75))
	_create_box_collider(Rect2(1180, 445, 110, 75))
	_create_box_collider(Rect2(1330, 445, 110, 75))

	_create_segment_collider(Vector2(639, 690), Vector2(1050, 690))
	_create_segment_collider(Vector2(1050, 690), Vector2(1050, 900))
	_create_segment_collider(Vector2(1050, 960), Vector2(1050, 1245))
	_create_segment_collider(Vector2(1050, 1245), Vector2(465, 1245))
	_create_segment_collider(Vector2(465, 1245), Vector2(465, 945))
	_create_segment_collider(Vector2(465, 945), Vector2(639, 945))
	_create_segment_collider(Vector2(639, 945), Vector2(639, 810))
	_create_segment_collider(Vector2(639, 750), Vector2(639, 690))

	_create_box_collider(Rect2(672, 730, 340, 170))
	_create_box_collider(Rect2(465, 945, 585, 300))

	_create_segment_collider(Vector2(1158, 730), Vector2(1260, 730))
	_create_segment_collider(Vector2(1320, 730), Vector2(1428, 730))
	_create_segment_collider(Vector2(1428, 730), Vector2(1428, 940))
	_create_segment_collider(Vector2(1428, 940), Vector2(1158, 940))
	_create_segment_collider(Vector2(1158, 940), Vector2(1158, 730))
	_create_box_collider(Rect2(1190, 760, 205, 150))

	_create_segment_collider(Vector2(1626, 324), Vector2(2016, 324))
	_create_segment_collider(Vector2(2016, 324), Vector2(2016, 549))
	_create_segment_collider(Vector2(2016, 549), Vector2(1626, 549))
	_create_segment_collider(Vector2(1626, 549), Vector2(1626, 480))
	_create_segment_collider(Vector2(1626, 420), Vector2(1626, 324))
	_create_box_collider(Rect2(1656, 350, 330, 175))

	# Tiga Rumah Warga Tenggara
	for hy in [705.0, 880.0, 1055.0]:
		_create_box_collider(Rect2(1648, hy + 6, 132, 100))
		_create_segment_collider(Vector2(1636, hy), Vector2(1792, hy))
		_create_segment_collider(Vector2(1636, hy), Vector2(1636, hy + 156))
		_create_segment_collider(Vector2(1792, hy), Vector2(1792, hy + 156))
		_create_segment_collider(Vector2(1636, hy + 156), Vector2(1696, hy + 156))
		_create_segment_collider(Vector2(1732, hy + 156), Vector2(1792, hy + 156))

	# Stasiun Kereta & Fasilitas
	_create_box_collider(Rect2(1880, 715, 270, 270))
	_create_box_collider(Rect2(1890, 1040, 120, 45))
	_create_box_collider(Rect2(1890, 1110, 120, 45))
	_create_box_collider(Rect2(1890, 1180, 120, 45))
	_create_box_collider(Rect2(1875, 1240, 40, 52))

	_create_segment_collider(Vector2(2160, 0), Vector2(2160, 1311))

	_create_segment_collider(Vector2(0, 0), Vector2(2160, 0))
	_create_segment_collider(Vector2(0, 0), Vector2(0, 1311))
	_create_segment_collider(Vector2(0, 1311), Vector2(2160, 1311))

	for p_pos in [Vector2(480, 225), Vector2(1040, 545), Vector2(1980, 225), Vector2(1460, 1195)]:
		_create_box_collider(Rect2(p_pos.x + 4, p_pos.y + 20, 40, 52))

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
