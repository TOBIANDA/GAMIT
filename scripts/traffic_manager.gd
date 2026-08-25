extends Node2D

# ── City Traffic Manager - Smart Vehicle Spawner & Route Controller ─────────
# Fitur:
# 1. Mengatur jadwal lalu lintas mobil di seluruh jalan aspal kota.
# 2. 4 Rute Jalan Raya Utama (Jalan Atas 2 Arah, Jalan Rel Timur, Jalan Lingkar Bawah).
# 3. Penjadwalan Drop-off Penumpang NPC secara berkala di Stasiun & RS.
# 4. Batasan Maksimal Kendaraan (Maks 3 mobil aktif) agar jalanan rapi dan lancar.

@export var spawn_interval_min: float = 12.0
@export var spawn_interval_max: float = 18.0
@export var max_active_cars: int = 3

var spawn_timer: float = 3.0 # Mobil pertama muncul setelah 3 detik
var car_counter: int = 0

var car_scene = preload("res://scenes/car.tscn")

# ── 4 Rute Jalan Raya Resmi Kota ─────────────────────────────────────────────
var routes: Array[Dictionary] = [
	# Rute 1: Jalan Atas (Barat ➔ Timur) - Drop-off di Stasiun
	{
		"points": [Vector2(-80, 235), Vector2(1100, 235), Vector2(2088, 235), Vector2(2240, 235)],
		"drop_idx": 2
	},
	# Rute 2: Jalan Atas (Timur ➔ Barat) - Drop-off di Depan RS/Kantor
	{
		"points": [Vector2(2240, 280), Vector2(1100, 280), Vector2(594, 280), Vector2(-80, 280)],
		"drop_idx": 2
	},
	# Rute 3: Jalan Sisi Rel Timur (Utara ➔ Selatan) - Drop-off di Peron Stasiun
	{
		"points": [Vector2(2055, -80), Vector2(2055, 520), Vector2(2055, 1380)],
		"drop_idx": 1
	},
	# Rute 4: Jalan Lingkar Bawah (Barat ➔ Timur)
	{
		"points": [Vector2(320, 1278), Vector2(1200, 1278), Vector2(2240, 1278)],
		"drop_idx": -1
	}
]

func _ready() -> void:
	z_index = 0

func _process(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)
		_attempt_spawn_car()

func _attempt_spawn_car() -> void:
	var active_cars = get_tree().get_nodes_in_group("cars")
	if active_cars.size() >= max_active_cars:
		return

	if not is_instance_valid(car_scene):
		return

	car_counter += 1
	var route_dict = routes[randi() % routes.size()]
	var route_points: Array[Vector2] = route_dict["points"]
	var drop_idx: int = route_dict["drop_idx"]

	# Tipe Mobil: Taksi (0), Polisi (1), Sedan Hitam (2), Sedan Merah (3)
	var car_type_int = randi() % 4
	# Setiap mobil ke-2 atau ke-3 membawa penumpang untuk di-drop off
	var with_passenger = (car_counter % 2 == 0) and (drop_idx != -1)

	var new_car = car_scene.instantiate()
	add_child(new_car)
	new_car.initialize_route(route_points, car_type_int, with_passenger, drop_idx)
