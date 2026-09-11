extends Node2D
class_name RouteAndZoneEditor

signal config_saved
signal editor_toggled(is_open: bool)

enum EditMode {
	PATROL_ROUTE,
	RETURN_ROUTE,
	SPOOK_GRID,
	STATION_ZONE
}

var current_mode: EditMode = EditMode.PATROL_ROUTE
var is_active: bool = false

# Konfigurasi data
var cell_size: float = 32.0
var use_grid: bool = true

var patrol_waypoints: Array[Vector2] = []
var return_waypoints: Array[Vector2] = []
var spook_waypoints: Array[Vector2] = []

var station_shape: String = "rect" # "rect" atau "circle"
var station_rect: Rect2 = Rect2(1820.0, 680.0, 380.0, 280.0)
var station_circle_center: Vector2 = Vector2(1950.0, 780.0)
var station_circle_radius: float = 180.0

# State interaksi mouse
var selected_point_idx: int = -1
var is_dragging_point: bool = false
var is_dragging_station_zone: bool = false
var station_drag_offset: Vector2 = Vector2.ZERO
var hovered_grid_cell: Vector2i = Vector2i.ZERO

# UI Nodes
var editor_layer: CanvasLayer
var editor_panel: PanelContainer
var toggle_btn: Button
var mode_tabs_container: HBoxContainer
var status_banner: Label

var station_controls_box: VBoxContainer
var slider_width: HSlider
var slider_height: HSlider
var slider_radius: HSlider
var shape_option_btn: OptionButton
var width_label: Label
var height_label: Label
var radius_label: Label

var route_info_label: Label
var hint_label: Label

const CONFIG_PATH := "res://data/police_route_config.json"

func _ready() -> void:
	z_index = 50
	load_config_data()
	_setup_ui()
	visible = false

func load_config_data() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		return
	var data: Dictionary = json.data

	if data.has("grid_system") and data["grid_system"] is Dictionary:
		cell_size = float(data["grid_system"].get("cell_size", 32.0))

	use_grid = bool(data.get("use_grid_coordinates", true))

	# 1. Patrol
	patrol_waypoints.clear()
	if use_grid and data.has("police_patrol_route_grid") and data["police_patrol_route_grid"] is Array:
		for pt in data["police_patrol_route_grid"]:
			if pt is Array and pt.size() >= 2:
				patrol_waypoints.append(Vector2(float(pt[0]) * cell_size + cell_size * 0.5, float(pt[1]) * cell_size + cell_size * 0.5))
	elif data.has("police_patrol_route_pixels") and data["police_patrol_route_pixels"] is Array:
		for pt in data["police_patrol_route_pixels"]:
			if pt is Array and pt.size() >= 2:
				patrol_waypoints.append(Vector2(float(pt[0]), float(pt[1])))

	# 2. Return
	return_waypoints.clear()
	if use_grid and data.has("police_return_route_grid") and data["police_return_route_grid"] is Array:
		for pt in data["police_return_route_grid"]:
			if pt is Array and pt.size() >= 2:
				return_waypoints.append(Vector2(float(pt[0]) * cell_size + cell_size * 0.5, float(pt[1]) * cell_size + cell_size * 0.5))
	elif data.has("police_return_route_pixels") and data["police_return_route_pixels"] is Array:
		for pt in data["police_return_route_pixels"]:
			if pt is Array and pt.size() >= 2:
				return_waypoints.append(Vector2(float(pt[0]), float(pt[1])))

	# 3. Spook
	spook_waypoints.clear()
	if data.has("spook_run_settings") and data["spook_run_settings"] is Dictionary:
		var spk = data["spook_run_settings"]
		if spk.has("grid_waypoints") and spk["grid_waypoints"] is Array:
			for pt in spk["grid_waypoints"]:
				if pt is Array and pt.size() >= 2:
					spook_waypoints.append(Vector2(float(pt[0]) * cell_size + cell_size * 0.5, float(pt[1]) * cell_size + cell_size * 0.5))

	# 4. Station Zone
	if data.has("station_forced_scene_trigger") and data["station_forced_scene_trigger"] is Dictionary:
		var trg = data["station_forced_scene_trigger"]
		station_shape = String(trg.get("shape", "rect")).to_lower()
		if trg.has("rect") and trg["rect"] is Dictionary:
			var r = trg["rect"]
			station_rect = Rect2(
				float(r.get("x", 1820.0)),
				float(r.get("y", 680.0)),
				float(r.get("width", 380.0)),
				float(r.get("height", 280.0))
			)
		if trg.has("circle") and trg["circle"] is Dictionary:
			var c = trg["circle"]
			station_circle_center = Vector2(float(c.get("center_x", 1950.0)), float(c.get("center_y", 780.0)))
			station_circle_radius = float(c.get("radius", 180.0))

func save_config_data() -> bool:
	var patrol_grid: Array = []
	var patrol_px: Array = []
	for p in patrol_waypoints:
		patrol_px.append([round(p.x), round(p.y)])
		patrol_grid.append([floor(p.x / cell_size), floor(p.y / cell_size)])

	var return_grid: Array = []
	var return_px: Array = []
	for p in return_waypoints:
		return_px.append([round(p.x), round(p.y)])
		return_grid.append([floor(p.x / cell_size), floor(p.y / cell_size)])

	var spook_grid: Array = []
	for p in spook_waypoints:
		spook_grid.append([floor(p.x / cell_size), floor(p.y / cell_size)])

	var config_dict = {
		"_panduan": "Konfigurasi Alur Jalan Polisi (Grid), Arah Lari Merinding, dan Area Forced Scene Stasiun. Diedit otomatis lewat In-Game Editor [F3].",
		"grid_system": {
			"cell_size": cell_size,
			"_keterangan": "Ukuran tiap petak grid kecil dalam pixel."
		},
		"use_grid_coordinates": true,
		"police_patrol_route_grid": patrol_grid,
		"police_patrol_route_pixels": patrol_px,
		"police_return_route_grid": return_grid,
		"police_return_route_pixels": return_px,
		"station_forced_scene_trigger": {
			"shape": station_shape,
			"_keterangan_shape": "Pilih 'rect' atau 'circle'.",
			"rect": {
				"x": round(station_rect.position.x),
				"y": round(station_rect.position.y),
				"width": round(station_rect.size.x),
				"height": round(station_rect.size.y)
			},
			"circle": {
				"center_x": round(station_circle_center.x),
				"center_y": round(station_circle_center.y),
				"radius": round(station_circle_radius)
			}
		},
		"spook_run_settings": {
			"follow_grid": true,
			"fast_run_speed": 180.0,
			"run_duration": 3.5,
			"_keterangan": "Titik grid yang dilewati saat lari ketakutan.",
			"grid_waypoints": spook_grid
		}
	}

	var json_str = JSON.stringify(config_dict, "    ")
	var file = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if not file:
		_show_status("Gagal menyimpan file konfigurasi!", Color.SALMON)
		return false
	file.store_string(json_str)
	file.close()

	config_saved.emit()
	_show_status("✔ Konfigurasi Rute & Zona Stasiun berhasil disimpan!", Color.LIGHT_GREEN)
	return true

func toggle_editor() -> void:
	is_active = not is_active
	visible = is_active
	if is_instance_valid(editor_panel):
		editor_panel.visible = is_active
	if is_active:
		if is_instance_valid(toggle_btn):
			toggle_btn.text = "Tutup Editor [F3]"
			toggle_btn.modulate = Color(1.0, 0.45, 0.45)
		load_config_data()
		_update_ui_for_mode()
	else:
		if is_instance_valid(toggle_btn):
			toggle_btn.text = "Atur Rute & Zona [F3]"
			toggle_btn.modulate = Color(1.0, 1.0, 1.0)
		selected_point_idx = -1
		is_dragging_point = false
		is_dragging_station_zone = false

	editor_toggled.emit(is_active)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_F3:
			toggle_editor()
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	var mouse_world = get_global_mouse_position()
	hovered_grid_cell = Vector2i(floor(mouse_world.x / cell_size), floor(mouse_world.y / cell_size))

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_handle_left_click(mouse_world)
			else:
				is_dragging_point = false
				is_dragging_station_zone = false
			queue_redraw()
			get_viewport().set_input_as_handled()

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_right_click(mouse_world)
			queue_redraw()
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion:
		if is_dragging_point and selected_point_idx >= 0:
			var snapped_pos = Vector2(hovered_grid_cell.x * cell_size + cell_size * 0.5, hovered_grid_cell.y * cell_size + cell_size * 0.5)
			_set_active_point_pos(selected_point_idx, snapped_pos)
			queue_redraw()
		elif is_dragging_station_zone:
			if station_shape == "rect":
				station_rect.position = mouse_world - station_drag_offset
			else:
				station_circle_center = mouse_world - station_drag_offset
			queue_redraw()
		else:
			queue_redraw()

func _handle_left_click(mouse_world: Vector2) -> void:
	if current_mode == EditMode.STATION_ZONE:
		if station_shape == "rect":
			if station_rect.has_point(mouse_world):
				is_dragging_station_zone = true
				station_drag_offset = mouse_world - station_rect.position
				_show_status("Menggeser Zona Stasiun...", Color.YELLOW)
		else:
			if mouse_world.distance_to(station_circle_center) <= station_circle_radius:
				is_dragging_station_zone = true
				station_drag_offset = mouse_world - station_circle_center
				_show_status("Menggeser Zona Stasiun...", Color.YELLOW)
		return

	# Mode Rute (Patrol, Return, Spook)
	var pts = _get_active_points_list()
	for i in range(pts.size()):
		if mouse_world.distance_to(pts[i]) <= 18.0:
			selected_point_idx = i
			is_dragging_point = true
			_show_status("Memilih Titik %d (Geser untuk memindahkan)" % (i + 1), Color.AQUAMARINE)
			_update_route_info()
			return

	# Jika klik di petak grid kosong, tambahkan titik baru pada petak tersebut!
	var snapped_new = Vector2(hovered_grid_cell.x * cell_size + cell_size * 0.5, hovered_grid_cell.y * cell_size + cell_size * 0.5)
	pts.append(snapped_new)
	selected_point_idx = pts.size() - 1
	_show_status("Titik %d ditambahkan pada petak [%d, %d]" % [pts.size(), hovered_grid_cell.x, hovered_grid_cell.y], Color.LIGHT_GREEN)
	_update_route_info()

func _handle_right_click(mouse_world: Vector2) -> void:
	if current_mode == EditMode.STATION_ZONE:
		return

	var pts = _get_active_points_list()
	for i in range(pts.size() - 1, -1, -1):
		if mouse_world.distance_to(pts[i]) <= 20.0:
			var removed_num = i + 1
			pts.remove_at(i)
			selected_point_idx = -1
			_show_status("Titik %d berhasil dihapus!" % removed_num, Color.ORANGE)
			_update_route_info()
			return

func _get_active_points_list() -> Array[Vector2]:
	match current_mode:
		EditMode.PATROL_ROUTE:
			return patrol_waypoints
		EditMode.RETURN_ROUTE:
			return return_waypoints
		EditMode.SPOOK_GRID:
			return spook_waypoints
	return patrol_waypoints

func _set_active_point_pos(idx: int, pos: Vector2) -> void:
	var pts = _get_active_points_list()
	if idx >= 0 and idx < pts.size():
		pts[idx] = pos
		_update_route_info()

func _draw() -> void:
	if not is_active:
		return

	var font = ThemeDB.fallback_font

	# 1. Gambar Grid Transparan di sekitar camera/viewport
	var cam_pos = get_global_mouse_position()
	var vp_size = get_viewport_rect().size * 1.5
	var start_x = floor((cam_pos.x - vp_size.x * 0.6) / cell_size) * cell_size
	var end_x   = ceil((cam_pos.x + vp_size.x * 0.6) / cell_size) * cell_size
	var start_y = floor((cam_pos.y - vp_size.y * 0.6) / cell_size) * cell_size
	var end_y   = ceil((cam_pos.y + vp_size.y * 0.6) / cell_size) * cell_size

	var grid_color = Color(0.2, 0.6, 0.9, 0.14)
	var x = start_x
	while x <= end_x:
		draw_line(Vector2(x, start_y), Vector2(x, end_y), grid_color, 1.0)
		x += cell_size

	var y = start_y
	while y <= end_y:
		draw_line(Vector2(start_x, y), Vector2(end_x, y), grid_color, 1.0)
		y += cell_size

	# 2. Highlight Petak Grid di Bawah Mouse
	var h_rect = Rect2(hovered_grid_cell.x * cell_size, hovered_grid_cell.y * cell_size, cell_size, cell_size)
	draw_rect(h_rect, Color(0.2, 0.85, 1.0, 0.22), true)
	draw_rect(h_rect, Color(0.4, 0.95, 1.0, 0.8), false, 1.5)
	draw_string(font, h_rect.position + Vector2(4, 14), "[%d,%d]" % [hovered_grid_cell.x, hovered_grid_cell.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.95, 1.0, 0.85))

	# 3. Gambar Semua Jalur Rute
	_draw_route_path(patrol_waypoints, Color(0.15, 0.65, 1.0), "Patroli", current_mode == EditMode.PATROL_ROUTE)
	_draw_route_path(return_waypoints, Color(0.2, 0.9, 0.5), "Pulang", current_mode == EditMode.RETURN_ROUTE)
	_draw_route_path(spook_waypoints, Color(1.0, 0.65, 0.15), "Merinding", current_mode == EditMode.SPOOK_GRID)

	# 4. Gambar Zona Forced Scene Stasiun
	var is_zone_active = (current_mode == EditMode.STATION_ZONE)
	var fill_color = Color(0.95, 0.2, 0.3, 0.28 if is_zone_active else 0.15)
	var border_color = Color(1.0, 0.3, 0.4, 0.95 if is_zone_active else 0.6)

	if station_shape == "rect":
		draw_rect(station_rect, fill_color, true)
		draw_rect(station_rect, border_color, false, 2.5 if is_zone_active else 1.5)
		var center_pt = station_rect.position + station_rect.size * 0.5
		draw_line(center_pt - Vector2(16, 0), center_pt + Vector2(16, 0), Color.YELLOW, 2.0)
		draw_line(center_pt - Vector2(0, 16), center_pt + Vector2(0, 16), Color.YELLOW, 2.0)
		draw_string(font, station_rect.position + Vector2(8, 22), "🚉 ZONA FORCED SCENE STASIUN (RECT: %.0fx%.0f)" % [station_rect.size.x, station_rect.size.y], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 0.9, 0.3))
	else:
		draw_circle(station_circle_center, station_circle_radius, fill_color)
		draw_arc(station_circle_center, station_circle_radius, 0, TAU, 64, border_color, 2.5 if is_zone_active else 1.5)
		draw_line(station_circle_center - Vector2(16, 0), station_circle_center + Vector2(16, 0), Color.YELLOW, 2.0)
		draw_line(station_circle_center - Vector2(0, 16), station_circle_center + Vector2(0, 16), Color.YELLOW, 2.0)
		draw_string(font, station_circle_center + Vector2(-110, -station_circle_radius - 8), "🚉 ZONA FORCED SCENE STASIUN (CIRCLE R: %.0f)" % station_circle_radius, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 0.9, 0.3))

func _draw_route_path(pts: Array[Vector2], col: Color, label_tag: String, is_selected: bool) -> void:
	if pts.is_empty():
		return

	var font = ThemeDB.fallback_font
	var line_alpha = 0.95 if is_selected else 0.35
	var line_col = Color(col.r, col.g, col.b, line_alpha)
	var thick = 3.0 if is_selected else 1.5

	# Garis penghubung
	for i in range(pts.size() - 1):
		draw_line(pts[i], pts[i + 1], line_col, thick)
		# Panah arah kecil
		var mid = (pts[i] + pts[i + 1]) * 0.5
		var dir = (pts[i + 1] - pts[i]).normalized()
		var norm = Vector2(-dir.y, dir.x)
		draw_line(mid, mid - dir * 8.0 + norm * 5.0, line_col, 2.0)
		draw_line(mid, mid - dir * 8.0 - norm * 5.0, line_col, 2.0)

	# Titik lingkaran
	for i in range(pts.size()):
		var p = pts[i]
		var is_this_selected = is_selected and (i == selected_point_idx)
		var r = 12.0 if is_this_selected else (9.0 if is_selected else 6.0)

		# Bulatan background
		draw_circle(p, r, Color(0.05, 0.08, 0.12, 0.9))
		draw_circle(p, r - 2.0, Color(col.r, col.g, col.b, 0.9 if is_selected else 0.5))
		if is_this_selected:
			draw_arc(p, r + 4.0, 0, TAU, 32, Color.YELLOW, 2.5)

		# Nomor urutan titik
		if is_selected:
			draw_string(font, p + Vector2(-4, 5), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color.WHITE)

func _setup_ui() -> void:
	editor_layer = CanvasLayer.new()
	editor_layer.layer = 28
	add_child(editor_layer)

	# 1. Tombol Toggle di HUD (Kanan Atas)
	toggle_btn = Button.new()
	toggle_btn.text = "Atur Rute & Zona [F3]"
	toggle_btn.focus_mode = Control.FOCUS_NONE
	toggle_btn.anchor_left = 1.0
	toggle_btn.anchor_right = 1.0
	toggle_btn.offset_left = -290.0
	toggle_btn.offset_right = -110.0
	toggle_btn.offset_top = 22.0
	toggle_btn.offset_bottom = 58.0
	toggle_btn.custom_minimum_size = Vector2(180, 36)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.12, 0.22, 0.32, 0.94)
	btn_style.border_color = Color(0.35, 0.85, 1.0, 1.0)
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(6)
	btn_style.content_margin_left = 10
	btn_style.content_margin_right = 10
	toggle_btn.add_theme_stylebox_override("normal", btn_style)
	toggle_btn.pressed.connect(toggle_editor)
	editor_layer.add_child(toggle_btn)

	# 2. Panel Editor Utama (Kiri Atas)
	editor_panel = PanelContainer.new()
	editor_panel.visible = false
	editor_panel.position = Vector2(25, 75)
	editor_panel.custom_minimum_size = Vector2(440, 500)

	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.07, 0.09, 0.13, 0.96)
	p_style.border_color = Color(0.3, 0.85, 1.0, 0.95)
	p_style.set_border_width_all(2)
	p_style.set_corner_radius_all(10)
	p_style.content_margin_left = 18
	p_style.content_margin_right = 18
	p_style.content_margin_top = 16
	p_style.content_margin_bottom = 16
	editor_panel.add_theme_stylebox_override("panel", p_style)
	editor_layer.add_child(editor_panel)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	editor_panel.add_child(vb)

	# Header Title
	var title = Label.new()
	title.text = "❖ EDITOR VISUAL RUTE POLISI & ZONA STASIUN ❖"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	vb.add_child(title)

	# Status Toast Banner
	status_banner = Label.new()
	status_banner.text = "Siap mengedit. Klik petak grid di map untuk tambah titik."
	status_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_banner.add_theme_font_size_override("font_size", 12)
	status_banner.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	vb.add_child(status_banner)

	vb.add_child(HSeparator.new())

	# Tab Pemilihan Mode
	mode_tabs_container = HBoxContainer.new()
	mode_tabs_container.add_theme_constant_override("separation", 6)
	vb.add_child(mode_tabs_container)

	_add_mode_tab("👮 Patroli", EditMode.PATROL_ROUTE)
	_add_mode_tab("🏠 Pulang", EditMode.RETURN_ROUTE)
	_add_mode_tab("⚡ Merinding", EditMode.SPOOK_GRID)
	_add_mode_tab("🚉 Zona Stasiun", EditMode.STATION_ZONE)

	vb.add_child(HSeparator.new())

	# Label Info Rute
	route_info_label = Label.new()
	route_info_label.text = "Total Titik: 0"
	route_info_label.add_theme_font_size_override("font_size", 13)
	vb.add_child(route_info_label)

	# Petunjuk Cara Pakai
	hint_label = Label.new()
	hint_label.text = "💡 Klik Kiri pada petak grid untuk tambah/pilih titik.\n💡 Klik Kanan pada titik untuk menghapus.\n💡 Drag titik untuk geser posisi."
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.85))
	vb.add_child(hint_label)

	# Box Khusus Pengaturan Zona Stasiun ("Seperti Mengatur Barang Rumah")
	station_controls_box = VBoxContainer.new()
	station_controls_box.visible = false
	station_controls_box.add_theme_constant_override("separation", 8)
	vb.add_child(station_controls_box)

	var shape_row = HBoxContainer.new()
	var shape_lbl = Label.new()
	shape_lbl.text = "Bentuk Zona:"
	shape_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shape_row.add_child(shape_lbl)

	shape_option_btn = OptionButton.new()
	shape_option_btn.add_item("Persegi Panjang (Rect)", 0)
	shape_option_btn.add_item("Lingkaran (Circle)", 1)
	shape_option_btn.item_selected.connect(_on_shape_selected)
	shape_row.add_child(shape_option_btn)
	station_controls_box.add_child(shape_row)

	width_label = Label.new()
	width_label.text = "Lebar (Width): 380 px"
	station_controls_box.add_child(width_label)
	slider_width = HSlider.new()
	slider_width.min_value = 100.0
	slider_width.max_value = 1000.0
	slider_width.step = 10.0
	slider_width.value = station_rect.size.x
	slider_width.value_changed.connect(func(val):
		station_rect.size.x = val
		width_label.text = "Lebar (Width): %.0f px" % val
		queue_redraw()
	)
	station_controls_box.add_child(slider_width)

	height_label = Label.new()
	height_label.text = "Tinggi (Height): 280 px"
	station_controls_box.add_child(height_label)
	slider_height = HSlider.new()
	slider_height.min_value = 80.0
	slider_height.max_value = 800.0
	slider_height.step = 10.0
	slider_height.value = station_rect.size.y
	slider_height.value_changed.connect(func(val):
		station_rect.size.y = val
		height_label.text = "Tinggi (Height): %.0f px" % val
		queue_redraw()
	)
	station_controls_box.add_child(slider_height)

	radius_label = Label.new()
	radius_label.text = "Radius: 180 px"
	station_controls_box.add_child(radius_label)
	slider_radius = HSlider.new()
	slider_radius.min_value = 50.0
	slider_radius.max_value = 500.0
	slider_radius.step = 10.0
	slider_radius.value = station_circle_radius
	slider_radius.value_changed.connect(func(val):
		station_circle_radius = val
		radius_label.text = "Radius: %.0f px" % val
		queue_redraw()
	)
	station_controls_box.add_child(slider_radius)

	# Tombol Tindakan Cepat
	var action_row = HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 6)
	vb.add_child(action_row)

	var btn_clear = Button.new()
	btn_clear.text = "🗑 Bersihkan"
	btn_clear.pressed.connect(_on_clear_current_route)
	action_row.add_child(btn_clear)

	var btn_undo = Button.new()
	btn_undo.text = "↩ Hapus Terakhir"
	btn_undo.pressed.connect(_on_undo_last_point)
	action_row.add_child(btn_undo)

	vb.add_child(HSeparator.new())

	# Tombol Simpan & Tutup
	var bottom_row = HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	vb.add_child(bottom_row)

	var btn_save = Button.new()
	btn_save.text = "💾 Simpan Konfigurasi"
	btn_save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var save_style = StyleBoxFlat.new()
	save_style.bg_color = Color(0.1, 0.45, 0.25, 0.95)
	save_style.set_corner_radius_all(6)
	btn_save.add_theme_stylebox_override("normal", save_style)
	btn_save.pressed.connect(func(): save_config_data())
	bottom_row.add_child(btn_save)

	var btn_close = Button.new()
	btn_close.text = "✕ Tutup [F3]"
	btn_close.pressed.connect(toggle_editor)
	bottom_row.add_child(btn_close)

func _add_mode_tab(text: String, mode: EditMode) -> void:
	var b = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(func():
		current_mode = mode
		selected_point_idx = -1
		_update_ui_for_mode()
		queue_redraw()
	)
	mode_tabs_container.add_child(b)

func _update_ui_for_mode() -> void:
	if is_instance_valid(mode_tabs_container):
		for idx in range(mode_tabs_container.get_child_count()):
			var b = mode_tabs_container.get_child(idx) as Button
			if is_instance_valid(b):
				if idx == int(current_mode):
					b.modulate = Color(0.4, 0.95, 1.0)
				else:
					b.modulate = Color(0.7, 0.7, 0.7)

	if current_mode == EditMode.STATION_ZONE:
		if is_instance_valid(station_controls_box):
			station_controls_box.visible = true
		if is_instance_valid(route_info_label):
			route_info_label.text = "Mode Pengaturan: Zona Forced Scene Stasiun"
		if is_instance_valid(hint_label):
			hint_label.text = "💡 Klik & geser kotak/lingkaran merah di peron stasiun untuk memindahkannya.\n💡 Gunakan slider di bawah untuk mengatur ukuran lebar, tinggi, atau radius."
		if is_instance_valid(shape_option_btn):
			shape_option_btn.selected = 0 if station_shape == "rect" else 1
			_on_shape_selected(shape_option_btn.selected)
	else:
		if is_instance_valid(station_controls_box):
			station_controls_box.visible = false
		_update_route_info()

func _update_route_info() -> void:
	if current_mode == EditMode.STATION_ZONE:
		return
	if not is_instance_valid(route_info_label):
		return
	var pts = _get_active_points_list()
	var mode_name = "Rute Patroli Polisi" if current_mode == EditMode.PATROL_ROUTE else ("Rute Pulang Polisi" if current_mode == EditMode.RETURN_ROUTE else "Jalur Lari Merinding")
	route_info_label.text = "[ %s ] Total: %d titik" % [mode_name, pts.size()]
	if selected_point_idx >= 0 and selected_point_idx < pts.size():
		var p = pts[selected_point_idx]
		route_info_label.text += " | Terpilih: Titik %d (X:%.0f, Y:%.0f)" % [selected_point_idx + 1, p.x, p.y]

func _on_shape_selected(idx: int) -> void:
	station_shape = "rect" if idx == 0 else "circle"
	width_label.visible = (station_shape == "rect")
	slider_width.visible = (station_shape == "rect")
	height_label.visible = (station_shape == "rect")
	slider_height.visible = (station_shape == "rect")
	radius_label.visible = (station_shape == "circle")
	slider_radius.visible = (station_shape == "circle")
	queue_redraw()

func _on_clear_current_route() -> void:
	if current_mode == EditMode.STATION_ZONE:
		return
	var pts = _get_active_points_list()
	pts.clear()
	selected_point_idx = -1
	_show_status("Semua titik rute berhasil dibersihkan!", Color.ORANGE)
	_update_route_info()
	queue_redraw()

func _on_undo_last_point() -> void:
	if current_mode == EditMode.STATION_ZONE:
		return
	var pts = _get_active_points_list()
	if not pts.is_empty():
		pts.pop_back()
		selected_point_idx = -1
		_show_status("Titik terakhir dihapus.", Color.YELLOW)
		_update_route_info()
		queue_redraw()

func _show_status(msg: String, col: Color = Color.WHITE) -> void:
	if is_instance_valid(status_banner):
		status_banner.text = msg
		status_banner.modulate = col
