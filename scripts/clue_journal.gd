extends CanvasLayer

# ── Clue Log / Jurnal Investigasi Detektif Benedict (Sesuai GDD) ─────────────
# Menampilkan buku catatan investigasi, status bukti, teka-teki ibu, dan progres kasus.
# Dapat dibuka dengan tombol 'J' atau tombol HUD kapan saja.

signal journal_opened
signal journal_closed

var is_open: bool = false

# UI References
var root_panel: PanelContainer
var tab_container: TabContainer
var objective_label: Label
var objective_desc: Label
var progress_bar: ProgressBar
var progress_percent_label: Label
var clues_container: VBoxContainer
var safe_hint_label: Label
var close_btn: Button

func _ready() -> void:
	layer = 15 # Di atas HUD
	_build_journal_ui()
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_J:
			toggle_journal()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and is_open:
			close_journal()
			get_viewport().set_input_as_handled()

func toggle_journal() -> void:
	if is_open:
		close_journal()
	else:
		open_journal()

func open_journal() -> void:
	is_open = true
	visible = true
	_refresh_journal_data()
	journal_opened.emit()

func close_journal() -> void:
	is_open = false
	visible = false
	journal_closed.emit()

# ── Membangun UI Jurnal Detektif ────────────────────────────────────────────
func _build_journal_ui() -> void:
	var bg_overlay = ColorRect.new()
	bg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_overlay.color = Color(0.02, 0.02, 0.04, 0.82)
	add_child(bg_overlay)

	# Container Tengah
	var center_margin = MarginContainer.new()
	center_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_margin.add_theme_constant_override("margin_left", 80)
	center_margin.add_theme_constant_override("margin_right", 80)
	center_margin.add_theme_constant_override("margin_top", 50)
	center_margin.add_theme_constant_override("margin_bottom", 50)
	add_child(center_margin)

	# Panel Utama Buku Catatan
	root_panel = PanelContainer.new()
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = Color(0.08, 0.10, 0.15, 0.96)
	box_style.border_color = Color(0.35, 0.55, 0.85, 0.9)
	box_style.set_border_width_all(2)
	box_style.set_corner_radius_all(12)
	box_style.shadow_color = Color(0, 0, 0, 0.6)
	box_style.shadow_size = 12
	root_panel.add_theme_stylebox_override("panel", box_style)
	center_margin.add_child(root_panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 14)
	var margin_inner = MarginContainer.new()
	margin_inner.add_theme_constant_override("margin_left", 24)
	margin_inner.add_theme_constant_override("margin_right", 24)
	margin_inner.add_theme_constant_override("margin_top", 20)
	margin_inner.add_theme_constant_override("margin_bottom", 20)
	margin_inner.add_child(main_vbox)
	root_panel.add_child(margin_inner)

	# Header Bar
	var header_hbox = HBoxContainer.new()
	main_vbox.add_child(header_hbox)

	var title_lbl = Label.new()
	title_lbl.text = "📓 JURNAL INVESTIGASI DETEKTIF BENEDICT — KASUS TKP 404"
	title_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	title_lbl.add_theme_font_size_override("font_size", 20)
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)

	close_btn = Button.new()
	close_btn.text = "✖ Tutup [ESC / J]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close_journal)
	header_hbox.add_child(close_btn)

	var sep = HSeparator.new()
	main_vbox.add_child(sep)

	# Tab Container
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(tab_container)

	# Tab 1: Kasus & Lead Aktif
	var tab1 = VBoxContainer.new()
	tab1.name = "📋 Lead Aktif & Status"
	tab1.add_theme_constant_override("separation", 12)
	tab_container.add_child(tab1)
	_build_tab1_content(tab1)

	# Tab 2: Barang Bukti (Clue List)
	var tab2 = ScrollContainer.new()
	tab2.name = "🔍 Berkas Barang Bukti"
	tab2.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tab_container.add_child(tab2)
	clues_container = VBoxContainer.new()
	clues_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clues_container.add_theme_constant_override("separation", 10)
	tab2.add_child(clues_container)

	# Tab 3: Side Quest & Pesan Ibu Medeline
	var tab3 = VBoxContainer.new()
	tab3.name = "🗝️ Pesan Ibu & Brankas (Side Quest)"
	tab3.add_theme_constant_override("separation", 12)
	tab_container.add_child(tab3)
	_build_tab3_content(tab3)

func _build_tab1_content(parent: VBoxContainer) -> void:
	var pad = MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 14)
	pad.add_theme_constant_override("margin_right", 14)
	pad.add_theme_constant_override("margin_top", 14)
	pad.add_theme_constant_override("margin_bottom", 14)
	parent.add_child(pad)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	pad.add_child(vb)

	var obj_head = Label.new()
	obj_head.text = "🎯 TARGET PENYELIDIKAN SAAT INI:"
	obj_head.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	obj_head.add_theme_font_size_override("font_size", 16)
	vb.add_child(obj_head)

	objective_label = Label.new()
	objective_label.text = "Periksa Meja Kerja & Pergi ke Kantor Polisi"
	objective_label.add_theme_color_override("font_color", Color(1, 1, 1))
	objective_label.add_theme_font_size_override("font_size", 17)
	vb.add_child(objective_label)

	objective_desc = Label.new()
	objective_desc.text = "Deskripsi target..."
	objective_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_desc.add_theme_color_override("font_color", Color(0.75, 0.8, 0.9))
	objective_desc.add_theme_font_size_override("font_size", 14)
	vb.add_child(objective_desc)

	vb.add_child(HSeparator.new())

	# Progress Bar
	var prog_head = Label.new()
	prog_head.text = "📊 KEMAJUAN PENGUNGKAPAN KEBENARAN KASUS:"
	prog_head.add_theme_color_override("font_color", Color(0.9, 0.7, 0.4))
	prog_head.add_theme_font_size_override("font_size", 15)
	vb.add_child(prog_head)

	var prog_hbox = HBoxContainer.new()
	vb.add_child(prog_hbox)

	progress_bar = ProgressBar.new()
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.custom_minimum_size = Vector2(0, 24)
	progress_bar.max_value = 100
	progress_bar.value = 20
	prog_hbox.add_child(progress_bar)

	progress_percent_label = Label.new()
	progress_percent_label.text = " 22%"
	progress_percent_label.add_theme_font_size_override("font_size", 15)
	prog_hbox.add_child(progress_percent_label)

func _build_tab3_content(parent: VBoxContainer) -> void:
	var pad = MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 14)
	pad.add_theme_constant_override("margin_right", 14)
	pad.add_theme_constant_override("margin_top", 14)
	pad.add_theme_constant_override("margin_bottom", 14)
	parent.add_child(pad)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	pad.add_child(vb)

	var sq_title = Label.new()
	sq_title.text = "💎 SIDE QUEST: HADIAH PENINGGALAN IBU MEDELINE"
	sq_title.add_theme_color_override("font_color", Color(0.95, 0.65, 0.9))
	sq_title.add_theme_font_size_override("font_size", 16)
	vb.add_child(sq_title)

	safe_hint_label = Label.new()
	safe_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	safe_hint_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.95))
	safe_hint_label.add_theme_font_size_override("font_size", 14)
	safe_hint_label.text = "Pesan di balik foto: 'Benedict anakku... Jika kamu membaca ini, ambillah hadiah yang kutinggalkan di brankas rumah ibu (Gedung Arsip Kiri Bawah). Kuncinya adalah waktu ketika hidup kita membeku... 1 - 6 - 4.'"
	vb.add_child(safe_hint_label)

	var reward_info = Label.new()
	reward_info.text = "✦ Buka brankas untuk memperoleh 'Liontin Kenangan Ibu Medeline' sebagai Emotional Item untuk membuka True Ending di hadapan Sang Dewa!"
	reward_info.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6))
	reward_info.add_theme_font_size_override("font_size", 13)
	vb.add_child(reward_info)

# ── Update & Refresh Tampilan Data ──────────────────────────────────────────
func _refresh_journal_data() -> void:
	var inv_mgr = get_node_or_null("/root/InvestigationManager")
	if not is_instance_valid(inv_mgr):
		return

	# Update Tab 1
	if is_instance_valid(objective_label):
		objective_label.text = inv_mgr.get_current_objective_title()
	if is_instance_valid(objective_desc):
		objective_desc.text = inv_mgr.get_current_objective_desc()
	if is_instance_valid(progress_bar):
		var pct = inv_mgr.get_investigation_progress_percent()
		progress_bar.value = pct
		progress_percent_label.text = " %d%%" % pct

	# Update Tab 2 (Clues)
	if is_instance_valid(clues_container):
		for child in clues_container.get_children():
			child.queue_free()

		for clue_key in inv_mgr.clues.keys():
			var clue_data = inv_mgr.clues[clue_key]
			var card = _create_clue_card(clue_data)
			clues_container.add_child(card)

func _create_clue_card(clue: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.22, 0.9) if clue["unlocked"] else Color(0.06, 0.07, 0.10, 0.7)
	style.border_color = Color(0.3, 0.6, 0.9, 0.8) if clue["unlocked"] else Color(0.2, 0.2, 0.3, 0.4)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)

	var vb = VBoxContainer.new()
	panel.add_child(vb)

	var title = Label.new()
	title.text = clue["title"] if clue["unlocked"] else "🔒 [Bukti Terkunci / Belum Ditemukan]"
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4) if clue["unlocked"] else Color(0.5, 0.5, 0.5))
	title.add_theme_font_size_override("font_size", 15)
	vb.add_child(title)

	var desc = Label.new()
	desc.text = clue["desc"] if clue["unlocked"] else "Lanjutkan investigasi untuk mengungkap bukti ini."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9) if clue["unlocked"] else Color(0.4, 0.4, 0.4))
	desc.add_theme_font_size_override("font_size", 13)
	vb.add_child(desc)

	return panel
