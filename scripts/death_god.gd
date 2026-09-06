extends CanvasLayer

signal death_god_closed

const SERVER_URL    = "http://127.0.0.1:8000"
const TYPING_SPEED  = 0.03

var server_pid      : int    = -1
var is_typing       : bool   = false
var full_response   : String = ""
var char_index      : int    = 0
var typing_timer    : float  = 0.0
var is_active       : bool   = false

var bg              : ColorRect
var title_label     : Label
var response_label  : Label
var input_field     : LineEdit
var submit_btn      : Button
var score_label     : Label
var loading_label   : Label
var close_btn       : Button

func _ready() -> void:
	layer = 16
	_build_ui()
	visible = false

func open_interface() -> void:
	is_active = true
	visible = true
	input_field.text = ""
	input_field.editable = true
	input_field.grab_focus()
	_ping_server_until_ready()

func close_interface() -> void:
	is_active = false
	visible = false
	death_god_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
		close_interface()
		get_viewport().set_input_as_handled()

func _build_ui() -> void:
	bg = ColorRect.new()
	bg.color = Color(0.04, 0.03, 0.07, 0.96)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 60)
	margin.add_theme_constant_override("margin_right", 60)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 16)
	margin.add_child(container)

	var header = HBoxContainer.new()
	container.add_child(header)

	title_label = Label.new()
	title_label.text = "✦ DEWA KEMATIAN — PENGHAKIMAN AKHIR ARWAH ✦"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_color_override("font_color", Color(0.8, 0.65, 1.0))
	title_label.add_theme_font_size_override("font_size", 20)
	header.add_child(title_label)

	close_btn = Button.new()
	close_btn.text = "✖ Kembali ke Dunia Game [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close_interface)
	header.add_child(close_btn)

	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.4, 0.25, 0.6, 0.8))
	container.add_child(sep)

	var response_container = PanelContainer.new()
	response_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(response_container)

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.06, 0.12, 0.95)
	style_box.border_color = Color(0.5, 0.35, 0.7, 0.6)
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(10)
	style_box.set_content_margin_all(20)
	response_container.add_theme_stylebox_override("panel", style_box)

	response_label = Label.new()
	response_label.text = "..."
	response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	response_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	response_label.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0))
	response_label.add_theme_font_size_override("font_size", 16)
	response_container.add_child(response_label)

	var prompt_label = Label.new()
	prompt_label.text = "Ceritakan padaku... apa yang telah kamu pelajari tentang takdir kematianmu?"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_color_override("font_color", Color(0.65, 0.58, 0.8))
	prompt_label.add_theme_font_size_override("font_size", 15)
	container.add_child(prompt_label)

	input_field = LineEdit.new()
	input_field.placeholder_text = "Ketik jawaban/kesimpulanmu di sini lalu tekan Enter..."
	input_field.custom_minimum_size = Vector2(0, 48)
	input_field.add_theme_font_size_override("font_size", 16)
	input_field.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	input_field.add_theme_color_override("font_placeholder_color", Color(0.45, 0.42, 0.55))
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.1, 0.08, 0.16)
	input_style.border_color = Color(0.6, 0.45, 0.8, 0.8)
	input_style.set_border_width_all(1)
	input_style.set_corner_radius_all(6)
	input_style.set_content_margin_all(12)
	input_field.add_theme_stylebox_override("normal", input_style)
	input_field.add_theme_stylebox_override("focus", input_style)
	container.add_child(input_field)

	submit_btn = Button.new()
	submit_btn.text = "✦ Sampaikan ke Dewa Kematian ✦"
	submit_btn.custom_minimum_size = Vector2(260, 44)
	submit_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	submit_btn.add_theme_font_size_override("font_size", 15)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.38, 0.22, 0.60)
	btn_style.set_corner_radius_all(6)
	btn_style.set_content_margin_all(10)
	submit_btn.add_theme_stylebox_override("normal", btn_style)
	submit_btn.pressed.connect(_on_submit)
	container.add_child(submit_btn)

	score_label = Label.new()
	score_label.text = ""
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.6))
	score_label.add_theme_font_size_override("font_size", 13)
	container.add_child(score_label)

	loading_label = Label.new()
	loading_label.text = ""
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.add_theme_color_override("font_color", Color(0.6, 0.55, 0.75))
	loading_label.add_theme_font_size_override("font_size", 13)
	container.add_child(loading_label)

	input_field.text_submitted.connect(func(_t): _on_submit())

func _ping_server_until_ready() -> void:
	loading_label.text = "Menghubungkan ke Dewa Kematian..."
	submit_btn.disabled = true
	_do_ping()

func _do_ping() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, _code, _h, _b):
		http.queue_free()
		if result == HTTPRequest.RESULT_SUCCESS:
			loading_label.text = ""
			submit_btn.disabled = false
			if response_label.text == "..." or response_label.text.is_empty():
				response_label.text = "Dewa Kematian menatap jiwamu dengan tenang dalam keabadian..."
		else:
			loading_label.text = "[Server AI NLP belum aktif / offline. Input tetap dapat dicoba]"
			submit_btn.disabled = false
	)
	http.request(SERVER_URL + "/ping")

func _on_submit() -> void:
	var teks = input_field.text.strip_edges()
	if teks.is_empty() or is_typing:
		return

	submit_btn.disabled = true
	loading_label.text = "Dewa Kematian sedang menimbang jawabanmu..."
	input_field.editable = false

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(result, code, _headers, body):
		http.queue_free()
		_on_response_received(result, code, body)
	)

	var payload = JSON.stringify({"teks": teks})
	var headers = ["Content-Type: application/json"]
	http.request(SERVER_URL + "/analisis", headers, HTTPClient.METHOD_POST, payload)

func _on_response_received(result: int, _code: int, body: PackedByteArray) -> void:
	loading_label.text = ""
	submit_btn.disabled = false
	input_field.editable = true

	if result != HTTPRequest.RESULT_SUCCESS:
		var fallback_text = "Dewa Kematian mengangguk perlahan dalam keheningan:\n\n'Jawabanmu telah sampai ke lubuk alam maut, Benedict. Kamu telah menerima kenyataan bahwa tugasmu di dunia ini telah selesai...'"
		_start_typewriter(fallback_text)
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null:
		response_label.text = "[Error parsing respon server]"
		return

	var respon = parsed.get("respon", "...")
	var skor_mati = parsed.get("skor_mati", 0.0)
	var skor_emosional = parsed.get("skor_emosional", 0.0)
	var kategori = parsed.get("kategori", "?")

	score_label.text = "[ Analisis Jiwa: Kesadaran Kematian: %.2f | Emosional: %.2f | Kategori: %s ]" % [
		skor_mati, skor_emosional, kategori
	]

	_start_typewriter(respon)

func _start_typewriter(text: String) -> void:
	full_response = text
	char_index = 0
	is_typing = true
	response_label.text = ""

func _process(delta: float) -> void:
	if not is_typing:
		return

	typing_timer += delta
	if typing_timer >= TYPING_SPEED:
		typing_timer = 0.0
		if char_index < full_response.length():
			response_label.text += full_response[char_index]
			char_index += 1
		else:
			is_typing = false
