extends Node2D

# ── Blueprint Architectural Map Renderer v4 (Vibrant Colored Pathways & Highways) ───
# Fitur:
# 1. Pewarnaan Jalan & Koridor Lengkap (Vibrant Pathways):
#    - Jalan Utama Atas (Burgundy Gold Runner)
#    - Jalan Tengah & Lingkar Bawah (Royal Slate Blue Highway)
#    - Jalan Vertikal Penghubung (Polished Pavers)
#    - Simpang Empat / Plaza Persimpangan (Decorative Nexus Tiles)
#    - Jalur Ambang Pintu Berwarna (Doorway Thresholds)
# 2. Peta Luas & Megah (2200 x 1350)
# 3. Bebas Tumpang Tindih & Tanpa Jalan Buntu
# 4. Tema Ruangan Berwarna (Sanctuary Ungu Dewa Kematian, Arsip Gading, Kantor Biru)

# ── Palette Warna Jalan & Koridor ───────────────────────────────────────────
const COLOR_VOID_BG       = Color(0.07, 0.09, 0.13, 1.0) # Area luar batas peta
const COLOR_CORRIDOR_BASE = Color(0.20, 0.23, 0.30, 1.0) # Dasar lantai lorong (Dark Slate)
const COLOR_CORRIDOR_TILE = Color(0.24, 0.28, 0.36, 1.0) # Ubin lantai lorong
const COLOR_GRID_LINE     = Color(0.30, 0.36, 0.46, 0.4) # Grid arsitektur

# Jalur Karpet / Jalan Utama Berwarna
const COLOR_PATH_TOP      = Color(0.38, 0.18, 0.24, 1.0) # Karpet jalan atas (Velvet Burgundy)
const COLOR_PATH_TOP_TRIM = Color(0.85, 0.65, 0.30, 0.8) # Garis tepi emas karpet atas
const COLOR_PATH_HIGHWAY  = Color(0.22, 0.32, 0.46, 1.0) # Jalan raya tengah & bawah (Royal Blue)
const COLOR_PATH_HW_TRIM  = Color(0.40, 0.65, 0.85, 0.8) # Garis tepi biru neon halus
const COLOR_PATH_AISLE    = Color(0.26, 0.30, 0.38, 1.0) # Jalan vertikal penghubung
const COLOR_PATH_PLAZA    = Color(0.28, 0.38, 0.52, 1.0) # Plaza persimpangan jalan
const COLOR_PLAZA_RUNE    = Color(0.60, 0.80, 1.00, 0.35)# Ornamen simpang empat

# Garis Dinding
const COLOR_WALL_LINE     = Color(0.08, 0.10, 0.14, 1.0) # Dinding struktural gelap
const COLOR_WALL_ACCENT   = Color(0.45, 0.55, 0.70, 0.9) # Garis lis atas dinding

# Lantai Ruangan Tematik
const COLOR_ROOM_OFFICE   = Color(0.86, 0.91, 0.96, 1.0) # Biru muda kantor arsip
const COLOR_ROOM_ARCHIVE  = Color(0.96, 0.93, 0.86, 1.0) # Gading hangat ruang berkas
const COLOR_ROOM_POD      = Color(0.88, 0.93, 0.88, 1.0) # Sage green bilik interogasi
const COLOR_ROOM_SANCTUARY= Color(0.14, 0.08, 0.20, 1.0) # Ungu gelap mistis Ruang Dewa Kematian
const COLOR_SANCTUARY_RUG = Color(0.26, 0.12, 0.38, 1.0) # Karpet ritual ungu tua
const COLOR_RUNE_GLOW     = Color(0.70, 0.32, 0.98, 0.40)# Lingkaran sihir ritual

# Meja & Perabotan
const COLOR_DESK_FILL     = Color(0.75, 0.80, 0.86, 1.0)
const COLOR_DESK_LINE     = Color(0.18, 0.22, 0.28, 1.0)

# Rel & Tangga
const COLOR_TRACK_BG      = Color(0.75, 0.78, 0.82, 1.0)
const COLOR_TRACK_RAIL    = Color(0.22, 0.25, 0.32, 1.0)
const COLOR_TRACK_TIE     = Color(0.45, 0.38, 0.32, 1.0)

const WALL_THICKNESS = 6.0
var collision_bodies: Array[StaticBody2D] = []

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ── 1. MENGGAMBAR MAP DENGAN JALUR BERWARNA LENGKAP ─────────────────────────
func _draw() -> void:
	# 0. Background Area Luar / Void
	draw_rect(Rect2(-100, -100, 2400, 1550), COLOR_VOID_BG, true)

	# 1. Base seluruh area bermain (Dark Slate Corridor Base)
	draw_rect(Rect2(20, 15, 2080, 1315), COLOR_CORRIDOR_BASE, true)

	# Grid Lantai Arsitektur Halus
	for x in range(40, 2120, 40):
		draw_line(Vector2(x, 15), Vector2(x, 1330), COLOR_GRID_LINE, 1.0)
	for y in range(20, 1330, 40):
		draw_line(Vector2(20, y), Vector2(2120, y), COLOR_GRID_LINE, 1.0)

	# ── A. LANTAI BERWARNA TIAP RUANGAN (DIGAMBAR PERTAMA) ───────────────────
	# 7. Bilik-Bilik Kecil Atas (16 Stalls)
	for i in range(16):
		var bx = 50.0 + i * 115.0
		draw_rect(Rect2(bx, 30, 85, 80), COLOR_ROOM_POD, true)

	# 1. Blok Kiri Atas (L-Shaped Area: 50-450, 230-580)
	draw_rect(Rect2(50, 230, 400, 350), COLOR_ROOM_ARCHIVE, true)

	# 2. Blok Tengah Atas (Kantor Utama: 550-1250, 230-580)
	draw_rect(Rect2(550, 230, 700, 350), COLOR_ROOM_OFFICE, true)

	# 3. Blok Kanan Atas (Workstation Pod: 1350-1850, 230-580)
	draw_rect(Rect2(1350, 230, 500, 350), COLOR_ROOM_OFFICE, true)

	# 4. Ruang Kiri Bawah (Arsip & Vault: 50-650, 680-1150)
	draw_rect(Rect2(50, 680, 600, 470), COLOR_ROOM_ARCHIVE, true)

	# 5. Bilik Tengah Bawah (Pod Interogasi: 780-1180, 680-1150)
	draw_rect(Rect2(780, 680, 400, 470), COLOR_ROOM_POD, true)

	# 6. Ruangan Dewa Kematian (Kanan Bawah: 1300-1950, 680-1150)
	draw_rect(Rect2(1300, 680, 650, 470), COLOR_ROOM_SANCTUARY, true)
	draw_rect(Rect2(1400, 750, 450, 330), COLOR_SANCTUARY_RUG, true)
	draw_circle(Vector2(1625, 915), 120.0, COLOR_RUNE_GLOW)
	draw_circle(Vector2(1625, 915), 75.0, Color(0.8, 0.35, 1.0, 0.25))

	# ── B. PEWARNAAN JALUR & JALAN UTAMA (DI ATAS RUANGAN) ───────────────────

	# 1. Jalan Utama Atas (Upper Highway Runner: y=110-230)
	draw_rect(Rect2(20, 110, 1980, 120), COLOR_PATH_TOP, true)
	draw_line(Vector2(20, 114), Vector2(2000, 114), COLOR_PATH_TOP_TRIM, 2.5)
	draw_line(Vector2(20, 226), Vector2(2000, 226), COLOR_PATH_TOP_TRIM, 2.5)

	# 2. Jalan Tengah (Central Crossway Highway: y=580-680)
	draw_rect(Rect2(20, 580, 1980, 100), COLOR_PATH_HIGHWAY, true)
	draw_line(Vector2(20, 584), Vector2(2000, 584), COLOR_PATH_HW_TRIM, 2.5)
	draw_line(Vector2(20, 676), Vector2(2000, 676), COLOR_PATH_HW_TRIM, 2.5)

	# 3. Jalan Lingkar Bawah (Grand Bottom Loop Highway: y=1150-1320)
	draw_rect(Rect2(20, 1150, 1980, 170), COLOR_PATH_HIGHWAY, true)
	draw_line(Vector2(20, 1155), Vector2(2000, 1155), COLOR_PATH_HW_TRIM, 3.0)
	draw_line(Vector2(20, 1316), Vector2(2000, 1316), COLOR_PATH_HW_TRIM, 3.0)
	# Garis marka tengah jalan lingkar bawah
	for x in range(50, 1980, 50):
		draw_line(Vector2(x, 1235), Vector2(x + 30, 1235), Color(0.8, 0.9, 1.0, 0.4), 2.0)

	# 4. Jalan Vertikal Penghubung (hanya di area ANTAR-ruangan / gap saja)
	# Aisle Kiri: gap antara ruang kiri atas & tengah atas (x=450-550)
	draw_rect(Rect2(450, 110, 100, 1040), COLOR_PATH_AISLE, true)
	# Aisle Tengah: gap antara ruang tengah atas & kanan atas (x=1250-1350)
	draw_rect(Rect2(1250, 110, 100, 1040), COLOR_PATH_AISLE, true)
	# Aisle Kanan: gap antara ruang kanan atas & rel (x=1850-2000)
	draw_rect(Rect2(1850, 110, 150, 1040), COLOR_PATH_AISLE, true)
	# Aisle Bawah antara Arsip & Pod (x=650-780)
	draw_rect(Rect2(650, 680, 130, 470), COLOR_PATH_AISLE, true)
	# Aisle Bawah antara Pod & Sanctuary (x=1180-1300)
	draw_rect(Rect2(1180, 680, 120, 470), COLOR_PATH_AISLE, true)

	# Namun jalur vertikal TIDAK menutupi area ruangan (lukis ulang room di atasnya tidak diperlukan
	# karena aisle hanya menimpa area void antar ruangan)

	# 5. Plaza Persimpangan Jalan (di setiap titik temu)
	_draw_crossroad_plaza(Vector2(500, 170), 48.0)   # Kiri-Atas
	_draw_crossroad_plaza(Vector2(1300, 170), 48.0)  # Tengah-Atas
	_draw_crossroad_plaza(Vector2(1925, 170), 48.0)  # Kanan-Atas
	_draw_crossroad_plaza(Vector2(500, 630), 48.0)   # Kiri-Tengah
	_draw_crossroad_plaza(Vector2(1300, 630), 48.0)  # Tengah
	_draw_crossroad_plaza(Vector2(1925, 630), 48.0)  # Kanan-Tengah
	_draw_crossroad_plaza(Vector2(500, 1235), 58.0)  # Kiri-Bawah
	_draw_crossroad_plaza(Vector2(1300, 1235), 58.0) # Tengah-Bawah
	_draw_crossroad_plaza(Vector2(1925, 1235), 58.0) # Kanan-Bawah

	# Karpet Ambang Pintu Dewa Kematian
	draw_rect(Rect2(1270, 870, 130, 130), COLOR_SANCTUARY_RUG, true) # Pintu Barat
	draw_rect(Rect2(1560, 648, 130, 100), COLOR_SANCTUARY_RUG, true) # Pintu Utara
	draw_rect(Rect2(1560, 1080, 130, 80), COLOR_SANCTUARY_RUG, true) # Pintu Selatan

	# (Ruangan sudah digambar di bagian A sebelum jalur, tidak perlu diulang)

	# ── C. TANGGA / REL VERTIKAL DI SISI KANAN ──────────────────────────────
	var track_x = 2030.0
	var track_w = 80.0
	var track_h = 1310.0
	draw_rect(Rect2(track_x, 15, track_w, track_h), COLOR_TRACK_BG, true)
	
	# Rel Besi
	draw_line(Vector2(track_x + 15, 15), Vector2(track_x + 15, 1325), COLOR_TRACK_RAIL, 3.5)
	draw_line(Vector2(track_x + track_w - 15, 15), Vector2(track_x + track_w - 15, 1325), COLOR_TRACK_RAIL, 3.5)

	# Bantalan Rel Kayu
	for y in range(25, 1320, 15):
		draw_line(Vector2(track_x + 8, y), Vector2(track_x + track_w - 8, y), COLOR_TRACK_TIE, 3.0)

	# ── D. GARIS DINDING DENGAN PINTU MASUK TERBUKA ─────────────────────────
	# 1. Baris Atas (16 Bilik dengan Pintu Bawah Terbuka)
	for i in range(16):
		var bx = 50.0 + i * 115.0
		draw_line(Vector2(bx, 110), Vector2(bx, 30), COLOR_WALL_LINE, WALL_THICKNESS)
		draw_line(Vector2(bx, 30), Vector2(bx + 85, 30), COLOR_WALL_LINE, WALL_THICKNESS)
		draw_line(Vector2(bx + 85, 30), Vector2(bx + 85, 110), COLOR_WALL_LINE, WALL_THICKNESS)
		_draw_desk(Rect2(bx + 15, 45, 55, 35))

	# Pembatas dinding antar bilik di koridor atas
	for i in range(16):
		var bx = 50.0 + i * 115.0
		var gap_end = bx + 115.0
		draw_line(Vector2(bx + 85, 110), Vector2(gap_end, 110), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(20, 110), Vector2(50, 110), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1890, 110), Vector2(2000, 110), COLOR_WALL_LINE, WALL_THICKNESS)

	# 2. Blok Kiri Atas (50-450, 230-580)
	# Dinding Atas (Pintu x=210-290)
	draw_line(Vector2(50, 230), Vector2(210, 230), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(290, 230), Vector2(450, 230), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu y=370-450)
	draw_line(Vector2(450, 230), Vector2(450, 370), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(450, 450), Vector2(450, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah (Pintu x=210-290)
	draw_line(Vector2(450, 580), Vector2(290, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(210, 580), Vector2(50, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri
	draw_line(Vector2(50, 580), Vector2(50, 230), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(80, 260, 80, 65))
	_draw_desk(Rect2(200, 260, 80, 65))
	_draw_desk(Rect2(320, 260, 80, 65))
	_draw_desk(Rect2(320, 370, 80, 65))
	_draw_desk(Rect2(320, 480, 80, 65))
	_draw_desk(Rect2(120, 460, 120, 80))

	# 3. Blok Tengah Atas (Kantor Utama: 550-1250, 230-580)
	# Dinding Atas (Pintu x=850-950)
	draw_line(Vector2(550, 230), Vector2(850, 230), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(950, 230), Vector2(1250, 230), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu y=370-450)
	draw_line(Vector2(1250, 230), Vector2(1250, 370), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1250, 450), Vector2(1250, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah (Pintu x=850-950)
	draw_line(Vector2(1250, 580), Vector2(950, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(850, 580), Vector2(550, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri (Pintu y=370-450)
	draw_line(Vector2(550, 580), Vector2(550, 450), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(550, 370), Vector2(550, 230), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(590, 280, 240, 150))
	_draw_desk(Rect2(930, 270, 95, 95))
	_draw_desk(Rect2(1070, 270, 95, 95))
	_draw_desk(Rect2(930, 430, 95, 95))
	_draw_desk(Rect2(1070, 430, 95, 95))

	# 4. Blok Kanan Atas (Workstation Pod: 1350-1850, 230-580)
	# Dinding Atas (Pintu x=1550-1650)
	draw_line(Vector2(1350, 230), Vector2(1550, 230), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1650, 230), Vector2(1850, 230), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu y=370-450)
	draw_line(Vector2(1850, 230), Vector2(1850, 370), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1850, 450), Vector2(1850, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah (Pintu x=1550-1650)
	draw_line(Vector2(1850, 580), Vector2(1650, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1550, 580), Vector2(1350, 580), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri (Pintu y=370-450)
	draw_line(Vector2(1350, 580), Vector2(1350, 450), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1350, 370), Vector2(1350, 230), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(1420, 270, 100, 95))
	_draw_desk(Rect2(1600, 270, 100, 95))
	_draw_desk(Rect2(1420, 430, 100, 95))
	_draw_desk(Rect2(1600, 430, 100, 95))

	# 5. Blok Kiri Bawah (Arsip & Vault: 50-650, 680-1150)
	# Dinding Atas (Pintu x=310-410)
	draw_line(Vector2(50, 680), Vector2(310, 680), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(410, 680), Vector2(650, 680), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu y=880-980)
	draw_line(Vector2(650, 680), Vector2(650, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(650, 980), Vector2(650, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah (PINTU LOOP HIGHWAY x=310-410)
	draw_line(Vector2(650, 1150), Vector2(410, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(310, 1150), Vector2(50, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri
	draw_line(Vector2(50, 1150), Vector2(50, 680), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(120, 730, 300, 120))
	_draw_desk(Rect2(120, 930, 360, 160))

	# 6. Blok Tengah Bawah (Pod Interogasi: 780-1180, 680-1150)
	# Dinding Atas (Pintu x=930-1030)
	draw_line(Vector2(780, 680), Vector2(930, 680), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1030, 680), Vector2(1180, 680), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu y=880-980)
	draw_line(Vector2(1180, 680), Vector2(1180, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1180, 980), Vector2(1180, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah (PINTU LOOP HIGHWAY x=930-1030)
	draw_line(Vector2(1180, 1150), Vector2(1030, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(930, 1150), Vector2(780, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri (Pintu y=880-980)
	draw_line(Vector2(780, 1150), Vector2(780, 980), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(780, 880), Vector2(780, 680), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(850, 740, 260, 110))
	_draw_desk(Rect2(880, 940, 200, 120))

	# 7. BLOK KANAN BAWAH: GRAND SANCTUARY DEWA KEMATIAN (1300-1950, 680-1150)
	# Dinding Utara (Pintu x=1570-1680)
	draw_line(Vector2(1300, 680), Vector2(1570, 680), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1680, 680), Vector2(1950, 680), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Timur (Pintu y=880-980)
	draw_line(Vector2(1950, 680), Vector2(1950, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1950, 980), Vector2(1950, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Selatan (PINTU LOOP HIGHWAY x=1570-1680)
	draw_line(Vector2(1950, 1150), Vector2(1680, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1570, 1150), Vector2(1300, 1150), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Barat (PINTU MASUK UTAMA SUPER MEGA LEBAR y=870-1010 -> 140px lebar!)
	draw_line(Vector2(1300, 1150), Vector2(1300, 1010), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1300, 870), Vector2(1300, 680), COLOR_WALL_LINE, WALL_THICKNESS)

	# 8. Batas Luar Peta Paling Luar
	draw_line(Vector2(20, 15), Vector2(2120, 15), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(20, 1330), Vector2(2120, 1330), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(20, 15), Vector2(20, 1330), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(2000, 110), Vector2(2000, 1330), COLOR_WALL_LINE, WALL_THICKNESS)

# ── Helper Gambar Plaza Persimpangan ─────────────────────────────────────────
func _draw_crossroad_plaza(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, COLOR_PATH_PLAZA)
	draw_circle(center, radius * 0.65, COLOR_PLAZA_RUNE)
	draw_arc(center, radius, 0.0, TAU, 24, COLOR_PATH_HW_TRIM, 1.5)

# ── Helper Gambar Meja ──────────────────────────────────────────────────────
func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.15), true)
	draw_rect(rect, COLOR_DESK_FILL, true)
	draw_rect(rect, COLOR_DESK_LINE, false, 2.0)
	
	if rect.size.x >= 60.0 and rect.size.y >= 50.0:
		var center = rect.position + rect.size / 2.0
		draw_rect(Rect2(center.x - 16, center.y - 16, 32, 12), Color(0.2, 0.25, 0.32), true)
		draw_rect(Rect2(center.x - 14, center.y + 4, 28, 8), Color(0.35, 0.4, 0.48), true)

# ── 2. MEMBANGUN COLLISION HANYA PADA DINDING TIPIS & MEJA ──────────────────
func _build_all_colliders() -> void:
	for b in collision_bodies:
		if is_instance_valid(b):
			b.queue_free()
	collision_bodies.clear()

	# A. Batas Luar Peta
	_add_wall_box(Rect2(0, 0, 2200, 20))        # North Outer
	_add_wall_box(Rect2(0, 1320, 2200, 30))     # South Outer
	_add_wall_box(Rect2(0, 0, 20, 1350))        # West Outer
	_add_wall_box(Rect2(2000, 110, 15, 1220))   # East Corridor Wall

	# B. Dinding 16 Bilik Atas
	for i in range(16):
		var bx = 50.0 + i * 115.0
		_add_wall_box(Rect2(bx - 3, 30, 6, 80))       # Left Wall
		_add_wall_box(Rect2(bx, 27, 85, 6))           # Top Wall
		_add_wall_box(Rect2(bx + 82, 30, 6, 80))      # Right Wall
		_add_wall_box(Rect2(bx + 15, 45, 55, 35))     # Desk Collider
		_add_wall_box(Rect2(bx + 85, 107, 30, 6))     # Corridor Divider

	_add_wall_box(Rect2(20, 107, 30, 6))
	_add_wall_box(Rect2(1890, 107, 110, 6))

	# C. Blok Kiri Atas (50-450, 230-580)
	_add_wall_box(Rect2(50, 227, 160, 6))         # Top-Left
	_add_wall_box(Rect2(290, 227, 160, 6))        # Top-Right (Doorway x=210-290)
	_add_wall_box(Rect2(447, 230, 6, 140))        # Right-Top
	_add_wall_box(Rect2(447, 450, 6, 130))        # Right-Bottom (Doorway y=370-450)
	_add_wall_box(Rect2(290, 577, 160, 6))        # Bottom-Right
	_add_wall_box(Rect2(50, 577, 160, 6))         # Bottom-Left (Doorway x=210-290)
	_add_wall_box(Rect2(47, 230, 6, 350))         # Left Wall

	_add_wall_box(Rect2(80, 260, 80, 65))
	_add_wall_box(Rect2(200, 260, 80, 65))
	_add_wall_box(Rect2(320, 260, 80, 65))
	_add_wall_box(Rect2(320, 370, 80, 65))
	_add_wall_box(Rect2(320, 480, 80, 65))
	_add_wall_box(Rect2(120, 460, 120, 80))

	# D. Blok Tengah Atas (Kantor Utama: 550-1250, 230-580)
	_add_wall_box(Rect2(550, 227, 300, 6))        # Top-Left
	_add_wall_box(Rect2(950, 227, 300, 6))        # Top-Right (Doorway x=850-950)
	_add_wall_box(Rect2(1247, 230, 6, 140))       # Right-Top
	_add_wall_box(Rect2(1247, 450, 6, 130))       # Right-Bottom (Doorway y=370-450)
	_add_wall_box(Rect2(950, 577, 300, 6))        # Bottom-Right
	_add_wall_box(Rect2(550, 577, 300, 6))        # Bottom-Left (Doorway x=850-950)
	_add_wall_box(Rect2(547, 230, 6, 140))        # Left-Top
	_add_wall_box(Rect2(547, 450, 6, 130))        # Left-Bottom (Doorway y=370-450)

	_add_wall_box(Rect2(590, 280, 240, 150))
	_add_wall_box(Rect2(930, 270, 95, 95))
	_add_wall_box(Rect2(1070, 270, 95, 95))
	_add_wall_box(Rect2(930, 430, 95, 95))
	_add_wall_box(Rect2(1070, 430, 95, 95))

	# E. Blok Kanan Atas (Workstation Pod: 1350-1850, 230-580)
	_add_wall_box(Rect2(1350, 227, 200, 6))       # Top-Left
	_add_wall_box(Rect2(1650, 227, 200, 6))       # Top-Right (Doorway x=1550-1650)
	_add_wall_box(Rect2(1847, 230, 6, 140))       # Right-Top
	_add_wall_box(Rect2(1847, 450, 6, 130))       # Right-Bottom (Doorway y=370-450)
	_add_wall_box(Rect2(1650, 577, 200, 6))       # Bottom-Right
	_add_wall_box(Rect2(1350, 577, 200, 6))       # Bottom-Left (Doorway x=1550-1650)
	_add_wall_box(Rect2(1347, 230, 6, 140))       # Left-Top
	_add_wall_box(Rect2(1347, 450, 6, 130))       # Left-Bottom (Doorway y=370-450)

	_add_wall_box(Rect2(1420, 270, 100, 95))
	_add_wall_box(Rect2(1600, 270, 100, 95))
	_add_wall_box(Rect2(1420, 430, 100, 95))
	_add_wall_box(Rect2(1600, 430, 100, 95))

	# F. Blok Kiri Bawah (Arsip & Vault: 50-650, 680-1150)
	_add_wall_box(Rect2(50, 677, 260, 6))         # Top-Left
	_add_wall_box(Rect2(410, 677, 240, 6))        # Top-Right (Doorway x=310-410)
	_add_wall_box(Rect2(647, 680, 6, 200))        # Right-Top
	_add_wall_box(Rect2(647, 980, 6, 170))        # Right-Bottom (Doorway y=880-980)
	_add_wall_box(Rect2(410, 1147, 240, 6))       # Bottom-Right (PINTU LOOP HIGHWAY)
	_add_wall_box(Rect2(50, 1147, 260, 6))        # Bottom-Left
	_add_wall_box(Rect2(47, 680, 6, 470))         # Left Wall

	_add_wall_box(Rect2(120, 730, 300, 120))
	_add_wall_box(Rect2(120, 930, 360, 160))

	# G. Blok Tengah Bawah (Pod Interogasi: 780-1180, 680-1150)
	_add_wall_box(Rect2(780, 677, 150, 6))        # Top-Left
	_add_wall_box(Rect2(1030, 677, 150, 6))       # Top-Right (Doorway x=930-1030)
	_add_wall_box(Rect2(1177, 680, 6, 200))        # Right-Top
	_add_wall_box(Rect2(1177, 980, 6, 170))        # Right-Bottom (Doorway y=880-980)
	_add_wall_box(Rect2(1030, 1147, 150, 6))      # Bottom-Right (PINTU LOOP HIGHWAY)
	_add_wall_box(Rect2(780, 1147, 150, 6))       # Bottom-Left
	_add_wall_box(Rect2(777, 680, 6, 200))        # Left-Top
	_add_wall_box(Rect2(777, 980, 6, 170))        # Left-Bottom (Doorway y=880-980)

	_add_wall_box(Rect2(850, 740, 260, 110))
	_add_wall_box(Rect2(880, 940, 200, 120))

	# H. BLOK KANAN BAWAH: GRAND SANCTUARY DEWA KEMATIAN (1300-1950, 680-1150)
	_add_wall_box(Rect2(1300, 677, 270, 6))       # North-Left
	_add_wall_box(Rect2(1680, 677, 270, 6))       # North-Right (Doorway x=1570-1680)
	_add_wall_box(Rect2(1947, 680, 6, 200))       # East-Top
	_add_wall_box(Rect2(1947, 980, 6, 170))       # East-Bottom (Doorway y=880-980)
	_add_wall_box(Rect2(1680, 1147, 270, 6))      # South-Right (PINTU LOOP HIGHWAY)
	_add_wall_box(Rect2(1300, 1147, 270, 6))      # South-Left
	_add_wall_box(Rect2(1297, 680, 6, 190))       # West-Top
	_add_wall_box(Rect2(1297, 1010, 6, 140))      # West-Bottom (Grand Double Doors at y=870-1010)

func _add_wall_box(rect: Rect2) -> void:
	var body = StaticBody2D.new()
	body.position = rect.position + rect.size / 2.0
	
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	
	body.add_child(col)
	add_child(body)
	collision_bodies.append(body)
