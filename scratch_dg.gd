extends SceneTree

func _init():
	var dg_script = load("res://scripts/death_god.gd")
	var dg = CanvasLayer.new()
	dg.set_script(dg_script)
	root.add_child(dg)
	
	print("Initial size: ", dg.standoff_panel.size)
	dg.open_interface()
	print("After open:")
	print("  standoff_panel.size: ", dg.standoff_panel.size)
	print("  mc_chibi_rect.position: ", dg.mc_chibi_rect.position, " size: ", dg.mc_chibi_rect.size, " visible: ", dg.mc_chibi_rect.is_visible_in_tree(), " tex: ", dg.mc_chibi_rect.texture)
	print("  grim_chibi_rect.position: ", dg.grim_chibi_rect.position, " size: ", dg.grim_chibi_rect.size, " visible: ", dg.grim_chibi_rect.is_visible_in_tree(), " tex: ", dg.grim_chibi_rect.texture)
	print("  mc_label.position: ", dg.mc_label.position)
	print("  grim_label.position: ", dg.grim_label.position)
	print("  vs_symbol_label.position: ", dg.vs_symbol_label.position)
	print("  content_hb.modulate.a: ", dg.content_hb.modulate.a)
	print("  layer: ", dg.layer)
	quit()
