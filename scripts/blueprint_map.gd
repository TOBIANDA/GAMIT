extends Node2D

# ── Blueprint Architectural Map Renderer v9 (100% Sesuai Gambar Referensi Asli) ─
# Skala 3.0x dari Canvas 774x437 -> Total Area: 2322 x 1311 px
#
# Kompleks Bangunan Nyatu:
# 1. TOP COMPLEX (Gedung Tengah Atas Nyatu - Stepped Polygon):
#    - Outline: [[639, 324], [1536, 324], [1536, 714], [1158, 714], [1158, 549], [639, 549]]
#    - Menggabungkan room_mid_top (Kiri) + 4-Grid Cubicles room_grid_center (Kanan)
# 2. BOTTOM COMPLEX (Gedung Tengah Bawah Nyatu - Stepped Polygon):
#    - Outline: [[639, 690], [1050, 690], [1050, 1245], [465, 1245], [465, 945], [639, 945]]
#    - Menggabungkan room_mid_center (Atas) + room_mid_bottom (Bawah)
# 3. L-SHAPED ROOM (Kiri Atas):
#    - Outline: [[0, 324], [516, 324], [516, 786], [192, 786], [192, 933], [0, 933]]
# 4. ROOM BOTTOM LEFT: (0, 951, 357, 360)
# 5. ROOM SMALL MID BOTTOM: (1158, 840, 270, 210)
# 6. ROOM GRID RIGHT: (1626, 324, 390, 390) -> 4 Grid Cubicles
# 7. ROOM BOTTOM RIGHT: (1581, 849, 504, 420) -> Sanctuary of Dewa Kematian (Altar: 1833, 1059)
# 8. 11 TOP ROW SQUARES: y=36..192
# 9. RAILWAY / LADDER TRACK: x=2160..2322
#
# JALANAN (Pathways):
# - Jalan Utama Atas: y=192..324
# - Jalan Menyiku Barat (L-shaped Path): Mengitari L-shaped room (x=516..639 -> x=192..639 -> x=357..465)
# - Jalan Tengah: y=549..840 (di antara gedung-gedung)
# - Gang Vertikal Kanan: x=1536..1626
# - Jalan Sisi Rel Kanan: x=2016..2160
# - Jalan Bawah: y=1245..1311

# ── Palette Warna ─────────────────────────────────────────────────────────────
const COLOR_VOID           = Color(0.06, 0.08, 0.11, 1.0)
const COLOR_CORRIDOR_BASE  = Color(0.18, 0.21, 0.27, 1.0) # Slate lantai dasar
const COLOR_GRID_LINE      = Color(0.26, 0.32, 0.42, 0.35)

# Jalur Berwarna
const COLOR_PATH_TOP       = Color(0.36, 0.17, 0.23, 1.0) # Velvet Burgundy
const COLOR_PATH_TOP_TRIM  = Color(0.85, 0.66, 0.30, 0.85)# Lis Emas
const COLOR_PATH_HIGHWAY   = Color(0.20, 0.30, 0.44, 1.0) # Royal Blue
const COLOR_PATH_HW_TRIM   = Color(0.42, 0.66, 0.86, 0.85)# Lis Neon Cyan
const COLOR_PATH_AISLE     = Color(0.24, 0.28, 0.36, 1.0) # Jalan Menyiku
const COLOR_PATH_PLAZA     = Color(0.26, 0.37, 0.52, 1.0) # Plaza Simpang Jalan
const COLOR_PLAZA_RUNE     = Color(0.60, 0.80, 1.00, 0.30)

# Lantai Ruangan Tematik
const COLOR_ROOM_TOP_STALL = Color(0.88, 0.93, 0.88, 1.0) # Sage green bilik atas
const COLOR_ROOM_ARCHIVE   = Color(0.96, 0.93, 0.86, 1.0) # Gading hangat ruang berkas
const COLOR_ROOM_OFFICE    = Color(0.86, 0.91, 0.96, 1.0) # Biru muda kantor utama
const COLOR_ROOM_POD       = Color(0.88, 0.93, 0.88, 1.0) # Bilik pod
const COLOR_ROOM_SANCTUARY = Color(0.14, 0.08, 0.20, 1.0) # Ungu gelap mistis Dewa Kematian
const COLOR_SANCTUARY_RUG  = Color(0.26, 0.12, 0.38, 1.0) # Karpet ritual ungu tua
const COLOR_RUNE_GLOW      = Color(0.70, 0.32, 0.98, 0.40)# Lingkaran sihir ritual

# Meja & Dinding
const COLOR_DESK_FILL      = Color(0.75, 0.80, 0.86, 1.0)
const COLOR_DESK_LINE      = Color(0.18, 0.22, 0.28, 1.0)
const COLOR_WALL_LINE      = Color(0.08, 0.10, 0.14, 1.0)

# Rel & Tangga
const COLOR_TRACK_BG       = Color(0.74, 0.77, 0.82, 1.0)
const COLOR_TRACK_RAIL     = Color(0.22, 0.25, 0.32, 1.0)
const COLOR_TRACK_TIE      = Color(0.44, 0.37, 0.30, 1.0)

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

	# 1. Base Lantai Koridor / Area Bermain (0 .. 2160, 0 .. 1311)
	draw_rect(Rect2(0, 0, 2160, 1311), COLOR_CORRIDOR_BASE, true)

	# Grid Lantai Arsitektur
	for gx in range(40, 2160, 40):
		draw_line(Vector2(gx, 0), Vector2(gx, 1311), COLOR_GRID_LINE, 1.0)
	for gy in range(40, 1311, 40):
		draw_line(Vector2(0, gy), Vector2(2160, gy), COLOR_GRID_LINE, 1.0)

	# ── A. GAMBAR LANTAI RUANGAN-RUANGAN (BASE) ──────────────────────────────

	# 1. 11 TOP ROW SQUARES (sq_top_1 .. sq_top_11)
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		draw_rect(Rect2(sq_x, 36, 156, 156), COLOR_ROOM_TOP_STALL, true)
		_draw_desk(Rect2(sq_x + 30, 70, 96, 75))

	# 2. ROOM LEFT L (L-Shaped Room: 0..516, 324..786 / 0..192, 786..933)
	var l_pts = PackedVector2Array([
		Vector2(0, 324), Vector2(516, 324), Vector2(516, 786),
		Vector2(192, 786), Vector2(192, 933), Vector2(0, 933)
	])
	draw_colored_polygon(l_pts, COLOR_ROOM_ARCHIVE)

	# 6 Inner Cluster Desks
	_draw_desk(Rect2(9, 324, 156, 156))    # sq_left_1
	_draw_desk(Rect2(195, 324, 156, 156))  # sq_left_2
	_draw_desk(Rect2(411, 324, 105, 156))  # sq_left_3
	_draw_desk(Rect2(411, 495, 105, 156))  # sq_left_4
	_draw_desk(Rect2(411, 666, 105, 120))  # sq_left_5
	_draw_desk(Rect2(25, 800, 140, 100))   # sq_left_small (Tepat di dalam room_left_L)

	# 3. ROOM BOTTOM LEFT (0, 951, 357, 360)
	draw_rect(Rect2(0, 951, 357, 360), COLOR_ROOM_OFFICE, true)
	_draw_desk(Rect2(40, 1000, 270, 120))
	_draw_desk(Rect2(40, 1160, 270, 120))

	# 4. TOP COMPLEX (GEDUNG TENGAH ATAS NYATU - STEPPED POLYGON)
	# Menggabungkan room_mid_top dan room_grid_center menjadi SATU BANGUNAN UTUH
	var top_complex_pts = PackedVector2Array([
		Vector2(639, 324),   # Kiri Atas
		Vector2(1536, 324),  # Kanan Atas
		Vector2(1536, 714),  # Kanan Bawah
		Vector2(1158, 714),  # Sudut Dalam Bawah
		Vector2(1158, 549),  # Sudut Dalam Tengah
		Vector2(639, 549)    # Kiri Bawah
	])
	draw_colored_polygon(top_complex_pts, COLOR_ROOM_OFFICE)

	# Meja di dalam Top Complex:
	# Ruang Kantor Kiri (room_mid_top)
	_draw_desk(Rect2(672, 360, 378, 150))
	# 4 Workstation Cubicles Kanan (room_grid_center)
	_draw_desk(Rect2(1191, 354, 120, 120)) # g1
	_draw_desk(Rect2(1341, 354, 120, 120)) # g2
	_draw_desk(Rect2(1191, 585, 120, 120)) # g3
	_draw_desk(Rect2(1341, 585, 120, 120)) # g4

	# 5. BOTTOM COMPLEX (GEDUNG TENGAH BAWAH NYATU - STEPPED POLYGON)
	# Menggabungkan room_mid_center dan room_mid_bottom menjadi SATU BANGUNAN UTUH
	var bot_complex_pts = PackedVector2Array([
		Vector2(639, 690),   # Kiri Atas
		Vector2(1050, 690),  # Kanan Atas
		Vector2(1050, 1245), # Kanan Bawah
		Vector2(465, 1245),  # Kiri Bawah
		Vector2(465, 945),   # Sudut Kiri Tengah
		Vector2(639, 945)    # Sudut Dalam
	])
	draw_colored_polygon(bot_complex_pts, COLOR_ROOM_ARCHIVE)

	# Meja di dalam Bottom Complex:
	# Ruang Atas (room_mid_center)
	_draw_desk(Rect2(672, 730, 340, 170))
	# Ruang Bawah (room_mid_bottom)
	_draw_desk(Rect2(510, 990, 490, 100))
	_draw_desk(Rect2(510, 1120, 490, 100))

	# 6. ROOM SMALL MID BOTTOM (1158, 840, 270, 210)
	draw_rect(Rect2(1158, 840, 270, 210), COLOR_ROOM_POD, true)
	_draw_desk(Rect2(1190, 880, 205, 120))

	# 7. ROOM GRID RIGHT (1626, 324, 390, 390)
	draw_rect(Rect2(1626, 324, 390, 390), COLOR_ROOM_OFFICE, true)
	_draw_desk(Rect2(1656, 354, 120, 120)) # g5
	_draw_desk(Rect2(1812, 354, 120, 120)) # g6
	_draw_desk(Rect2(1656, 585, 120, 120)) # g7
	_draw_desk(Rect2(1812, 585, 120, 120)) # g8

	# 8. ROOM BOTTOM RIGHT: Sanctuary of Dewa Kematian (1581, 849, 504, 420)
	draw_rect(Rect2(1581, 849, 504, 420), COLOR_ROOM_SANCTUARY, true)
	draw_rect(Rect2(1640, 900, 385, 310), COLOR_SANCTUARY_RUG, true)
	draw_circle(Vector2(1833, 1059), 120.0, COLOR_RUNE_GLOW)
	draw_circle(Vector2(1833, 1059), 75.0, Color(0.8, 0.35, 1.0, 0.25))
	# Karpet ambang pintu masuk barat & utara
	draw_rect(Rect2(1530, 1000, 60, 120), COLOR_SANCTUARY_RUG, true)
	draw_rect(Rect2(1770, 810, 125, 60), COLOR_SANCTUARY_RUG, true)

	# ── B. JALUR & JALAN BERWARNA (DI ATAS RUANGAN) ───────────────────────────

	# 1. JALAN UTAMA ATAS (y=192..324) – Velvet Burgundy
	draw_rect(Rect2(0, 192, 2160, 132), COLOR_PATH_TOP, true)
	draw_line(Vector2(0, 196), Vector2(2160, 196), COLOR_PATH_TOP_TRIM, 2.5)
	draw_line(Vector2(0, 320), Vector2(2160, 320), COLOR_PATH_TOP_TRIM, 2.5)

	# 2. JALAN MENYIKU BARAT (L-Shaped Alley mengitari L-room & Gedung Tengah)
	# Segmen Vertikal Atas (x=516..639, y=192..786)
	draw_rect(Rect2(516, 192, 123, 594), COLOR_PATH_AISLE, true)
	# Segmen Belokan Menyiku Tengah (x=192..639, y=786..945)
	draw_rect(Rect2(192, 786, 447, 159), COLOR_PATH_AISLE, true)
	# Segmen Vertikal Bawah (x=357..465, y=945..1311)
	draw_rect(Rect2(357, 945, 108, 366), COLOR_PATH_AISLE, true)

	# 3. JALAN TENGAH (Horizontal Crossway di antara Top & Bottom Complex)
	# Area di bawah Top Complex (x=639..1158, y=549..690)
	draw_rect(Rect2(639, 549, 519, 141), COLOR_PATH_HIGHWAY, true)
	# Area tengah utama (x=1050..1626, y=714..840)
	draw_rect(Rect2(1050, 714, 576, 126), COLOR_PATH_HIGHWAY, true)
	draw_line(Vector2(1050, 718), Vector2(1626, 718), COLOR_PATH_HW_TRIM, 2.5)
	draw_line(Vector2(1050, 836), Vector2(1626, 836), COLOR_PATH_HW_TRIM, 2.5)

	# 4. GANG VERTIKAL KANAN (x=1536..1626, y=192..714)
	draw_rect(Rect2(1536, 192, 90, 522), COLOR_PATH_AISLE, true)

	# 5. JALAN SISI REL KANAN (x=2016..2160, y=192..1311)
	draw_rect(Rect2(2016, 192, 144, 1119), COLOR_PATH_HIGHWAY, true)
	draw_line(Vector2(2020, 192), Vector2(2020, 1311), COLOR_PATH_HW_TRIM, 2.5)
	draw_line(Vector2(2156, 192), Vector2(2156, 1311), COLOR_PATH_HW_TRIM, 2.5)

	# 6. JALAN LINGKAR BAWAH (x=357..2160, y=1245..1311 - Tidak menutupi gedung kiri bawah)
	draw_rect(Rect2(357, 1245, 1803, 66), COLOR_PATH_HIGHWAY, true)
	draw_line(Vector2(357, 1248), Vector2(2160, 1248), COLOR_PATH_HW_TRIM, 2.5)
	for mx in range(370, 2160, 60):
		draw_line(Vector2(mx, 1278), Vector2(mx + 35, 1278), Color(0.85, 0.95, 1.0, 0.45), 2.0)

	# 7. PLAZA PERSIMPANGAN
	_draw_plaza(Vector2(577, 258), 42.0)   # Simpang Atas-Kiri
	_draw_plaza(Vector2(1581, 258), 40.0)  # Simpang Atas-Kanan
	_draw_plaza(Vector2(2088, 258), 45.0)  # Simpang Atas-Rel
	_draw_plaza(Vector2(577, 780), 45.0)   # Simpang Siku Tengah-Kiri
	_draw_plaza(Vector2(1104, 780), 45.0)  # Simpang Tengah
	_draw_plaza(Vector2(1581, 780), 45.0)  # Simpang Tengah-Kanan
	_draw_plaza(Vector2(2088, 780), 45.0)  # Simpang Tengah-Rel
	_draw_plaza(Vector2(411, 1278), 45.0)  # Simpang Bawah-Kiri
	_draw_plaza(Vector2(2088, 1278), 45.0) # Simpang Bawah-Rel

	# ── C. REL / TANGGA KANAN (wall_right: 2160..2322) ────────────────────────
	draw_rect(Rect2(2160, 0, 162, 1311), COLOR_TRACK_BG, true)
	draw_line(Vector2(2185, 0), Vector2(2185, 1311), COLOR_TRACK_RAIL, 4.0)
	draw_line(Vector2(2295, 0), Vector2(2295, 1311), COLOR_TRACK_RAIL, 4.0)
	for ty in range(15, 1311, 18):
		draw_line(Vector2(2172, ty), Vector2(2308, ty), COLOR_TRACK_TIE, 3.5)
		draw_line(Vector2(2175, ty - 1), Vector2(2305, ty - 1), Color(0.92, 0.96, 1.0, 0.45), 1.5)

	# ── D. GARIS DINDING & PERIMETER LENGKAP DENGAN PINTU ─────────────────────

	# 1. 11 Bilik Atas
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		draw_line(Vector2(sq_x, 192), Vector2(sq_x, 36), COLOR_WALL_LINE, WT)
		draw_line(Vector2(sq_x, 36), Vector2(sq_x + 156, 36), COLOR_WALL_LINE, WT)
		draw_line(Vector2(sq_x + 156, 36), Vector2(sq_x + 156, 192), COLOR_WALL_LINE, WT)

	# Pembatas lorong atas
	draw_line(Vector2(0, 192), Vector2(2160, 192), COLOR_WALL_LINE, WT)

	# 2. room_left_L (Outline Polygon Dinding dengan Pintu)
	# Atas: (0..516, 324) -> Pintu di (210..310)
	draw_line(Vector2(0, 324), Vector2(210, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(310, 324), Vector2(516, 324), COLOR_WALL_LINE, WT)
	# Kanan-Atas: (516, 324..786) -> Pintu di (516, 450..550)
	draw_line(Vector2(516, 324), Vector2(516, 450), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 550), Vector2(516, 786), COLOR_WALL_LINE, WT)
	# Bawah-Kanan: (516..192, 786)
	draw_line(Vector2(516, 786), Vector2(192, 786), COLOR_WALL_LINE, WT)
	# Kanan-Bawah: (192, 786..933)
	draw_line(Vector2(192, 786), Vector2(192, 933), COLOR_WALL_LINE, WT)
	# Bawah: (192..0, 933)
	draw_line(Vector2(192, 933), Vector2(0, 933), COLOR_WALL_LINE, WT)
	# Kiri: (0, 933..324)
	draw_line(Vector2(0, 933), Vector2(0, 324), COLOR_WALL_LINE, WT)

	# 3. room_bottom_left (0, 951, 357, 360)
	draw_line(Vector2(0, 951), Vector2(180, 951), COLOR_WALL_LINE, WT)
	draw_line(Vector2(260, 951), Vector2(357, 951), COLOR_WALL_LINE, WT) # Pintu Atas (180..260)
	draw_line(Vector2(357, 951), Vector2(357, 1070), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 1150), Vector2(357, 1311), COLOR_WALL_LINE, WT)# Pintu Kanan (1070..1150)
	draw_line(Vector2(0, 1311), Vector2(357, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(0, 951), Vector2(0, 1311), COLOR_WALL_LINE, WT)

	# 4. TOP COMPLEX (Dinding Perimeter Stepped Polygon Utuh)
	# Atas: (639..1536, 324) -> Pintu di (770..870) & (1300..1400)
	draw_line(Vector2(639, 324), Vector2(770, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(870, 324), Vector2(1300, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1400, 324), Vector2(1536, 324), COLOR_WALL_LINE, WT)
	# Kanan: (1536, 324..714) -> Pintu di (1536, 480..560)
	draw_line(Vector2(1536, 324), Vector2(1536, 480), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1536, 560), Vector2(1536, 714), COLOR_WALL_LINE, WT)
	# Bawah Kanan: (1536..1158, 714) -> Pintu di (1300..1400)
	draw_line(Vector2(1536, 714), Vector2(1400, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1300, 714), Vector2(1158, 714), COLOR_WALL_LINE, WT)
	# Step Naik: (1158, 714..549)
	draw_line(Vector2(1158, 714), Vector2(1158, 549), COLOR_WALL_LINE, WT)
	# Bawah Kiri: (1158..639, 549) -> Pintu di (770..870)
	draw_line(Vector2(1158, 549), Vector2(870, 549), COLOR_WALL_LINE, WT)
	draw_line(Vector2(770, 549), Vector2(639, 549), COLOR_WALL_LINE, WT)
	# Kiri: (639, 549..324) -> Pintu di (639, 400..470)
	draw_line(Vector2(639, 549), Vector2(639, 470), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 400), Vector2(639, 324), COLOR_WALL_LINE, WT)

	# Pembatas dalam antara room_mid_top dan cubicle grid (dengan pintu terbuka)
	draw_line(Vector2(1050, 324), Vector2(1050, 400), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 480), Vector2(1050, 549), COLOR_WALL_LINE, WT)

	# 5. BOTTOM COMPLEX (Dinding Perimeter Stepped Polygon Utuh)
	# Atas: (639..1050, 690) -> Pintu di (780..880)
	draw_line(Vector2(639, 690), Vector2(780, 690), COLOR_WALL_LINE, WT)
	draw_line(Vector2(880, 690), Vector2(1050, 690), COLOR_WALL_LINE, WT)
	# Kanan: (1050, 690..1245) -> Pintu di (1050, 780..860) & (1050, 1050..1130)
	draw_line(Vector2(1050, 690), Vector2(1050, 780), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 860), Vector2(1050, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 1130), Vector2(1050, 1245), COLOR_WALL_LINE, WT)
	# Bawah: (1050..465, 1245) -> Pintu di (680..780)
	draw_line(Vector2(1050, 1245), Vector2(780, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(680, 1245), Vector2(465, 1245), COLOR_WALL_LINE, WT)
	# Kiri Bawah: (465, 1245..945) -> Pintu di (465, 1050..1130)
	draw_line(Vector2(465, 1245), Vector2(465, 1130), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 1050), Vector2(465, 945), COLOR_WALL_LINE, WT)
	# Step Horizontal Kiri: (465..639, 945)
	draw_line(Vector2(465, 945), Vector2(639, 945), COLOR_WALL_LINE, WT)
	# Kiri Atas: (639, 945..690) -> Pintu di (639, 770..850)
	draw_line(Vector2(639, 945), Vector2(639, 850), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 770), Vector2(639, 690), COLOR_WALL_LINE, WT)

	# 6. room_small_mid_bottom (1158, 840, 270, 210)
	draw_line(Vector2(1158, 840), Vector2(1240, 840), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1320, 840), Vector2(1428, 840), COLOR_WALL_LINE, WT) # Pintu Atas (1240..1320)
	draw_line(Vector2(1428, 840), Vector2(1428, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1428, 1050), Vector2(1320, 1050), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1240, 1050), Vector2(1158, 1050), COLOR_WALL_LINE, WT)# Pintu Bawah
	draw_line(Vector2(1158, 1050), Vector2(1158, 840), COLOR_WALL_LINE, WT)

	# 7. room_grid_right (1626, 324, 390, 390)
	draw_line(Vector2(1626, 324), Vector2(1770, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1850, 324), Vector2(2016, 324), COLOR_WALL_LINE, WT) # Pintu Atas (1770..1850)
	draw_line(Vector2(2016, 324), Vector2(2016, 480), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2016, 560), Vector2(2016, 714), COLOR_WALL_LINE, WT) # Pintu Kanan (480..560)
	draw_line(Vector2(2016, 714), Vector2(1850, 714), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1770, 714), Vector2(1626, 714), COLOR_WALL_LINE, WT) # Pintu Bawah
	draw_line(Vector2(1626, 714), Vector2(1626, 560), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1626, 480), Vector2(1626, 324), COLOR_WALL_LINE, WT) # Pintu Kiri (480..560)

	# 8. room_bottom_right: SANCTUARY DEWA KEMATIAN (1581, 849, 504, 420)
	draw_line(Vector2(1581, 849), Vector2(1770, 849), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1895, 849), Vector2(2085, 849), COLOR_WALL_LINE, WT) # Pintu Utara (1770..1895)
	draw_line(Vector2(2085, 849), Vector2(2085, 1000), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2085, 1100), Vector2(2085, 1269), COLOR_WALL_LINE, WT)# Pintu Timur (1000..1100)
	draw_line(Vector2(2085, 1269), Vector2(1895, 1269), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1770, 1269), Vector2(1581, 1269), COLOR_WALL_LINE, WT)# Pintu Selatan (1770..1895)
	draw_line(Vector2(1581, 1269), Vector2(1581, 1120), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1581, 1000), Vector2(1581, 849), COLOR_WALL_LINE, WT) # PINTU BARAT UTAMA (1000..1120 -> 120px)

	# 9. Batas Luar Peta
	draw_line(Vector2(0, 0), Vector2(2322, 0), COLOR_WALL_LINE, WT)
	draw_line(Vector2(0, 1311), Vector2(2322, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(0, 0), Vector2(0, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(2160, 0), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	# ── E. LANDMARK PENANDA AREA PENYELIDIKAN (SESUAI GDD) ────────────────────
	# 1. Rumah Detektif Benedict & Kamar Gelap (1170, 270)
	draw_circle(Vector2(1170, 270), 28.0, Color(0.3, 0.7, 1.0, 0.35))
	draw_arc(Vector2(1170, 270), 28.0, 0.0, TAU, 18, Color(0.4, 0.8, 1.0, 0.8), 2.0)

	# 2. Kantor Polisi & Marcus (350, 430)
	draw_circle(Vector2(350, 430), 32.0, Color(0.2, 0.4, 0.9, 0.35))
	draw_arc(Vector2(350, 430), 32.0, 0.0, TAU, 20, Color(0.3, 0.6, 1.0, 0.8), 2.0)

	# 3. Peron Stasiun Kereta Api Timur (2080, 520)
	draw_circle(Vector2(2080, 520), 32.0, Color(1.0, 0.6, 0.2, 0.35))
	draw_arc(Vector2(2080, 520), 32.0, 0.0, TAU, 20, Color(1.0, 0.7, 0.3, 0.8), 2.0)

	# 4. Kamar Mayat Rumah Sakit (850, 1000)
	draw_circle(Vector2(850, 1000), 30.0, Color(0.2, 0.8, 0.4, 0.35))
	draw_arc(Vector2(850, 1000), 30.0, 0.0, TAU, 18, Color(0.3, 0.9, 0.5, 0.8), 2.0)
	# Palang medis
	draw_rect(Rect2(846, 990, 8, 20), Color(0.9, 1.0, 0.9, 0.9), true)
	draw_rect(Rect2(840, 996, 20, 8), Color(0.9, 1.0, 0.9, 0.9), true)

	# 5. Brankas Rumah Ibu Medeline (180, 1050)
	draw_circle(Vector2(180, 1050), 26.0, Color(0.9, 0.7, 0.2, 0.35))
	draw_arc(Vector2(180, 1050), 26.0, 0.0, TAU, 16, Color(1.0, 0.8, 0.3, 0.8), 2.0)

# ── Helper Gambar Plaza & Meja ────────────────────────────────────────────────
func _draw_plaza(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, COLOR_PATH_PLAZA)
	draw_circle(center, radius * 0.60, COLOR_PLAZA_RUNE)
	draw_arc(center, radius, 0.0, TAU, 24, COLOR_PATH_HW_TRIM, 1.5)

func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.15), true)
	draw_rect(rect, COLOR_DESK_FILL, true)
	draw_rect(rect, COLOR_DESK_LINE, false, 2.0)
	if rect.size.x >= 60.0 and rect.size.y >= 50.0:
		var c = rect.position + rect.size / 2.0
		draw_rect(Rect2(c.x - 16, c.y - 16, 32, 12), Color(0.2, 0.25, 0.32), true)
		draw_rect(Rect2(c.x - 14, c.y + 4, 28, 8), Color(0.35, 0.40, 0.48), true)

# ── Collision Builder Presisi ────────────────────────────────────────────────
func _build_all_colliders() -> void:
	for b in collision_bodies:
		if is_instance_valid(b):
			b.queue_free()
	collision_bodies.clear()

	# Batas Luar
	_W(Rect2(0, 0, 2322, 20))
	_W(Rect2(0, 1300, 2322, 20))
	_W(Rect2(0, 0, 20, 1311))
	_W(Rect2(2154, 0, 12, 1311))

	# 11 Top Bilik Colliders
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		_W(Rect2(sq_x - 3, 36, 6, 156))
		_W(Rect2(sq_x, 33, 156, 6))
		_W(Rect2(sq_x + 153, 36, 6, 156))
		_W(Rect2(sq_x + 30, 70, 96, 75))

	# Pembatas lorong atas
	_W(Rect2(0, 189, 2160, 6))

	# room_left_L Colliders
	_W(Rect2(0, 321, 210, 6))
	_W(Rect2(310, 321, 206, 6))
	_W(Rect2(513, 324, 6, 126))
	_W(Rect2(513, 550, 6, 236))
	_W(Rect2(192, 783, 324, 6))
	_W(Rect2(189, 786, 6, 147))
	_W(Rect2(0, 930, 192, 6))
	# Desks L
	_W(Rect2(9, 324, 156, 156))
	_W(Rect2(195, 324, 156, 156))
	_W(Rect2(411, 324, 105, 156))
	_W(Rect2(411, 495, 105, 156))
	_W(Rect2(411, 666, 105, 120))
	_W(Rect2(25, 800, 140, 100))

	# room_bottom_left
	_W(Rect2(0, 948, 180, 6))
	_W(Rect2(260, 948, 97, 6))
	_W(Rect2(354, 951, 6, 119))
	_W(Rect2(354, 1150, 6, 161))
	_W(Rect2(40, 1000, 270, 120))
	_W(Rect2(40, 1160, 270, 120))

	# TOP COMPLEX (Gedung Tengah Atas Nyatu)
	_W(Rect2(639, 321, 131, 6))
	_W(Rect2(870, 321, 430, 6))
	_W(Rect2(1400, 321, 136, 6))
	_W(Rect2(1533, 324, 6, 156))
	_W(Rect2(1533, 560, 6, 154))
	_W(Rect2(1400, 711, 136, 6))
	_W(Rect2(1158, 711, 142, 6))
	_W(Rect2(1155, 549, 6, 165))
	_W(Rect2(870, 546, 288, 6))
	_W(Rect2(639, 546, 131, 6))
	_W(Rect2(636, 470, 6, 79))
	_W(Rect2(636, 324, 6, 76))
	_W(Rect2(1047, 324, 6, 76))
	_W(Rect2(1047, 480, 6, 69))
	_W(Rect2(672, 360, 378, 150))
	_W(Rect2(1191, 354, 120, 120))
	_W(Rect2(1341, 354, 120, 120))
	_W(Rect2(1191, 585, 120, 120))
	_W(Rect2(1341, 585, 120, 120))

	# BOTTOM COMPLEX (Gedung Tengah Bawah Nyatu)
	_W(Rect2(639, 687, 141, 6))
	_W(Rect2(880, 687, 170, 6))
	_W(Rect2(1047, 690, 6, 90))
	_W(Rect2(1047, 860, 6, 190))
	_W(Rect2(1047, 1130, 6, 115))
	_W(Rect2(780, 1242, 270, 6))
	_W(Rect2(465, 1242, 215, 6))
	_W(Rect2(462, 1130, 6, 115))
	_W(Rect2(462, 945, 6, 105))
	_W(Rect2(465, 942, 174, 6))
	_W(Rect2(636, 850, 6, 95))
	_W(Rect2(636, 690, 6, 80))
	_W(Rect2(672, 730, 340, 170))
	_W(Rect2(510, 990, 490, 100))
	_W(Rect2(510, 1120, 490, 100))

	# room_small_mid_bottom
	_W(Rect2(1158, 837, 82, 6))
	_W(Rect2(1320, 837, 108, 6))
	_W(Rect2(1425, 840, 6, 210))
	_W(Rect2(1158, 1047, 82, 6))
	_W(Rect2(1320, 1047, 108, 6))
	_W(Rect2(1155, 840, 6, 210))
	_W(Rect2(1190, 880, 205, 120))

	# room_grid_right
	_W(Rect2(1626, 321, 144, 6))
	_W(Rect2(1850, 321, 166, 6))
	_W(Rect2(2013, 324, 6, 156))
	_W(Rect2(2013, 560, 6, 154))
	_W(Rect2(1626, 711, 144, 6))
	_W(Rect2(1850, 711, 166, 6))
	_W(Rect2(1623, 560, 6, 154))
	_W(Rect2(1623, 324, 6, 156))
	_W(Rect2(1656, 354, 120, 120))
	_W(Rect2(1812, 354, 120, 120))
	_W(Rect2(1656, 585, 120, 120))
	_W(Rect2(1812, 585, 120, 120))

	# room_bottom_right (Sanctuary Dewa Kematian)
	_W(Rect2(1581, 846, 189, 6))
	_W(Rect2(1895, 846, 190, 6))
	_W(Rect2(2082, 849, 6, 151))
	_W(Rect2(2082, 1100, 6, 169))
	_W(Rect2(1581, 1266, 189, 6))
	_W(Rect2(1895, 1266, 190, 6))
	_W(Rect2(1578, 1120, 6, 149))
	_W(Rect2(1578, 849, 6, 151))

func _W(rect: Rect2) -> void:
	var body = StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	body.add_child(col)
	add_child(body)
	collision_bodies.append(body)
