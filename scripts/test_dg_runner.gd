extends SceneTree

func _init():
	print('--- TEST DEATH GOD INIT ---')
	var script = load('res://scripts/death_god.gd')
	var dg = CanvasLayer.new()
	dg.set_script(script)
	root.add_child(dg)
	print('standoff_panel size before:', dg.standoff_panel.size)
	dg.open_interface()
	print('standoff_panel size after:', dg.standoff_panel.size)
	print('mc chibi pos:', dg.mc_chibi_rect.position)
	print('grim chibi pos:', dg.grim_chibi_rect.position)
	print('content_hb a:', dg.content_hb.modulate.a)
	print('--- DONE ---')
	quit()
