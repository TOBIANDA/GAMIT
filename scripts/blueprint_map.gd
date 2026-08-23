extends Node2D

# ── Blueprint Map v5 – Layout Sesuai Sketsa Tangan ────────────────────────────
# Layout (dari sketsa):
# ATAS  : Deretan bilik kecil (Rumah MC + Tetangga Gemetar)
# KIRI  : Lahan kosong/taman berarsir
# TENGAH: 5 Gedung bertumpuk vertikal
# GK    : "Gana Kecil" – gang/lorong vertikal sempit membelah tengah peta
# KANAN : Blok bangunan dengan jendela-jendela kecil
# BAWAH-KIRI : Kantor Polisi
# BAWAH-TENGAH: Rumah Sakit
# BAWAH-TENGAH-KANAN: Pod "P" (Penjara / Ruang Interogasi)
# BAWAH-KANAN : Rumah Eksplorasi + Sanctuary Dewa Kematian

# ── Palet Warna ───────────────────────────────────────────────────────────────
const COLOR_VOID_BG        = Color(0.07, 0.09, 0.13, 1.0)
const COLOR_FLOOR_BASE     = Color(0.21, 0.24, 0.31, 1.0)
const COLOR_GRID           = Color(0.28, 0.33, 0.43, 0.35)

# Jalur Berwarna
const COLOR_PATH_TOP       = Color(0.36, 0.17, 0.23, 1.0)  # Koridor atas – Velvet Burgundy
const COLOR_PATH_TOP_TRIM  = Color(0.85, 0.66, 0.30, 0.85) # Lis emas
const COLOR_PATH_MID       = Color(0.20, 0.30, 0.44, 1.0)  # Koridor tengah – Royal Blue
const COLOR_PATH_MID_TRIM  = Color(0.42, 0.66, 0.86, 0.85) # Lis neon biru
const COLOR_PATH_BOT       = Color(0.20, 0.30, 0.44, 1.0)  # Jalan lingkar bawah
const COLOR_PATH_AISLE     = Color(0.24, 0.28, 0.36, 1.0)  # Aisle/gang samping
const COLOR_GANG_KECIL     = Color(0.12, 0.14, 0.18, 1.0)  # Gang Kecil – gelap misterius
const COLOR_GANG_TRIM      = Color(0.55, 0.45, 0.90, 0.7)  # Lis ungu gang kecil
const COLOR_PLAZA          = Color(0.26, 0.37, 0.52, 1.0)
const COLOR_PLAZA_RUNE     = Color(0.55, 0.78, 1.00, 0.30)

# Ruangan Tematik
const COLOR_STALL          = Color(0.88, 0.93, 0.88, 1.0)  # Bilik atas – sage green
const COLOR_STALL_MC       = Color(0.95, 0.90, 0.82, 1.0)  # Rumah MC – warm ivory
const COLOR_LAHAN_KOSONG   = Color(0.17, 0.20, 0.26, 1.0)  # Lahan kosong – gelap
const COLOR_LAHAN_HATCH    = Color(0.26, 0.30, 0.40, 0.6)  # Arsiran lahan
const COLOR_GEDUNG         = Color(0.82, 0.88, 0.95, 1.0)  # Gedung – biru kantor
const COLOR_GEDUNG_WINDOW  = Color(0.55, 0.72, 0.90, 0.9)  # Jendela gedung
const COLOR_BLOK_KANAN     = Color(0.94, 0.92, 0.86, 1.0)  # Blok kanan – gading
const COLOR_KANTOR_POLISI  = Color(0.16, 0.20, 0.40, 1.0)  # Kantor polisi – biru tua
const COLOR_KANTOR_TRIM    = Color(0.40, 0.60, 1.00, 0.7)
const COLOR_RUMAH_SAKIT    = Color(0.94, 0.97, 0.97, 1.0)  # Rumah sakit – putih klinis
const COLOR_RS_TRIM        = Color(0.70, 0.90, 0.90, 0.9)
const COLOR_POD            = Color(0.86, 0.89, 0.86, 1.0)  # Pod interogasi – sage
const COLOR_EKSPLORASI     = Color(0.14, 0.08, 0.20, 1.0)  # Rumah eksplorasi – ungu gelap
const COLOR_EKSPLORASI_RUG = Color(0.24, 0.11, 0.36, 1.0)
const COLOR_RUNE_GLOW      = Color(0.68, 0.30, 0.96, 0.38)

# Furniture
const COLOR_DESK_FILL      = Color(0.74, 0.79, 0.86, 1.0)
const COLOR_DESK_LINE      = Color(0.18, 0.22, 0.28, 1.0)

# Dinding
const COLOR_WALL           = Color(0.08, 0.10, 0.14, 1.0)

# Rel kanan
const COLOR_TRACK_BG       = Color(0.72, 0.76, 0.80, 1.0)
const COLOR_TRACK_RAIL     = Color(0.22, 0.25, 0.32, 1.0)
const COLOR_TRACK_TIE      = Color(0.44, 0.37, 0.30, 1.0)

const WT = 6.0  # Wall Thickness

# ── Koordinat Layout (Sesuai Sketsa) ─────────────────────────────────────────
# Baris bilik atas:       y =  20 .. 120
# Koridor Utama Atas:     y = 120 .. 230
# Blok Tengah Atas:       y = 230 .. 680
# Koridor Tengah:         y = 680 .. 780
# Blok Tengah Bawah:      y = 780 .. 1200
# Jalan Lingkar Bawah:    y = 1200 .. 1330
#
# Lahan Kosong (kiri):    x =  20 .. 360
# 5 Gedung (tengah-kiri): x = 360 .. 720
# Gang Kecil:             x = 720 .. 820
# Blok Jendela:           x = 820 .. 1240
# Gang Tengah:            x = 1240 .. 1330
# Blok Kanan Atas:        x = 1330 .. 1940
# Aisle Kanan:            x = 1940 .. 2010
# Rel:                    x = 2010 .. 2100

var collision_bodies: Array[StaticBody2D] = []

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ─────────────────────────────────────────────────────────────────────────────
func _draw() -> void:

	# 0. Void luar
	draw_rect(Rect2(-200, -200, 2600, 1800), COLOR_VOID_BG, true)

	# 1. Base lantai seluruh area bermain
	draw_rect(Rect2(20, 20, 2090, 1310), COLOR_FLOOR_BASE, true)

	# Grid
	for gx in range(40, 2120, 40):
		draw_line(Vector2(gx, 20), Vector2(gx, 1330), COLOR_GRID, 1.0)
	for gy in range(20, 1330, 40):
		draw_line(Vector2(20, gy), Vector2(2110, gy), COLOR_GRID, 1.0)

	# ── A. LANTAI RUANGAN (digambar dulu sebagai base) ──────────────────────

	# Bilik atas kiri (x=20-420, 14 bilik) – Tetangga Gemetar
	for i in range(7):
		var bx = 20.0 + i * 58.0
		draw_rect(Rect2(bx + 2, 22, 50, 94), COLOR_STALL, true)

	# Bilik atas tengah-kiri area (x=420-720)
	for i in range(5):
		var bx = 420.0 + i * 60.0
		draw_rect(Rect2(bx + 2, 22, 52, 94), COLOR_STALL, true)

	# Rumah MC (bilik khusus di tengah, x=720-820 Gang Kecil atasnya, x=820-1000)
	draw_rect(Rect2(822, 22, 170, 94), COLOR_STALL_MC, true)
	# Label "MC" tulis manual di ruangan (via garis atap warna beda)
	draw_rect(Rect2(822, 22, 170, 6), Color(0.85, 0.65, 0.30, 0.9), true)

	# Bilik atas kanan (x=1000-1940)
	for i in range(16):
		var bx = 1000.0 + i * 58.5
		if bx + 50 > 1940:
			break
		draw_rect(Rect2(bx + 2, 22, 50, 94), COLOR_STALL, true)

	# LAHAN KOSONG / TAMAN (Kiri Atas, diarsir)
	draw_rect(Rect2(20, 230, 340, 450), COLOR_LAHAN_KOSONG, true)
	# Arsiran diagonal
	var hatch_step = 22
	for k in range(-20, 40):
		var x0 = 20.0 + k * hatch_step
		var y0 = 230.0
		var x1 = x0 + 450.0
		var y1 = y0 + 450.0
		var xa = clampf(x0, 20, 360)
		var ya = 230.0 + (xa - x0)
		var xb = clampf(x1, 20, 360)
		var yb = 230.0 + (xb - x0)
		ya = clampf(ya, 230, 680)
		yb = clampf(yb, 230, 680)
		if xa != xb:
			draw_line(Vector2(xa, ya), Vector2(xb, yb), COLOR_LAHAN_HATCH, 1.5)

	# 5 GEDUNG bertumpuk (x=360-720, y=230-680)
	var gedung_colors = [
		Color(0.82, 0.88, 0.95, 1.0),
		Color(0.80, 0.86, 0.93, 1.0),
		Color(0.84, 0.89, 0.96, 1.0),
		Color(0.78, 0.85, 0.92, 1.0),
		Color(0.83, 0.90, 0.95, 1.0),
	]
	var gedung_h = 87.0
	var gedung_gap = 3.0
	for gi in range(5):
		var gy = 230.0 + gi * (gedung_h + gedung_gap)
		draw_rect(Rect2(362, gy, 354, gedung_h), gedung_colors[gi], true)
		# Jendela-jendela kecil di kanan gedung
		for wi in range(3):
			var wx = 510.0 + wi * 65.0
			draw_rect(Rect2(wx, gy + 18, 28, 24), COLOR_GEDUNG_WINDOW, true)
			draw_rect(Rect2(wx, gy + 18, 28, 24), Color(0.22, 0.30, 0.45), false, 1.5)
		# Pintu kecil di sisi kanan gedung
		draw_rect(Rect2(712, gy + 30, 14, 40), COLOR_PATH_AISLE, true)

	# Blok jendela-kecil TENGAH KANAN atas (x=820-1240, y=230-680)
	draw_rect(Rect2(820, 230, 420, 450), COLOR_BLOK_KANAN, true)
	# Jendela-jendela kecil
	for row in range(4):
		for col in range(5):
			var wx = 850.0 + col * 72.0
			var wy = 260.0 + row * 95.0
			draw_rect(Rect2(wx, wy, 38, 32), COLOR_GEDUNG_WINDOW, true)
			draw_rect(Rect2(wx, wy, 38, 32), Color(0.22, 0.30, 0.45), false, 1.5)

	# Blok Kanan Atas (x=1330-1940, y=230-680)
	draw_rect(Rect2(1330, 230, 610, 450), COLOR_BLOK_KANAN, true)
	_draw_desk(Rect2(1380, 280, 220, 130))
	_draw_desk(Rect2(1640, 280, 200, 130))
	_draw_desk(Rect2(1380, 480, 220, 130))
	_draw_desk(Rect2(1640, 480, 200, 130))

	# KANTOR POLISI (kiri bawah: x=20-420, y=780-1200)
	draw_rect(Rect2(20, 780, 400, 420), COLOR_KANTOR_POLISI, true)
	# Badge/stripe biru di kiri
	draw_rect(Rect2(20, 780, 8, 420), COLOR_KANTOR_TRIM, true)
	draw_rect(Rect2(20, 780, 400, 8), COLOR_KANTOR_TRIM, true)
	# Meja polisi
	_draw_desk(Rect2(60, 830, 300, 110))
	_draw_desk(Rect2(60, 1010, 300, 130))
	# Counter / bar
	draw_rect(Rect2(60, 990, 310, 12), Color(0.50, 0.60, 0.80, 0.8), true)

	# RUMAH SAKIT (x=420-870, y=780-1200)
	draw_rect(Rect2(420, 780, 450, 420), COLOR_RUMAH_SAKIT, true)
	draw_rect(Rect2(420, 780, 450, 7), COLOR_RS_TRIM, true)
	draw_rect(Rect2(420, 780, 7, 420), COLOR_RS_TRIM, true)
	# Tempat tidur RS
	for bed_row in range(3):
		for bed_col in range(2):
			var bx2 = 460.0 + bed_col * 190.0
			var by2 = 820.0 + bed_row * 120.0
			draw_rect(Rect2(bx2, by2, 150, 80), Color(0.88, 0.96, 0.96, 1.0), true)
			draw_rect(Rect2(bx2, by2, 150, 80), COLOR_RS_TRIM, false, 1.5)
			draw_rect(Rect2(bx2, by2, 30, 80), Color(0.72, 0.88, 0.90, 1.0), true) # Bantal

	# POD "P" / Ruang Interogasi (x=870-1300, y=780-1200)
	draw_rect(Rect2(870, 780, 430, 420), COLOR_POD, true)
	_draw_desk(Rect2(920, 840, 320, 110))
	_draw_desk(Rect2(950, 1020, 280, 120))
	# Label "P" besar
	draw_rect(Rect2(870, 780, 6, 420), Color(0.45, 0.55, 0.50, 0.9), true)

	# RUMAH EKSPLORASI + SANCTUARY (x=1300-1940, y=780-1200)
	draw_rect(Rect2(1300, 780, 640, 420), COLOR_EKSPLORASI, true)
	draw_rect(Rect2(1380, 840, 490, 290), COLOR_EKSPLORASI_RUG, true)
	draw_circle(Vector2(1620, 985), 115.0, COLOR_RUNE_GLOW)
	draw_circle(Vector2(1620, 985), 72.0, Color(0.80, 0.32, 1.0, 0.22))

	# ── B. JALUR BERWARNA (di atas ruangan) ───────────────────────────────────

	# 1. Koridor Utama Atas (y=120-230) – Burgundy
	draw_rect(Rect2(20, 120, 2080, 110), COLOR_PATH_TOP, true)
	draw_line(Vector2(20, 124), Vector2(2100, 124), COLOR_PATH_TOP_TRIM, 2.5)
	draw_line(Vector2(20, 226), Vector2(2100, 226), COLOR_PATH_TOP_TRIM, 2.5)

	# 2. Gang Kecil "Gana Kecil" (x=720-820) – gelap misterius, vertikal
	draw_rect(Rect2(720, 120, 100, 1080), COLOR_GANG_KECIL, true)
	draw_line(Vector2(723, 120), Vector2(723, 1200), COLOR_GANG_TRIM, 2.0)
	draw_line(Vector2(817, 120), Vector2(817, 1200), COLOR_GANG_TRIM, 2.0)
	# Pola lantai gang
	for gy2 in range(130, 1200, 25):
		draw_line(Vector2(728, gy2), Vector2(815, gy2), Color(0.18, 0.20, 0.28, 0.5), 1.0)

	# 3. Aisle Kiri (x=360-420 antara lahan & gedung - di atas + bawah koridor)
	draw_rect(Rect2(360, 120, 60, 1080), COLOR_PATH_AISLE, true)

	# 4. Aisle Tengah antara blok jendela & blok kanan (x=1240-1330)
	draw_rect(Rect2(1240, 120, 90, 1080), COLOR_PATH_AISLE, true)

	# 5. Aisle Kanan (x=1940-2010)
	draw_rect(Rect2(1940, 120, 70, 1080), COLOR_PATH_AISLE, true)

	# 6. Koridor Tengah (y=680-780) – Royal Blue
	draw_rect(Rect2(20, 680, 2080, 100), COLOR_PATH_MID, true)
	draw_line(Vector2(20, 684), Vector2(2100, 684), COLOR_PATH_MID_TRIM, 2.5)
	draw_line(Vector2(20, 776), Vector2(2100, 776), COLOR_PATH_MID_TRIM, 2.5)

	# 7. Jalan Lingkar Bawah (y=1200-1330) – Royal Blue
	draw_rect(Rect2(20, 1200, 2080, 130), COLOR_PATH_BOT, true)
	draw_line(Vector2(20, 1205), Vector2(2100, 1205), COLOR_PATH_MID_TRIM, 3.0)
	draw_line(Vector2(20, 1326), Vector2(2100, 1326), COLOR_PATH_MID_TRIM, 3.0)
	# Marka tengah putus-putus
	for mx in range(50, 2080, 55):
		draw_line(Vector2(mx, 1263), Vector2(mx + 32, 1263), Color(0.8, 0.9, 1.0, 0.4), 2.0)

	# 8. Plaza Persimpangan
	_draw_plaza(Vector2(390, 175), 42.0)
	_draw_plaza(Vector2(770, 175), 42.0)
	_draw_plaza(Vector2(1285, 175), 42.0)
	_draw_plaza(Vector2(1965, 175), 42.0)
	_draw_plaza(Vector2(390, 730), 42.0)
	_draw_plaza(Vector2(770, 730), 42.0)
	_draw_plaza(Vector2(1285, 730), 42.0)
	_draw_plaza(Vector2(1965, 730), 42.0)
	_draw_plaza(Vector2(390, 1263), 52.0)
	_draw_plaza(Vector2(770, 1263), 52.0)
	_draw_plaza(Vector2(1285, 1263), 52.0)
	_draw_plaza(Vector2(1965, 1263), 52.0)

	# Karpet Pintu Sanctuary
	draw_rect(Rect2(1265, 920, 100, 120), COLOR_EKSPLORASI_RUG, true)  # Pintu Barat
	draw_rect(Rect2(1545, 645, 130, 90), COLOR_EKSPLORASI_RUG, true)   # Pintu Utara
	draw_rect(Rect2(1545, 1130, 130, 80), COLOR_EKSPLORASI_RUG, true)  # Pintu Selatan

	# ── C. REL VERTIKAL KANAN ─────────────────────────────────────────────────
	draw_rect(Rect2(2010, 20, 90, 1310), COLOR_TRACK_BG, true)
	draw_line(Vector2(2025, 20), Vector2(2025, 1330), COLOR_TRACK_RAIL, 3.5)
	draw_line(Vector2(2085, 20), Vector2(2085, 1330), COLOR_TRACK_RAIL, 3.5)
	for ty in range(30, 1325, 16):
		draw_line(Vector2(2016, ty), Vector2(2094, ty), COLOR_TRACK_TIE, 3.0)

	# ── D. GARIS DINDING ──────────────────────────────────────────────────────

	# Batas luar
	draw_line(Vector2(20, 20), Vector2(2105, 20), COLOR_WALL, WT)
	draw_line(Vector2(20, 1330), Vector2(2105, 1330), COLOR_WALL, WT)
	draw_line(Vector2(20, 20), Vector2(20, 1330), COLOR_WALL, WT)
	draw_line(Vector2(2000, 120), Vector2(2000, 1330), COLOR_WALL, WT)

	# Dinding bilik atas kiri (7 bilik, x=20-426)
	for i in range(7):
		var bx = 20.0 + i * 58.0
		draw_line(Vector2(bx, 116), Vector2(bx, 22), COLOR_WALL, WT)
		draw_line(Vector2(bx, 22), Vector2(bx + 52, 22), COLOR_WALL, WT)
		draw_line(Vector2(bx + 52, 22), Vector2(bx + 52, 116), COLOR_WALL, WT)

	# Bilik tengah kiri (5 bilik, x=426-720)
	for i in range(5):
		var bx = 426.0 + i * 60.0
		draw_line(Vector2(bx, 116), Vector2(bx, 22), COLOR_WALL, WT)
		draw_line(Vector2(bx, 22), Vector2(bx + 54, 22), COLOR_WALL, WT)
		draw_line(Vector2(bx + 54, 22), Vector2(bx + 54, 116), COLOR_WALL, WT)

	# Rumah MC (x=820-992)
	draw_line(Vector2(820, 116), Vector2(820, 22), COLOR_WALL, WT)
	draw_line(Vector2(820, 22), Vector2(992, 22), COLOR_WALL, WT)
	draw_line(Vector2(992, 22), Vector2(992, 116), COLOR_WALL, WT)

	# Bilik atas kanan
	for i in range(16):
		var bx = 1000.0 + i * 58.5
		if bx + 50 > 1945:
			break
		draw_line(Vector2(bx, 116), Vector2(bx, 22), COLOR_WALL, WT)
		draw_line(Vector2(bx, 22), Vector2(bx + 52, 22), COLOR_WALL, WT)
		draw_line(Vector2(bx + 52, 22), Vector2(bx + 52, 116), COLOR_WALL, WT)

	# Garis atas lorong (bawah bilik)
	draw_line(Vector2(20, 118), Vector2(718, 118), COLOR_WALL, WT)
	draw_line(Vector2(820, 118), Vector2(2000, 118), COLOR_WALL, WT)

	# LAHAN KOSONG (dinding kotak, x=20-360, y=230-680)
	draw_line(Vector2(20, 230), Vector2(360, 230), COLOR_WALL, WT)
	draw_line(Vector2(360, 230), Vector2(360, 680), COLOR_WALL, WT)
	draw_line(Vector2(360, 680), Vector2(20, 680), COLOR_WALL, WT)
	# Kiri lahan = batas peta

	# 5 GEDUNG (dinding, x=362-716, y=230-680)
	for gi in range(6):
		var gy = 230.0 + gi * 90.0
		draw_line(Vector2(362, gy), Vector2(716, gy), COLOR_WALL, WT)
	draw_line(Vector2(362, 230), Vector2(362, 680), COLOR_WALL, WT)
	draw_line(Vector2(716, 230), Vector2(716, 680), COLOR_WALL, WT)

	# Blok Jendela Tengah Kanan (x=820-1240, y=230-680, pintu di aisle)
	draw_line(Vector2(820, 230), Vector2(1240, 230), COLOR_WALL, WT)  # Atas (pintu di koridor y=120 atas)
	draw_line(Vector2(1240, 230), Vector2(1240, 530), COLOR_WALL, WT) # Kanan atas (pintu y=530-620)
	draw_line(Vector2(1240, 620), Vector2(1240, 680), COLOR_WALL, WT) # Kanan bawah
	draw_line(Vector2(820, 680), Vector2(1240, 680), COLOR_WALL, WT)  # Bawah
	draw_line(Vector2(820, 230), Vector2(820, 430), COLOR_WALL, WT)   # Kiri atas (pintu y=430-540)
	draw_line(Vector2(820, 540), Vector2(820, 680), COLOR_WALL, WT)   # Kiri bawah

	# Blok Kanan Atas (x=1330-1940, y=230-680)
	draw_line(Vector2(1330, 230), Vector2(1680, 230), COLOR_WALL, WT) # Atas kiri (pintu x=1680-1790)
	draw_line(Vector2(1790, 230), Vector2(1940, 230), COLOR_WALL, WT) # Atas kanan
	draw_line(Vector2(1940, 230), Vector2(1940, 380), COLOR_WALL, WT) # Kanan atas (pintu y=380-480)
	draw_line(Vector2(1940, 480), Vector2(1940, 680), COLOR_WALL, WT) # Kanan bawah
	draw_line(Vector2(1940, 680), Vector2(1790, 680), COLOR_WALL, WT) # Bawah kanan
	draw_line(Vector2(1680, 680), Vector2(1330, 680), COLOR_WALL, WT) # Bawah kiri (pintu x=1680-1790)
	draw_line(Vector2(1330, 680), Vector2(1330, 480), COLOR_WALL, WT) # Kiri bawah (pintu y=380-480)
	draw_line(Vector2(1330, 380), Vector2(1330, 230), COLOR_WALL, WT) # Kiri atas

	# KANTOR POLISI (x=20-420, y=780-1200)
	draw_line(Vector2(20, 780), Vector2(200, 780), COLOR_WALL, WT)    # Atas kiri (pintu x=200-320)
	draw_line(Vector2(320, 780), Vector2(420, 780), COLOR_WALL, WT)   # Atas kanan
	draw_line(Vector2(420, 780), Vector2(420, 960), COLOR_WALL, WT)   # Kanan atas (pintu y=960-1060)
	draw_line(Vector2(420, 1060), Vector2(420, 1200), COLOR_WALL, WT) # Kanan bawah
	draw_line(Vector2(420, 1200), Vector2(200, 1200), COLOR_WALL, WT) # Bawah kanan (pintu x=200-320 ke loop)
	draw_line(Vector2(120, 1200), Vector2(20, 1200), COLOR_WALL, WT)  # Bawah kiri
	draw_line(Vector2(20, 1200), Vector2(20, 780), COLOR_WALL, WT)    # Kiri

	# RUMAH SAKIT (x=420-870, y=780-1200)
	draw_line(Vector2(420, 780), Vector2(630, 780), COLOR_WALL, WT)   # Atas kiri (pintu x=630-730)
	draw_line(Vector2(730, 780), Vector2(870, 780), COLOR_WALL, WT)   # Atas kanan
	draw_line(Vector2(870, 780), Vector2(870, 960), COLOR_WALL, WT)   # Kanan atas (pintu y=960-1060)
	draw_line(Vector2(870, 1060), Vector2(870, 1200), COLOR_WALL, WT) # Kanan bawah
	draw_line(Vector2(870, 1200), Vector2(730, 1200), COLOR_WALL, WT) # Bawah kanan (pintu ke loop)
	draw_line(Vector2(630, 1200), Vector2(420, 1200), COLOR_WALL, WT) # Bawah kiri

	# POD "P" (x=870-1300, y=780-1200)
	draw_line(Vector2(870, 780), Vector2(1060, 780), COLOR_WALL, WT)  # Atas kiri (pintu x=1060-1160)
	draw_line(Vector2(1160, 780), Vector2(1300, 780), COLOR_WALL, WT) # Atas kanan
	draw_line(Vector2(1300, 780), Vector2(1300, 960), COLOR_WALL, WT) # Kanan atas (pintu y=960-1060)
	draw_line(Vector2(1300, 1060), Vector2(1300, 1200), COLOR_WALL, WT)# Kanan bawah
	draw_line(Vector2(1300, 1200), Vector2(1160, 1200), COLOR_WALL, WT)# Bawah kanan
	draw_line(Vector2(1060, 1200), Vector2(870, 1200), COLOR_WALL, WT) # Bawah kiri (pintu loop)
	draw_line(Vector2(870, 1200), Vector2(870, 1060), COLOR_WALL, WT)  # Kiri bawah
	draw_line(Vector2(870, 960), Vector2(870, 780), COLOR_WALL, WT)    # Kiri atas (pintu y=960-1060)

	# RUMAH EKSPLORASI + SANCTUARY (x=1300-1940, y=780-1200)
	draw_line(Vector2(1300, 780), Vector2(1560, 780), COLOR_WALL, WT)  # Utara kiri (pintu x=1560-1680)
	draw_line(Vector2(1680, 780), Vector2(1940, 780), COLOR_WALL, WT)  # Utara kanan
	draw_line(Vector2(1940, 780), Vector2(1940, 960), COLOR_WALL, WT)  # Timur atas (pintu y=960-1060)
	draw_line(Vector2(1940, 1060), Vector2(1940, 1200), COLOR_WALL, WT)# Timur bawah
	draw_line(Vector2(1940, 1200), Vector2(1680, 1200), COLOR_WALL, WT)# Selatan kanan (pintu loop)
	draw_line(Vector2(1560, 1200), Vector2(1300, 1200), COLOR_WALL, WT)# Selatan kiri
	draw_line(Vector2(1300, 1200), Vector2(1300, 1060), COLOR_WALL, WT)# Barat bawah
	draw_line(Vector2(1300, 900), Vector2(1300, 780), COLOR_WALL, WT)  # Barat atas (PINTU UTAMA y=900-1060)

# ── Helpers ───────────────────────────────────────────────────────────────────
func _draw_plaza(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, COLOR_PLAZA)
	draw_circle(center, radius * 0.62, COLOR_PLAZA_RUNE)
	draw_arc(center, radius, 0.0, TAU, 24, COLOR_PATH_MID_TRIM, 1.5)

func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.14), true)
	draw_rect(rect, COLOR_DESK_FILL, true)
	draw_rect(rect, COLOR_DESK_LINE, false, 1.8)
	if rect.size.x >= 55.0 and rect.size.y >= 45.0:
		var c = rect.position + rect.size / 2.0
		draw_rect(Rect2(c.x - 14, c.y - 14, 28, 10), Color(0.2, 0.25, 0.32), true)
		draw_rect(Rect2(c.x - 12, c.y + 2, 24, 7), Color(0.35, 0.40, 0.48), true)

# ── Collision Builder ──────────────────────────────────────────────────────────
func _build_all_colliders() -> void:
	for b in collision_bodies:
		if is_instance_valid(b): b.queue_free()
	collision_bodies.clear()

	# Batas luar
	_add_wall_box(Rect2(0, 0, 2110, 22))        # North
	_add_wall_box(Rect2(0, 1326, 2110, 24))     # South
	_add_wall_box(Rect2(0, 0, 22, 1350))        # West
	_add_wall_box(Rect2(1996, 120, 14, 1210))   # East inner

	# Bilik atas kiri (7 bilik)
	for i in range(7):
		var bx = 20.0 + i * 58.0
		_add_wall_box(Rect2(bx - 3, 22, 6, 96))
		_add_wall_box(Rect2(bx, 19, 54, 6))
		_add_wall_box(Rect2(bx + 49, 22, 6, 96))

	# Bilik tengah kiri (5 bilik)
	for i in range(5):
		var bx = 426.0 + i * 60.0
		_add_wall_box(Rect2(bx - 3, 22, 6, 96))
		_add_wall_box(Rect2(bx, 19, 56, 6))
		_add_wall_box(Rect2(bx + 52, 22, 6, 96))

	# Rumah MC
	_add_wall_box(Rect2(817, 22, 6, 96))
	_add_wall_box(Rect2(820, 19, 174, 6))
	_add_wall_box(Rect2(989, 22, 6, 96))

	# Bilik atas kanan
	for i in range(16):
		var bx = 1000.0 + i * 58.5
		if bx + 50 > 1945: break
		_add_wall_box(Rect2(bx - 3, 22, 6, 96))
		_add_wall_box(Rect2(bx, 19, 54, 6))
		_add_wall_box(Rect2(bx + 50, 22, 6, 96))

	# Garis bawah bilik atas
	_add_wall_box(Rect2(20, 115, 700, 6))
	_add_wall_box(Rect2(820, 115, 1180, 6))

	# Lahan kosong (dinding)
	_add_wall_box(Rect2(20, 227, 340, 6))    # Atas
	_add_wall_box(Rect2(357, 230, 6, 450))   # Kanan
	_add_wall_box(Rect2(20, 677, 340, 6))    # Bawah

	# 5 Gedung (horizontal dividers)
	for gi in range(6):
		var gy = 230.0 + gi * 90.0
		_add_wall_box(Rect2(362, gy - 3, 356, 6))
	_add_wall_box(Rect2(359, 230, 6, 450))  # Kiri gedung
	_add_wall_box(Rect2(713, 230, 6, 450))  # Kanan gedung

	# Blok jendela tengah kanan atas
	_add_wall_box(Rect2(820, 227, 420, 6))   # Atas
	_add_wall_box(Rect2(1237, 230, 6, 300))  # Kanan atas (pintu y=530-620)
	_add_wall_box(Rect2(1237, 617, 6, 66))   # Kanan bawah
	_add_wall_box(Rect2(820, 677, 420, 6))   # Bawah
	_add_wall_box(Rect2(817, 230, 6, 200))   # Kiri atas (pintu y=430-540)
	_add_wall_box(Rect2(817, 537, 6, 146))   # Kiri bawah

	# Blok kanan atas
	_add_wall_box(Rect2(1330, 227, 350, 6))  # Atas kiri (pintu x=1680-1790)
	_add_wall_box(Rect2(1787, 227, 156, 6))  # Atas kanan
	_add_wall_box(Rect2(1937, 230, 6, 150))  # Kanan atas (pintu y=380-480)
	_add_wall_box(Rect2(1937, 477, 6, 206))  # Kanan bawah
	_add_wall_box(Rect2(1787, 677, 153, 6))  # Bawah kanan (pintu x=1680-1790)
	_add_wall_box(Rect2(1330, 677, 350, 6))  # Bawah kiri
	_add_wall_box(Rect2(1327, 477, 6, 206))  # Kiri bawah (pintu y=380-480)
	_add_wall_box(Rect2(1327, 230, 6, 150))  # Kiri atas

	# Meja blok kanan atas
	_add_wall_box(Rect2(1380, 280, 220, 130))
	_add_wall_box(Rect2(1640, 280, 200, 130))
	_add_wall_box(Rect2(1380, 480, 220, 130))
	_add_wall_box(Rect2(1640, 480, 200, 130))

	# Kantor Polisi
	_add_wall_box(Rect2(20, 777, 180, 6))    # Atas kiri (pintu x=200-320)
	_add_wall_box(Rect2(317, 777, 106, 6))   # Atas kanan
	_add_wall_box(Rect2(417, 780, 6, 180))   # Kanan atas (pintu y=960-1060)
	_add_wall_box(Rect2(417, 1057, 6, 146))  # Kanan bawah
	_add_wall_box(Rect2(317, 1197, 103, 6))  # Bawah kanan
	_add_wall_box(Rect2(20, 1197, 100, 6))   # Bawah kiri
	_add_wall_box(Rect2(17, 780, 6, 420))    # Kiri wall (batas peta)
	_add_wall_box(Rect2(60, 830, 300, 110))
	_add_wall_box(Rect2(60, 1010, 300, 130))

	# Rumah Sakit
	_add_wall_box(Rect2(420, 777, 210, 6))   # Atas kiri (pintu x=630-730)
	_add_wall_box(Rect2(727, 777, 146, 6))   # Atas kanan
	_add_wall_box(Rect2(867, 780, 6, 180))   # Kanan atas (pintu y=960-1060)
	_add_wall_box(Rect2(867, 1057, 6, 146))  # Kanan bawah
	_add_wall_box(Rect2(727, 1197, 146, 6))  # Bawah kanan
	_add_wall_box(Rect2(420, 1197, 210, 6))  # Bawah kiri

	# Pod "P"
	_add_wall_box(Rect2(870, 777, 190, 6))   # Atas kiri (pintu x=1060-1160)
	_add_wall_box(Rect2(1157, 777, 146, 6))  # Atas kanan
	_add_wall_box(Rect2(1297, 780, 6, 180))  # Kanan atas (pintu y=960-1060)
	_add_wall_box(Rect2(1297, 1057, 6, 146)) # Kanan bawah
	_add_wall_box(Rect2(1157, 1197, 146, 6)) # Bawah kanan
	_add_wall_box(Rect2(1060, 1197, 97, 6))  # Bawah tengah (pintu loop)
	_add_wall_box(Rect2(870, 1197, 190, 6))  # Bawah kiri
	_add_wall_box(Rect2(867, 1057, 6, 143))  # Kiri bawah (pintu y=960-1060)
	_add_wall_box(Rect2(867, 780, 6, 180))   # Kiri atas
	_add_wall_box(Rect2(920, 840, 320, 110))
	_add_wall_box(Rect2(950, 1020, 280, 120))

	# Rumah Eksplorasi + Sanctuary
	_add_wall_box(Rect2(1300, 777, 260, 6))  # Utara kiri (pintu x=1560-1680)
	_add_wall_box(Rect2(1677, 777, 266, 6))  # Utara kanan
	_add_wall_box(Rect2(1937, 780, 6, 180))  # Timur atas (pintu y=960-1060)
	_add_wall_box(Rect2(1937, 1057, 6, 146)) # Timur bawah
	_add_wall_box(Rect2(1677, 1197, 266, 6)) # Selatan kanan
	_add_wall_box(Rect2(1300, 1197, 260, 6)) # Selatan kiri (pintu loop)
	_add_wall_box(Rect2(1297, 1057, 6, 146)) # Barat bawah
	_add_wall_box(Rect2(1297, 780, 6, 120))  # Barat atas (PINTU UTAMA y=900-1060 →160px lebar)

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
