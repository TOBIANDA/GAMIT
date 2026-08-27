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

	nav_poly.add_outline(PackedVector2Array([
		Vector2(1591, 859), Vector2(2006, 859), Vector2(2006, 1259), Vector2(1591, 1259)
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
			# Pagar Belakang (3 panel x 52px = 156px)
			draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_belakang_geser_x, 32 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
			draw_texture_rect(tex_pagar, Rect2(sq_x + pw + pg + pagar_belakang_geser_x, 32 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
			draw_texture_rect(tex_pagar, Rect2(sq_x + (pw + pg) * 2.0 + pagar_belakang_geser_x, 32 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)

			# Pagar Samping Kiri & Kanan (Panel saling tumpang tindih / overlapping tanpa celah garis)
			var side_y = 30 + pagar_samping_geser_y + gap_sudut_atas_samping
			var side_w = (pagar_samping_lebar if (pagar_samping_lebar != null and pagar_samping_lebar > 0.0) else 12.0)
			var side_total_h = (pagar_samping_tinggi if (pagar_samping_tinggi != null and pagar_samping_tinggi > 0.0) else 148.0)
			var n_panels = max(1, 2 if (pagar_samping_jumlah_panel == null or pagar_samping_jumlah_panel <= 0) else int(pagar_samping_jumlah_panel))
			var overlap_px = 16.0
			var panel_h = (side_total_h + (n_panels - 1) * overlap_px) / float(n_panels)
			var step_y = panel_h - overlap_px + (0.0 if pagar_samping_gap_panel == null else float(pagar_samping_gap_panel))

			for p in range(n_panels):
				var py = side_y + p * step_y
				# Sisi Kiri di-flip horizontal (true), Sisi Kanan normal (false)
				_draw_side_fence(Rect2(sq_x - 3 + pagar_samping_kiri_geser_x, py, side_w, panel_h), true)
				_draw_side_fence(Rect2(sq_x + 156 - side_w + 3 + pagar_samping_kanan_geser_x, py, side_w, panel_h), false)

			# Pagar Depan Kiri
			draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_kiri_geser_x, 166 + pagar_kiri_geser_y, pagar_kiri_lebar * sk_kiri, 26 * sk_kiri), false)
			# Pintu Pagar Tengah (Jalan Masuk)
			draw_texture_rect(tex_pintu_pagar, Rect2(sq_x + 62 + pintu_pagar_geser_x, 162 + pintu_pagar_geser_y, pintu_pagar_lebar * sk_pintu, 30 * sk_pintu), false)
			# Pagar Depan Kanan (di-rotate/mirror horizontal)
			_draw_texture_flipped(tex_pagar, Rect2(sq_x + 94 + pagar_kanan_geser_x, 166 + pagar_kanan_geser_y, pagar_kanan_lebar * sk_kanan, 26 * sk_kanan), true, false)

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
	_draw_texture_fit(tex_police, Rect2(8, 955, 341, 350))

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

	var bot_complex_pts = PackedVector2Array([
		Vector2(639, 690), Vector2(1050, 690), Vector2(1050, 1245),
		Vector2(465, 1245), Vector2(465, 945), Vector2(639, 945)
	])
	draw_colored_polygon(bot_complex_pts, COLOR_ROOM_STONE_B)
	_draw_tile_pattern(Rect2(639, 690, 411, 255), COLOR_PLAZA_TILE_LINE)

	# Taman & Plaza Utara Kompleks
	_draw_desk(Rect2(672, 730, 340, 170))
	_draw_courtyard_garden(Vector2(780, 830), 40.0)

	# Gedung Utama Rumah Sakit (Mentok ke tepi jalan dan batas blok)
	_draw_hospital_main_building(Rect2(465, 945, 585, 300))

	_draw_room_pavement(Rect2(1158, 730, 270, 210), COLOR_ROOM_OCHRE)
	_draw_texture_fit(tex_rumah_belakang, Rect2(1180, 745, 220, 175))

	_draw_room_pavement(Rect2(1626, 324, 390, 225), COLOR_ROOM_STONE_A)
	_draw_texture_fit(tex_rumah_samping, Rect2(1650, 335, 340, 205))

	draw_rect(Rect2(1581, 849, 504, 420), COLOR_ROOM_DARK, true)
	draw_rect(Rect2(1640, 900, 385, 310), COLOR_ROOM_RUG, true)
	draw_circle(Vector2(1833, 1059), 110.0, Color(0.85, 0.72, 0.25, 0.35))
	draw_circle(Vector2(1833, 1059), 85.0, Color(0.12, 0.13, 1.0, 1.0))
	draw_circle(Vector2(1833, 1059), 80.0, Color(0.85, 0.72, 0.25, 0.8))
	draw_circle(Vector2(1833, 1059), 74.0, Color(0.12, 0.13, 0.16, 1.0))
	draw_rect(Rect2(1530, 1000, 60, 120), COLOR_ROOM_RUG, true)
	draw_rect(Rect2(1770, 810, 125, 60), COLOR_ROOM_RUG, true)

	_draw_city_road_network()

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
	_draw_poi_badge(Vector2(750, 1095), "Rumah Sakit",    Color(0.85, 0.25, 0.25))
	_draw_poi_badge(Vector2(180, 1050), "Brankas Ibu",    Color(0.80, 0.50, 0.90))
	_draw_poi_badge(Vector2(1833, 1059),"Altar Dewa",     Color(0.70, 0.25, 0.95))

func _draw_hospital_main_building(rect: Rect2) -> void:
	draw_rect(rect, COLOR_ROOM_STONE_B, true)
	_draw_tile_pattern(rect, COLOR_PLAZA_TILE_LINE)
	_draw_texture_fit(tex_hospital, Rect2(rect.position.x + 4, rect.position.y + 4, rect.size.x - 8, rect.size.y - 8))

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

func _draw_city_road_network() -> void:
	# ── 1. Trotoar & Lapisan Dasar Aspal (Seamless Asphalt Base) ─────────────
	var road_polys = [
		Rect2(-2, 190, 2164, 136),     # North Blvd
		Rect2(514, 190, 127, 598),     # West Vertical Road
		Rect2(190, 784, 451, 163),     # Mid-West Plaza Road
		Rect2(355, 943, 112, 370),     # South-West Street (Police alley)
		Rect2(514, 547, 1504, 145),    # Central Blvd
		Rect2(1534, 190, 94, 1057),    # East Vertical Avenue
		Rect2(2014, 190, 148, 1123),   # Far-East Highway
		Rect2(355, 1243, 1807, 70),    # South Ring Road
	]
	for r in road_polys:
		draw_rect(r, COLOR_SIDEWALK_BEVEL, true)

	var asphalts = [
		Rect2(0, 192, 2160, 132),      # North Blvd (y=192..324)
		Rect2(516, 192, 123, 594),     # West Vertical (x=516..639, y=192..786)
		Rect2(192, 786, 447, 159),     # Mid-West Plaza (x=192..639, y=786..945)
		Rect2(357, 945, 108, 366),     # South-West Street (x=357..465, y=945..1311)
		Rect2(516, 549, 1500, 141),    # Central Blvd (x=516..2016, y=549..690)
		Rect2(1536, 192, 90, 1053),    # East Vertical Avenue (x=1536..1626, y=192..1245)
		Rect2(2016, 192, 144, 1119),   # Far-East Highway (x=2016..2160, y=192..1311)
		Rect2(357, 1245, 1803, 66),    # South Ring Road (x=357..2160, y=1245..1311)
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
	draw_line(Vector2(639, 553), Vector2(1536, 553), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1626, 553), Vector2(2016, 553), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(639, 686), Vector2(1536, 686), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1626, 686), Vector2(2016, 686), COLOR_CURB_LINE, 2.0)

	# West Vertical Road
	draw_line(Vector2(520, 324), Vector2(520, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(635, 324), Vector2(635, 549), COLOR_CURB_LINE, 2.0)

	# East Vertical Avenue
	draw_line(Vector2(1540, 324), Vector2(1540, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1622, 324), Vector2(1622, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1540, 690), Vector2(1540, 1245), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1622, 690), Vector2(1622, 849), COLOR_CURB_LINE, 2.0)

	# South-West L-Turn (Jalan Nyiku di dekat Kantor Polisi)
	draw_line(Vector2(192, 790), Vector2(516, 790), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(461, 945), Vector2(461, 1245), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(192, 941), Vector2(361, 941), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(361, 941), Vector2(361, 1245), COLOR_CURB_LINE, 2.0)

	# South Ring Road Bottom
	draw_line(Vector2(0, 1307), Vector2(2160, 1307), COLOR_CURB_LINE, 2.0)

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

	# East Vertical Avenue (x = 1581)
	_draw_lane_dashes(Vector2(1581, 344), Vector2(1581, 529), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(1581, 710), Vector2(1581, 1225), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# Mid-West L-Turn Alley (y = 865, x = 411)
	_draw_lane_dashes(Vector2(212, 865), Vector2(390, 865), 18.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.5), 1.5)
	_draw_lane_dashes(Vector2(411, 965), Vector2(411, 1225), 18.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.5), 1.5)

	# Far-East Highway (x = 2088)
	_draw_lane_dashes(Vector2(2088, 344), Vector2(2088, 529), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(2088, 710), Vector2(2088, 1225), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# South Ring Road (y = 1278)
	_draw_lane_dashes(Vector2(485, 1278), Vector2(1516, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(1646, 1278), Vector2(1996, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

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

	# Persimpangan Far-East Highway
	_draw_stop_bar(Vector2(2012, 200), Vector2(2012, 316))
	_draw_stop_bar(Vector2(2012, 557), Vector2(2012, 682))
	_draw_stop_bar(Vector2(2012, 1250), Vector2(2012, 1305))

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
