
extends SceneTree

func _init():
	print("--- TESTING MINIGAME PHOTO WASH ---")
	var script = load("res://scripts/minigame_photo_wash.gd")
	var node = CanvasLayer.new()
	node.set_script(script)
	root.add_child(node)
	
	node.start_minigame()
	print("Step 0 active:", node.current_step == 0)
	
	# Transition to step 1
	node._setup_qte_step()
	print("Step 1 active:", node.current_step == 1)
	print("Initial photo idx:", node.current_photo_idx)
	print("Initial sub_click:", node.photo_sub_click)
	assert(node.photo_sub_click == 0)
	assert(node.current_photo_idx == 0)
	
	# Test click 1 hit (slider at 0.5)
	node.slider_val = 0.5
	node._try_qte_hit()
	print("After hit 1: sub_click =", node.photo_sub_click, "zone size =", node.ZONE_SIZES[node.photo_sub_click])
	assert(node.photo_sub_click == 1)
	
	# Test click 2 hit (slider at 0.5)
	node.slider_val = 0.5
	node._try_qte_hit()
	print("After hit 2: sub_click =", node.photo_sub_click, "zone size =", node.ZONE_SIZES[node.photo_sub_click])
	assert(node.photo_sub_click == 2)
	
	# Test MISS on click 3 (slider at 0.05 - outside zone)
	node.slider_val = 0.05
	node._try_qte_hit()
	print("After MISS on click 3: sub_click =", node.photo_sub_click, "(expected 0 - reset to click 1!)")
	assert(node.photo_sub_click == 0)
	assert(node.ZONE_SIZES[node.photo_sub_click] == 0.42)
	
	# Now complete all 4 clicks for photo 1
	for i in range(4):
		node.slider_val = 0.5
		node._try_qte_hit()
	print("After completing photo 1: current_photo_idx =", node.current_photo_idx, "sub_click =", node.photo_sub_click)
	assert(node.current_photo_idx == 1)
	assert(node.photo_sub_click == 0)
	assert(node.ZONE_SIZES[node.photo_sub_click] == 0.42)
	
	# Complete remaining 3 photos
	for p in range(1, 4):
		for i in range(4):
			node.slider_val = 0.5
			node._try_qte_hit()
	print("All photos completed! Step =", node.current_step)
	assert(node.current_step == 2) # Revelation step
	
	print("--- ALL MINIGAME PHOTO WASH TESTS PASSED! ---")
	quit()
