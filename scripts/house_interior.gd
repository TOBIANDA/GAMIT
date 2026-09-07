extends Node2D

# Koordinat penempatan interior rumah di world space
const ROOM_ORIGIN := Vector2(3600.0, 400.0)
const ROOM_SIZE := Vector2(560.0, 360.0)

# Titik-titik penting di dalam rumah
const ENTRANCE_POS := Vector2(3600.0 + 270.0, 400.0 + 310.0)
const EXIT_DOOR_POS := Vector2(3600.0 + 270.0, 400.0 + 342.0)
const DESK_LETTER_POS := Vector2(3600.0 + 410.0, 400.0 + 250.0)
const SAFE_POS := Vector2(3600.0 + 505.0, 400.0 + 215.0)
const PHOTO_BASIN_POS := Vector2(3600.0 + 335.0, 400.0 + 83.0)

# Aset Tekstur
var tex_sofa_panjang: Texture2D
var tex_sofa_kecil: Texture2D
var tex_meja_panjang: Texture2D
var tex_karpet: Texture2D
var tex_meja_detektif: Texture2D
var tex_kitchen_unit: Texture2D
var tex_meja_lab_foto: Texture2D
var tex_bed: Texture2D
var tex_lemari: Texture2D
var tex_laci: Texture2D
var tex_karpet_kamar: Texture2D
var tex_surat: Texture2D
var tex_berangkas: Texture2D
var tex_baskom: Texture2D

var letter_glow_time: float = 0.0
var sprite_letter: Sprite2D
var static_body: StaticBody2D

func _ready() -> void:
	z_index = 0
	y_sort_enabled = true
	_load_textures()
	_build_room_collisions()
	_setup_furniture_nodes()

func _load_textures() -> void:
	# Ruang Tamu
	tex_sofa_panjang = load("res://Environment/ruang tamu/sofaPanjang.png")
	tex_sofa_kecil = load("res://Environment/ruang tamu/sofaKecilSamping.png")
	tex_meja_panjang = load("res://Environment/ruang tamu/mejaPanjang.png")
	tex_karpet = load("res://Environment/ruang tamu/karpet.png")
	tex_meja_detektif = load("res://Environment/ruang tamu/meja_detektif.png")

	# Dapur & Lab Foto
	tex_kitchen_unit = load("res://Environment/dapur/kitchen_unit.png")
	tex_meja_lab_foto = load("res://Environment/dapur/meja_lab_foto.png")

	# Kamar Tidur
	tex_bed = load("res://Environment/kamar/bed.png")
	tex_lemari = load("res://Environment/kamar/lemari.png")
	tex_laci = load("res://Environment/kamar/laci.png")
	tex_karpet_kamar = load("res://Environment/kamar/karpet.png")

	# Aset Interaktif
	tex_surat = load("res://Environment/interactable assets/surat.png")
	tex_berangkas = load("res://Environment/interactable assets/berangkas.png")
	tex_baskom = load("res://Environment/interactable assets/baskom cetak photo.png")

func _build_room_collisions() -> void:
	static_body = StaticBody2D.new()
	static_body.name = "HouseInteriorCollisions"
	static_body.collision_layer = 1
	static_body.collision_mask = 0
	add_child(static_body)

	# 1. Dinding Luar Atas
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 40.0))
	# 2. Dinding Luar Kiri
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y))
	# 3. Dinding Luar Kanan
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y))
	# 4. Dinding Luar Bawah Kiri (sebelah pintu keluar)
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, 240.0, 20.0))
	# 5. Dinding Luar Bawah Kanan (sebelah pintu keluar)
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 300.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, 260.0, 20.0))

	# 6. Dinding Sekat Pembatas Ruangan (Divider Wall) dengan Pintu Terbuka
	# Bagian Atas
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 266.0, ROOM_ORIGIN.y + 40.0, 8.0, 110.0))
	# Bagian Bawah
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 266.0, ROOM_ORIGIN.y + 220.0, 8.0, 120.0))

	# 7. Kolisi Perabot Kamar Tidur
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 42.0, ROOM_ORIGIN.y + 40.0, 46.0, 50.0)) # Bed
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 138.0, ROOM_ORIGIN.y + 40.0, 44.0, 32.0)) # Wardrobe
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 94.0, ROOM_ORIGIN.y + 54.0, 22.0, 22.0)) # Nakas

	# 8. Kolisi Perabot Ruang Tamu
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 88.0, ROOM_ORIGIN.y + 220.0, 65.0, 30.0)) # Sofa
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 100.0, ROOM_ORIGIN.y + 258.0, 40.0, 24.0)) # Meja Kopi
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 53.0, ROOM_ORIGIN.y + 253.0, 24.0, 24.0)) # Armchair
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 24.0, ROOM_ORIGIN.y + 304.0, 22.0, 22.0)) # Corner Table

	# 9. Kolisi Perabot Dapur & Meja Cuci Foto
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 390.0, ROOM_ORIGIN.y + 40.0, 100.0, 52.0)) # Kitchen Unit
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 306.0, ROOM_ORIGIN.y + 60.0, 48.0, 34.0)) # Meja Foto

	# 10. Kolisi Meja Kerja Detektif & Brankas (Pembatas solid agar tidak tembus)
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 371.0, ROOM_ORIGIN.y + 228.0, 78.0, 45.0)) # Meja Kerja Detektif
	_add_box_collider(static_body, Rect2(ROOM_ORIGIN.x + 491.0, ROOM_ORIGIN.y + 200.0, 28.0, 30.0)) # Brankas Baja

func _add_box_collider(body: StaticBody2D, rect: Rect2) -> void:
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.position + rect.size * 0.5
	body.add_child(col)

func _setup_furniture_nodes() -> void:
	# ==========================================
	# 1. ZONE KAMAR TIDUR (Top-Left)
	# ==========================================
	# Karpet Kamar (di bawah lantai)
	if is_instance_valid(tex_karpet_kamar):
		var sp = Sprite2D.new()
		sp.texture = tex_karpet_kamar
		sp.position = ROOM_ORIGIN + Vector2(65.0, 125.0)
		sp.scale = Vector2(50.0 / tex_karpet_kamar.get_width(), 50.0 / tex_karpet_kamar.get_width())
		sp.z_index = -1
		add_child(sp)

	# Ranjang Tidur (Bed)
	if is_instance_valid(tex_bed):
		var sp = Sprite2D.new()
		sp.texture = tex_bed
		sp.position = ROOM_ORIGIN + Vector2(65.0, 80.0)
		sp.scale = Vector2(46.0 / tex_bed.get_width(), 46.0 / tex_bed.get_width())
		sp.z_index = 0
		add_child(sp)

	# Nakas / Meja Kecil dengan Bunga
	if is_instance_valid(tex_laci):
		var sp = Sprite2D.new()
		sp.texture = tex_laci
		sp.position = ROOM_ORIGIN + Vector2(105.0, 65.0)
		sp.scale = Vector2(22.0 / tex_laci.get_width(), 22.0 / tex_laci.get_width())
		sp.z_index = 0
		add_child(sp)

	# Lemari Pakaian Kayu
	if is_instance_valid(tex_lemari):
		var sp = Sprite2D.new()
		sp.texture = tex_lemari
		sp.position = ROOM_ORIGIN + Vector2(160.0, 65.0)
		sp.scale = Vector2(44.0 / tex_lemari.get_width(), 44.0 / tex_lemari.get_width())
		sp.z_index = 0
		add_child(sp)

	# ==========================================
	# 2. ZONE RUANG TAMU (Bottom-Left)
	# ==========================================
	# Karpet Tamu Oval (di bawah lantai)
	if is_instance_valid(tex_karpet):
		var sp = Sprite2D.new()
		sp.texture = tex_karpet
		sp.position = ROOM_ORIGIN + Vector2(120.0, 265.0)
		sp.scale = Vector2(85.0 / tex_karpet.get_width(), 85.0 / tex_karpet.get_width())
		sp.z_index = -1
		add_child(sp)

	# Sofa Tamu Hijau
	if is_instance_valid(tex_sofa_panjang):
		var sp = Sprite2D.new()
		sp.texture = tex_sofa_panjang
		sp.position = ROOM_ORIGIN + Vector2(120.0, 235.0)
		sp.scale = Vector2(65.0 / tex_sofa_panjang.get_width(), 65.0 / tex_sofa_panjang.get_width())
		sp.z_index = 0
		add_child(sp)

	# Meja Kopi Panjang
	if is_instance_valid(tex_meja_panjang):
		var sp = Sprite2D.new()
		sp.texture = tex_meja_panjang
		sp.position = ROOM_ORIGIN + Vector2(120.0, 270.0)
		sp.scale = Vector2(40.0 / tex_meja_panjang.get_width(), 40.0 / tex_meja_panjang.get_width())
		sp.z_index = 0
		add_child(sp)

	# Sofa Kecil Samping (Armchair)
	if is_instance_valid(tex_sofa_kecil):
		var sp = Sprite2D.new()
		sp.texture = tex_sofa_kecil
		sp.position = ROOM_ORIGIN + Vector2(65.0, 265.0)
		sp.scale = Vector2(24.0 / tex_sofa_kecil.get_width(), 24.0 / tex_sofa_kecil.get_width())
		sp.z_index = 0
		add_child(sp)

	# Meja Hias Bunga di Sudut Tamu
	if is_instance_valid(tex_laci):
		var sp = Sprite2D.new()
		sp.texture = tex_laci
		sp.position = ROOM_ORIGIN + Vector2(35.0, 315.0)
		sp.scale = Vector2(22.0 / tex_laci.get_width(), 22.0 / tex_laci.get_width())
		sp.z_index = 0
		add_child(sp)

	# ==========================================
	# 3. ZONE DAPUR & LAB FOTO (Top-Right)
	# ==========================================
	# Unit Dapur Lengkap Sesuai susunan.jpg (Lemari Atas, Meja Dapur, Kulkas Rapat Bersebelahan)
	if is_instance_valid(tex_kitchen_unit):
		var sp = Sprite2D.new()
		sp.texture = tex_kitchen_unit
		sp.position = ROOM_ORIGIN + Vector2(440.0, 80.0)
		sp.scale = Vector2(100.0 / tex_kitchen_unit.get_width(), 100.0 / tex_kitchen_unit.get_width())
		sp.z_index = 0
		add_child(sp)

	# Meja Kayu Lab Cuci Foto
	var sp_meja_foto: Sprite2D = null
	if is_instance_valid(tex_meja_lab_foto):
		sp_meja_foto = Sprite2D.new()
		sp_meja_foto.texture = tex_meja_lab_foto
		sp_meja_foto.position = ROOM_ORIGIN + Vector2(330.0, 85.0)
		sp_meja_foto.scale = Vector2(48.0 / tex_meja_lab_foto.get_width(), 48.0 / tex_meja_lab_foto.get_width())
		sp_meja_foto.z_index = 0
		add_child(sp_meja_foto)

	# Baskom Cuci Foto (Ditaruh tepat DI ATAS meja lab foto)
	if is_instance_valid(tex_baskom):
		var sp = Sprite2D.new()
		sp.texture = tex_baskom
		if is_instance_valid(sp_meja_foto):
			sp.position = Vector2(5.0, -2.0)
			sp.scale = Vector2(26.0 / (48.0 * (tex_baskom.get_width() / tex_meja_lab_foto.get_width())), 26.0 / (48.0 * (tex_baskom.get_width() / tex_meja_lab_foto.get_width())))
			sp_meja_foto.add_child(sp)
		else:
			sp.position = PHOTO_BASIN_POS
			sp.scale = Vector2(26.0 / tex_baskom.get_width(), 26.0 / tex_baskom.get_width())
			sp.z_index = 0
			add_child(sp)

	# ==========================================
	# 4. ZONE RUANG KERJA DETEKTIF & BRANKAS (Bottom-Right)
	# ==========================================
	# Meja Kerja Detektif Kayu (dengan bantalan kulit, lampu bankir, wadah tinta, dan buku catatan)
	var sp_meja: Sprite2D = null
	if is_instance_valid(tex_meja_detektif):
		sp_meja = Sprite2D.new()
		sp_meja.texture = tex_meja_detektif
		sp_meja.position = ROOM_ORIGIN + Vector2(410.0, 250.0)
		sp_meja.scale = Vector2(78.0 / tex_meja_detektif.get_width(), 78.0 / tex_meja_detektif.get_width())
		sp_meja.z_index = 0
		add_child(sp_meja)

	# Brankas Baja Keluarga (Di sudut ruang kerja, bebas box putih)
	if is_instance_valid(tex_berangkas):
		var sp = Sprite2D.new()
		sp.name = "SpriteBrankas"
		sp.texture = tex_berangkas
		sp.position = SAFE_POS
		sp.scale = Vector2(28.0 / tex_berangkas.get_width(), 28.0 / tex_berangkas.get_width())
		sp.z_index = 0
		add_child(sp)

	# Surat Penugasan (Ditaruh tepat DI ATAS meja kerja detektif secara realistis)
	if is_instance_valid(tex_surat):
		sprite_letter = Sprite2D.new()
		sprite_letter.name = "SpriteSurat"
		sprite_letter.texture = tex_surat
		if is_instance_valid(sp_meja):
			sprite_letter.position = Vector2(0.0, 0.0)
			var base_s = (18.0 / tex_surat.get_width()) / (78.0 / tex_meja_detektif.get_width())
			sprite_letter.scale = Vector2(base_s, base_s)
			sp_meja.add_child(sprite_letter)
		else:
			sprite_letter.position = DESK_LETTER_POS
			var s_factor = 18.0 / tex_surat.get_width()
			sprite_letter.scale = Vector2(s_factor, s_factor)
			sprite_letter.z_index = 0
			add_child(sprite_letter)

func _process(delta: float) -> void:
	letter_glow_time += delta * 3.5
	if is_instance_valid(sprite_letter) and tex_surat and tex_meja_detektif:
		var base_s = (18.0 / tex_surat.get_width()) / (78.0 / tex_meja_detektif.get_width())
		var s = base_s * (1.0 + 0.05 * sin(letter_glow_time))
		sprite_letter.scale = Vector2(s, s)
	queue_redraw()

func _draw() -> void:
	# ==========================================
	# 1. DASAR LANTAI PARQUET KAYU HANGAT
	# ==========================================
	var floor_rect = Rect2(ROOM_ORIGIN.x + 20.0, ROOM_ORIGIN.y + 40.0, ROOM_SIZE.x - 40.0, ROOM_SIZE.y - 60.0)
	draw_rect(floor_rect, Color(0.18, 0.14, 0.10), true)

	# Garis papan kayu lantai parquet
	var plank_h: float = 16.0
	var curr_y: float = floor_rect.position.y
	while curr_y < floor_rect.end.y:
		draw_line(Vector2(floor_rect.position.x, curr_y), Vector2(floor_rect.end.x, curr_y), Color(0.14, 0.10, 0.07, 0.5), 1.0)
		curr_y += plank_h

	# ==========================================
	# 2. LANTAI KERAMIK DAPUR (Top-Right)
	# ==========================================
	var tile_size: float = 20.0
	var kx_start = ROOM_ORIGIN.x + 280.0
	var kx_end = ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0
	var ky_start = ROOM_ORIGIN.y + 40.0
	var ky_end = ROOM_ORIGIN.y + 170.0

	var tx = kx_start
	while tx < kx_end:
		var ty = ky_start
		while ty < ky_end:
			var is_alt = int(floor((tx - kx_start) / tile_size) + floor((ty - ky_start) / tile_size)) % 2 == 0
			var tile_col = Color(0.22, 0.20, 0.19) if is_alt else Color(0.17, 0.16, 0.15)
			draw_rect(Rect2(tx, ty, tile_size, tile_size), tile_col, true)
			draw_rect(Rect2(tx, ty, tile_size, tile_size), Color(0.13, 0.12, 0.12), false, 1.0)
			ty += tile_size
		tx += tile_size

	# ==========================================
	# 3. DINDING LUAR BANGUNAN
	# ==========================================
	# Dinding Atas
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, ROOM_SIZE.x, 40.0), Color(0.12, 0.10, 0.14), true)
	draw_line(Vector2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + 40.0), Vector2(ROOM_ORIGIN.x + ROOM_SIZE.x, ROOM_ORIGIN.y + 40.0), Color(0.32, 0.24, 0.18), 3.0)

	# Dinding Kiri & Kanan
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y), Color(0.09, 0.08, 0.11), true)
	draw_rect(Rect2(ROOM_ORIGIN.x + ROOM_SIZE.x - 20.0, ROOM_ORIGIN.y, 20.0, ROOM_SIZE.y), Color(0.09, 0.08, 0.11), true)

	# Dinding Bawah Kiri & Kanan (dengan bukaan pintu di tengah)
	draw_rect(Rect2(ROOM_ORIGIN.x, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, 240.0, 20.0), Color(0.09, 0.08, 0.11), true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 300.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 20.0, 260.0, 20.0), Color(0.09, 0.08, 0.11), true)

	# ==========================================
	# 4. DINDING SEKAT PEMBATAS RUANGAN
	# ==========================================
	# Sekat Vertikal antara Sisi Kiri (Tamu/Kamar) dan Sisi Kanan (Dapur/Kerja)
	draw_rect(Rect2(ROOM_ORIGIN.x + 266.0, ROOM_ORIGIN.y + 40.0, 8.0, 110.0), Color(0.12, 0.10, 0.14), true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 266.0, ROOM_ORIGIN.y + 220.0, 8.0, 120.0), Color(0.12, 0.10, 0.14), true)
	# Lis kayu pembatas pintu
	draw_rect(Rect2(ROOM_ORIGIN.x + 264.0, ROOM_ORIGIN.y + 148.0, 12.0, 5.0), Color(0.32, 0.24, 0.18), true)
	draw_rect(Rect2(ROOM_ORIGIN.x + 264.0, ROOM_ORIGIN.y + 217.0, 12.0, 5.0), Color(0.32, 0.24, 0.18), true)

	# ==========================================
	# 5. ELEMEN INTERIOR TAMBAHAN
	# ==========================================
	# Kursi Kerja Detektif di belakang meja
	draw_rect(Rect2(DESK_LETTER_POS.x - 12.0, DESK_LETTER_POS.y - 32.0, 24.0, 8.0), Color(0.20, 0.13, 0.08), true)
	draw_rect(Rect2(DESK_LETTER_POS.x - 12.0, DESK_LETTER_POS.y - 32.0, 24.0, 8.0), Color(0.32, 0.20, 0.12), false, 1.0)

	# Efek Sorot Cahaya Meja Kerja Hangat di sekitar surat
	var glow_alpha = 0.20 + 0.08 * sin(letter_glow_time)
	draw_circle(DESK_LETTER_POS, 18.0, Color(1.0, 0.90, 0.45, glow_alpha))

	# Keset Pintu Masuk / Keluar
	var mat_rect = Rect2(ROOM_ORIGIN.x + 248.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 25.0, 44.0, 16.0)
	draw_rect(mat_rect, Color(0.50, 0.16, 0.16), true)
	draw_rect(mat_rect, Color(0.70, 0.26, 0.24), false, 1.5)

	# Cahaya Jendela Lembut (Sunbeam)
	var sun_points = PackedVector2Array([
		Vector2(ROOM_ORIGIN.x + 80.0, ROOM_ORIGIN.y + 40.0),
		Vector2(ROOM_ORIGIN.x + 150.0, ROOM_ORIGIN.y + 40.0),
		Vector2(ROOM_ORIGIN.x + 210.0, ROOM_ORIGIN.y + 240.0),
		Vector2(ROOM_ORIGIN.x + 90.0, ROOM_ORIGIN.y + 240.0)
	])
	draw_colored_polygon(sun_points, Color(1.0, 0.95, 0.75, 0.04))

	# Penanda Pintu Keluar
	draw_string(ThemeDB.fallback_font, Vector2(ROOM_ORIGIN.x + 242.0, ROOM_ORIGIN.y + ROOM_SIZE.y - 30.0), "PINTU KELUAR", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(1.0, 0.88, 0.55, 0.85))
