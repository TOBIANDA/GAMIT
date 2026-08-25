extends Node2D

# ── Blueprint Map v6 (Realistic Cohesive City Asphalt & Architectural Palette) ──
# Dioptimalkan sesuai referensi peta arsitektur kota top-down:
# 1. Jalan Aspal Charcoal Gelap Terpadu & Konsisten di Seluruh Peta
# 2. Garis Marka Jalan Putih & Kuning (Garis Putus-Putus Jalur & Garis Tepi Trotoar)
# 3. Persimpangan Jalan dengan Marka Sambungan Teratur
# 4. Palet Warna Bangunan & Ruangan Alami (Batu Gading, Slate Abu-Abu, Oker Hangat)
# 5. Detail Courtyard Taman Hijau, Ubin Plaza Batu, dan Helipad (H) Kuning
# 6. Preservasi 100% Collision Statis & Area Navigasi Pemain

# ── Palet Warna Terpadu & Konsisten (Sesuai Gambar Referensi) ────────────────
const COLOR_VOID            = Color(0.12, 0.13, 0.15, 1.0) # Latar luar peta gelap

# Jalan Aspal & Marka
const COLOR_ASPHALT         = Color(0.22, 0.23, 0.25, 1.0) # Aspal gelap charcoal (#383a40)
const COLOR_ASPHALT_DARK    = Color(0.18, 0.19, 0.21, 1.0) # Aspal dalam
const COLOR_CURB_LINE       = Color(0.55, 0.58, 0.62, 0.85)# Garis solid tepi jalan
const COLOR_LANE_DASH       = Color(0.85, 0.88, 0.92, 0.80)# Garis putus-putus marka jalan
const COLOR_SIDEWALK        = Color(0.42, 0.44, 0.47, 1.0) # Trotoar abu-abu beton
const COLOR_SIDEWALK_BEVEL  = Color(0.28, 0.30, 0.33, 1.0) # Bayangan tepi trotoar

# Lantai Ruangan & Plaza Arsitektur
const COLOR_ROOM_STONE_A    = Color(0.76, 0.74, 0.69, 1.0) # Batu gading tan hangat
const COLOR_ROOM_STONE_B    = Color(0.68, 0.67, 0.64, 1.0) # Batu slate abu-abu
const COLOR_ROOM_OCHRE      = Color(0.74, 0.58, 0.42, 1.0) # Aksen oker terakota hangat
const COLOR_ROOM_DARK       = Color(0.16, 0.17, 0.20, 1.0) # Ruang obsidian Dewa Kematian
const COLOR_ROOM_RUG        = Color(0.28, 0.16, 0.24, 1.0) # Karpet merah marun tua

# Plaza, Taman & Helipad
const COLOR_PLAZA_TILES     = Color(0.72, 0.70, 0.65, 1.0) # Ubin paving plaza
const COLOR_PLAZA_TILE_LINE = Color(0.58, 0.56, 0.52, 0.60)# Garis ubin
const COLOR_GRASS           = Color(0.45, 0.55, 0.22, 1.0) # Rumput taman hijau segar
const COLOR_TREE_DARK       = Color(0.24, 0.32, 0.14, 1.0) # Rimbun pohon atas
const COLOR_TREE_LIGHT      = Color(0.38, 0.48, 0.20, 1.0) # Daun pohon highlight
const COLOR_HELIPAD_RING    = Color(0.92, 0.78, 0.22, 1.0) # Lingkaran kuning Helipad

# Meja, Dinding & Rel
const COLOR_DESK_WOOD       = Color(0.52, 0.44, 0.36, 1.0) # Meja kayu walnut
const COLOR_DESK_RIM        = Color(0.24, 0.20, 0.16, 1.0) # Pinggir meja
const COLOR_WALL_LINE       = Color(0.10, 0.11, 0.13, 1.0) # Garis dinding hitam arsitektur
const COLOR_WALL_PARAPET    = Color(0.82, 0.84, 0.87, 1.0) # Pinggir atas dinding putih abu-abu

const COLOR_TRACK_BALLAST   = Color(0.20, 0.21, 0.23, 1.0) # Kerikil rel gelap
const COLOR_TRACK_RAIL      = Color(0.70, 0.74, 0.80, 1.0) # Rel baja perak
const COLOR_TRACK_TIE       = Color(0.38, 0.33, 0.28, 1.0) # Bantalan kayu rel

const WT = 6.0 # Wall thickness
var collision_bodies: Array[StaticBody2D] = []

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ─────────────────────────────────────────────────────────────────────────────
func _draw() -> void:
	# 0. Background Area Luar / Void
	draw_rect(Rect2(-200, -200, 2800, 1800), COLOR_VOID, true)

	# 1. Base Trotoar / Lantai Dasar Map (0 .. 2160, 0 .. 1311)
	draw_rect(Rect2(0, 0, 2160, 1311), COLOR_SIDEWALK, true)

	# Grid Trotoar Halus
	for gx in range(40, 2160, 40):
		draw_line(Vector2(gx, 0), Vector2(gx, 1311), Color(0, 0, 0, 0.08), 1.0)
	for gy in range(40, 1311, 40):
		draw_line(Vector2(0, gy), Vector2(2160, gy), Color(0, 0, 0, 0.08), 1.0)

	# ── A. RUANGAN-RUANGAN DENGAN PALET WARNA KONSISTEN ────────────────────────

	# 1. 11 TOP ROW SQUARES (sq_top_1 .. sq_top_11)
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		var r_color = COLOR_ROOM_STONE_A if i % 2 == 0 else COLOR_ROOM_STONE_B
		if i == 0 or i == 10:
			r_color = COLOR_ROOM_OCHRE
		_draw_room_pavement(Rect2(sq_x, 36, 156, 156), r_color)
		_draw_desk(Rect2(sq_x + 30, 70, 96, 75))

	# 2. ROOM LEFT L (L-Shaped Room)
	var l_pts = PackedVector2Array([
		Vector2(0, 324), Vector2(516, 324), Vector2(516, 786),
		Vector2(192, 786), Vector2(192, 933), Vector2(0, 933)
	])
	draw_colored_polygon(l_pts, COLOR_ROOM_STONE_A)
	_draw_tile_pattern(Rect2(0, 324, 516, 462), COLOR_PLAZA_TILE_LINE)

	# Desks di dalam Room Left L
	_draw_desk(Rect2(9, 324, 156, 156))
	_draw_desk(Rect2(195, 324, 156, 156))
	_draw_desk(Rect2(411, 324, 105, 156))
	_draw_desk(Rect2(411, 495, 105, 156))
	_draw_desk(Rect2(411, 666, 105, 120))
	_draw_desk(Rect2(25, 800, 140, 100))

	# 3. ROOM BOTTOM LEFT (0, 951, 357, 360) - Kantor & Arsip Barat
	_draw_room_pavement(Rect2(0, 951, 357, 360), COLOR_ROOM_STONE_B)
	_draw_desk(Rect2(40, 1000, 270, 120))
	_draw_desk(Rect2(40, 1160, 270, 120))

	# 4. TOP COMPLEX (GEDUNG TENGAH ATAS NYATU - STEPPED POLYGON)
	var top_complex_pts = PackedVector2Array([
		Vector2(639, 324), Vector2(1536, 324), Vector2(1536, 714),
		Vector2(1158, 714), Vector2(1158, 549), Vector2(639, 549)
	])
	draw_colored_polygon(top_complex_pts, COLOR_ROOM_STONE_A)
	_draw_tile_pattern(Rect2(639, 324, 897, 225), COLOR_PLAZA_TILE_LINE)

	# Taman Courtyard Kecil & Workstations
	_draw_courtyard_garden(Vector2(950, 435), 65.0)
	_draw_desk(Rect2(672, 360, 220, 150))
	_draw_desk(Rect2(1191, 354, 120, 120))
	_draw_desk(Rect2(1341, 354, 120, 120))
	_draw_desk(Rect2(1191, 585, 120, 120))
	_draw_desk(Rect2(1341, 585, 120, 120))

	# 5. BOTTOM COMPLEX (GEDUNG TENGAH BAWAH NYATU)
	var bot_complex_pts = PackedVector2Array([
		Vector2(639, 690), Vector2(1050, 690), Vector2(1050, 1245),
		Vector2(465, 1245), Vector2(465, 945), Vector2(639, 945)
	])
	draw_colored_polygon(bot_complex_pts, COLOR_ROOM_STONE_B)
	_draw_tile_pattern(Rect2(465, 945, 585, 300), COLOR_PLAZA_TILE_LINE)

	# Desks & Courtyard di Bottom Complex
	_draw_desk(Rect2(672, 730, 340, 170))
	_draw_desk(Rect2(510, 990, 490, 100))
	_draw_desk(Rect2(510, 1120, 490, 100))
	_draw_courtyard_garden(Vector2(780, 830), 40.0)

	# 6. ROOM SMALL MID BOTTOM (1158, 840, 270, 210)
	_draw_room_pavement(Rect2(1158, 840, 270, 210), COLOR_ROOM_OCHRE)
	_draw_desk(Rect2(1190, 880, 205, 120))

	# 7. ROOM GRID RIGHT (1626, 324, 390, 390)
	_draw_room_pavement(Rect2(1626, 324, 390, 390), COLOR_ROOM_STONE_A)
	_draw_desk(Rect2(1656, 354, 120, 120))
	_draw_desk(Rect2(1812, 354, 120, 120))
	_draw_desk(Rect2(1656, 585, 120, 120))
	_draw_desk(Rect2(1812, 585, 120, 120))

	# 8. ROOM BOTTOM RIGHT: Sanctuary of Dewa Kematian (1581, 849, 504, 420)
	draw_rect(Rect2(1581, 849, 504, 420), COLOR_ROOM_DARK, true)
	draw_rect(Rect2(1640, 900, 385, 310), COLOR_ROOM_RUG, true)
	# Altar Emas Arsitektur
	draw_circle(Vector2(1833, 1059), 110.0, Color(0.85, 0.72, 0.25, 0.35))
	draw_circle(Vector2(1833, 1059), 85.0, Color(0.12, 0.13, 0.16, 1.0))
	draw_circle(Vector2(1833, 1059), 80.0, Color(0.85, 0.72, 0.25, 0.8))
	draw_circle(Vector2(1833, 1059), 74.0, Color(0.12, 0.13, 0.16, 1.0))
	# Ambang pintu masuk
	draw_rect(Rect2(1530, 1000, 60, 120), COLOR_ROOM_RUG, true)
	draw_rect(Rect2(1770, 810, 125, 60), COLOR_ROOM_RUG, true)

	# ── B. SISTEM JALAN ASPAL CHARCOAL KONSISTEN & MARKA JALAN LENGKAP ────────

	# 1. JALAN UTAMA ATAS (y=192..324) - 2 Jalur Lebar dengan Marka Tengah
	_draw_asphalt_strip(Rect2(0, 192, 2160, 132), true, 2)

	# 2. JALAN MENYIKU BARAT (L-Shaped Alley)
	# Segmen Vertikal Atas (x=516..639, y=192..786)
	_draw_asphalt_strip(Rect2(516, 192, 123, 594), false, 1)
	# Segmen Belokan Tengah (x=192..639, y=786..945)
	_draw_asphalt_strip(Rect2(192, 786, 447, 159), true, 2)
	# Segmen Vertikal Bawah (x=357..465, y=945..1311)
	_draw_asphalt_strip(Rect2(357, 945, 108, 366), false, 1)

	# 3. JALAN TENGAH (Horizontal Crossway)
	# Area di bawah Top Complex (x=639..1158, y=549..690)
	_draw_asphalt_strip(Rect2(639, 549, 519, 141), true, 2)
	# Area tengah utama (x=1050..1626, y=714..840)
	_draw_asphalt_strip(Rect2(1050, 714, 576, 126), true, 2)

	# 4. GANG VERTIKAL KANAN (x=1536..1626, y=192..714)
	_draw_asphalt_strip(Rect2(1536, 192, 90, 522), false, 1)

	# 5. JALAN SISI REL KANAN (x=2016..2160, y=192..1311)
	_draw_asphalt_strip(Rect2(2016, 192, 144, 1119), false, 2)

	# 6. JALAN LINGKAR BAWAH (x=357..2160, y=1245..1311)
	_draw_asphalt_strip(Rect2(357, 1245, 1803, 66), true, 1)

	# 7. PERSIMPANGAN / PLAZA PERTEMUAN JALAN DENGAN MARKA KOTA
	_draw_intersection_hub(Vector2(577, 258), 66.0)   # Simpang Atas-Kiri
	_draw_intersection_hub(Vector2(1581, 258), 66.0)  # Simpang Atas-Kanan
	_draw_intersection_hub(Vector2(2088, 258), 70.0)  # Simpang Atas-Rel (dengan Helipad)
	_draw_intersection_hub(Vector2(577, 780), 75.0)   # Simpang Siku Tengah-Kiri
	_draw_intersection_hub(Vector2(1104, 780), 63.0)  # Simpang Tengah
	_draw_intersection_hub(Vector2(1581, 780), 63.0)  # Simpang Tengah-Kanan
	_draw_intersection_hub(Vector2(2088, 780), 70.0)  # Simpang Tengah-Rel
	_draw_intersection_hub(Vector2(411, 1278), 45.0)  # Simpang Bawah-Kiri
	_draw_intersection_hub(Vector2(2088, 1278), 50.0) # Simpang Bawah-Rel

	# 8. HELIPAD KUNING SESUAI GAMBAR REFERENSI
	_draw_helipad(Vector2(2088, 258), 34.0)
	_draw_helipad(Vector2(1360, 945), 32.0)

	# ── C. REL KERETA API TIMUR (wall_right: 2160..2322) ──────────────────────
	draw_rect(Rect2(2160, 0, 162, 1311), COLOR_TRACK_BALLAST, true)
	# Rel Baja Ganda
	draw_line(Vector2(2185, 0), Vector2(2185, 1311), COLOR_TRACK_RAIL, 4.5)
	draw_line(Vector2(2295, 0), Vector2(2295, 1311), COLOR_TRACK_RAIL, 4.5)
	for ty in range(12, 1311, 16):
		draw_line(Vector2(2170, ty), Vector2(2310, ty), COLOR_TRACK_TIE, 3.5)

	# ── D. GARIS DINDING & PERIMETER ARSITEKTUR ──────────────────────────────

	# 1. 11 Bilik Atas
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		draw_line(Vector2(sq_x, 192), Vector2(sq_x, 36), COLOR_WALL_LINE, WT)
		draw_line(Vector2(sq_x, 36), Vector2(sq_x + 156, 36), COLOR_WALL_LINE, WT)
		draw_line(Vector2(sq_x + 156, 36), Vector2(sq_x + 156, 192), COLOR_WALL_LINE, WT)

	# Pembatas lorong atas
	draw_line(Vector2(0, 192), Vector2(2160, 192), COLOR_WALL_LINE, WT)

	# 2. room_left_L (Outline Dinding dengan Pintu Masuk)
	draw_line(Vector2(0, 324), Vector2(516, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 324), Vector2(516, 510), COLOR_WALL_LINE, WT)
	# Pintu Timur Atas (y=510..570)
	draw_line(Vector2(516, 570), Vector2(516, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 786), Vector2(380, 786), COLOR_WALL_LINE, WT)
	# Pintu Selatan (x=380..320)
	draw_line(Vector2(320, 786), Vector2(192, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(192, 786), Vector2(192, 933), COLOR_WALL_LINE, WT)
	draw_line(Vector2(192, 933), Vector2(0, 933), COLOR_WALL_LINE, WT)

	# 3. room_bottom_left
	draw_line(Vector2(0, 951), Vector2(357, 951), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 951), Vector2(357, 1080), COLOR_WALL_LINE, WT)
	# Pintu Timur (y=1080..1150)
	draw_line(Vector2(357, 1150), Vector2(357, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 1311), Vector2(0, 1311), COLOR_WALL_LINE, WT)

	# 4. TOP COMPLEX OUTLINE
	draw_line(Vector2(639, 324), Vector2(1000, 324), COLOR_WALL_LINE, WT)
	# Pintu Utara (x=1000..1060)
	draw_line(Vector2(1060, 324), Vector2(1536, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 324), Vector2(1536, 480), COLOR_WALL_LINE, WT)
	# Pintu Timur (y=480..540)
	draw_line(Vector2(1536, 540), Vector2(1536, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 714), Vector2(1158, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 714), Vector2(1158, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 549), Vector2(639, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 549), Vector2(639, 440), COLOR_WALL_LINE, WT)
	# Pintu Barat (y=440..380)
	draw_line(Vector2(639, 380), Vector2(639, 324), COLOR_WALL_LINE, WT)

	# 5. BOTTOM COMPLEX OUTLINE
	draw_line(Vector2(639, 690), Vector2(1050, 690), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 690), Vector2(1050, 900), COLOR_WALL_LINE, WT)
	# Pintu Timur (y=900..960)
	draw_line(Vector2(1050, 960), Vector2(1050, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 1245), Vector2(465, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 1245), Vector2(465, 945), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 945), Vector2(639, 945), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 945), Vector2(639, 810), COLOR_WALL_LINE, WT)
	# Pintu Barat (y=810..750)
	draw_line(Vector2(639, 750), Vector2(639, 690), COLOR_WALL_LINE, WT)

	# 6. room_small_mid_bottom
	draw_line(Vector2(1158, 840), Vector2(1260, 840), COLOR_WALL_LINE, WT)
	# Pintu Utara (x=1260..1320)
	draw_line(Vector2(1320, 840), Vector2(1428, 840), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 840), Vector2(1428, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 1050), Vector2(1158, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1158, 1050), Vector2(1158, 840), COLOR_WALL_LINE, WT)

	# 7. room_grid_right
	draw_line(Vector2(1626, 324), Vector2(2016, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 324), Vector2(2016, 480), COLOR_WALL_LINE, WT)
	# Pintu Timur (y=480..540)
	draw_line(Vector2(2016, 540), Vector2(2016, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 714), Vector2(1626, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1626, 714), Vector2(1626, 540), COLOR_WALL_LINE, WT)
	# Pintu Barat (y=540..480)
	draw_line(Vector2(1626, 480), Vector2(1626, 324), COLOR_WALL_LINE, WT)

	# 8. room_bottom_right (Kuil Dewa Kematian)
	draw_line(Vector2(1581, 849), Vector2(1770, 849), COLOR_WALL_LINE, WT)
	# Pintu Utara (x=1770..1890)
	draw_line(Vector2(1890, 849), Vector2(2085, 849), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2085, 849), Vector2(2085, 1269), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2085, 1269), Vector2(1581, 1269), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1581, 1269), Vector2(1581, 1120), COLOR_WALL_LINE, WT)
	# Pintu Barat (y=1120..1000)
	draw_line(Vector2(1581, 1000), Vector2(1581, 849), COLOR_WALL_LINE, WT)

	# Pembatas Rel Kanan
	draw_line(Vector2(2160, 0), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	# ── E. PENANDA LANDMARK INVESTIGASI INTERAKTIF (POI) ──────────────────────
	_draw_poi_badge(Vector2(1170, 270), "Rumah Detektif", Color(0.35, 0.65, 0.95))
	_draw_poi_badge(Vector2(350, 258),  "Kantor Polisi",  Color(0.25, 0.50, 0.85))
	_draw_poi_badge(Vector2(2088, 550), "Stasiun Kereta", Color(0.95, 0.70, 0.20))
	_draw_poi_badge(Vector2(594, 550),  "Kamar Jenazah",  Color(0.85, 0.35, 0.35))
	_draw_poi_badge(Vector2(180, 1050), "Brankas Ibu",    Color(0.80, 0.50, 0.90))
	_draw_poi_badge(Vector2(1833, 1059),"Altar Dewa",     Color(0.70, 0.25, 0.95))

# ── Helper Gambar Jalan Aspal & Marka Kota ──────────────────────────────────
func _draw_asphalt_strip(rect: Rect2, is_horizontal: bool, num_lanes: int) -> void:
	# 1. Bayangan & Trotoar Tepi
	draw_rect(Rect2(rect.position - Vector2(2, 2), rect.size + Vector2(4, 4)), COLOR_SIDEWALK_BEVEL, true)
	# 2. Badan Aspal Utama
	draw_rect(rect, COLOR_ASPHALT, true)

	# 3. Garis Tepi Jalan Solid
	if is_horizontal:
		draw_line(Vector2(rect.position.x, rect.position.y + 4), Vector2(rect.end.x, rect.position.y + 4), COLOR_CURB_LINE, 2.0)
		draw_line(Vector2(rect.position.x, rect.end.y - 4), Vector2(rect.end.x, rect.end.y - 4), COLOR_CURB_LINE, 2.0)
		
		# Garis Putus-Putus Marka Tengah
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

# ── Helper Gambar Persimpangan & Helipad ────────────────────────────────────
func _draw_intersection_hub(center: Vector2, radius: float) -> void:
	# Lingkaran Aspal Pertemuan
	draw_circle(center, radius + 2.0, COLOR_SIDEWALK_BEVEL)
	draw_circle(center, radius, COLOR_ASPHALT)
	# Marka Luar Persimpangan
	draw_arc(center, radius - 4.0, 0, TAU, 32, Color(COLOR_CURB_LINE.r, COLOR_CURB_LINE.g, COLOR_CURB_LINE.b, 0.5), 1.5)

func _draw_helipad(center: Vector2, radius: float) -> void:
	# Landasan Helipad
	draw_circle(center, radius, Color(0.20, 0.21, 0.24, 1.0))
	draw_arc(center, radius - 3.0, 0, TAU, 32, COLOR_HELIPAD_RING, 3.0)
	# Huruf 'H' Kuning
	var hw = radius * 0.45
	var hh = radius * 0.55
	draw_line(Vector2(center.x - hw, center.y - hh), Vector2(center.x - hw, center.y + hh), COLOR_HELIPAD_RING, 3.5)
	draw_line(Vector2(center.x + hw, center.y - hh), Vector2(center.x + hw, center.y + hh), COLOR_HELIPAD_RING, 3.5)
	draw_line(Vector2(center.x - hw, center.y), Vector2(center.x + hw, center.y), COLOR_HELIPAD_RING, 3.5)

func _draw_courtyard_garden(center: Vector2, radius: float) -> void:
	# Taman Rumput Hijau dengan Pohon Rindang
	draw_circle(center, radius, COLOR_GRASS)
	draw_arc(center, radius, 0, TAU, 24, COLOR_SIDEWALK_BEVEL, 2.0)
	# Pohon 1
	draw_circle(center + Vector2(-8, -6), radius * 0.45, COLOR_TREE_DARK)
	draw_circle(center + Vector2(-10, -8), radius * 0.35, COLOR_TREE_LIGHT)
	# Pohon 2
	draw_circle(center + Vector2(10, 8), radius * 0.38, COLOR_TREE_DARK)
	draw_circle(center + Vector2(8, 6), radius * 0.28, COLOR_TREE_LIGHT)

# ── Helper Gambar Ubin Ruangan & Meja ───────────────────────────────────────
func _draw_room_pavement(rect: Rect2, color: Color) -> void:
	draw_rect(rect, color, true)
	_draw_tile_pattern(rect, COLOR_PLAZA_TILE_LINE)

func _draw_tile_pattern(rect: Rect2, color: Color) -> void:
	for x in range(int(rect.position.x) + 30, int(rect.end.x), 30):
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), color, 0.8)
	for y in range(int(rect.position.y) + 30, int(rect.end.y), 30):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), color, 0.8)

func _draw_desk(rect: Rect2) -> void:
	# Bayangan meja
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color(0, 0, 0, 0.25), true)
	draw_rect(rect, COLOR_DESK_WOOD, true)
	draw_rect(rect, COLOR_DESK_RIM, false, 2.0)
	# Garis laci / pembatas
	if rect.size.x > rect.size.y:
		draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + 2),
				  Vector2(rect.position.x + rect.size.x * 0.5, rect.end.y - 2), COLOR_DESK_RIM, 1.5)

func _draw_poi_badge(pos: Vector2, _label: String, color: Color) -> void:
	var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004)
	draw_circle(pos, 20.0 + pulse * 4.0, Color(color.r, color.g, color.b, 0.25))
	draw_circle(pos, 9.0, color)
	draw_circle(pos, 5.0, Color(1, 1, 1, 0.95))

# ── Colliders Fisik Peta (Preservasi 100%) ────────────────────────────────────
func _build_all_colliders() -> void:
	for body in collision_bodies:
		if is_instance_valid(body):
			body.queue_free()
	collision_bodies.clear()

	# 1. 11 Bilik Atas
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		_create_segment_collider(Vector2(sq_x, 192), Vector2(sq_x, 36))
		_create_segment_collider(Vector2(sq_x, 36), Vector2(sq_x + 156, 36))
		_create_segment_collider(Vector2(sq_x + 156, 36), Vector2(sq_x + 156, 192))
		_create_box_collider(Rect2(sq_x + 30, 70, 96, 75))

	# Pembatas lorong atas
	_create_segment_collider(Vector2(0, 192), Vector2(2160, 192))

	# 2. room_left_L
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

	# 3. room_bottom_left
	_create_segment_collider(Vector2(0, 951), Vector2(357, 951))
	_create_segment_collider(Vector2(357, 951), Vector2(357, 1080))
	_create_segment_collider(Vector2(357, 1150), Vector2(357, 1311))
	_create_segment_collider(Vector2(357, 1311), Vector2(0, 1311))
	_create_box_collider(Rect2(40, 1000, 270, 120))
	_create_box_collider(Rect2(40, 1160, 270, 120))

	# 4. TOP COMPLEX
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

	# 5. BOTTOM COMPLEX
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

	# 6. room_small_mid_bottom
	_create_segment_collider(Vector2(1158, 840), Vector2(1260, 840))
	_create_segment_collider(Vector2(1320, 840), Vector2(1428, 840))
	_create_segment_collider(Vector2(1428, 840), Vector2(1428, 1050))
	_create_segment_collider(Vector2(1428, 1050), Vector2(1158, 1050))
	_create_segment_collider(Vector2(1158, 1050), Vector2(1158, 840))
	_create_box_collider(Rect2(1190, 880, 205, 120))

	# 7. room_grid_right
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

	# 8. room_bottom_right (Sanctuary)
	_create_segment_collider(Vector2(1581, 849), Vector2(1770, 849))
	_create_segment_collider(Vector2(1890, 849), Vector2(2085, 849))
	_create_segment_collider(Vector2(2085, 849), Vector2(2085, 1269))
	_create_segment_collider(Vector2(2085, 1269), Vector2(1581, 1269))
	_create_segment_collider(Vector2(1581, 1269), Vector2(1581, 1120))
	_create_segment_collider(Vector2(1581, 1000), Vector2(1581, 849))

	# Pembatas Rel
	_create_segment_collider(Vector2(2160, 0), Vector2(2160, 1311))

	# Boundary Luar
	_create_segment_collider(Vector2(0, 0), Vector2(2160, 0))
	_create_segment_collider(Vector2(0, 0), Vector2(0, 1311))
	_create_segment_collider(Vector2(0, 1311), Vector2(2160, 1311))

# ── Helper Collider ─────────────────────────────────────────────────────────
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
