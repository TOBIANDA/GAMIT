extends CanvasLayer

signal death_god_closed
signal afterlife_ascended

const SERVER_URL = "http://127.0.0.1:8000"
const TYPING_SPEED = 0.03

var is_active: bool = false
var current_question_idx: int = 0
var correct_answers_count: int = 0
var is_ending_screen: bool = false

# UI Elements
var bg: ColorRect
var title_label: Label
var grim_portrait_rect: TextureRect
var question_box: PanelContainer
var prompt_label: Label
var options_container: VBoxContainer
var feedback_label: Label
var progress_label: Label
var close_btn: Button

# NLP freeform mode toggle
var nlp_panel: VBoxContainer
var input_field: LineEdit
var submit_btn: Button
var score_label: Label
var loading_label: Label
var is_typing: bool = false
var full_response: String = ""
var char_index: int = 0
var typing_timer: float = 0.0

var afterlife_audio: AudioStreamPlayer

const QUESTIONS = [
	{
		"q": "Pertanyaan Pertama:\nJam berapa jarum waktu kota membeku saat detik terakhir hidupmu?",
		"options": [
			{"text": "A. Pukul 12:00 Siang", "correct": false},
			{"text": "B. Pukul 16:04 Sore", "correct": true},
			{"text": "C. Pukul 19:30 Malam", "correct": false}
		],
		"correct_feedback": "✦ Tepat. Pukul 16:04... saat itulah denyut jantungmu di dunia berhenti berdetak."
	},
	{
		"q": "Pertanyaan Kedua:\nMengapa orang-orang yang kau sapa di jalanan bergidik dingin dan tak menyahut?",
		"options": [
			{"text": "A. Karena warga kota sedang terburu-buru", "correct": false},
			{"text": "B. Karena ragamu sudah tiada — mereka hanya merasakan hawa dingin arwahmu", "correct": true},
			{"text": "C. Karena angin musim gugur bertiup kencang", "correct": false}
		],
		"correct_feedback": "✦ Benar. Manusia fana hanya merasakan hawa dingin menusuk saat arwahmu melintas."
	},
	{
		"q": "Pertanyaan Ketiga:\nSiapakah sosok korban sebenarnya yang tercetak di foto peron dan terbaring di ruang jenazah?",
		"options": [
			{"text": "A. Penumpang kereta asing yang tak dikenal", "correct": false},
			{"text": "B. Inspektur Marcus dari kepolisian", "correct": false},
			{"text": "C. Diriku sendiri... Detektif Benedict", "correct": true}
		],
		"correct_feedback": "✦ Kau akhirnya berani mengakui kenyataan ini. Seluruh penyelidikanmu adalah pencarian jiwa atas jasadmu sendiri."
	},
	{
		"q": "Pertanyaan Terakhir (Penerimaan Jiwa):\nBagaimana sikapmu sekarang terhadap takdir kematianmu?",
		"options": [
			{"text": "A. Aku ikhlas menerima kematianku. Tugas dan penyelidikanku telah tuntas, aku siap beristirahat dalam damai.", "correct": true},
			{"text": "B. Aku masih menolak dan ingin kembali ke dunia orang hidup.", "correct": false}
		],
		"correct_feedback": "✦ Jiwamu telah ikhlas dan damai. Ikatan penyesalan di dunia fana kini terlepas selamanya..."
	}
]

func _ready() -> void:
	layer = 20
	_setup_audio()
	_build_ui()
	visible = false

func _setup_audio() -> void:
	afterlife_audio = AudioStreamPlayer.new()
	afterlife_audio.name = "AfterlifePlayer"
	if ResourceLoader.exists("res://sound/Afterlife.mp3"):
		afterlife_audio.stream = load("res://sound/Afterlife.mp3")
		afterlife_audio.volume_db = -5.0
	add_child(afterlife_audio)

func _build_ui() -> void:
	bg = ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.06, 0.97)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	margin.add_child(vb)

	# Header
	var header = HBoxContainer.new()
	vb.add_child(header)

	title_label = Label.new()
	title_label.text = "✦ ALAM KEABADIAN — PENGHAKIMAN DEWA KEMATIAN ✦"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_color_override("font_color", Color(0.85, 0.70, 1.0))
	title_label.add_theme_font_size_override("font_size", 20)
	header.add_child(title_label)

	close_btn = Button.new()
	close_btn.text = "Kembali ke Dunia [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close_interface)
	header.add_child(close_btn)

	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.45, 0.3, 0.65, 0.8))
	vb.add_child(sep)

	# Middle Content: Grim Portrait + Question Box
	var content_hb = HBoxContainer.new()
	content_hb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hb.add_theme_constant_override("separation", 24)
	vb.add_child(content_hb)

	# Left: Grim Portrait Card
	var grim_card = PanelContainer.new()
	grim_card.custom_minimum_size = Vector2(230, 0)
	var gc_style = StyleBoxFlat.new()
	gc_style.bg_color = Color(0.06, 0.04, 0.10, 0.9)
	gc_style.border_color = Color(0.65, 0.45, 0.9, 0.8)
	gc_style.set_border_width_all(2)
	gc_style.set_corner_radius_all(10)
	grim_card.add_theme_stylebox_override("panel", gc_style)
	content_hb.add_child(grim_card)

	var gc_vb = VBoxContainer.new()
	gc_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	gc_vb.add_theme_constant_override("separation", 10)
	grim_card.add_child(gc_vb)

	grim_portrait_rect = TextureRect.new()
	if ResourceLoader.exists("res://karakter/grim.png"):
		grim_portrait_rect.texture = load("res://karakter/grim.png")
	elif ResourceLoader.exists("res://grimChibi/depan.png"):
		grim_portrait_rect.texture = load("res://grimChibi/depan.png")
	grim_portrait_rect.custom_minimum_size = Vector2(180, 240)
	grim_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grim_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gc_vb.add_child(grim_portrait_rect)

	var grim_name_lbl = Label.new()
	grim_name_lbl.text = "Sang Dewa Kematian"
	grim_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grim_name_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0))
	grim_name_lbl.add_theme_font_size_override("font_size", 14)
	gc_vb.add_child(grim_name_lbl)

	progress_label = Label.new()
	progress_label.text = "Pertanyaan 1 dari 4"
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_color_override("font_color", Color(0.6, 0.55, 0.75))
	progress_label.add_theme_font_size_override("font_size", 12)
	gc_vb.add_child(progress_label)

	# Right: Interactive Question & Answer Box
	question_box = PanelContainer.new()
	question_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var qb_style = StyleBoxFlat.new()
	qb_style.bg_color = Color(0.07, 0.05, 0.12, 0.95)
	qb_style.border_color = Color(0.5, 0.35, 0.75, 0.7)
	qb_style.set_border_width_all(2)
	qb_style.set_corner_radius_all(10)
	qb_style.set_content_margin_all(20)
	question_box.add_theme_stylebox_override("panel", qb_style)
	content_hb.add_child(question_box)

	var q_vb = VBoxContainer.new()
	q_vb.add_theme_constant_override("separation", 16)
	question_box.add_child(q_vb)

	prompt_label = Label.new()
	prompt_label.text = "Memulai review bukti kematian..."
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.add_theme_color_override("font_color", Color(0.95, 0.92, 1.0))
	prompt_label.add_theme_font_size_override("font_size", 16)
	q_vb.add_child(prompt_label)

	options_container = VBoxContainer.new()
	options_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	options_container.add_theme_constant_override("separation", 10)
	q_vb.add_child(options_container)

	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
	feedback_label.add_theme_font_size_override("font_size", 14)
	q_vb.add_child(feedback_label)

	# Bottom NLP Toggle / Input field container
	nlp_panel = VBoxContainer.new()
	nlp_panel.add_theme_constant_override("separation", 6)
	vb.add_child(nlp_panel)

	var nlp_hb = HBoxContainer.new()
	nlp_hb.add_theme_constant_override("separation", 10)
	nlp_panel.add_child(nlp_hb)

	input_field = LineEdit.new()
	input_field.placeholder_text = "Opsi Tambahan: Ketik bebas pesan/pengakuan terakhirmu kepada Dewa Kematian..."
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.custom_minimum_size = Vector2(0, 42)
	var if_style = StyleBoxFlat.new()
	if_style.bg_color = Color(0.1, 0.08, 0.16)
	if_style.border_color = Color(0.5, 0.35, 0.7, 0.8)
	if_style.set_border_width_all(1)
	if_style.set_corner_radius_all(6)
	if_style.set_content_margin_all(10)
	input_field.add_theme_stylebox_override("normal", if_style)
	nlp_hb.add_child(input_field)

	submit_btn = Button.new()
	submit_btn.text = "Kirim Pesan"
	submit_btn.custom_minimum_size = Vector2(130, 42)
	submit_btn.pressed.connect(_on_nlp_submit)
	nlp_hb.add_child(submit_btn)

	input_field.text_submitted.connect(func(_t): _on_nlp_submit())

	loading_label = Label.new()
	loading_label.text = ""
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.add_theme_color_override("font_color", Color(0.65, 0.6, 0.8))
	loading_label.add_theme_font_size_override("font_size", 12)
	nlp_panel.add_child(loading_label)

func open_interface() -> void:
	is_active = true
	is_ending_screen = false
	current_question_idx = 0
	correct_answers_count = 0
	visible = true
	feedback_label.text = ""
	_play_afterlife_sound()
	_display_current_question()

func close_interface() -> void:
	is_active = false
	visible = false
	if is_instance_valid(afterlife_audio) and afterlife_audio.playing:
		afterlife_audio.stop()
	death_god_closed.emit()

func _play_afterlife_sound() -> void:
	if is_instance_valid(afterlife_audio) and afterlife_audio.stream:
		if not afterlife_audio.playing:
			afterlife_audio.play()

func _display_current_question() -> void:
	if current_question_idx >= QUESTIONS.size():
		_show_peaceful_ascension()
		return

	var q_data = QUESTIONS[current_question_idx]
	prompt_label.text = q_data["q"]
	progress_label.text = "Pertanyaan %d dari %d" % [current_question_idx + 1, QUESTIONS.size()]
	feedback_label.text = ""

	# Clear previous options
	for child in options_container.get_children():
		child.queue_free()

	# Populate options buttons
	for opt in q_data["options"]:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(0.12, 0.09, 0.20, 0.95)
		b_style.border_color = Color(0.45, 0.35, 0.65, 0.8)
		b_style.set_border_width_all(1)
		b_style.set_corner_radius_all(8)
		b_style.content_margin_left = 16
		b_style.content_margin_right = 16
		btn.add_theme_stylebox_override("normal", b_style)

		var h_style = b_style.duplicate()
		h_style.bg_color = Color(0.24, 0.16, 0.38, 0.98)
		h_style.border_color = Color(0.75, 0.55, 1.0, 1.0)
		btn.add_theme_stylebox_override("hover", h_style)

		btn.pressed.connect(func(): _on_option_selected(opt["correct"], q_data["correct_feedback"]))
		options_container.add_child(btn)

func _on_option_selected(is_correct: bool, feedback: String) -> void:
	if is_correct:
		feedback_label.text = feedback
		feedback_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
		correct_answers_count += 1
		# Disable option buttons to prevent multiple clicks
		for btn in options_container.get_children():
			if btn is Button:
				btn.disabled = true

		var tw = create_tween()
		tw.tween_interval(1.8)
		tw.tween_callback(func():
			current_question_idx += 1
			_display_current_question()
		)
	else:
		feedback_label.text = "Dewa Kematian menggeleng perlahan: 'Bukan itu yang sesungguhnya terjadi... renungkanlah bukti yang telah kau temui.'"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

func _show_peaceful_ascension() -> void:
	is_ending_screen = true
	# Clear options
	for child in options_container.get_children():
		child.queue_free()

	progress_label.text = "✦ Ujian Jiwa Selesai ✦"
	prompt_label.text = "✦ KEPUTUSAN SANG DEWA KEMATIAN ✦\n\n'Seluruh misteri telah terurai, Benedict. Kau telah memecahkan teka-teki terakhirmu: kematian dirimu sendiri.\n\nTidak ada lagi penyesalan, tidak ada lagi rasa dingin yang membelenggu. Jiwamu kini ikhlas dan damai. Melangkahlah menuju cahaya peristirahatan abadi.'"

	feedback_label.text = "ARWAH BENEDICT IKHLAS DAN DAMAI MENUJU AFTERLIFE "
	feedback_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))

	# Ascension Card
	var victory_btn = Button.new()
	victory_btn.text = "MELANGKAH MENUJU AFTERLIFE DENGAN DAMAI "
	victory_btn.custom_minimum_size = Vector2(0, 52)
	var vb_style = StyleBoxFlat.new()
	vb_style.bg_color = Color(0.25, 0.18, 0.42, 0.98)
	vb_style.border_color = Color(1.0, 0.85, 0.4, 1.0)
	vb_style.set_border_width_all(2)
	vb_style.set_corner_radius_all(10)
	victory_btn.add_theme_stylebox_override("normal", vb_style)
	victory_btn.pressed.connect(_finish_game_afterlife)
	options_container.add_child(victory_btn)

	afterlife_ascended.emit()

func _finish_game_afterlife() -> void:
	# White transition fade
	var white_fade = ColorRect.new()
	white_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	white_fade.color = Color(1, 1, 1, 0.0)
	add_child(white_fade)

	var tw = create_tween()
	tw.tween_property(white_fade, "color:a", 1.0, 2.0)
	tw.tween_callback(func():
		_display_final_credits()
	)

func _display_final_credits() -> void:
	# Clear children and show beautiful final ending card
	for c in get_children():
		if c != afterlife_audio:
			c.queue_free()

	var end_bg = ColorRect.new()
	end_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_bg.color = Color(0.04, 0.03, 0.07, 1.0)
	add_child(end_bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vb = VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 18)
	center.add_child(vb)

	var t1 = Label.new()
	t1.text = "✦ KASUS TERAKHIR SELESAI ✦"
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t1.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	t1.add_theme_font_size_override("font_size", 28)
	vb.add_child(t1)

	var t2 = Label.new()
	t2.text = "Detektif Benedict telah menerima takdirnya dan melangkah ke alam berikutnya dalam damai."
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t2.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	t2.add_theme_font_size_override("font_size", 16)
	vb.add_child(t2)

	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(400, 20)
	vb.add_child(sep)

	var restart_btn = Button.new()
	restart_btn.text = "Mulai Ulang Investigasi"
	restart_btn.custom_minimum_size = Vector2(280, 48)
	restart_btn.pressed.connect(func():
		get_tree().reload_current_scene()
	)
	vb.add_child(restart_btn)

func _on_nlp_submit() -> void:
	var teks = input_field.text.strip_edges()
	if teks.is_empty():
		return
	input_field.text = ""
	loading_label.text = "Dewa Kematian menimbang ucapanmu..."

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, _code, _h, body):
		http.queue_free()
		loading_label.text = ""
		if result == HTTPRequest.RESULT_SUCCESS:
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if parsed and parsed.has("respon"):
				feedback_label.text = "✦ Respon Dewa Kematian: " + parsed["respon"]
				return
		feedback_label.text = "✦ Dewa Kematian mengangguk tenang: 'Kata-katamu telah tersimpan dalam keabadian, Benedict.'"
	)

	var payload = JSON.stringify({"teks": teks})
	var headers = ["Content-Type: application/json"]
	http.request(SERVER_URL + "/analisis", headers, HTTPClient.METHOD_POST, payload)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		close_interface()
		get_viewport().set_input_as_handled()
