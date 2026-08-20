extends Node2D

# ── Blueprint Architectural Map Renderer & Collider Generator ──────────────
# Menggambar layout map persis seperti sketsa/blueprint arsitektur user
# Dilengkapi StaticBody2D collision shapes otomatis untuk setiap dinding & meja

# Warna Blueprint
const COLOR_BG        = Color(0.98, 0.98, 0.99, 1.0) # Putih bersih
const COLOR_LINE      = Color(0.08, 0.08, 0.12, 1.0) # Garis hitam pekat
const COLOR_TRACK_BG  = Color(0.94, 0.94, 0.96, 1.0) # Jalur tangga/rel
const LINE_WIDTH      = 3.0

var collision_bodies: Array[StaticBody2D] = []

func _ready() -> void:
	z_index = -1
	_build_all_colliders()
	queue_redraw()

# ── 1. MENGGAMBAR MAP PERSIS SEPERTI GAMBAR BLUEPRINT ───────────────────────
func _draw() -> void:
	# 0. Base Floor Canvas (1600 x 920)
	draw_rect(Rect2(0, 0, 1600, 920), COLOR_BG, true)

	# ── A. Baris Kotak-Kotak Kecil di Bagian Atas (13 Kotak) ────────────────
	var top_y = 35.0
	var top_box_w = 68.0
	var top_box_h = 60.0
	var top_start_x = 40.0
	var top_gap = 26.0

	for i in range(13):
		var bx = top_start_x + i * (top_box_w + top_gap)
		_draw_box(Rect2(bx, top_y, top_box_w, top_box_h))

	# Garis horizontal batas koridor atas
	draw_line(Vector2(20, 120), Vector2(1380, 120), COLOR_LINE, LINE_WIDTH)

	# ── B. Tangga / Rel Vertikal di Sisi Kanan ──────────────────────────────
	var track_x = 1430.0
	var track_w = 60.0
	var track_h = 880.0
	draw_rect(Rect2(track_x, 15, track_w, track_h), COLOR_TRACK_BG, true)
	draw_rect(Rect2(track_x, 15, track_w, track_h), COLOR_LINE, false, LINE_WIDTH)

	# Garis anak tangga / rel horizontal setiap 12px
	for y in range(25, 885, 12):
		draw_line(Vector2(track_x, y), Vector2(track_x + track_w, y), COLOR_LINE, 1.5)

	# ── C. Blok Kiri Atas (L-Shaped Area dengan Kotak-Kotak Kecil) ───────────
	# Boundary luar L
	_draw_polygon_lines([
		Vector2(20, 180),
		Vector2(320, 180),
		Vector2(320, 480),
		Vector2(200, 480),
		Vector2(200, 520),
		Vector2(20, 520),
		Vector2(20, 180)
	])

	# 3 Kotak kecil horizontal di atas kiri
	_draw_box(Rect2(40, 200, 65, 60))
	_draw_box(Rect2(135, 200, 65, 60))
	_draw_box(Rect2(230, 200, 65, 60))

	# 2 Kotak kecil vertikal di sisi kanan L
	_draw_box(Rect2(230, 290, 65, 65))
	_draw_box(Rect2(230, 390, 65, 65))

	# Kotak kecil di tekukan bawah
	_draw_box(Rect2(130, 485, 55, 55))

	# Ruangan persegi besar di pojok kiri bawah
	_draw_box(Rect2(30, 580, 160, 280))

	# ── D. Blok Tengah Atas (Ruang Meja Persegi Panjang + 2x2 Cubicle) ──────
	# Outline pembatas blok
	_draw_polygon_lines([
		Vector2(390, 180),
		Vector2(880, 180),
		Vector2(880, 430),
		Vector2(670, 430),
		Vector2(670, 340),
		Vector2(390, 340),
		Vector2(390, 180)
	])

	# Inner meja persegi panjang (kiri)
	_draw_box(Rect2(410, 200, 230, 115))

	# 2x2 Kotak Meja (kanan)
	_draw_box(Rect2(690, 200, 75, 75))
	_draw_box(Rect2(785, 200, 75, 75))
	_draw_box(Rect2(690, 320, 75, 75))
	_draw_box(Rect2(785, 320, 75, 75))

	# ── E. Blok Kanan Atas (2x2 Cubicle Pod) ─────────────────────────────────
	_draw_box(Rect2(930, 180, 220, 250))
	_draw_box(Rect2(950, 200, 75, 75))
	_draw_box(Rect2(1055, 200, 75, 75))
	_draw_box(Rect2(950, 320, 75, 75))
	_draw_box(Rect2(1055, 320, 75, 75))

	# ── F. Blok Kiri-Bawah Bertingkat (Stepped Room & Inner Tables) ──────────
	# Outline bertingkat
	_draw_polygon_lines([
		Vector2(290, 410),
		Vector2(570, 410),
		Vector2(570, 880),
		Vector2(270, 880),
		Vector2(270, 560),
		Vector2(290, 560),
		Vector2(290, 410)
	])

	# Meja atas bertingkat
	_draw_box(Rect2(310, 430, 240, 115))
	# Meja besar bawah
	_draw_box(Rect2(290, 580, 260, 270))

	# ── G. Blok Tengah Bawah (Chamber Vertikal) ──────────────────────────────
	_draw_box(Rect2(650, 500, 170, 380))
	_draw_box(Rect2(665, 520, 140, 100)) # Compartment atas

	# ── H. Blok Kanan Bawah (Ruangan Besar) ──────────────────────────────────
	_draw_box(Rect2(890, 500, 310, 380))

	# ── I. Garis Batas Koridor Kanan & Luar ──────────────────────────────────
	draw_line(Vector2(1380, 120), Vector2(1380, 880), COLOR_LINE, LINE_WIDTH)
	draw_line(Vector2(20, 15), Vector2(1510, 15), COLOR_LINE, LINE_WIDTH)
	draw_line(Vector2(20, 895), Vector2(1510, 895), COLOR_LINE, LINE_WIDTH)
	draw_line(Vector2(20, 15), Vector2(20, 895), COLOR_LINE, LINE_WIDTH)

# ── Helper Gambar Box & Polygon ─────────────────────────────────────────────
func _draw_box(rect: Rect2) -> void:
	draw_rect(rect, COLOR_LINE, false, LINE_WIDTH)

func _draw_polygon_lines(points: Array[Vector2]) -> void:
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], COLOR_LINE, LINE_WIDTH)

# ── 2. MEMBANGUN COLLISION STATICBODY2D UNTUK SEMUA DINDING & MEJA ──────────
func _build_all_colliders() -> void:
	# Bersihkan collider lama jika ada
	for b in collision_bodies:
		if is_instance_valid(b):
			b.queue_free()
	collision_bodies.clear()

	# A. Batas Luar Map
	_add_wall_box(Rect2(0, 0, 1600, 20))      # North Border
	_add_wall_box(Rect2(0, 890, 1600, 30))    # South Border
	_add_wall_box(Rect2(0, 0, 20, 920))       # West Border
	_add_wall_box(Rect2(1420, 0, 20, 920))    # East Corridor Wall Border

	# B. Kotak-Kotak Kecil Baris Atas (13 Kotak)
	var top_y = 35.0
	var top_box_w = 68.0
	var top_box_h = 60.0
	var top_start_x = 40.0
	var top_gap = 26.0
	for i in range(13):
		var bx = top_start_x + i * (top_box_w + top_gap)
		_add_wall_box(Rect2(bx, top_y, top_box_w, top_box_h))

	# C. Blok Kiri Atas
	_add_wall_box(Rect2(40, 200, 65, 60))
	_add_wall_box(Rect2(135, 200, 65, 60))
	_add_wall_box(Rect2(230, 200, 65, 60))
	_add_wall_box(Rect2(230, 290, 65, 65))
	_add_wall_box(Rect2(230, 390, 65, 65))
	_add_wall_box(Rect2(130, 485, 55, 55))
	_add_wall_box(Rect2(30, 580, 160, 280)) # Large Bottom Left Room

	# D. Blok Tengah Atas
	_add_wall_box(Rect2(410, 200, 230, 115)) # Rect Desk
	_add_wall_box(Rect2(690, 200, 75, 75))
	_add_wall_box(Rect2(785, 200, 75, 75))
	_add_wall_box(Rect2(690, 320, 75, 75))
	_add_wall_box(Rect2(785, 320, 75, 75))

	# E. Blok Kanan Atas (2x2 Cubicle Pod)
	_add_wall_box(Rect2(950, 200, 75, 75))
	_add_wall_box(Rect2(1055, 200, 75, 75))
	_add_wall_box(Rect2(950, 320, 75, 75))
	_add_wall_box(Rect2(1055, 320, 75, 75))

	# F. Blok Kiri Bawah Bertingkat
	_add_wall_box(Rect2(310, 430, 240, 115))
	_add_wall_box(Rect2(290, 580, 260, 270))

	# G. Blok Tengah Bawah
	_add_wall_box(Rect2(665, 520, 140, 100))
	_add_wall_box(Rect2(650, 640, 170, 240))

	# H. Blok Kanan Bawah
	_add_wall_box(Rect2(890, 500, 310, 380))

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
