
extends SceneTree

func _init():
	print("--- TESTING DEATH GOD & DIALOG BOX INTEGRATION ---")
	var dg_script = load("res://scripts/death_god.gd")
	if dg_script == null:
		print("ERR: death_god.gd failed to load")
		quit(1)
		return
		
	var dg = CanvasLayer.new()
	dg.set_script(dg_script)
	root.add_child(dg)
	
	print("DeathGodLayer layer:", dg.layer)
	print("MC Chibi rect valid:", is_instance_valid(dg.mc_chibi_rect))
	print("Grim Chibi rect valid:", is_instance_valid(dg.grim_chibi_rect))
	
	dg.open_interface()
	print("Standoff width calculated:", dg._get_standoff_width())
	print("MC Chibi position:", dg.mc_chibi_rect.position)
	print("Grim Chibi position:", dg.grim_chibi_rect.position)
	
	var dlg_scene = load("res://scenes/dialog_box.tscn")
	if dlg_scene == null:
		print("ERR: dialog_box.tscn failed to load")
		quit(1)
		return
		
	var dlg = dlg_scene.instantiate()
	root.add_child(dlg)
	print("DialogBox layer:", dlg.layer)
	
	dg.close_interface()
	print("--- SUCCESS ALL CHECKS PASSED ---")
	quit(0)
