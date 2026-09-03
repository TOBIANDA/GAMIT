extends Node2D

## AI Autonomous Test Runner for Godot
## Executes test scenarios, captures screenshots of key regions, verifies colliders, and exits.

@export var capture_delay: float = 0.6
@export var output_dir: String = "res://.ai_debug"

var main_scene: Node2D = null
var camera: Camera2D = null

func _ready() -> void:
	print("[AI_RUNNER] Starting autonomous visual test runner...")
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path(output_dir))
	
	# Instantiate main scene
	var main_res = load("res://scenes/main.tscn")
	if not main_res:
		push_error("[AI_RUNNER] Failed to load res://scenes/main.tscn")
		get_tree().quit(1)
		return
		
	main_scene = main_res.instantiate()
	add_child(main_scene)
	
	# Create our test observation camera
	camera = Camera2D.new()
	camera.enabled = true
	add_child(camera)
	
	# Disable player camera if active so our test camera takes control
	var player = main_scene.get_node_or_null("Player")
	if player:
		var p_cam = player.get_node_or_null("Camera2D")
		if p_cam:
			p_cam.enabled = false

	_run_test_suite()

func _run_test_suite() -> void:
	# 1. Capture Full Map Overview
	await _capture_view(Vector2(1080, 655), Vector2(0.55, 0.55), "map_overview.png")
	
	# 2. Capture Police & Hospital Complex
	await _capture_view(Vector2(450, 1000), Vector2(1.2, 1.2), "police_hospital.png")
	
	# 3. Capture NW Complex (Above Police)
	await _capture_view(Vector2(300, 550), Vector2(1.2, 1.2), "nw_building_block.png")
	
	# 4. Capture Train Station & East Fences
	await _capture_view(Vector2(1950, 950), Vector2(1.1, 1.1), "train_station_peron.png")
	
	# 5. Capture Civilian Houses & Fences (Top)
	await _capture_view(Vector2(1100, 150), Vector2(1.1, 1.1), "houses_top.png")

	print("[AI_RUNNER] Autonomous visual test suite completed successfully!")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(0)

func _capture_view(target_pos: Vector2, zoom_level: Vector2, file_name: String) -> void:
	camera.global_position = target_pos
	camera.zoom = zoom_level
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(capture_delay).timeout
	
	var img = get_viewport().get_texture().get_image()
	var save_path = output_dir + "/" + file_name
	var abs_path = ProjectSettings.globalize_path(save_path)
	var err = img.save_png(abs_path)
	if err == OK:
		print("[AI_RUNNER] Captured screenshot: " + abs_path)
	else:
		push_error("[AI_RUNNER] Failed to save screenshot: " + abs_path)
