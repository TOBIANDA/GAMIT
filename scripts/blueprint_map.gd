extends Node2D

# ── Blueprint Architectural Map Renderer v2 (Rich Colors & Open Doorways) ───
# Fitur:
# 1. Warna & Estetika Menawan: Tiap ruangan memiliki warna lantai tematik (Sanctuary Ungu Dewa Kematian, Arsip Gading, Kantor Biru Azure, Rel Baja Industri).
# 2. Pintu Masuk Terbuka (Walkable Rooms): Dinding dibuat hollow/berlubang pintu sehingga pemain & NPC bisa masuk ke SEMUA ruangan termasuk Ruang Dewa Kematian!
# 3. Collision Dinding & Meja Presisi: Hanya garis dinding tipis & meja yang memiliki collision, bagian dalam ruangan 100% bebas dijelajahi.

# ── Palette Warna Tematik ───────────────────────────────────────────────────
const COLOR_CORRIDOR_BG   = Color(0.93, 0.94, 0.96, 1.0) # Lantai lorong abu-abu blueprint terang
const COLOR_GRID_LINE     = Color(0.85, 0.88, 0.92, 0.5) # Garis grid halus
const COLOR_WALL_LINE     = Color(0.12, 0.14, 0.18, 1.0) # Dinding struktural tebal
const COLOR_WALL_SHADOW   = Color(0.0, 0.0, 0.0, 0.08)   # Bayangan dinding halus

# Lantai Ruangan Tematik
const COLOR_ROOM_OFFICE   = Color(0.88, 0.92, 0.96, 1.0) # Biru muda kantor arsip
const COLOR_ROOM_ARCHIVE  = Color(0.96, 0.94, 0.88, 1.0) # Gading hangat ruang berkas
const COLOR_ROOM_POD      = Color(0.90, 0.93, 0.90, 1.0) # Sage green bilik interogasi
const COLOR_ROOM_SANCTUARY= Color(0.14, 0.09, 0.20, 1.0) # Ungu gelap mistis Ruang Dewa Kematian
const COLOR_SANCTUARY_RUG = Color(0.24, 0.12, 0.35, 1.0) # Karpet ritual ungu tua
const COLOR_RUNE_GLOW     = Color(0.65, 0.30, 0.95, 0.35)# Lingkaran sihir ritual

# Meja & Perabotan
const COLOR_DESK_FILL     = Color(0.78, 0.82, 0.88, 1.0) # Warna permukaan meja
const COLOR_DESK_LINE     = Color(0.20, 0.24, 0.30, 1.0) # Garis tepi meja
const COLOR_DOORWAY_CARPET= Color(0.40, 0.60, 0.80, 0.25)# Indikator pintu masuk

# Rel & Tangga
const COLOR_TRACK_BG      = Color(0.82, 0.85, 0.88, 1.0)
const COLOR_TRACK_RAIL    = Color(0.25, 0.28, 0.35, 1.0)
const COLOR_TRACK_TIE     = Color(0.48, 0.42, 0.36, 1.0)

const WALL_THICKNESS = 6.0
var collision_bodies: Array[StaticBody2D] = []

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ── 1. MENGGAMBAR MAP DENGAN WARNA DAN PINTU MASUK LENGKAP ──────────────────
func _draw() -> void:
	# 0. Base Floor Canvas (1600 x 920)
	draw_rect(Rect2(0, 0, 1600, 920), COLOR_CORRIDOR_BG, true)

	# Grid Lantai Arsitektur Halus
	for x in range(40, 1560, 40):
		draw_line(Vector2(x, 20), Vector2(x, 900), COLOR_GRID_LINE, 1.0)
	for y in range(20, 900, 40):
		draw_line(Vector2(40, y), Vector2(1560, y), COLOR_GRID_LINE, 1.0)

	# ── A. Lantai Berwarna Tiap Ruangan ─────────────────────────────────────
	# 1. Ruangan Dewa Kematian (Kanan Bawah)
	draw_rect(Rect2(890, 490, 460, 390), COLOR_ROOM_SANCTUARY, true)
	draw_rect(Rect2(960, 560, 320, 260), COLOR_SANCTUARY_RUG, true)
	draw_circle(Vector2(1120, 680), 90.0, COLOR_RUNE_GLOW)
	draw_circle(Vector2(1120, 680), 55.0, Color(0.8, 0.35, 1.0, 0.2))

	# Karpet Jalan Masuk Pintu Dewa Kematian
	draw_rect(Rect2(880, 630, 85, 100), COLOR_SANCTUARY_RUG, true) # Pintu Barat
	draw_rect(Rect2(1060, 480, 100, 85), COLOR_SANCTUARY_RUG, true) # Pintu Utara

	# 2. Ruang Kiri Bawah (Arsip & Vault)
	draw_rect(Rect2(270, 450, 310, 430), COLOR_ROOM_ARCHIVE, true)

	# 3. Bilik Tengah Bawah (Pod Interogasi)
	draw_rect(Rect2(640, 490, 190, 390), COLOR_ROOM_POD, true)

	# 4. Blok Tengah Atas (Kantor Diskusi)
	draw_rect(Rect2(390, 175, 500, 265), COLOR_ROOM_OFFICE, true)

	# 5. Blok Kanan Atas (Workstation Cubicles)
	draw_rect(Rect2(930, 175, 340, 265), COLOR_ROOM_OFFICE, true)

	# 6. Blok Kiri Atas (L-Shaped Investigation Area)
	var l_pts = PackedVector2Array([
		Vector2(20, 175), Vector2(330, 175), Vector2(330, 490),
		Vector2(200, 490), Vector2(200, 530), Vector2(20, 530)
	])
	draw_colored_polygon(l_pts, COLOR_ROOM_ARCHIVE)

	# 7. Bilik-Bilik Kecil Atas (13 Stalls)
	for i in range(13):
		var bx = 40.0 + i * 94.0
		draw_rect(Rect2(bx, 30, 70, 75), COLOR_ROOM_POD, true)

	# ── B. Tangga / Rel Vertikal di Sisi Kanan ──────────────────────────────
	var track_x = 1440.0
	var track_w = 65.0
	var track_h = 880.0
	draw_rect(Rect2(track_x, 15, track_w, track_h), COLOR_TRACK_BG, true)
	
	# Rel Besi
	draw_line(Vector2(track_x + 10, 15), Vector2(track_x + 10, 895), COLOR_TRACK_RAIL, 3.0)
	draw_line(Vector2(track_x + track_w - 10, 15), Vector2(track_x + track_w - 10, 895), COLOR_TRACK_RAIL, 3.0)

	# Bantalan Rel Kayu
	for y in range(25, 885, 14):
		draw_line(Vector2(track_x + 5, y), Vector2(track_x + track_w - 5, y), COLOR_TRACK_TIE, 3.0)

	# ── C. Garis Dinding dengan Pintu Masuk Terbuka ──────────────────────────
	# 1. Baris Atas (13 Bilik dengan Pintu Bawah Terbuka)
	for i in range(13):
		var bx = 40.0 + i * 94.0
		# Dinding Kiri, Atas, Kanan (Bawah terbuka sebagai pintu masuk!)
		draw_line(Vector2(bx, 105), Vector2(bx, 30), COLOR_WALL_LINE, WALL_THICKNESS)
		draw_line(Vector2(bx, 30), Vector2(bx + 70, 30), COLOR_WALL_LINE, WALL_THICKNESS)
		draw_line(Vector2(bx + 70, 30), Vector2(bx + 70, 105), COLOR_WALL_LINE, WALL_THICKNESS)
		# Meja kecil di dalam bilik
		_draw_desk(Rect2(bx + 12, 45, 46, 30))

	# Garis horizontal koridor atas (dengan celah pintu setiap bilik)
	for i in range(13):
		var bx = 40.0 + i * 94.0
		var gap_end = bx + 94.0
		draw_line(Vector2(bx + 70, 105), Vector2(gap_end, 105), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(20, 105), Vector2(40, 105), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1262, 105), Vector2(1400, 105), COLOR_WALL_LINE, WALL_THICKNESS)

	# 2. Blok Kiri Atas (L-Shaped)
	# Dinding Atas (Pintu di tengah x=150-210)
	draw_line(Vector2(20, 175), Vector2(150, 175), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(210, 175), Vector2(330, 175), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu di tengah y=310-370)
	draw_line(Vector2(330, 175), Vector2(330, 310), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(330, 370), Vector2(330, 490), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah & Samping
	draw_line(Vector2(330, 490), Vector2(200, 490), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(200, 490), Vector2(200, 530), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(200, 530), Vector2(20, 530), COLOR_WALL_LINE, WALL_THICKNESS)

	# Meja-meja di Ruang Kiri Atas
	_draw_desk(Rect2(40, 200, 65, 55))
	_draw_desk(Rect2(135, 200, 65, 55))
	_draw_desk(Rect2(235, 200, 65, 55))
	_draw_desk(Rect2(235, 285, 65, 55))
	_draw_desk(Rect2(235, 395, 65, 55))
	_draw_desk(Rect2(130, 455, 55, 55))

	# 3. Blok Tengah Atas (Kantor Utama)
	# Dinding Atas (Pintu x=510-580)
	draw_line(Vector2(390, 175), Vector2(510, 175), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(580, 175), Vector2(890, 175), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan
	draw_line(Vector2(890, 175), Vector2(890, 440), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah (Pintu x=510-580)
	draw_line(Vector2(890, 440), Vector2(670, 440), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(670, 440), Vector2(670, 350), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(670, 350), Vector2(580, 350), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(510, 350), Vector2(390, 350), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri
	draw_line(Vector2(390, 350), Vector2(390, 175), COLOR_WALL_LINE, WALL_THICKNESS)

	# Meja Konferensi & Cubicles
	_draw_desk(Rect2(415, 205, 200, 110))
	_draw_desk(Rect2(700, 205, 75, 75))
	_draw_desk(Rect2(795, 205, 75, 75))
	_draw_desk(Rect2(700, 330, 75, 75))
	_draw_desk(Rect2(795, 330, 75, 75))

	# 4. Blok Kanan Atas (Workstation Pod)
	# Dinding Atas (Pintu x=1060-1130)
	draw_line(Vector2(930, 175), Vector2(1060, 175), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1130, 175), Vector2(1270, 175), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan
	draw_line(Vector2(1270, 175), Vector2(1270, 440), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah
	draw_line(Vector2(1270, 440), Vector2(930, 440), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Barat (Pintu y=270-340)
	draw_line(Vector2(930, 440), Vector2(930, 340), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(930, 270), Vector2(930, 175), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(960, 205, 75, 75))
	_draw_desk(Rect2(1065, 205, 75, 75))
	_draw_desk(Rect2(960, 330, 75, 75))
	_draw_desk(Rect2(1065, 330, 75, 75))

	# 5. Blok Kiri Bawah (Arsip & Vault Bertingkat)
	# Dinding Atas (Pintu x=390-460)
	draw_line(Vector2(270, 450), Vector2(390, 450), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(460, 450), Vector2(580, 450), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan (Pintu y=640-720)
	draw_line(Vector2(580, 450), Vector2(580, 640), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(580, 720), Vector2(580, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Bawah
	draw_line(Vector2(580, 880), Vector2(250, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kiri
	draw_line(Vector2(250, 880), Vector2(250, 560), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(250, 560), Vector2(270, 560), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(270, 560), Vector2(270, 450), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(300, 480, 220, 95))
	_draw_desk(Rect2(280, 630, 240, 210))

	# 6. Blok Tengah Bawah (Pod Interogasi)
	# Dinding Atas (Pintu x=700-770)
	draw_line(Vector2(640, 490), Vector2(700, 490), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(770, 490), Vector2(830, 490), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Kanan & Bawah & Kiri
	draw_line(Vector2(830, 490), Vector2(830, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(830, 880), Vector2(640, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(640, 880), Vector2(640, 490), COLOR_WALL_LINE, WALL_THICKNESS)

	_draw_desk(Rect2(665, 520, 140, 90))

	# 7. BLOK KANAN BAWAH: RUANGAN DEWA KEMATIAN (GRAND SANCTUARY)
	# Dinding Utara (Pintu Lebar x=1060-1160)
	draw_line(Vector2(890, 490), Vector2(1060, 490), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1160, 490), Vector2(1350, 490), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Timur
	draw_line(Vector2(1350, 490), Vector2(1350, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Selatan
	draw_line(Vector2(1350, 880), Vector2(890, 880), COLOR_WALL_LINE, WALL_THICKNESS)
	# Dinding Barat (PINTU MASUK UTAMA SUPER LEBAR y=630-730)
	draw_line(Vector2(890, 880), Vector2(890, 730), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(890, 630), Vector2(890, 490), COLOR_WALL_LINE, WALL_THICKNESS)

	# 8. Batas Luar Peta
	draw_line(Vector2(20, 15), Vector2(1520, 15), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(20, 895), Vector2(1520, 895), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(20, 15), Vector2(20, 895), COLOR_WALL_LINE, WALL_THICKNESS)
	draw_line(Vector2(1400, 105), Vector2(1400, 895), COLOR_WALL_LINE, WALL_THICKNESS)

# ── Helper Gambar Meja & Aset Perabotan ─────────────────────────────────────
func _draw_desk(rect: Rect2) -> void:
	# Bayangan meja
	draw_rect(Rect2(rect.position + Vector2(2, 3), rect.size), Color(0, 0, 0, 0.15), true)
	# Permukaan Meja
	draw_rect(rect, COLOR_DESK_FILL, true)
	draw_rect(rect, COLOR_DESK_LINE, false, 2.0)
	
	# Ornamen dekorasi meja (komputer / berkas) jika ukuran meja cukup
	if rect.size.x >= 60.0 and rect.size.y >= 50.0:
		var center = rect.position + rect.size / 2.0
		# Layar monitor
		draw_rect(Rect2(center.x - 14, center.y - 14, 28, 10), Color(0.2, 0.25, 0.32), true)
		# Keyboard
		draw_rect(Rect2(center.x - 12, center.y + 2, 24, 7), Color(0.35, 0.4, 0.48), true)

# ── 2. MEMBANGUN COLLISION HANYA PADA DINDING TIPIS & MEJA ──────────────────
func _build_all_colliders() -> void:
	for b in collision_bodies:
		if is_instance_valid(b):
			b.queue_free()
	collision_bodies.clear()

	# A. Batas Luar Peta
	_add_wall_box(Rect2(0, 0, 1600, 20))       # North Outer
	_add_wall_box(Rect2(0, 890, 1600, 30))     # South Outer
	_add_wall_box(Rect2(0, 0, 20, 920))        # West Outer
	_add_wall_box(Rect2(1400, 105, 15, 790))   # East Corridor Wall

	# B. Dinding 13 Bilik Atas (Tiap bilik terbuka di bawah)
	for i in range(13):
		var bx = 40.0 + i * 94.0
		_add_wall_box(Rect2(bx - 3, 30, 6, 75))      # Left Wall
		_add_wall_box(Rect2(bx, 27, 70, 6))          # Top Wall
		_add_wall_box(Rect2(bx + 67, 30, 6, 75))     # Right Wall
		_add_wall_box(Rect2(bx + 12, 45, 46, 30))    # Inner Desk Collider
		# Dinding pembatas antar bilik di koridor
		_add_wall_box(Rect2(bx + 70, 102, 24, 6))

	_add_wall_box(Rect2(20, 102, 20, 6))
	_add_wall_box(Rect2(1262, 102, 140, 6))

	# C. Blok Kiri Atas (L-Shaped Room)
	_add_wall_box(Rect2(20, 172, 130, 6))        # Top-Left
	_add_wall_box(Rect2(210, 172, 120, 6))       # Top-Right (Doorway at x=150-210)
	_add_wall_box(Rect2(327, 175, 6, 135))       # Right-Top
	_add_wall_box(Rect2(327, 370, 6, 120))       # Right-Bottom (Doorway at y=310-370)
	_add_wall_box(Rect2(200, 487, 130, 6))       # Bottom-Step
	_add_wall_box(Rect2(197, 490, 6, 40))
	_add_wall_box(Rect2(20, 527, 180, 6))
	
	# Meja-meja di L-room
	_add_wall_box(Rect2(40, 200, 65, 55))
	_add_wall_box(Rect2(135, 200, 65, 55))
	_add_wall_box(Rect2(235, 200, 65, 55))
	_add_wall_box(Rect2(235, 285, 65, 55))
	_add_wall_box(Rect2(235, 395, 65, 55))
	_add_wall_box(Rect2(130, 455, 55, 55))

	# D. Blok Tengah Atas (Kantor Utama)
	_add_wall_box(Rect2(390, 172, 120, 6))       # Top-Left
	_add_wall_box(Rect2(580, 172, 310, 6))       # Top-Right (Doorway x=510-580)
	_add_wall_box(Rect2(887, 175, 6, 265))       # Right Wall
	_add_wall_box(Rect2(670, 437, 220, 6))       # Bottom-Right
	_add_wall_box(Rect2(667, 350, 6, 90))
	_add_wall_box(Rect2(580, 347, 90, 6))
	_add_wall_box(Rect2(390, 347, 120, 6))       # Bottom-Left (Doorway x=510-580)
	_add_wall_box(Rect2(387, 175, 6, 175))       # Left Wall
	
	# Meja-meja Kantor
	_add_wall_box(Rect2(415, 205, 200, 110))
	_add_wall_box(Rect2(700, 205, 75, 75))
	_add_wall_box(Rect2(795, 205, 75, 75))
	_add_wall_box(Rect2(700, 330, 75, 75))
	_add_wall_box(Rect2(795, 330, 75, 75))

	# E. Blok Kanan Atas (Workstation Pod)
	_add_wall_box(Rect2(930, 172, 130, 6))       # Top-Left
	_add_wall_box(Rect2(1130, 172, 140, 6))      # Top-Right (Doorway x=1060-1130)
	_add_wall_box(Rect2(1267, 175, 6, 265))      # Right Wall
	_add_wall_box(Rect2(930, 437, 340, 6))       # Bottom Wall
	_add_wall_box(Rect2(927, 340, 6, 100))       # Left-Bottom
	_add_wall_box(Rect2(927, 175, 6, 95))        # Left-Top (Doorway y=270-340)

	_add_wall_box(Rect2(960, 205, 75, 75))
	_add_wall_box(Rect2(1065, 205, 75, 75))
	_add_wall_box(Rect2(960, 330, 75, 75))
	_add_wall_box(Rect2(1065, 330, 75, 75))

	# F. Blok Kiri Bawah (Arsip & Vault)
	_add_wall_box(Rect2(270, 447, 120, 6))       # Top-Left
	_add_wall_box(Rect2(460, 447, 120, 6))       # Top-Right (Doorway x=390-460)
	_add_wall_box(Rect2(577, 450, 6, 190))       # Right-Top
	_add_wall_box(Rect2(577, 720, 6, 160))       # Right-Bottom (Doorway y=640-720)
	_add_wall_box(Rect2(250, 877, 330, 6))       # Bottom Wall
	_add_wall_box(Rect2(247, 560, 6, 320))       # Left-Bottom
	_add_wall_box(Rect2(250, 557, 20, 6))
	_add_wall_box(Rect2(267, 450, 6, 110))

	_add_wall_box(Rect2(300, 480, 220, 95))
	_add_wall_box(Rect2(280, 630, 240, 210))

	# G. Blok Tengah Bawah (Pod Interogasi)
	_add_wall_box(Rect2(640, 487, 60, 6))        # Top-Left
	_add_wall_box(Rect2(770, 487, 60, 6))        # Top-Right (Doorway x=700-770)
	_add_wall_box(Rect2(827, 490, 6, 390))       # Right Wall
	_add_wall_box(Rect2(640, 877, 190, 6))       # Bottom Wall
	_add_wall_box(Rect2(637, 490, 6, 390))       # Left Wall

	_add_wall_box(Rect2(665, 520, 140, 90))

	# H. BLOK KANAN BAWAH: RUANGAN DEWA KEMATIAN (GRAND SANCTUARY)
	# Dinding Utara (Pintu Masuk Utara x=1060-1160)
	_add_wall_box(Rect2(890, 487, 170, 6))
	_add_wall_box(Rect2(1160, 487, 190, 6))
	# Dinding Timur & Selatan
	_add_wall_box(Rect2(1347, 490, 6, 390))
	_add_wall_box(Rect2(890, 877, 460, 6))
	# Dinding Barat (PINTU MASUK UTAMA SUPER LEBAR y=630-730 -> 100px lebar!)
	_add_wall_box(Rect2(887, 490, 6, 140))       # West-Top
	_add_wall_box(Rect2(887, 730, 6, 150))       # West-Bottom

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
