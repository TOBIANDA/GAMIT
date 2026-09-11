
extends SceneTree

func _init():
	print("--- TESTING OPENING CUTSCENE TIMINGS & AUDIO ---")
	var script = load("res://scripts/opening_cutscene.gd")
	var cs = Control.new()
	cs.set_script(script)
	root.add_child(cs)
	
	# Test CS1 initialization
	cs._start_cutscene_slide_1()
	print("CS1 state:", cs.current_state == cs.State.CS_IMAGE_1)
	print("CS1 timer:", cs.state_timer)
	assert(cs.state_timer >= 6.5) # Durasi CS1 agak lama (7.0s)
	print("Breathing audio active in CS1:", is_instance_valid(cs.breathing_player) and cs.breathing_player.playing)
	
	# Test transition to dim
	cs._start_fade_dim()
	print("Dim state:", cs.current_state == cs.State.CS_FADE_DIM)
	
	# Test CS2 initialization
	cs._start_cutscene_slide_2()
	print("CS2 state:", cs.current_state == cs.State.CS_IMAGE_2)
	print("CS2 timer:", cs.state_timer)
	assert(cs.state_timer <= 3.5 and cs.state_timer >= 2.0) # Durasi CS2 agak bentar (2.8s)
	print("Breathing audio stopped in CS2:", is_instance_valid(cs.breathing_player) and not cs.breathing_player.playing)
	assert(not cs.breathing_player.playing) # Suara berat TIDAK bunyi di CS2!
	
	print("--- CUTSCENE TESTS PASSED SUCCESSFULLY! ---")
	quit()
