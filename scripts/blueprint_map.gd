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
		Vector2(2420, 192),
		Vector2(2420, 1311),
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

	# 3. Jalur Rel Kereta Api (Membentang vertikal di antara Peron 1 dan Peron 2: x=2160..2280)
	draw_rect(Rect2(2160, 0, 120, 1311), COLOR_TRACK_BALLAST, true)
	for ty in range(12, 1311, 16):
		draw_line(Vector2(2168, ty), Vector2(2272, ty), COLOR_TRACK_TIE, 3.5)
	draw_line(Vector2(2185, 0), Vector2(2185, 1311), COLOR_TRACK_RAIL, 4.5)
	draw_line(Vector2(2255, 0), Vector2(2255, 1311), COLOR_TRACK_RAIL, 4.5)

	# 4. Kompleks Stasiun Kereta Api Timur (Parkiran + Peron 1 + Penyeberangan Rel + Peron 2)
	_draw_train_station(Rect2(1860, 690, 300, 621))

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

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER GAMBAR MOBIL TOP-DOWN
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_topdown_car(pos: Vector2, color: Color, is_vertical: bool = false, is_taxi: bool = false) -> void:
	var cw := 24.0 if is_vertical else 46.0
	var ch := 46.0 if is_vertical else 24.0

	# Bayangan jatuh mobil
	draw_rect(Rect2(pos.x - 3, pos.y + 4, cw + 2, ch), Color(0.06, 0.07, 0.09, 0.40), true)

	# Bodi Utama Mobil (Chassis)
	draw_rect(Rect2(pos.x, pos.y, cw, ch), color, true)
	draw_rect(Rect2(pos.x, pos.y, cw, ch), color.darkened(0.35), false, 1.5) # Border bodi

	if not is_vertical:
		# Mobil Horizontal (Menghadap Kanan)
		# Kaca Depan (Kanan)
		draw_rect(Rect2(pos.x + 30, pos.y + 3, 6, 18), Color(0.14, 0.18, 0.24), true)
		draw_line(Vector2(pos.x + 31, pos.y + 5), Vector2(pos.x + 35, pos.y + 9), Color(0.75, 0.90, 1.0, 0.70), 1.2)
		# Kaca Belakang (Kiri)
		draw_rect(Rect2(pos.x + 10, pos.y + 3, 5, 18), Color(0.14, 0.18, 0.24), true)
		# Atap Mobil (Roof)
		draw_rect(Rect2(pos.x + 15, pos.y + 3, 15, 18), color.darkened(0.15), true)
		# Lampu Depan (Kuning Terang di Kanan)
		draw_rect(Rect2(pos.x + 44, pos.y + 2, 2, 4), Color(0.98, 0.95, 0.50), true)
		draw_rect(Rect2(pos.x + 44, pos.y + 18, 2, 4), Color(0.98, 0.95, 0.50), true)
		# Lampu Belakang (Merah di Kiri)
		draw_rect(Rect2(pos.x, pos.y + 2, 2, 4), Color(0.95, 0.20, 0.20), true)
		draw_rect(Rect2(pos.x, pos.y + 18, 2, 4), Color(0.95, 0.20, 0.20), true)
		# Spion
		draw_rect(Rect2(pos.x + 29, pos.y - 2, 3, 2), color.darkened(0.25), true)
		draw_rect(Rect2(pos.x + 29, pos.y + 24, 3, 2), color.darkened(0.25), true)
		# Atap Taksi (Jika Taksi)
		if is_taxi:
			draw_rect(Rect2(pos.x + 20, pos.y + 8, 8, 8), Color(0.98, 0.95, 0.20), true)
			draw_rect(Rect2(pos.x + 20, pos.y + 8, 8, 8), COLOR_WALL_LINE, false, 1.0)
			draw_line(Vector2(pos.x + 22, pos.y + 12), Vector2(pos.x + 26, pos.y + 12), COLOR_WALL_LINE, 1.5)
	else:
		# Mobil Vertikal (Menghadap Bawah)
		draw_rect(Rect2(pos.x + 3, pos.y + 30, 18, 6), Color(0.14, 0.18, 0.24), true) # Kaca depan
		draw_rect(Rect2(pos.x + 3, pos.y + 10, 18, 5), Color(0.14, 0.18, 0.24), true) # Kaca belakang
		draw_rect(Rect2(pos.x + 3, pos.y + 15, 18, 15), color.darkened(0.15), true) # Atap
		draw_rect(Rect2(pos.x + 2, pos.y + 44, 4, 2), Color(0.98, 0.95, 0.50), true) # Lampu depan
		draw_rect(Rect2(pos.x + 18, pos.y + 44, 4, 2), Color(0.98, 0.95, 0.50), true)
		draw_rect(Rect2(pos.x + 2, pos.y, 4, 2), Color(0.95, 0.20, 0.20), true) # Lampu belakang
		draw_rect(Rect2(pos.x + 18, pos.y, 4, 2), Color(0.95, 0.20, 0.20), true)


# ═══════════════════════════════════════════════════════════════════════════════
# HELPER GAMBAR TEMPAT PARKIR STASIUN (Parking Lot)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_parking_lot(rect: Rect2) -> void:
	var px := rect.position.x
	var py := rect.position.y
	var pw := rect.size.x   # 125
	var ph := rect.size.y   # 621

	# Aspal Lantai Parkir
	draw_rect(rect, COLOR_ASPHALT, true)

	# Trotoar Pembatas Sisi Barat (Gang) & Sisi Timur (Peron)
	draw_line(Vector2(px, py), Vector2(px, py + ph), COLOR_SIDEWALK_BEVEL, 3.0)
	draw_line(Vector2(px + pw, py), Vector2(px + pw, py + ph), COLOR_CURB_LINE, 2.5)

	# Marka Slot Parkir Mobil Horizontal (Putih Rapi)
	var slot_y_list := [py + 30.0, py + 95.0, py + 160.0, py + 225.0, py + 290.0, py + 410.0, py + 475.0, py + 540.0]
	for sy in slot_y_list:
		# Garis petak parkir
		draw_line(Vector2(px + 8, sy), Vector2(px + 85, sy), Color(0.92, 0.94, 0.98, 0.85), 2.0)
		# Pembatas ban / Wheel stop beton
		draw_rect(Rect2(px + 12, sy + 16, 6, 32), Color(0.70, 0.72, 0.76), true)
		draw_rect(Rect2(px + 12, sy + 16, 6, 32), Color(0.35, 0.38, 0.42), false, 1.0)

	# Mobil-Mobil yang Sedang Terparkir
	_draw_topdown_car(Vector2(px + 24, py + 38), Color(0.20, 0.45, 0.78), false, false) # Sedan Biru
	_draw_topdown_car(Vector2(px + 24, py + 103), Color(0.92, 0.75, 0.15), false, true)  # Taksi Kuning
	_draw_topdown_car(Vector2(px + 24, py + 168), Color(0.78, 0.80, 0.84), false, false) # Mobil Silver
	_draw_topdown_car(Vector2(px + 24, py + 418), Color(0.85, 0.22, 0.20), false, false) # Mobil Merah
	_draw_topdown_car(Vector2(px + 24, py + 483), Color(0.18, 0.58, 0.35), false, false) # Mobil Hijau

	# Area Parkir Sepeda / Motor di Tengah (y + 350)
	var bike_y := py + 350.0
	draw_rect(Rect2(px + 10, bike_y, 75, 45), Color(0.28, 0.30, 0.34), true)
	draw_rect(Rect2(px + 10, bike_y, 75, 45), COLOR_CURB_LINE, false, 1.5)
	# Rak besi sepeda
	for bx in range(int(px) + 18, int(px) + 80, 14):
		draw_rect(Rect2(bx, bike_y + 6, 4, 32), COLOR_STEEL_LIGHT, true)
		# Mini motor/sepeda
		draw_circle(Vector2(bx + 2, bike_y + 12), 3.0, Color(0.85, 0.25, 0.25))
		draw_circle(Vector2(bx + 2, bike_y + 32), 3.0, Color(0.20, 0.20, 0.20))

	# Taman Peneduh Parkiran (Tree Island) di Ujung Bawah
	var tree_y := py + 575.0
	draw_rect(Rect2(px + 10, tree_y, 75, 38), COLOR_GRASS, true)
	draw_rect(Rect2(px + 10, tree_y, 75, 38), COLOR_SIDEWALK_BEVEL, false, 2.0)
	draw_circle(Vector2(px + 45, tree_y + 18), 16.0, COLOR_TREE_DARK)
	draw_circle(Vector2(px + 45, tree_y + 18), 11.0, COLOR_TREE_LIGHT)

	# Tiang Lampu Jalan Parkiran
	for ly_pos in [py + 70.0, py + 260.0, py + 450.0]:
		draw_circle(Vector2(px + pw - 14, ly_pos), 5.0, COLOR_STEEL_DARK)
		draw_circle(Vector2(px + pw - 14, ly_pos), 3.0, Color(0.98, 0.95, 0.50)) # Lampu menyala

	# Jalur Penyeberangan Zebra (Pedestrian Walkway) Menuju Peron 1
	var cross_y := py + 348.0
	for zy in range(int(cross_y), int(cross_y) + 48, 10):
		draw_line(Vector2(px + pw - 24, zy), Vector2(px + pw + 8, zy), Color(0.92, 0.94, 0.98, 0.85), 4.0)


# ═══════════════════════════════════════════════════════════════════════════════
# HELPER GAMBAR KANOPI PENEDUH VERTIKAL 3D (Vertical 3D Elevated Canopy)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_vertical_canopy(rect: Rect2) -> void:
	var cx := rect.position.x
	var cy := rect.position.y
	var cw := rect.size.x   # e.g. 70
	var ch := rect.size.y   # e.g. 550

	# 1. Bayangan Jatuh Atap (Elevated Drop Shadow 14px ke Kiri)
	var shadow_rect := Rect2(cx - 14, cy + 12, cw + 8, ch)
	draw_rect(shadow_rect, Color(0.06, 0.07, 0.10, 0.38), true)

	# 2. Tiang Kolom Baja Silinder Menjulang dari Lantai
	for pi in range(6):
		var py_pos := cy + 30.0 + pi * (ch - 60.0) / 5.0
		var col_pt := Vector2(cx + cw * 0.5, py_pos)
		# Base plate tiang
		draw_circle(col_pt + Vector2(-3, 3), 6.0, Color(0.08, 0.09, 0.12, 0.40))
		draw_rect(Rect2(col_pt.x - 6, col_pt.y - 6, 12, 12), Color(0.24, 0.25, 0.28), true)
		draw_circle(col_pt, 5.0, COLOR_STEEL_DARK)
		draw_circle(col_pt, 3.0, COLOR_STEEL_LIGHT)

	# 3. Struktur Atap Kanopi 3D Memanjang Vertikal
	# A. Lisplang Bawah / Underside
	draw_rect(Rect2(cx - 2, cy - 2, cw + 4, ch + 4), Color(0.16, 0.17, 0.20), true)

	# B. Kemiringan Sisi Barat (Terpapar Sinar Matahari)
	var slope_w := cw * 0.50
	draw_rect(Rect2(cx, cy, slope_w, ch), Color(0.50, 0.47, 0.44), true)

	# C. Kemiringan Sisi Timur (Sisi Bayangan)
	draw_rect(Rect2(cx + slope_w, cy, slope_w, ch), Color(0.32, 0.30, 0.28), true)

	# D. Bubungan Tengah Atap (Center Ridge Highlight)
	draw_line(Vector2(cx + slope_w, cy), Vector2(cx + slope_w, cy + ch), Color(0.80, 0.77, 0.74), 2.5)

	# E. Garis-Garis Panel Seng Gelombang / Standing Seams
	for py_pos in range(int(cy) + 12, int(cy + ch), 14):
		draw_line(Vector2(cx + 2, py_pos), Vector2(cx + slope_w - 1, py_pos), Color(0.40, 0.37, 0.34), 1.2)
		draw_line(Vector2(cx + slope_w + 1, py_pos), Vector2(cx + cw - 2, py_pos), Color(0.22, 0.20, 0.18), 1.2)

	# F. Lisplang Tepi Atap 3D
	draw_rect(Rect2(cx, cy, cw, ch), Color(0.14, 0.13, 0.12), false, 2.0)

	# G. Lampu-Lampu Gantung Stasiun di Bawah Atap
	for pi in range(5):
		var py_pos := cy + 50.0 + pi * (ch - 100.0) / 4.0
		draw_circle(Vector2(cx + slope_w, py_pos), 4.5, Color(0.98, 0.90, 0.40))
		draw_circle(Vector2(cx + slope_w, py_pos), 2.5, Color(1.0, 1.0, 0.90))


# ═══════════════════════════════════════════════════════════════════════════════
# FUNGSI UTAMA: KOMPLEKS STASIUN KERETA API (Parkiran + Peron 1 + Rel + Peron 2)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_train_station(rect: Rect2) -> void:
	var x  := rect.position.x   # 1860
	var y  := rect.position.y   # 690
	var rw := rect.size.x       # 300
	var rh := rect.size.y       # 621

	# ─────────────────────────────────────────────────────────────────────────
	# 1. AREA PARKIRAN STASIUN (Di Bagian Barat Blok: x = 1860 .. 1985)
	# ─────────────────────────────────────────────────────────────────────────
	var park_w := 125.0
	_draw_parking_lot(Rect2(x, y, park_w, rh))

	# ─────────────────────────────────────────────────────────────────────────
	# 2. PERON 1 BARAT (Stasiun Utama: x = 1985 .. 2160)
	# ─────────────────────────────────────────────────────────────────────────
	var p1_x := x + park_w      # 1985
	var p1_w := rw - park_w     # 175
	var p1_rect := Rect2(p1_x, y, p1_w, rh)

	# Lantai Keramik Peron 1
	draw_rect(p1_rect, COLOR_ROOM_STONE_A, true)
	_draw_tile_pattern(p1_rect, COLOR_PLAZA_TILE_LINE)

	# Kanopi Peneduh Vertikal Peron 1
	_draw_vertical_canopy(Rect2(p1_x + 14, y + 25, 75, rh - 50))

	# Papan Nama Besar: "STASIUN KOTA - PERON 1" (Utara)
	var sign1_x := p1_x + 20.0
	var sign1_y := y + 35.0
	draw_rect(Rect2(sign1_x, sign1_y, 65, 20), Color(0.12, 0.25, 0.45), true)
	draw_rect(Rect2(sign1_x, sign1_y, 65, 20), COLOR_HELIPAD_RING, false, 1.5)
	draw_line(Vector2(sign1_x + 4, sign1_y + 10), Vector2(sign1_x + 61, sign1_y + 10), Color(0.95, 0.95, 0.95), 2.0)

	# Papan Jadwal Digital LED (PIDS Screen)
	var pids1_y := y + 140.0
	draw_rect(Rect2(sign1_x, pids1_y, 65, 28), Color(0.08, 0.10, 0.14), true)
	draw_rect(Rect2(sign1_x, pids1_y, 65, 28), Color(0.25, 0.45, 0.70), false, 1.5)
	draw_line(Vector2(sign1_x + 4, pids1_y + 8), Vector2(sign1_x + 61, pids1_y + 8), Color(0.30, 0.85, 0.95), 1.8)
	draw_line(Vector2(sign1_x + 4, pids1_y + 16), Vector2(sign1_x + 55, pids1_y + 16), COLOR_RUG_GOLD, 1.5)
	draw_line(Vector2(sign1_x + 4, pids1_y + 22), Vector2(sign1_x + 48, pids1_y + 22), COLOR_RUG_GOLD, 1.5)

	# Bangku Tunggu Kayu & Penumpang di Bawah Kanopi Peron 1
	var bench_spots_p1 := [y + 220.0, y + 320.0, y + 420.0]
	for by_pos in bench_spots_p1:
		_draw_station_bench(Vector2(p1_x + 26, by_pos), 50.0, 18.0)
		# Penumpang mini
		draw_circle(Vector2(p1_x + 51, by_pos + 8), 4.5, Color(0.85, 0.65, 0.45))
		draw_circle(Vector2(p1_x + 51, by_pos + 6), 4.5, COLOR_PARQUET_DARK)
		draw_rect(Rect2(p1_x + 47, by_pos + 10, 8, 7), Color(0.25, 0.45, 0.75), true)

	# Vending Machine Minuman Merah di Peron 1
	draw_rect(Rect2(p1_x + 28, y + 480, 24, 38), COLOR_MED_RED, true)
	draw_rect(Rect2(p1_x + 28, y + 480, 24, 38), Color(0.18, 0.12, 0.12), false, 1.5)
	draw_rect(Rect2(p1_x + 31, y + 484, 18, 16), Color(0.10, 0.12, 0.16), true)

	# Bilik Telepon Stasiun & Tempat Sampah di Selatan
	_draw_phone_booth(Rect2(p1_x + 20, y + 545, 42, 60))
	draw_rect(Rect2(p1_x + 70, y + 555, 10, 14), Color(0.22, 0.58, 0.28), true) # Hijau
	draw_rect(Rect2(p1_x + 70, y + 555, 10, 14), COLOR_WALL_LINE, false, 1.5)

	# Garis Kuning Pemandu / Tactile Warning Strip Peron 1 (Tepat di Tepi Rel x=2138..2160)
	var warn_w := 22.0
	var warn1_x := rect.end.x - warn_w # 2138
	draw_rect(Rect2(warn1_x, y, warn_w, rh), COLOR_HELIPAD_RING, true)
	for ty in range(int(y) + 4, int(y + rh), 8):
		draw_circle(Vector2(warn1_x + 5, ty), 1.4, Color(0.70, 0.58, 0.12))
		draw_circle(Vector2(warn1_x + 16, ty), 1.4, Color(0.70, 0.58, 0.12))
	draw_line(Vector2(rect.end.x, y), Vector2(rect.end.x, y + rh), COLOR_WALL_LINE, 3.0)

	# ─────────────────────────────────────────────────────────────────────────
	# 3. PERON 2 TIMUR (Seberang Rel Kereta: x = 2280 .. 2420)
	# ─────────────────────────────────────────────────────────────────────────
	var p2_x := 2280.0
	var p2_w := 140.0
	var p2_rect := Rect2(p2_x, y, p2_w, rh)

	# Lantai Keramik Peron 2
	draw_rect(p2_rect, COLOR_ROOM_STONE_A, true)
	_draw_tile_pattern(p2_rect, COLOR_PLAZA_TILE_LINE)

	# Garis Kuning Keselamatan Peron 2 (Sisi Barat Menghadap Rel x=2280..2302)
	draw_rect(Rect2(p2_x, y, warn_w, rh), COLOR_HELIPAD_RING, true)
	for ty in range(int(y) + 4, int(y + rh), 8):
		draw_circle(Vector2(p2_x + 6, ty), 1.4, Color(0.70, 0.58, 0.12))
		draw_circle(Vector2(p2_x + 16, ty), 1.4, Color(0.70, 0.58, 0.12))
	draw_line(Vector2(p2_x, y), Vector2(p2_x, y + rh), COLOR_WALL_LINE, 3.0)

	# Kanopi Peneduh Vertikal Peron 2
	_draw_vertical_canopy(Rect2(p2_x + 40, y + 25, 65, rh - 50))

	# Papan Nama "PERON 2 - JALUR TIMUR"
	var sign2_x := p2_x + 45.0
	draw_rect(Rect2(sign2_x, sign1_y, 55, 20), Color(0.12, 0.25, 0.45), true)
	draw_rect(Rect2(sign2_x, sign1_y, 55, 20), COLOR_HELIPAD_RING, false, 1.5)
	draw_line(Vector2(sign2_x + 4, sign1_y + 10), Vector2(sign2_x + 51, sign1_y + 10), Color(0.95, 0.95, 0.95), 2.0)

	# Bangku Tunggu Kayu & Tempat Sampah di Peron 2
	for by_pos in [y + 180.0, y + 320.0, y + 460.0]:
		_draw_station_bench(Vector2(p2_x + 48, by_pos), 48.0, 18.0)
		draw_circle(Vector2(p2_x + 72, by_pos + 8), 4.5, Color(0.85, 0.65, 0.45))
		draw_circle(Vector2(p2_x + 72, by_pos + 6), 4.5, COLOR_PARQUET_DARK)
		draw_rect(Rect2(p2_x + 68, by_pos + 10, 8, 7), Color(0.75, 0.25, 0.35), true) # Baju merah

	# Pagar Pembatas Ujung Timur Stasiun
	draw_line(Vector2(p2_x + p2_w, y), Vector2(p2_x + p2_w, y + rh), COLOR_WALL_LINE, 3.5)

	# ─────────────────────────────────────────────────────────────────────────
	# 4. PENYEBERANGAN PEJALAN KAKI ANTAR PERON (Pedestrian Track Crossing)
	# ─────────────────────────────────────────────────────────────────────────
	var cross_y := y + 280.0
	var cross_h := 60.0
	# Papan kayu penyeberangan rel antar peron
	draw_rect(Rect2(2138, cross_y, 2280 - 2138 + warn_w, cross_h), Color(0.38, 0.28, 0.20), true)
	for cx_bar in range(2145, 2300, 16):
		draw_line(Vector2(cx_bar, cross_y), Vector2(cx_bar, cross_y + cross_h), Color(0.24, 0.16, 0.10), 2.0)
	# Strip kuning penyeberangan
	draw_line(Vector2(2138, cross_y), Vector2(2302, cross_y), COLOR_HELIPAD_RING, 3.0)
	draw_line(Vector2(2138, cross_y + cross_h), Vector2(2302, cross_y + cross_h), COLOR_HELIPAD_RING, 3.0)

	# Lampu Sinyal Penyeberangan Peron (Platform Crossing Signal Light)
	draw_circle(Vector2(2145, cross_y - 10), 5.0, COLOR_STEEL_DARK)
	draw_circle(Vector2(2145, cross_y - 10), 3.0, COLOR_ECG_GREEN)
	draw_circle(Vector2(2295, cross_y - 10), 5.0, COLOR_STEEL_DARK)
	draw_circle(Vector2(2295, cross_y - 10), 3.0, COLOR_ECG_GREEN)

	# Border Dinding Pembatas Blok Barat Stasiun
	draw_rect(rect, COLOR_WALL_LINE, false, 3.0)


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
