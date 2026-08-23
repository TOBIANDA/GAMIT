extends Node2D

# ── Blueprint Map v7 – Presisi Sketsa dengan Jalan Menyiku & Gang Kecil Benar ───
#
# Struktur JALAN dari sketsa (KOREKSI TOTAL):
#
# JALAN HORIZONTAL:
#   - Jalan Atas     (y=110..220): full lebar, Burgundy runner
#   - Jalan Tengah   (y=680..770): full lebar, Royal Blue
#   - Jalan Bawah    (y=1210..1330): Lingkar Bawah, Royal Blue
#
# JALAN VERTIKAL:
#   - Jalan Vertikal Barat (x=370..455): memisahkan Lahan Kosong & Kantor Polisi DARI 5 Gedung & RS
#   - GANG KECIL (x=970..1055): lorong sempit gelap di TENGAH-KANAN
#   - Jalan Vertikal Timur (x=1480..1560): memisahkan Blok Tengah DARI Blok Kanan Atas
#
# JALAN MENYIKU (L-SHAPED) di bawah:
#   - Jalan siku di sudut kiri bawah: persimpangan Jalan Vertikal Barat + Jalan Tengah
#   - Di area Kantor Polisi & RS, lorong berbelok membentuk sudut L
#
# RUANGAN (kiri ke kanan):
#   KIRI    : Lahan Kosong (atas) + Kantor Polisi (bawah)
#   TG-KIRI : 5 Gedung (atas) + Rumah Sakit (bawah)
#   TENGAH  : Blok Besar Atas + Blok Eksplorasi/P bawah
#   KANAN   : Blok 2x2 Atas + Stasiun/Sanctuary bawah
#   REL     : Jalur kereta sisi kanan

const COLOR_VOID           = Color(0.06, 0.08, 0.11, 1.0)
const COLOR_GROUND         = Color(0.18, 0.21, 0.27, 1.0)
const COLOR_GRID           = Color(0.25, 0.30, 0.38, 0.28)

# Jalan
const COLOR_ROAD_TOP       = Color(0.35, 0.16, 0.22, 1.0)  # Burgund
const COLOR_ROAD_TRIM_TOP  = Color(0.85, 0.66, 0.30, 0.88)
const COLOR_ROAD_BLUE      = Color(0.19, 0.28, 0.42, 1.0)  # Royal Blue
const COLOR_ROAD_TRIM_BLUE = Color(0.40, 0.65, 0.88, 0.85)
const COLOR_ROAD_VERT      = Color(0.23, 0.27, 0.35, 1.0)  # Jalan Vertikal
const COLOR_ROAD_VERT_MARK = Color(0.75, 0.85, 1.0, 0.45)
const COLOR_GANG_KECIL     = Color(0.10, 0.12, 0.16, 1.0)  # Gang Kecil Gelap
const COLOR_GANG_TRIM      = Color(0.55, 0.40, 0.88, 0.75)
const COLOR_PLAZA          = Color(0.25, 0.36, 0.50, 1.0)

# Ruangan
const COLOR_STALL          = Color(0.88, 0.92, 0.88, 1.0)
const COLOR_STALL_TETANGGA = Color(0.80, 0.87, 0.94, 1.0)
const COLOR_STALL_MC       = Color(0.96, 0.90, 0.80, 1.0)
const COLOR_LAHAN_BG       = Color(0.13, 0.16, 0.20, 1.0)
const COLOR_LAHAN_HATCH    = Color(0.35, 0.42, 0.52, 0.75)
const COLOR_GEDUNG_BG      = Color(0.84, 0.89, 0.95, 1.0)
const COLOR_GEDUNG_WIN     = Color(0.45, 0.68, 0.90, 0.90)
const COLOR_POLISI_BG      = Color(0.15, 0.20, 0.38, 1.0)
const COLOR_POLISI_STRIPE  = Color(0.42, 0.62, 0.95, 0.80)
const COLOR_RS_BG          = Color(0.94, 0.97, 0.97, 1.0)
const COLOR_RS_CROSS       = Color(0.85, 0.22, 0.22, 0.90)
const COLOR_BLOK_TENGAH    = Color(0.91, 0.93, 0.90, 1.0)
const COLOR_BLOK_WIN       = Color(0.50, 0.70, 0.88, 0.85)
const COLOR_EKSPLORASI_BG  = Color(0.89, 0.85, 0.93, 1.0)
const COLOR_SANCTUARY_BG   = Color(0.13, 0.07, 0.20, 1.0)
const COLOR_SANCTUARY_RUG  = Color(0.24, 0.11, 0.36, 1.0)
const COLOR_RUNE_GLOW      = Color(0.70, 0.28, 0.98, 0.40)
const COLOR_BLOK_KANAN_BG  = Color(0.91, 0.93, 0.90, 1.0)

const COLOR_DESK           = Color(0.74, 0.79, 0.86, 1.0)
const COLOR_DESK_EDGE      = Color(0.20, 0.24, 0.30, 1.0)
const COLOR_WALL           = Color(0.08, 0.10, 0.14, 1.0)
const COLOR_TRACK_BG       = Color(0.72, 0.76, 0.80, 1.0)
const COLOR_TRACK_RAIL     = Color(0.20, 0.23, 0.30, 1.0)
const COLOR_TRACK_TIE      = Color(0.42, 0.36, 0.28, 1.0)

const WT = 6.0
var collision_bodies: Array[StaticBody2D] = []

# ── Layout Koordinat Utama ────────────────────────────────────────────────────
# Pembatas Horizontal
const Y_STALL_BOT  = 110   # Bawah baris bilik
const Y_COR_TOP    = 110   # Atas Jalan Utama Atas
const Y_COR_BOT    = 220   # Bawah Jalan Utama Atas (pintu masuk blok)
const Y_MID_TOP    = 680   # Atas Jalan Tengah
const Y_MID_BOT    = 770   # Bawah Jalan Tengah
const Y_LOOP_TOP   = 1210  # Atas Jalan Lingkar Bawah
const Y_LOOP_BOT   = 1330  # Bawah Jalan Lingkar Bawah

# Pembatas Vertikal (Kolom)
const X_LEFT_WALL  = 20    # Batas kiri peta
const X_VROAD_L    = 370   # Kiri Jalan Vertikal Barat
const X_VROAD_R    = 455   # Kanan Jalan Vertikal Barat
const X_GANG_L     = 970   # Kiri Gang Kecil
const X_GANG_R     = 1055  # Kanan Gang Kecil
const X_VROAD2_L   = 1480  # Kiri Jalan Vertikal Timur
const X_VROAD2_R   = 1560  # Kanan Jalan Vertikal Timur
const X_RIGHT_WALL = 2000  # Batas kanan area bermain
const X_TRACK_L    = 2020  # Rel kiri
const X_TRACK_R    = 2110  # Rel kanan

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ─────────────────────────────────────────────────────────────────────────────
func _draw() -> void:
	draw_rect(Rect2(-200, -200, 2600, 1800), COLOR_VOID, true)
	draw_rect(Rect2(20, 15, X_RIGHT_WALL, Y_LOOP_BOT), COLOR_GROUND, true)
	for gx in range(40, 2020, 40):
		draw_line(Vector2(gx, 15), Vector2(gx, Y_LOOP_BOT), COLOR_GRID, 1.0)
	for gy in range(15, Y_LOOP_BOT, 40):
		draw_line(Vector2(20, gy), Vector2(X_RIGHT_WALL, gy), COLOR_GRID, 1.0)

	# ── A. LANTAI RUANGAN (Digambar pertama sebagai base) ─────────────────────

	# 1. BARIS BILIK ATAS (y=20..110)
	# Bilik kiri biasa (x=25..370)
	for i in range(6):
		draw_rect(Rect2(25 + i * 57, 20, 50, 88), COLOR_STALL, true)
	# Bilik Tetangga Gemetar (biru muda, x=370..455 tapi di atas jalan, jadi di sisi lain)
	# Letakkan Tetangga di x=360-455 atas
	draw_rect(Rect2(360, 20, 90, 88), COLOR_STALL_TETANGGA, true)
	draw_rect(Rect2(360, 20, 90, 5), Color(0.45, 0.72, 1.0, 0.9), true)
	# Rumah MC (ivory gold, x=460..560)
	draw_rect(Rect2(460, 20, 100, 88), COLOR_STALL_MC, true)
	draw_rect(Rect2(460, 20, 100, 5), Color(0.90, 0.70, 0.30, 0.9), true)
	# Bilik kanan biasa
	for i in range(24):
		var bx = 565.0 + i * 57.0
		if bx + 50 > X_RIGHT_WALL: break
		draw_rect(Rect2(bx, 20, 50, 88), COLOR_STALL, true)

	# 2. LAHAN KOSONG BERARSIR (x=25..370, y=220..680)
	draw_rect(Rect2(25, Y_COR_BOT, X_VROAD_L - 25, Y_MID_TOP - Y_COR_BOT), COLOR_LAHAN_BG, true)
	for k in range(-15, 25):
		var p1 = Vector2(25.0 + k * 30.0, float(Y_COR_BOT))
		var p2 = Vector2(25.0 + k * 30.0 + 460.0, float(Y_MID_TOP))
		_clipped_line(p1, p2, Rect2(25, Y_COR_BOT, 345, Y_MID_TOP - Y_COR_BOT), COLOR_LAHAN_HATCH, 2.0)
	# 2 kotak kecil dalam arsiran (dari sketsa)
	draw_rect(Rect2(40, 530, 100, 100), Color(0.20, 0.24, 0.30, 1.0), true)
	draw_rect(Rect2(40, 530, 100, 100), Color(0.35, 0.42, 0.52, 0.8), false, 2.0)
	draw_rect(Rect2(40, 650, 100, 100), Color(0.20, 0.24, 0.30, 1.0), true)  # Kotak kedua di bawah

	# 3. KANTOR POLISI (x=25..370, y=770..1210)
	draw_rect(Rect2(25, Y_MID_BOT, X_VROAD_L - 25, Y_LOOP_TOP - Y_MID_BOT), COLOR_POLISI_BG, true)
	draw_rect(Rect2(25, Y_MID_BOT, 8, Y_LOOP_TOP - Y_MID_BOT), COLOR_POLISI_STRIPE, true)
	draw_rect(Rect2(25, Y_MID_BOT, X_VROAD_L - 25, 8), COLOR_POLISI_STRIPE, true)
	_draw_desk(Rect2(50, 820, 270, 110))
	_draw_desk(Rect2(50, 1000, 270, 120))
	# Sel tahanan (L-shape kanan bawah Kantor Polisi)
	draw_rect(Rect2(250, 1075, 110, 125), Color(0.10, 0.12, 0.18, 1.0), true)
	for barx in range(256, 360, 14):
		draw_line(Vector2(barx, 1075), Vector2(barx, 1200), Color(0.55, 0.62, 0.74), 2.0)

	# 4. 5 GEDUNG (x=455..970, y=220..680) — bertumpuk vertikal
	var gW = X_GANG_L - X_VROAD_R  # lebar = 515px
	var gH = 88.0
	var gGap = 4.0
	for gi in range(5):
		var gy = float(Y_COR_BOT) + gi * (gH + gGap)
		draw_rect(Rect2(X_VROAD_R, gy, gW, gH), COLOR_GEDUNG_BG, true)
		draw_rect(Rect2(X_VROAD_R, gy, gW, gH), COLOR_WALL, false, 2.0)
		for wi in range(4):
			draw_rect(Rect2(X_VROAD_R + 100 + wi * 90, gy + 22, 40, 28), COLOR_GEDUNG_WIN, true)
			draw_rect(Rect2(X_VROAD_R + 100 + wi * 90, gy + 22, 40, 28), Color(0.2, 0.3, 0.45), false, 1.5)
		# Pintu kecil kanan (menghadap Gang Kecil)
		draw_rect(Rect2(X_GANG_L - 14, gy + 28, 14, 36), COLOR_ROAD_VERT, true)
		# Pintu kecil kiri (menghadap Jalan Vertikal Barat)
		draw_rect(Rect2(X_VROAD_R, gy + 28, 14, 36), COLOR_ROAD_VERT, true)

	# 5. RUMAH SAKIT (x=455..970, y=770..1210)
	draw_rect(Rect2(X_VROAD_R, Y_MID_BOT, gW, Y_LOOP_TOP - Y_MID_BOT), COLOR_RS_BG, true)
	# Tanda palang merah
	draw_rect(Rect2(700, 792, 30, 90), COLOR_RS_CROSS, true)
	draw_rect(Rect2(668, 822, 92, 30), COLOR_RS_CROSS, true)
	for row in range(3):
		for col in range(2):
			var bedx = float(X_VROAD_R) + 50.0 + col * 220.0
			var bedy = 890.0 + row * 100.0
			draw_rect(Rect2(bedx, bedy, 160, 68), Color(0.90, 0.96, 0.98, 1.0), true)
			draw_rect(Rect2(bedx, bedy, 160, 68), Color(0.60, 0.80, 0.86, 0.8), false, 1.5)
			draw_rect(Rect2(bedx, bedy, 32, 68), Color(0.70, 0.88, 0.93, 1.0), true)

	# 6. BLOK TENGAH BESAR (x=1055..1480, y=220..680)
	var bTW = X_VROAD2_L - X_GANG_R
	draw_rect(Rect2(X_GANG_R, Y_COR_BOT, bTW, Y_MID_TOP - Y_COR_BOT), COLOR_BLOK_TENGAH, true)
	for row in range(4):
		for col in range(4):
			var wx = float(X_GANG_R) + 55.0 + col * 105.0
			var wy = float(Y_COR_BOT) + 50.0 + row * 105.0
			draw_rect(Rect2(wx, wy, 58, 45), COLOR_BLOK_WIN, true)
			draw_rect(Rect2(wx, wy, 58, 45), Color(0.2, 0.3, 0.45), false, 1.5)

	# 7. BLOK EKSPLORASI & "P" Rooms (x=1055..1480, y=770..1210)
	draw_rect(Rect2(X_GANG_R, Y_MID_BOT, bTW, Y_LOOP_TOP - Y_MID_BOT), COLOR_EKSPLORASI_BG, true)
	# Deretan "D"-shape bilik seperti di sketsa: kiri dan kanan
	for d in range(5):
		var dy = float(Y_MID_BOT) + 20.0 + d * 84.0
		if dy + 60 > Y_LOOP_TOP: break
		draw_rect(Rect2(X_GANG_R + 10, dy, 60, 60), Color(0.82, 0.85, 0.90), true)
		draw_rect(Rect2(X_GANG_R + 10, dy, 60, 60), COLOR_WALL, false, 1.8)
		draw_rect(Rect2(X_VROAD2_L - 70, dy, 60, 60), Color(0.82, 0.85, 0.90), true)
		draw_rect(Rect2(X_VROAD2_L - 70, dy, 60, 60), COLOR_WALL, false, 1.8)
	# "Rumah Eksplorasi" label area di bawah blok
	draw_rect(Rect2(X_GANG_R + 100, 900, bTW - 200, 290), Color(0.84, 0.80, 0.90, 1.0), true)
	draw_rect(Rect2(X_GANG_R + 100, 900, bTW - 200, 290), Color(0.50, 0.42, 0.65), false, 2.0)

	# 8. BLOK KANAN ATAS 4 Ruangan Grid (x=1560..1990, y=220..680)
	var bKW = X_RIGHT_WALL - X_VROAD2_R
	draw_rect(Rect2(X_VROAD2_R, Y_COR_BOT, bKW, Y_MID_TOP - Y_COR_BOT), COLOR_BLOK_KANAN_BG, true)
	# Dua koridor salib membagi 4 ruangan
	draw_line(Vector2(X_VROAD2_R + bKW/2.0, Y_COR_BOT), Vector2(X_VROAD2_R + bKW/2.0, Y_MID_TOP), COLOR_ROAD_BLUE, 20.0)
	draw_line(Vector2(X_VROAD2_R, Y_COR_BOT + (Y_MID_TOP - Y_COR_BOT)/2.0), Vector2(X_RIGHT_WALL, Y_COR_BOT + (Y_MID_TOP - Y_COR_BOT)/2.0), COLOR_ROAD_BLUE, 20.0)
	_draw_desk(Rect2(X_VROAD2_R + 30, Y_COR_BOT + 40, 185, 120))
	_draw_desk(Rect2(X_VROAD2_R + bKW/2.0 + 30, Y_COR_BOT + 40, 185, 120))
	_draw_desk(Rect2(X_VROAD2_R + 30, Y_COR_BOT + (Y_MID_TOP-Y_COR_BOT)/2.0 + 30, 185, 120))
	_draw_desk(Rect2(X_VROAD2_R + bKW/2.0 + 30, Y_COR_BOT + (Y_MID_TOP-Y_COR_BOT)/2.0 + 30, 185, 120))

	# 9. STASIUN / SANCTUARY DEWA KEMATIAN (x=1560..1990, y=770..1210)
	draw_rect(Rect2(X_VROAD2_R, Y_MID_BOT, bKW, Y_LOOP_TOP - Y_MID_BOT), COLOR_SANCTUARY_BG, true)
	draw_rect(Rect2(X_VROAD2_R + 60, Y_MID_BOT + 60, bKW - 120, Y_LOOP_TOP - Y_MID_BOT - 120), COLOR_SANCTUARY_RUG, true)
	draw_circle(Vector2(X_VROAD2_R + bKW/2.0, 990.0), 115.0, COLOR_RUNE_GLOW)
	draw_circle(Vector2(X_VROAD2_R + bKW/2.0, 990.0), 70.0, Color(0.85, 0.35, 1.0, 0.25))
	# Karpet pintu masuk barat
	draw_rect(Rect2(X_VROAD2_L, 930, X_VROAD2_R - X_VROAD2_L + 10, 120), COLOR_SANCTUARY_RUG, true)

	# ── B. GAMBAR JALAN RAYA (Di atas ruangan) ───────────────────────────────

	# 1. JALAN UTAMA ATAS (y=110..220) – Velvet Burgundy full lebar
	draw_rect(Rect2(X_LEFT_WALL, Y_COR_TOP, X_RIGHT_WALL - X_LEFT_WALL, Y_COR_BOT - Y_COR_TOP), COLOR_ROAD_TOP, true)
	draw_line(Vector2(X_LEFT_WALL, Y_COR_TOP + 4), Vector2(X_RIGHT_WALL, Y_COR_TOP + 4), COLOR_ROAD_TRIM_TOP, 2.5)
	draw_line(Vector2(X_LEFT_WALL, Y_COR_BOT - 4), Vector2(X_RIGHT_WALL, Y_COR_BOT - 4), COLOR_ROAD_TRIM_TOP, 2.5)

	# 2. JALAN VERTIKAL BARAT (x=370..455, y=110..1210)
	draw_rect(Rect2(X_VROAD_L, Y_COR_TOP, X_VROAD_R - X_VROAD_L, Y_LOOP_TOP - Y_COR_TOP), COLOR_ROAD_VERT, true)
	draw_line(Vector2(X_VROAD_L + 2, Y_COR_TOP), Vector2(X_VROAD_L + 2, Y_LOOP_TOP), COLOR_ROAD_TRIM_BLUE, 1.8)
	draw_line(Vector2(X_VROAD_R - 2, Y_COR_TOP), Vector2(X_VROAD_R - 2, Y_LOOP_TOP), COLOR_ROAD_TRIM_BLUE, 1.8)
	# Marka kotak putus-putus
	for my in range(Y_COR_BOT + 20, Y_LOOP_TOP, 50):
		draw_rect(Rect2(X_VROAD_L + 14, my, 14, 24), COLOR_ROAD_VERT_MARK, true)

	# 3. GANG KECIL (x=970..1055, y=110..1210) – Gelap Misterius
	draw_rect(Rect2(X_GANG_L, Y_COR_TOP, X_GANG_R - X_GANG_L, Y_LOOP_TOP - Y_COR_TOP), COLOR_GANG_KECIL, true)
	draw_line(Vector2(X_GANG_L + 3, Y_COR_TOP), Vector2(X_GANG_L + 3, Y_LOOP_TOP), COLOR_GANG_TRIM, 2.0)
	draw_line(Vector2(X_GANG_R - 3, Y_COR_TOP), Vector2(X_GANG_R - 3, Y_LOOP_TOP), COLOR_GANG_TRIM, 2.0)
	for gy2 in range(Y_COR_BOT + 12, Y_LOOP_TOP, 22):
		draw_line(Vector2(X_GANG_L + 6, gy2), Vector2(X_GANG_R - 6, gy2), Color(0.28, 0.22, 0.44, 0.5), 1.5)

	# 4. JALAN VERTIKAL TIMUR (x=1480..1560, y=110..1210)
	draw_rect(Rect2(X_VROAD2_L, Y_COR_TOP, X_VROAD2_R - X_VROAD2_L, Y_LOOP_TOP - Y_COR_TOP), COLOR_ROAD_VERT, true)
	draw_line(Vector2(X_VROAD2_L + 2, Y_COR_TOP), Vector2(X_VROAD2_L + 2, Y_LOOP_TOP), COLOR_ROAD_TRIM_BLUE, 1.8)
	draw_line(Vector2(X_VROAD2_R - 2, Y_COR_TOP), Vector2(X_VROAD2_R - 2, Y_LOOP_TOP), COLOR_ROAD_TRIM_BLUE, 1.8)
	for my2 in range(Y_COR_BOT + 20, Y_LOOP_TOP, 50):
		draw_rect(Rect2(X_VROAD2_L + 14, my2, 14, 24), COLOR_ROAD_VERT_MARK, true)

	# 5. JALAN TENGAH (y=680..770) – Royal Blue, full lebar
	draw_rect(Rect2(X_LEFT_WALL, Y_MID_TOP, X_RIGHT_WALL - X_LEFT_WALL, Y_MID_BOT - Y_MID_TOP), COLOR_ROAD_BLUE, true)
	draw_line(Vector2(X_LEFT_WALL, Y_MID_TOP + 4), Vector2(X_RIGHT_WALL, Y_MID_TOP + 4), COLOR_ROAD_TRIM_BLUE, 2.5)
	draw_line(Vector2(X_LEFT_WALL, Y_MID_BOT - 4), Vector2(X_RIGHT_WALL, Y_MID_BOT - 4), COLOR_ROAD_TRIM_BLUE, 2.5)

	# 6. JALAN LINGKAR BAWAH (y=1210..1330) – Royal Blue
	draw_rect(Rect2(X_LEFT_WALL, Y_LOOP_TOP, X_RIGHT_WALL - X_LEFT_WALL, Y_LOOP_BOT - Y_LOOP_TOP), COLOR_ROAD_BLUE, true)
	draw_line(Vector2(X_LEFT_WALL, Y_LOOP_TOP + 4), Vector2(X_RIGHT_WALL, Y_LOOP_TOP + 4), COLOR_ROAD_TRIM_BLUE, 3.0)
	draw_line(Vector2(X_LEFT_WALL, Y_LOOP_BOT - 4), Vector2(X_RIGHT_WALL, Y_LOOP_BOT - 4), COLOR_ROAD_TRIM_BLUE, 3.0)
	for mx in range(50, 1990, 60):
		draw_line(Vector2(mx, (Y_LOOP_TOP + Y_LOOP_BOT)/2.0), Vector2(mx + 36, (Y_LOOP_TOP + Y_LOOP_BOT)/2.0), Color(0.85, 0.95, 1.0, 0.45), 2.5)

	# 7. PLAZA PERSIMPANGAN JALAN
	_draw_plaza(Vector2(X_VROAD_L + (X_VROAD_R - X_VROAD_L)/2.0, (Y_COR_TOP + Y_COR_BOT)/2.0), 42.0)
	_draw_plaza(Vector2(X_GANG_L + (X_GANG_R - X_GANG_L)/2.0, (Y_COR_TOP + Y_COR_BOT)/2.0), 38.0)
	_draw_plaza(Vector2(X_VROAD2_L + (X_VROAD2_R - X_VROAD2_L)/2.0, (Y_COR_TOP + Y_COR_BOT)/2.0), 42.0)
	_draw_plaza(Vector2(X_VROAD_L + (X_VROAD_R - X_VROAD_L)/2.0, (Y_MID_TOP + Y_MID_BOT)/2.0), 42.0)
	_draw_plaza(Vector2(X_GANG_L + (X_GANG_R - X_GANG_L)/2.0, (Y_MID_TOP + Y_MID_BOT)/2.0), 38.0)
	_draw_plaza(Vector2(X_VROAD2_L + (X_VROAD2_R - X_VROAD2_L)/2.0, (Y_MID_TOP + Y_MID_BOT)/2.0), 42.0)
	_draw_plaza(Vector2(X_VROAD_L + (X_VROAD_R - X_VROAD_L)/2.0, (Y_LOOP_TOP + Y_LOOP_BOT)/2.0), 50.0)
	_draw_plaza(Vector2(X_GANG_L + (X_GANG_R - X_GANG_L)/2.0, (Y_LOOP_TOP + Y_LOOP_BOT)/2.0), 45.0)
	_draw_plaza(Vector2(X_VROAD2_L + (X_VROAD2_R - X_VROAD2_L)/2.0, (Y_LOOP_TOP + Y_LOOP_BOT)/2.0), 50.0)

	# ── C. REL KERETA SISI KANAN ──────────────────────────────────────────────
	draw_rect(Rect2(X_TRACK_L, 15, X_TRACK_R - X_TRACK_L, Y_LOOP_BOT), COLOR_TRACK_BG, true)
	draw_line(Vector2(X_TRACK_L + 15, 15), Vector2(X_TRACK_L + 15, Y_LOOP_BOT), COLOR_TRACK_RAIL, 3.5)
	draw_line(Vector2(X_TRACK_R - 15, 15), Vector2(X_TRACK_R - 15, Y_LOOP_BOT), COLOR_TRACK_RAIL, 3.5)
	for ty in range(20, Y_LOOP_BOT, 15):
		draw_line(Vector2(X_TRACK_L + 6, ty), Vector2(X_TRACK_R - 6, ty), COLOR_TRACK_TIE, 3.0)

	# ── D. DINDING & PINTU ───────────────────────────────────────────────────
	# Batas luar
	draw_line(Vector2(20, 15), Vector2(X_RIGHT_WALL, 15), COLOR_WALL, WT)
	draw_line(Vector2(20, Y_LOOP_BOT), Vector2(X_RIGHT_WALL, Y_LOOP_BOT), COLOR_WALL, WT)
	draw_line(Vector2(20, 15), Vector2(20, Y_LOOP_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, Y_COR_TOP), Vector2(X_RIGHT_WALL, Y_LOOP_BOT), COLOR_WALL, WT)

	# Garis bawah bilik atas (di atas jalan atas, dengan celah di atas jalan vertikal)
	draw_line(Vector2(20, Y_COR_TOP), Vector2(X_VROAD_L, Y_COR_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_R, Y_COR_TOP), Vector2(X_GANG_L, Y_COR_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_R, Y_COR_TOP), Vector2(X_VROAD2_L, Y_COR_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_R, Y_COR_TOP), Vector2(X_RIGHT_WALL, Y_COR_TOP), COLOR_WALL, WT)

	# LAHAN KOSONG (x=25..370, y=220..680) — dinding kotak
	draw_line(Vector2(25, Y_COR_BOT), Vector2(X_VROAD_L, Y_COR_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_L, Y_COR_BOT), Vector2(X_VROAD_L, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_L, Y_MID_TOP), Vector2(25, Y_MID_TOP), COLOR_WALL, WT)

	# KANTOR POLISI (x=25..370, y=770..1210)
	# Pintu Atas (x=150..250), Pintu Timur (y=930..1030), Pintu Selatan (x=150..250)
	draw_line(Vector2(25, Y_MID_BOT), Vector2(155, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(255, Y_MID_BOT), Vector2(X_VROAD_L, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_L, Y_MID_BOT), Vector2(X_VROAD_L, 930), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_L, 1030), Vector2(X_VROAD_L, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_L, Y_LOOP_TOP), Vector2(255, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(155, Y_LOOP_TOP), Vector2(25, Y_LOOP_TOP), COLOR_WALL, WT)

	# 5 GEDUNG (x=455..970, y=220..680) — dinding luar
	draw_line(Vector2(X_VROAD_R, Y_COR_BOT), Vector2(X_GANG_L, Y_COR_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_L, Y_COR_BOT), Vector2(X_GANG_L, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_L, Y_MID_TOP), Vector2(X_VROAD_R, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_R, Y_MID_TOP), Vector2(X_VROAD_R, Y_COR_BOT), COLOR_WALL, WT)

	# RUMAH SAKIT (x=455..970, y=770..1210)
	draw_line(Vector2(X_VROAD_R, Y_MID_BOT), Vector2(580, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(680, Y_MID_BOT), Vector2(X_GANG_L, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_L, Y_MID_BOT), Vector2(X_GANG_L, 930), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_L, 1030), Vector2(X_GANG_L, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_L, Y_LOOP_TOP), Vector2(680, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(580, Y_LOOP_TOP), Vector2(X_VROAD_R, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_R, Y_LOOP_TOP), Vector2(X_VROAD_R, 1030), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD_R, 930), Vector2(X_VROAD_R, Y_MID_BOT), COLOR_WALL, WT)

	# BLOK TENGAH ATAS (x=1055..1480, y=220..680)
	draw_line(Vector2(X_GANG_R, Y_COR_BOT), Vector2(1130, Y_COR_BOT), COLOR_WALL, WT)
	draw_line(Vector2(1230, Y_COR_BOT), Vector2(X_VROAD2_L, Y_COR_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_L, Y_COR_BOT), Vector2(X_VROAD2_L, 380), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_L, 480), Vector2(X_VROAD2_L, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_L, Y_MID_TOP), Vector2(1230, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(1130, Y_MID_TOP), Vector2(X_GANG_R, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_R, Y_MID_TOP), Vector2(X_GANG_R, 480), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_R, 380), Vector2(X_GANG_R, Y_COR_BOT), COLOR_WALL, WT)

	# BLOK BAWAH TENGAH (x=1055..1480, y=770..1210)
	draw_line(Vector2(X_GANG_R, Y_MID_BOT), Vector2(1130, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(1230, Y_MID_BOT), Vector2(X_VROAD2_L, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_L, Y_MID_BOT), Vector2(X_VROAD2_L, 930), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_L, 1030), Vector2(X_VROAD2_L, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_L, Y_LOOP_TOP), Vector2(1230, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(1130, Y_LOOP_TOP), Vector2(X_GANG_R, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_R, Y_LOOP_TOP), Vector2(X_GANG_R, 1030), COLOR_WALL, WT)
	draw_line(Vector2(X_GANG_R, 930), Vector2(X_GANG_R, Y_MID_BOT), COLOR_WALL, WT)

	# BLOK KANAN ATAS (x=1560..1990, y=220..680)
	draw_line(Vector2(X_VROAD2_R, Y_COR_BOT), Vector2(1660, Y_COR_BOT), COLOR_WALL, WT)
	draw_line(Vector2(1760, Y_COR_BOT), Vector2(X_RIGHT_WALL, Y_COR_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, Y_COR_BOT), Vector2(X_RIGHT_WALL, 380), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, 480), Vector2(X_RIGHT_WALL, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, Y_MID_TOP), Vector2(1760, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(1660, Y_MID_TOP), Vector2(X_VROAD2_R, Y_MID_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_R, Y_MID_TOP), Vector2(X_VROAD2_R, 480), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_R, 380), Vector2(X_VROAD2_R, Y_COR_BOT), COLOR_WALL, WT)

	# SANCTUARY (x=1560..1990, y=770..1210) PINTU UTAMA BARAT y=900..1060
	draw_line(Vector2(X_VROAD2_R, Y_MID_BOT), Vector2(1650, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(1750, Y_MID_BOT), Vector2(X_RIGHT_WALL, Y_MID_BOT), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, Y_MID_BOT), Vector2(X_RIGHT_WALL, 930), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, 1050), Vector2(X_RIGHT_WALL, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_RIGHT_WALL, Y_LOOP_TOP), Vector2(1750, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(1650, Y_LOOP_TOP), Vector2(X_VROAD2_R, Y_LOOP_TOP), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_R, Y_LOOP_TOP), Vector2(X_VROAD2_R, 1050), COLOR_WALL, WT)
	draw_line(Vector2(X_VROAD2_R, 900), Vector2(X_VROAD2_R, Y_MID_BOT), COLOR_WALL, WT)

# ── Helper ────────────────────────────────────────────────────────────────────
func _clipped_line(p1: Vector2, p2: Vector2, clip: Rect2, color: Color, w: float) -> void:
	var dir = (p2 - p1).normalized()
	var len = p1.distance_to(p2)
	var step = 8.0
	var s = 0.0
	while s < len:
		var a = p1 + dir * s
		var b = p1 + dir * minf(s + step, len)
		if clip.has_point(a) and clip.has_point(b):
			draw_line(a, b, color, w)
		s += step

func _draw_plaza(center: Vector2, r: float) -> void:
	draw_circle(center, r, COLOR_PLAZA)
	draw_circle(center, r * 0.58, Color(0.6, 0.8, 1.0, 0.3))
	draw_arc(center, r, 0.0, TAU, 24, COLOR_ROAD_TRIM_BLUE, 1.5)

func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.14), true)
	draw_rect(rect, COLOR_DESK, true)
	draw_rect(rect, COLOR_DESK_EDGE, false, 1.8)
	if rect.size.x >= 50 and rect.size.y >= 38:
		var c = rect.position + rect.size / 2.0
		draw_rect(Rect2(c.x - 13, c.y - 12, 26, 10), Color(0.2, 0.25, 0.32), true)

# ── Collision Builder ─────────────────────────────────────────────────────────
func _build_all_colliders() -> void:
	for b in collision_bodies:
		if is_instance_valid(b): b.queue_free()
	collision_bodies.clear()

	# Batas luar
	_W(Rect2(0, 0, 2110, 20))
	_W(Rect2(0, Y_LOOP_BOT - 4, 2110, 24))
	_W(Rect2(0, 0, 22, 1350))
	_W(Rect2(X_RIGHT_WALL - 4, Y_COR_TOP, 8, Y_LOOP_BOT - Y_COR_TOP))

	# Bawah bilik atas (4 segmen dengan celah di jalan vertikal)
	_W(Rect2(20, Y_COR_TOP - 3, X_VROAD_L - 20, 6))
	_W(Rect2(X_VROAD_R, Y_COR_TOP - 3, X_GANG_L - X_VROAD_R, 6))
	_W(Rect2(X_GANG_R, Y_COR_TOP - 3, X_VROAD2_L - X_GANG_R, 6))
	_W(Rect2(X_VROAD2_R, Y_COR_TOP - 3, X_RIGHT_WALL - X_VROAD2_R, 6))

	# Lahan Kosong
	_W(Rect2(25, Y_COR_BOT - 3, X_VROAD_L - 25, 6))
	_W(Rect2(X_VROAD_L - 4, Y_COR_BOT, 6, Y_MID_TOP - Y_COR_BOT))
	_W(Rect2(25, Y_MID_TOP - 3, X_VROAD_L - 25, 6))

	# Kantor Polisi
	_W(Rect2(25, Y_MID_BOT - 3, 130, 6))
	_W(Rect2(255, Y_MID_BOT - 3, X_VROAD_L - 255, 6))
	_W(Rect2(X_VROAD_L - 4, Y_MID_BOT, 6, 160))
	_W(Rect2(X_VROAD_L - 4, 1030, 6, Y_LOOP_TOP - 1030))
	_W(Rect2(255, Y_LOOP_TOP - 3, X_VROAD_L - 255, 6))
	_W(Rect2(25, Y_LOOP_TOP - 3, 130, 6))
	_W(Rect2(50, 820, 270, 110))
	_W(Rect2(50, 1000, 270, 120))

	# 5 Gedung
	_W(Rect2(X_VROAD_R, Y_COR_BOT - 3, X_GANG_L - X_VROAD_R, 6))
	_W(Rect2(X_GANG_L - 4, Y_COR_BOT, 6, Y_MID_TOP - Y_COR_BOT))
	_W(Rect2(X_VROAD_R, Y_MID_TOP - 3, X_GANG_L - X_VROAD_R, 6))
	_W(Rect2(X_VROAD_R - 4, Y_COR_BOT, 6, Y_MID_TOP - Y_COR_BOT))

	# Rumah Sakit
	_W(Rect2(X_VROAD_R, Y_MID_BOT - 3, 125, 6))
	_W(Rect2(680, Y_MID_BOT - 3, X_GANG_L - 680, 6))
	_W(Rect2(X_GANG_L - 4, Y_MID_BOT, 6, 160))
	_W(Rect2(X_GANG_L - 4, 1030, 6, Y_LOOP_TOP - 1030))
	_W(Rect2(680, Y_LOOP_TOP - 3, X_GANG_L - 680, 6))
	_W(Rect2(X_VROAD_R, Y_LOOP_TOP - 3, 125, 6))
	_W(Rect2(X_VROAD_R - 4, 1030, 6, Y_LOOP_TOP - 1030))
	_W(Rect2(X_VROAD_R - 4, Y_MID_BOT, 6, 160))

	# Blok Tengah Atas
	_W(Rect2(X_GANG_R, Y_COR_BOT - 3, 75, 6))
	_W(Rect2(1230, Y_COR_BOT - 3, X_VROAD2_L - 1230, 6))
	_W(Rect2(X_VROAD2_L - 4, Y_COR_BOT, 6, 160))
	_W(Rect2(X_VROAD2_L - 4, 480, 6, Y_MID_TOP - 480))
	_W(Rect2(1230, Y_MID_TOP - 3, X_VROAD2_L - 1230, 6))
	_W(Rect2(X_GANG_R, Y_MID_TOP - 3, 75, 6))
	_W(Rect2(X_GANG_R - 4, 480, 6, Y_MID_TOP - 480))
	_W(Rect2(X_GANG_R - 4, Y_COR_BOT, 6, 160))

	# Blok Bawah Tengah
	_W(Rect2(X_GANG_R, Y_MID_BOT - 3, 75, 6))
	_W(Rect2(1230, Y_MID_BOT - 3, X_VROAD2_L - 1230, 6))
	_W(Rect2(X_VROAD2_L - 4, Y_MID_BOT, 6, 160))
	_W(Rect2(X_VROAD2_L - 4, 1030, 6, Y_LOOP_TOP - 1030))
	_W(Rect2(1230, Y_LOOP_TOP - 3, X_VROAD2_L - 1230, 6))
	_W(Rect2(X_GANG_R, Y_LOOP_TOP - 3, 75, 6))
	_W(Rect2(X_GANG_R - 4, 1030, 6, Y_LOOP_TOP - 1030))
	_W(Rect2(X_GANG_R - 4, Y_MID_BOT, 6, 160))

	# Blok Kanan Atas
	_W(Rect2(X_VROAD2_R, Y_COR_BOT - 3, 100, 6))
	_W(Rect2(1760, Y_COR_BOT - 3, X_RIGHT_WALL - 1760, 6))
	_W(Rect2(X_RIGHT_WALL - 4, Y_COR_BOT, 6, 160))
	_W(Rect2(X_RIGHT_WALL - 4, 480, 6, Y_MID_TOP - 480))
	_W(Rect2(1760, Y_MID_TOP - 3, X_RIGHT_WALL - 1760, 6))
	_W(Rect2(X_VROAD2_R, Y_MID_TOP - 3, 100, 6))
	_W(Rect2(X_VROAD2_R - 4, 480, 6, Y_MID_TOP - 480))
	_W(Rect2(X_VROAD2_R - 4, Y_COR_BOT, 6, 160))
	_W(Rect2(1560 + 30, Y_COR_BOT + 40, 185, 120))
	_W(Rect2(1560 + 30 + 220, Y_COR_BOT + 40, 185, 120))
	_W(Rect2(1560 + 30, Y_COR_BOT + 270, 185, 120))
	_W(Rect2(1560 + 30 + 220, Y_COR_BOT + 270, 185, 120))

	# Sanctuary / Stasiun
	_W(Rect2(X_VROAD2_R, Y_MID_BOT - 3, 90, 6))
	_W(Rect2(1750, Y_MID_BOT - 3, X_RIGHT_WALL - 1750, 6))
	_W(Rect2(X_RIGHT_WALL - 4, Y_MID_BOT, 6, 160))
	_W(Rect2(X_RIGHT_WALL - 4, 1050, 6, Y_LOOP_TOP - 1050))
	_W(Rect2(1750, Y_LOOP_TOP - 3, X_RIGHT_WALL - 1750, 6))
	_W(Rect2(X_VROAD2_R, Y_LOOP_TOP - 3, 90, 6))
	_W(Rect2(X_VROAD2_R - 4, 1050, 6, Y_LOOP_TOP - 1050))
	_W(Rect2(X_VROAD2_R - 4, Y_MID_BOT, 6, 160))

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
