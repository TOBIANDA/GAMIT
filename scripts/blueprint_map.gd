extends Node2D

# ── Blueprint Map v6 – Presisi 100% Sesuai Sketsa Tangan Buku Catatan ─────────
# Struktur Kolom & Baris (Berdasarkan Sketsa):
# 
# 1. BARIS ATAS (y=20..110):
#    - Deretan rumah/bilik: [][][][] [Tetangga yg gemeter] [Rumah MC] [][][][][][][]
# 
# 2. JALAN UTAMA ATAS (y=110..220)
# 
# 3. AREA KIRI (x=25..380):
#    - Atas: LAHAN KOSONG (Diarsir diagonal miring tebal)
#    - Bawah: KANTOR POLISI (dengan meja dan ruang sel)
# 
# 4. JALAN VERTIKAL UTAMA (x=380..470, y=110..1330):
#    - Jalan vertikal bergaris marka membelah kiri dan tengah
# 
# 5. KOLOM 2 (x=470..830):
#    - Atas: 5 GEDUNG BERTUMPUK VERTIKAL (Gedung 1 s/d 5)
#    - Bawah: RUMAH SAKIT (di bawah Gedung, dengan ranjang medis)
# 
# 6. KOLOM 3 (x=850..1330):
#    - Atas: BLOK TENGAH BESAR
#    - Bawah: BLOK EKSPLORASI & RUMAH EKSPLORASI (dengan deretan bilik D)
# 
# 7. GANG KECIL (x=1330..1410, y=110..1330):
#    - Lorong vertikal sempit misterius "GANG KECIL"
# 
# 8. KOLOM 4 - KANAN (x=1410..1990):
#    - Atas: 4 RUANGAN GRID (2x2)
#    - Bawah: STASIUN & SANCTUARY DEWA KEMATIAN
# 
# 9. REL KERETA (x=2020..2100, y=20..1330)
# 10. JALAN LINGKAR BAWAH (y=1210..1330)

# ── Palet Warna ───────────────────────────────────────────────────────────────
const COLOR_VOID           = Color(0.06, 0.08, 0.11, 1.0)
const COLOR_BASE_GROUND    = Color(0.18, 0.21, 0.27, 1.0)
const COLOR_GRID           = Color(0.25, 0.30, 0.38, 0.3)

# Jalur & Jalan
const COLOR_ROAD_TOP       = Color(0.35, 0.16, 0.22, 1.0) # Velvet Burgundy
const COLOR_ROAD_TOP_TRIM  = Color(0.85, 0.65, 0.30, 0.85)# Lis Emas
const COLOR_ROAD_MAIN      = Color(0.20, 0.29, 0.42, 1.0) # Royal Blue Highway
const COLOR_ROAD_TRIM      = Color(0.40, 0.65, 0.88, 0.8) # Lis Biru Neon
const COLOR_ROAD_VERT      = Color(0.23, 0.27, 0.35, 1.0) # Jalan Vertikal Barat
const COLOR_GANG_KECIL     = Color(0.11, 0.13, 0.17, 1.0) # Gang Kecil Gelap
const COLOR_GANG_TRIM      = Color(0.60, 0.45, 0.85, 0.7) # Lis Ungu Gang
const COLOR_PLAZA          = Color(0.26, 0.37, 0.50, 1.0) # Simpang Jalan

# Ruangan Tematik
const COLOR_STALL_NORMAL   = Color(0.88, 0.92, 0.88, 1.0)
const COLOR_STALL_TETANGGA = Color(0.80, 0.86, 0.92, 1.0) # Rumah Tetangga Gemetar
const COLOR_STALL_MC       = Color(0.96, 0.90, 0.80, 1.0) # Rumah MC
const COLOR_LAHAN_BG       = Color(0.13, 0.16, 0.20, 1.0) # Lahan Kosong Hitam Arsir
const COLOR_LAHAN_HATCH    = Color(0.32, 0.38, 0.48, 0.8) # Garis Arsir Diagonal Tebal
const COLOR_GEDUNG_BG      = Color(0.84, 0.89, 0.95, 1.0) # 5 Gedung
const COLOR_GEDUNG_WINDOW  = Color(0.45, 0.68, 0.88, 0.9)
const COLOR_POLISI_BG      = Color(0.16, 0.22, 0.38, 1.0) # Kantor Polisi Navy
const COLOR_POLISI_TRIM    = Color(0.45, 0.65, 0.95, 0.8)
const COLOR_RS_BG          = Color(0.94, 0.97, 0.97, 1.0) # RS Putih Medis
const COLOR_RS_CROSS       = Color(0.85, 0.25, 0.25, 0.9) # Palang Merah
const COLOR_BLOK_TENGAH    = Color(0.92, 0.94, 0.90, 1.0)
const COLOR_EKSPLORASI_BG  = Color(0.88, 0.85, 0.92, 1.0) # Rumah Eksplorasi
const COLOR_STASIUN_BG     = Color(0.14, 0.08, 0.20, 1.0) # Stasiun / Sanctuary Ungu
const COLOR_SANCTUARY_RUG  = Color(0.25, 0.12, 0.36, 1.0)
const COLOR_RUNE_GLOW      = Color(0.70, 0.30, 0.98, 0.40)

# Dinding & Detail
const COLOR_WALL           = Color(0.08, 0.10, 0.14, 1.0)
const COLOR_DESK           = Color(0.75, 0.80, 0.86, 1.0)
const COLOR_DESK_LINE      = Color(0.20, 0.24, 0.30, 1.0)

# Rel Kereta
const COLOR_TRACK_BG       = Color(0.72, 0.75, 0.80, 1.0)
const COLOR_TRACK_RAIL     = Color(0.20, 0.23, 0.30, 1.0)
const COLOR_TRACK_TIE      = Color(0.42, 0.35, 0.28, 1.0)

const WT = 6.0 # Wall Thickness
var collision_bodies: Array[StaticBody2D] = []

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ─────────────────────────────────────────────────────────────────────────────
func _draw() -> void:
	# 0. Void luar peta
	draw_rect(Rect2(-200, -200, 2600, 1800), COLOR_VOID, true)

	# 1. Base lantai area bermain
	draw_rect(Rect2(20, 15, 2090, 1315), COLOR_BASE_GROUND, true)

	# Grid Arsitektur
	for gx in range(40, 2120, 40):
		draw_line(Vector2(gx, 15), Vector2(gx, 1330), COLOR_GRID, 1.0)
	for gy in range(20, 1330, 40):
		draw_line(Vector2(20, gy), Vector2(2110, gy), COLOR_GRID, 1.0)

	# ── A. GAMBAR LANTAI RUANGAN-RUANGAN (BASE) ──────────────────────────────

	# 1. DERETAN BILIK / RUMAH ATAS (y=20..110)
	# Sisi Kiri (x=25..380): 6 Bilik
	for i in range(6):
		var bx = 25.0 + i * 58.0
		draw_rect(Rect2(bx, 20, 52, 90), COLOR_STALL_NORMAL, true)

	# Sisi Tengah Atas (x=380..520): Rumah Tetangga yg gemeter
	draw_rect(Rect2(385, 20, 75, 90), COLOR_STALL_TETANGGA, true)
	draw_rect(Rect2(385, 20, 75, 6), Color(0.4, 0.7, 1.0, 0.9), true)

	# Rumah MC (x=465..550): Pas di atas pintu masuk Jalan Vertikal
	draw_rect(Rect2(465, 20, 80, 90), COLOR_STALL_MC, true)
	draw_rect(Rect2(465, 20, 80, 6), Color(0.9, 0.7, 0.3, 0.9), true)

	# Sisi Kanan Atas (x=550..1990): 23 Bilik berjejer sampai kanan
	for i in range(24):
		var bx = 555.0 + i * 60.0
		if bx + 52 > 1990: break
		draw_rect(Rect2(bx, 20, 52, 90), COLOR_STALL_NORMAL, true)

	# 2. KOLOM 1 KIRI (x=25..380)
	# Atas: LAHAN KOSONG BERARSIR (x=25..380, y=220..680)
	draw_rect(Rect2(25, 220, 355, 460), COLOR_LAHAN_BG, true)
	# Arsiran miring tebal sesuai sketsa tangan
	for k in range(-15, 30):
		var p1 = Vector2(25.0 + k * 28.0, 220.0)
		var p2 = Vector2(25.0 + k * 28.0 + 350.0, 570.0)
		_draw_clipped_line(p1, p2, Rect2(25, 220, 355, 460), COLOR_LAHAN_HATCH, 2.0)

	# Kotak kecil diarsir di bawah lahan (seperti di sketsa)
	draw_rect(Rect2(35, 540, 120, 120), Color(0.18, 0.22, 0.28, 1.0), true)
	draw_rect(Rect2(35, 540, 120, 120), COLOR_LAHAN_HATCH, false, 2.0)

	# Bawah: KANTOR POLISI (x=25..380, y=770..1210)
	draw_rect(Rect2(25, 770, 355, 440), COLOR_POLISI_BG, true)
	draw_rect(Rect2(25, 770, 355, 8), COLOR_POLISI_TRIM, true)
	draw_rect(Rect2(25, 770, 8, 440), COLOR_POLISI_TRIM, true)
	_draw_desk(Rect2(50, 820, 240, 100))
	_draw_desk(Rect2(50, 990, 240, 120))
	# Sel tahanan kecil di sudut
	draw_rect(Rect2(270, 1070, 100, 130), Color(0.10, 0.12, 0.18), true)
	for bar_x in range(275, 370, 15):
		draw_line(Vector2(bar_x, 1070), Vector2(bar_x, 1200), Color(0.6, 0.65, 0.75), 2.0)

	# 3. KOLOM 2 (x=470..830)
	# Atas: 5 GEDUNG BERTUMPUK VERTIKAL (y=220..680)
	var g_h = 88.0
	var g_gap = 4.0
	for gi in range(5):
		var gy = 220.0 + gi * (g_h + g_gap)
		draw_rect(Rect2(470, gy, 360, g_h), COLOR_GEDUNG_BG, true)
		draw_rect(Rect2(470, gy, 360, g_h), COLOR_WALL, false, 2.0)
		# Jendela gedung & pintu kecil di sisi kiri jalan vertikal
		for w in range(3):
			draw_rect(Rect2(580 + w * 70, gy + 20, 36, 26), COLOR_GEDUNG_WINDOW, true)
			draw_rect(Rect2(580 + w * 70, gy + 20, 36, 26), Color(0.2, 0.3, 0.4), false, 1.5)
		# Pintu gedung menghadap Jalan Vertikal (kiri)
		draw_rect(Rect2(470, gy + 25, 12, 38), COLOR_ROAD_VERT, true)

	# Bawah: RUMAH SAKIT (x=470..830, y=770..1210)
	draw_rect(Rect2(470, 770, 360, 440), COLOR_RS_BG, true)
	# Simbol Palang Merah Medis
	draw_rect(Rect2(635, 790, 30, 90), COLOR_RS_CROSS, true)
	draw_rect(Rect2(605, 820, 90, 30), COLOR_RS_CROSS, true)
	# Ranjang Pasien RS
	for row in range(3):
		for col in range(2):
			var bx2 = 500.0 + col * 170.0
			var by2 = 910.0 + row * 95.0
			draw_rect(Rect2(bx2, by2, 130, 65), Color(0.90, 0.96, 0.98), true)
			draw_rect(Rect2(bx2, by2, 130, 65), Color(0.60, 0.80, 0.85), false, 1.5)
			draw_rect(Rect2(bx2, by2, 28, 65), Color(0.70, 0.88, 0.92), true) # Bantal

	# 4. KOLOM 3 - TENGAH (x=850..1330)
	# Atas: BLOK TENGAH BESAR (y=220..680)
	draw_rect(Rect2(850, 220, 480, 460), COLOR_BLOK_TENGAH, true)
	# Grid meja/jendela blok tengah
	for row in range(4):
		for col in range(4):
			var wx2 = 885.0 + col * 110.0
			var wy2 = 255.0 + row * 105.0
			draw_rect(Rect2(wx2, wy2, 60, 45), COLOR_GEDUNG_WINDOW, true)
			draw_rect(Rect2(wx2, wy2, 60, 45), Color(0.2, 0.3, 0.4), false, 1.5)

	# Bawah: BLOK EKSPLORASI & RUMAH EKSPLORASI (x=850..1330, y=770..1210)
	draw_rect(Rect2(850, 770, 480, 440), COLOR_EKSPLORASI_BG, true)
	# Deretan Bilik D di sisi kiri dan kanan (sesuai sketsa: D D D D)
	for d in range(5):
		var dy = 785.0 + d * 82.0
		# D sisi kiri
		draw_rect(Rect2(860, dy, 55, 55), Color(0.80, 0.84, 0.90), true)
		draw_arc(Vector2(887, dy + 27), 24.0, -PI/2, PI/2, 16, Color(0.3, 0.35, 0.45), 2.0)
		# D sisi kanan
		draw_rect(Rect2(1260, dy, 55, 55), Color(0.80, 0.84, 0.90), true)
		draw_arc(Vector2(1287, dy + 27), 24.0, -PI/2, PI/2, 16, Color(0.3, 0.35, 0.45), 2.0)

	# Ruang-ruang tengah & RUMAH EKSPLORASI di bawah
	draw_rect(Rect2(935, 785, 305, 110), Color(0.92, 0.94, 0.96), true)
	draw_rect(Rect2(935, 915, 305, 110), Color(0.92, 0.94, 0.96), true)
	# RUMAH EKSPLORASI (Bawah)
	draw_rect(Rect2(935, 1045, 305, 150), Color(0.82, 0.78, 0.88), true)
	draw_rect(Rect2(935, 1045, 305, 150), Color(0.5, 0.4, 0.6), false, 2.0)

	# 5. KOLOM 4 - KANAN (x=1410..1990)
	# Atas: 4 RUANGAN GRID 2x2 (y=220..680)
	draw_rect(Rect2(1410, 220, 580, 460), COLOR_BLOK_TENGAH, true)
	# Koridor salib membagi 4 ruangan
	draw_line(Vector2(1700, 220), Vector2(1700, 680), COLOR_ROAD_MAIN, 18.0)
	draw_line(Vector2(1410, 450), Vector2(1990, 450), COLOR_ROAD_MAIN, 18.0)
	_draw_desk(Rect2(1450, 260, 200, 120))
	_draw_desk(Rect2(1740, 260, 200, 120))
	_draw_desk(Rect2(1450, 490, 200, 120))
	_draw_desk(Rect2(1740, 490, 200, 120))

	# Bawah: STASIUN / SANCTUARY DEWA KEMATIAN (x=1410..1990, y=770..1210)
	draw_rect(Rect2(1410, 770, 580, 440), COLOR_STASIUN_BG, true)
	draw_rect(Rect2(1480, 830, 440, 310), COLOR_SANCTUARY_RUG, true)
	draw_circle(Vector2(1700, 985), 115.0, COLOR_RUNE_GLOW)
	draw_circle(Vector2(1700, 985), 70.0, Color(0.85, 0.35, 1.0, 0.25))
	# Karpet jalan masuk
	draw_rect(Rect2(1380, 930, 90, 110), COLOR_SANCTUARY_RUG, true) # Pintu Barat
	draw_rect(Rect2(1630, 735, 140, 80), COLOR_SANCTUARY_RUG, true) # Pintu Utara

	# ── B. GAMBAR JALUR & JALAN RAYA (DI ATAS RUANGAN) ────────────────────────

	# 1. JALAN UTAMA ATAS (y=110..220) – Velvet Burgundy
	draw_rect(Rect2(20, 110, 2080, 110), COLOR_ROAD_TOP, true)
	draw_line(Vector2(20, 114), Vector2(2100, 114), COLOR_ROAD_TOP_TRIM, 2.5)
	draw_line(Vector2(20, 216), Vector2(2100, 216), COLOR_ROAD_TOP_TRIM, 2.5)

	# 2. JALAN VERTIKAL UTAMA (x=380..470, y=110..1330)
	draw_rect(Rect2(380, 110, 90, 1100), COLOR_ROAD_VERT, true)
	draw_line(Vector2(382, 110), Vector2(382, 1210), COLOR_ROAD_TRIM, 2.0)
	draw_line(Vector2(468, 110), Vector2(468, 1210), COLOR_ROAD_TRIM, 2.0)
	# Marka jalan vertikal (deretan kotak putus-putus seperti di sketsa)
	for my in range(130, 1200, 45):
		draw_rect(Rect2(420, my, 12, 22), Color(0.9, 0.95, 1.0, 0.45), true)

	# 3. GANG KECIL (x=1330..1410, y=110..1330)
	draw_rect(Rect2(1330, 110, 80, 1100), COLOR_GANG_KECIL, true)
	draw_line(Vector2(1333, 110), Vector2(1333, 1210), COLOR_GANG_TRIM, 2.0)
	draw_line(Vector2(1407, 110), Vector2(1407, 1210), COLOR_GANG_TRIM, 2.0)
	for gy3 in range(125, 1200, 24):
		draw_line(Vector2(1338, gy3), Vector2(1402, gy3), Color(0.3, 0.25, 0.45, 0.5), 1.5)

	# 4. JALAN TENGAH (y=680..770) – Royal Blue Highway
	draw_rect(Rect2(20, 680, 2080, 90), COLOR_ROAD_MAIN, true)
	draw_line(Vector2(20, 684), Vector2(2100, 684), COLOR_ROAD_TRIM, 2.5)
	draw_line(Vector2(20, 766), Vector2(2100, 766), COLOR_ROAD_TRIM, 2.5)
	# Deretan booth D kecil di sepanjang jalan tengah (seperti di sketsa)
	for bd in range(6):
		var bdx = 870.0 + bd * 70.0
		draw_rect(Rect2(bdx, 695, 45, 35), Color(0.85, 0.88, 0.94), true)
		draw_arc(Vector2(bdx + 22, 712), 16.0, -PI/2, PI/2, 12, Color(0.3, 0.4, 0.5), 1.5)

	# 5. JALAN LINGKAR BAWAH (y=1210..1330) – Royal Blue Highway
	draw_rect(Rect2(20, 1210, 2080, 120), COLOR_ROAD_MAIN, true)
	draw_line(Vector2(20, 1214), Vector2(2100, 1214), COLOR_ROAD_TRIM, 3.0)
	draw_line(Vector2(20, 1326), Vector2(2100, 1326), COLOR_ROAD_TRIM, 3.0)
	for mx in range(50, 2080, 60):
		draw_line(Vector2(mx, 1270), Vector2(mx + 35, 1270), Color(0.85, 0.95, 1.0, 0.45), 2.5)

	# 6. SIMPANG PLAZA
	_draw_plaza(Vector2(425, 165), 45.0)
	_draw_plaza(Vector2(1370, 165), 45.0)
	_draw_plaza(Vector2(425, 725), 45.0)
	_draw_plaza(Vector2(1370, 725), 45.0)
	_draw_plaza(Vector2(425, 1270), 55.0)
	_draw_plaza(Vector2(1370, 1270), 55.0)

	# ── C. REL KERETA SISI KANAN (x=2020..2100) ──────────────────────────────
	draw_rect(Rect2(2020, 15, 80, 1315), COLOR_TRACK_BG, true)
	draw_line(Vector2(2035, 15), Vector2(2035, 1330), COLOR_TRACK_RAIL, 3.5)
	draw_line(Vector2(2085, 15), Vector2(2085, 1330), COLOR_TRACK_RAIL, 3.5)
	for ty in range(25, 1325, 15):
		draw_line(Vector2(2026, ty), Vector2(2094, ty), COLOR_TRACK_TIE, 3.0)

	# ── D. GARIS DINDING & PINTU ──────────────────────────────────────────────
	# Batas Luar
	draw_line(Vector2(20, 15), Vector2(2100, 15), COLOR_WALL, WT)
	draw_line(Vector2(20, 1330), Vector2(2100, 1330), COLOR_WALL, WT)
	draw_line(Vector2(20, 15), Vector2(20, 1330), COLOR_WALL, WT)
	draw_line(Vector2(2000, 110), Vector2(2000, 1330), COLOR_WALL, WT)

	# Dinding bilik atas
	draw_line(Vector2(20, 110), Vector2(380, 110), COLOR_WALL, WT)
	draw_line(Vector2(470, 110), Vector2(1330, 110), COLOR_WALL, WT)
	draw_line(Vector2(1410, 110), Vector2(2000, 110), COLOR_WALL, WT)

	# Dinding Lahan Kosong (x=25..380, y=220..680)
	draw_line(Vector2(25, 220), Vector2(380, 220), COLOR_WALL, WT)
	draw_line(Vector2(380, 220), Vector2(380, 680), COLOR_WALL, WT)
	draw_line(Vector2(380, 680), Vector2(25, 680), COLOR_WALL, WT)

	# Dinding Kantor Polisi (x=25..380, y=770..1210)
	draw_line(Vector2(25, 770), Vector2(180, 770), COLOR_WALL, WT)
	draw_line(Vector2(280, 770), Vector2(380, 770), COLOR_WALL, WT) # Pintu Atas (x=180..280)
	draw_line(Vector2(380, 770), Vector2(380, 930), COLOR_WALL, WT)
	draw_line(Vector2(380, 1030), Vector2(380, 1210), COLOR_WALL, WT)# Pintu Timur (y=930..1030)
	draw_line(Vector2(380, 1210), Vector2(280, 1210), COLOR_WALL, WT)
	draw_line(Vector2(180, 1210), Vector2(25, 1210), COLOR_WALL, WT) # Pintu Selatan (x=180..280)

	# Dinding 5 Gedung (x=470..830, y=220..680)
	draw_line(Vector2(470, 220), Vector2(830, 220), COLOR_WALL, WT)
	draw_line(Vector2(830, 220), Vector2(830, 680), COLOR_WALL, WT)
	draw_line(Vector2(830, 680), Vector2(470, 680), COLOR_WALL, WT)
	draw_line(Vector2(470, 680), Vector2(470, 220), COLOR_WALL, WT)

	# Dinding Rumah Sakit (x=470..830, y=770..1210)
	draw_line(Vector2(470, 770), Vector2(600, 770), COLOR_WALL, WT)
	draw_line(Vector2(700, 770), Vector2(830, 770), COLOR_WALL, WT) # Pintu Atas (x=600..700)
	draw_line(Vector2(830, 770), Vector2(830, 930), COLOR_WALL, WT)
	draw_line(Vector2(830, 1030), Vector2(830, 1210), COLOR_WALL, WT)# Pintu Timur (y=930..1030)
	draw_line(Vector2(830, 1210), Vector2(700, 1210), COLOR_WALL, WT)
	draw_line(Vector2(600, 1210), Vector2(470, 1210), COLOR_WALL, WT)# Pintu Selatan (x=600..700)
	draw_line(Vector2(470, 1210), Vector2(470, 1030), COLOR_WALL, WT)
	draw_line(Vector2(470, 930), Vector2(470, 770), COLOR_WALL, WT) # Pintu Barat (y=930..1030)

	# Dinding Blok Tengah Atas (x=850..1330, y=220..680)
	draw_line(Vector2(850, 220), Vector2(1040, 220), COLOR_WALL, WT)
	draw_line(Vector2(1140, 220), Vector2(1330, 220), COLOR_WALL, WT)
	draw_line(Vector2(1330, 220), Vector2(1330, 400), COLOR_WALL, WT)
	draw_line(Vector2(1330, 500), Vector2(1330, 680), COLOR_WALL, WT)
	draw_line(Vector2(1330, 680), Vector2(1140, 680), COLOR_WALL, WT)
	draw_line(Vector2(1040, 680), Vector2(850, 680), COLOR_WALL, WT)
	draw_line(Vector2(850, 680), Vector2(850, 500), COLOR_WALL, WT)
	draw_line(Vector2(850, 400), Vector2(850, 220), COLOR_WALL, WT)

	# Dinding Blok Bawah Tengah & Rumah Eksplorasi (x=850..1330, y=770..1210)
	draw_line(Vector2(850, 770), Vector2(1040, 770), COLOR_WALL, WT)
	draw_line(Vector2(1140, 770), Vector2(1330, 770), COLOR_WALL, WT)
	draw_line(Vector2(1330, 770), Vector2(1330, 930), COLOR_WALL, WT)
	draw_line(Vector2(1330, 1030), Vector2(1330, 1210), COLOR_WALL, WT)
	draw_line(Vector2(1330, 1210), Vector2(1140, 1210), COLOR_WALL, WT)
	draw_line(Vector2(1040, 1210), Vector2(850, 1210), COLOR_WALL, WT)
	draw_line(Vector2(850, 1210), Vector2(850, 1030), COLOR_WALL, WT)
	draw_line(Vector2(850, 930), Vector2(850, 770), COLOR_WALL, WT)

	# Dinding Blok Kanan Atas (x=1410..1990, y=220..680)
	draw_line(Vector2(1410, 220), Vector2(1650, 220), COLOR_WALL, WT)
	draw_line(Vector2(1750, 220), Vector2(1990, 220), COLOR_WALL, WT)
	draw_line(Vector2(1990, 220), Vector2(1990, 400), COLOR_WALL, WT)
	draw_line(Vector2(1990, 500), Vector2(1990, 680), COLOR_WALL, WT)
	draw_line(Vector2(1990, 680), Vector2(1750, 680), COLOR_WALL, WT)
	draw_line(Vector2(1650, 680), Vector2(1410, 680), COLOR_WALL, WT)
	draw_line(Vector2(1410, 680), Vector2(1410, 500), COLOR_WALL, WT)
	draw_line(Vector2(1410, 400), Vector2(1410, 220), COLOR_WALL, WT)

	# Dinding Stasiun & Sanctuary Dewa Kematian (x=1410..1990, y=770..1210)
	draw_line(Vector2(1410, 770), Vector2(1630, 770), COLOR_WALL, WT)
	draw_line(Vector2(1770, 770), Vector2(1990, 770), COLOR_WALL, WT) # Pintu Utara
	draw_line(Vector2(1990, 770), Vector2(1990, 930), COLOR_WALL, WT)
	draw_line(Vector2(1990, 1050), Vector2(1990, 1210), COLOR_WALL, WT)# Pintu Timur
	draw_line(Vector2(1990, 1210), Vector2(1770, 1210), COLOR_WALL, WT)
	draw_line(Vector2(1630, 1210), Vector2(1410, 1210), COLOR_WALL, WT)# Pintu Selatan
	draw_line(Vector2(1410, 1210), Vector2(1410, 1050), COLOR_WALL, WT)
	draw_line(Vector2(1410, 930), Vector2(1410, 770), COLOR_WALL, WT)  # PINTU BARAT LEBAR

# ── Helper Gambar Garis Terpotong (Clip) ──────────────────────────────────────
func _draw_clipped_line(from: Vector2, to: Vector2, rect: Rect2, color: Color, width: float) -> void:
	var dir = (to - from).normalized()
	var length = from.distance_to(to)
	var steps = int(length / 8.0)
	for s in range(steps):
		var p = from + dir * (s * 8.0)
		var np = from + dir * ((s + 1) * 8.0)
		if rect.has_point(p) and rect.has_point(np):
			draw_line(p, np, color, width)

func _draw_plaza(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, COLOR_PLAZA)
	draw_circle(center, radius * 0.60, Color(0.6, 0.8, 1.0, 0.3))
	draw_arc(center, radius, 0.0, TAU, 24, COLOR_ROAD_TRIM, 1.5)

func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.15), true)
	draw_rect(rect, COLOR_DESK, true)
	draw_rect(rect, COLOR_DESK_LINE, false, 1.8)
	if rect.size.x >= 50.0 and rect.size.y >= 40.0:
		var c = rect.position + rect.size / 2.0
		draw_rect(Rect2(c.x - 14, c.y - 12, 28, 10), Color(0.2, 0.25, 0.32), true)

# ── Collision Builder ──────────────────────────────────────────────────────────
func _build_all_colliders() -> void:
	for b in collision_bodies:
		if is_instance_valid(b): b.queue_free()
	collision_bodies.clear()

	# Batas Luar Peta
	_add_wall_box(Rect2(0, 0, 2110, 20))
	_add_wall_box(Rect2(0, 1326, 2110, 24))
	_add_wall_box(Rect2(0, 0, 22, 1350))
	_add_wall_box(Rect2(1996, 110, 14, 1220))

	# Pembatas bawah bilik atas
	_add_wall_box(Rect2(20, 107, 360, 6))
	_add_wall_box(Rect2(470, 107, 860, 6))
	_add_wall_box(Rect2(1410, 107, 590, 6))

	# Lahan Kosong
	_add_wall_box(Rect2(25, 217, 355, 6))
	_add_wall_box(Rect2(377, 220, 6, 460))
	_add_wall_box(Rect2(25, 677, 355, 6))

	# Kantor Polisi
	_add_wall_box(Rect2(25, 767, 155, 6))
	_add_wall_box(Rect2(280, 767, 100, 6))
	_add_wall_box(Rect2(377, 770, 6, 160))
	_add_wall_box(Rect2(377, 1030, 6, 180))
	_add_wall_box(Rect2(280, 1207, 100, 6))
	_add_wall_box(Rect2(25, 1207, 155, 6))
	_add_wall_box(Rect2(22, 770, 6, 440))
	_add_wall_box(Rect2(50, 820, 240, 100))
	_add_wall_box(Rect2(50, 990, 240, 120))

	# 5 Gedung
	_add_wall_box(Rect2(470, 217, 360, 6))
	_add_wall_box(Rect2(827, 220, 6, 460))
	_add_wall_box(Rect2(470, 677, 360, 6))
	_add_wall_box(Rect2(467, 220, 6, 460))

	# Rumah Sakit
	_add_wall_box(Rect2(470, 767, 130, 6))
	_add_wall_box(Rect2(700, 767, 130, 6))
	_add_wall_box(Rect2(827, 770, 6, 160))
	_add_wall_box(Rect2(827, 1030, 6, 180))
	_add_wall_box(Rect2(700, 1207, 130, 6))
	_add_wall_box(Rect2(470, 1207, 130, 6))
	_add_wall_box(Rect2(467, 1030, 6, 180))
	_add_wall_box(Rect2(467, 770, 6, 160))

	# Blok Tengah Atas
	_add_wall_box(Rect2(850, 217, 190, 6))
	_add_wall_box(Rect2(1140, 217, 190, 6))
	_add_wall_box(Rect2(1327, 220, 6, 180))
	_add_wall_box(Rect2(1327, 500, 6, 180))
	_add_wall_box(Rect2(1140, 677, 190, 6))
	_add_wall_box(Rect2(850, 677, 190, 6))
	_add_wall_box(Rect2(847, 500, 6, 180))
	_add_wall_box(Rect2(847, 220, 6, 180))

	# Blok Bawah Tengah & Rumah Eksplorasi
	_add_wall_box(Rect2(850, 767, 190, 6))
	_add_wall_box(Rect2(1140, 767, 190, 6))
	_add_wall_box(Rect2(1327, 770, 6, 160))
	_add_wall_box(Rect2(1327, 1030, 6, 180))
	_add_wall_box(Rect2(1140, 1207, 190, 6))
	_add_wall_box(Rect2(850, 1207, 190, 6))
	_add_wall_box(Rect2(847, 1030, 6, 180))
	_add_wall_box(Rect2(847, 770, 6, 160))

	# Blok Kanan Atas (4 Ruangan)
	_add_wall_box(Rect2(1410, 217, 240, 6))
	_add_wall_box(Rect2(1750, 217, 240, 6))
	_add_wall_box(Rect2(1987, 220, 6, 180))
	_add_wall_box(Rect2(1987, 500, 6, 180))
	_add_wall_box(Rect2(1750, 677, 240, 6))
	_add_wall_box(Rect2(1410, 677, 240, 6))
	_add_wall_box(Rect2(1407, 500, 6, 180))
	_add_wall_box(Rect2(1407, 220, 6, 180))
	_add_wall_box(Rect2(1450, 260, 200, 120))
	_add_wall_box(Rect2(1740, 260, 200, 120))
	_add_wall_box(Rect2(1450, 490, 200, 120))
	_add_wall_box(Rect2(1740, 490, 200, 120))

	# Stasiun & Sanctuary Dewa Kematian
	_add_wall_box(Rect2(1410, 767, 220, 6))
	_add_wall_box(Rect2(1770, 767, 220, 6))
	_add_wall_box(Rect2(1987, 770, 6, 160))
	_add_wall_box(Rect2(1987, 1050, 6, 160))
	_add_wall_box(Rect2(1770, 1207, 220, 6))
	_add_wall_box(Rect2(1410, 1207, 220, 6))
	_add_wall_box(Rect2(1407, 1050, 6, 160))
	_add_wall_box(Rect2(1407, 770, 6, 160))

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
