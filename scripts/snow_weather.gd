extends CanvasLayer

var snow_particles_fg: CPUParticles2D
var snow_particles_mg: CPUParticles2D
var snow_particles_bg: CPUParticles2D

var wind_time: float = 0.0

func _ready() -> void:
	layer = 8
	_build_snow_layers()
	get_viewport().size_changed.connect(_on_viewport_resized)

func _build_snow_layers() -> void:
	var vp = get_viewport().get_visible_rect().size
	if vp.x < 100 or vp.y < 100:
		vp = Vector2(1600, 900)

	snow_particles_bg = CPUParticles2D.new()
	snow_particles_bg.position = Vector2(vp.x * 0.5, -20)
	snow_particles_bg.amount = 120
	snow_particles_bg.lifetime = 10.0
	snow_particles_bg.preprocess = 5.0
	snow_particles_bg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow_particles_bg.emission_rect_extents = Vector2(vp.x * 0.7, 10)
	snow_particles_bg.gravity = Vector2(-8, 35)
	snow_particles_bg.direction = Vector2(-0.2, 1.0)
	snow_particles_bg.spread = 15.0
	snow_particles_bg.initial_velocity_min = 20.0
	snow_particles_bg.initial_velocity_max = 45.0
	snow_particles_bg.scale_amount_min = 1.5
	snow_particles_bg.scale_amount_max = 3.0
	snow_particles_bg.color = Color(0.85, 0.92, 1.0, 0.45)
	add_child(snow_particles_bg)

	snow_particles_mg = CPUParticles2D.new()
	snow_particles_mg.position = Vector2(vp.x * 0.5, -30)
	snow_particles_mg.amount = 90
	snow_particles_mg.lifetime = 8.0
	snow_particles_mg.preprocess = 4.0
	snow_particles_mg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow_particles_mg.emission_rect_extents = Vector2(vp.x * 0.75, 10)
	snow_particles_mg.gravity = Vector2(-15, 60)
	snow_particles_mg.direction = Vector2(-0.3, 1.0)
	snow_particles_mg.spread = 20.0
	snow_particles_mg.initial_velocity_min = 35.0
	snow_particles_mg.initial_velocity_max = 75.0
	snow_particles_mg.scale_amount_min = 3.5
	snow_particles_mg.scale_amount_max = 6.0
	snow_particles_mg.color = Color(0.92, 0.96, 1.0, 0.75)
	add_child(snow_particles_mg)

	snow_particles_fg = CPUParticles2D.new()
	snow_particles_fg.position = Vector2(vp.x * 0.5, -40)
	snow_particles_fg.amount = 35
	snow_particles_fg.lifetime = 6.0
	snow_particles_fg.preprocess = 3.0
	snow_particles_fg.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow_particles_fg.emission_rect_extents = Vector2(vp.x * 0.8, 10)
	snow_particles_fg.gravity = Vector2(-22, 85)
	snow_particles_fg.direction = Vector2(-0.4, 1.0)
	snow_particles_fg.spread = 22.0
	snow_particles_fg.initial_velocity_min = 50.0
	snow_particles_fg.initial_velocity_max = 110.0
	snow_particles_fg.scale_amount_min = 7.0
	snow_particles_fg.scale_amount_max = 12.0
	snow_particles_fg.color = Color(1.0, 1.0, 1.0, 0.85)
	add_child(snow_particles_fg)

func _on_viewport_resized() -> void:
	var vp = get_viewport().get_visible_rect().size
	if is_instance_valid(snow_particles_bg):
		snow_particles_bg.position = Vector2(vp.x * 0.5, -20)
		snow_particles_bg.emission_rect_extents = Vector2(vp.x * 0.7, 10)
	if is_instance_valid(snow_particles_mg):
		snow_particles_mg.position = Vector2(vp.x * 0.5, -30)
		snow_particles_mg.emission_rect_extents = Vector2(vp.x * 0.75, 10)
	if is_instance_valid(snow_particles_fg):
		snow_particles_fg.position = Vector2(vp.x * 0.5, -40)
		snow_particles_fg.emission_rect_extents = Vector2(vp.x * 0.8, 10)

func _process(delta: float) -> void:
	wind_time += delta
	var wind_gust = sin(wind_time * 0.4) * 15.0

	if is_instance_valid(snow_particles_mg):
		snow_particles_mg.gravity.x = -15.0 + wind_gust
	if is_instance_valid(snow_particles_fg):
		snow_particles_fg.gravity.x = -22.0 + wind_gust * 1.5
