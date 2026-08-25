extends Node

const SERVER_URL    = "http://127.0.0.1:8000"
const TYPING_SPEED  = 0.03

var server_pid      : int    = -1
var is_typing       : bool   = false
var full_response   : String = ""
var char_index      : int    = 0
var typing_timer    : float  = 0.0

var bg              : ColorRect
var title_label     : Label
var response_label  : Label
var input_field     : LineEdit
var submit_btn      : Button
var score_label     : Label
var loading_label   : Label

func _ready() -> void:
	_build_ui()
	_start_server()
	_ping_server_until_ready()

func _build_ui() -> void:
	bg = ColorRect.new()
	bg.color         = Color(0.04, 0.04, 0.06)
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var container      = VBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.position = Vector2(-420, -280)
	container.custom_minimum_size = Vector2(840, 560)
	container.add_theme_constant_override("separation", 20)
	add_child(container)

	title_label                   = Label.new()
	title_label.text              = "— DEWA KEMATIAN —"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color",        Color(0.7, 0.6, 1.0))
	title_label.add_theme_font_size_override("font_size", 22)
	container.add_child(title_label)

	var sep       = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.3, 0.2, 0.5, 0.8))
	container.add_child(sep)

	var response_container = PanelContainer.new()
	response_container.custom_minimum_size = Vector2(840, 240)
	container.add_child(response_container)

	var style_box          = StyleBoxFlat.new()
	style_box.bg_color     = Color(0.08, 0.06, 0.12, 0.9)
	style_box.border_color = Color(0.4, 0.3, 0.6, 0.5)
	style_box.set_border_width_all(1)
	style_box.set_corner_radius_all(8)
	style_box.set_content_margin_all(20)
	response_container.add_theme_stylebox_override("panel", style_box)

	response_label                          = Label.new()
	response_label.text                     = "..."
	response_label.autowrap_mode            = TextServer.AUTOWRAP_WORD_SMART
	response_label.horizontal_alignment     = HORIZONTAL_ALIGNMENT_LEFT
	response_label.vertical_alignment       = VERTICAL_ALIGNMENT_TOP
	response_label.add_theme_color_override("font_color",    Color(0.85, 0.82, 0.95))
	response_label.add_theme_font_size_override("font_size", 16)
	response_container.add_child(response_label)

	var prompt_label                         = Label.new()
	prompt_label.text                        = "Ceritakan padaku... apa yang telah kamu pelajari?"
	prompt_label.horizontal_alignment        = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_color_override("font_color",     Color(0.5, 0.45, 0.65))
	prompt_label.add_theme_font_size_override("font_size",  14)
	container.add_child(prompt_label)

	input_field                              = LineEdit.new()
	input_field.placeholder_text            = "Ketik kesimpulanmu di sini..."
	input_field.custom_minimum_size         = Vector2(840, 50)
	input_field.add_theme_font_size_override("font_size",   16)
	input_field.add_theme_color_override("font_color",       Color(0.9, 0.9, 1.0))
	input_field.add_theme_color_override("font_placeholder_color", Color(0.4, 0.38, 0.5))
	var input_style                          = StyleBoxFlat.new()
	input_style.bg_color                    = Color(0.1, 0.08, 0.16)
	input_style.border_color                = Color(0.5, 0.4, 0.7, 0.6)
	input_style.set_border_width_all(1)
	input_style.set_corner_radius_all(6)
	input_style.set_content_margin_all(12)
	input_field.add_theme_stylebox_override("normal", input_style)
	input_field.add_theme_stylebox_override("focus",  input_style)
	container.add_child(input_field)

	submit_btn                               = Button.new()
	submit_btn.text                          = "Sampaikan"
	submit_btn.custom_minimum_size          = Vector2(200, 45)
	submit_btn.size_flags_horizontal        = Control.SIZE_SHRINK_CENTER
	submit_btn.add_theme_font_size_override("font_size", 15)
	var btn_style                            = StyleBoxFlat.new()
	btn_style.bg_color                       = Color(0.35, 0.2, 0.55)
	btn_style.set_corner_radius_all(6)
	btn_style.set_content_margin_all(10)
	submit_btn.add_theme_stylebox_override("normal", btn_style)
	submit_btn.add_theme_stylebox_override("hover",  _make_btn_hover_style())
	submit_btn.pressed.connect(_on_submit)
	container.add_child(submit_btn)

	score_label                              = Label.new()
	score_label.text                         = ""
	score_label.horizontal_alignment         = HORIZONTAL_ALIGNMENT_CENTER
	score_label.add_theme_color_override("font_color",     Color(0.35, 0.3, 0.45))
	score_label.add_theme_font_size_override("font_size",  12)
	container.add_child(score_label)

	loading_label                            = Label.new()
	loading_label.text                       = ""
	loading_label.horizontal_alignment       = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.add_theme_color_override("font_color",   Color(0.5, 0.45, 0.65))
	loading_label.add_theme_font_size_override("font_size", 13)
	container.add_child(loading_label)

	input_field.text_submitted.connect(func(_t): _on_submit())

func _make_btn_hover_style() -> StyleBoxFlat:
	var s            = StyleBoxFlat.new()
	s.bg_color       = Color(0.5, 0.3, 0.75)
	s.set_corner_radius_all(6)
	s.set_content_margin_all(10)
	return s

func _start_server() -> void:
	var exe_path = OS.get_executable_path().get_base_dir() + "/ai_server.exe"
	if FileAccess.file_exists(exe_path):
		server_pid = OS.create_process(exe_path, [])
		print("[DeathGod] Server dimulai (PID: %d)" % server_pid)
	else:
		var dev_path = ProjectSettings.globalize_path("res://ai_server/main.py")
		if FileAccess.file_exists(dev_path):
			server_pid = OS.create_process("python", [dev_path])
			print("[DeathGod] Server development dimulai")
		else:
			print("[DeathGod] Warning: ai_server tidak ditemukan!")

func _ping_server_until_ready() -> void:
	loading_label.text = "Memuat Dewa Kematian..."
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
			response_label.text = "..."
		else:
			await get_tree().create_timer(1.0).timeout
			_do_ping()
	)
	http.request(SERVER_URL + "/ping")

func _on_submit() -> void:
	var teks = input_field.text.strip_edges()
	if teks.is_empty() or is_typing:
		return

	submit_btn.disabled  = true
	loading_label.text   = "Dewa Kematian sedang berpikir..."
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
	loading_label.text   = ""
	submit_btn.disabled  = false
	input_field.editable = true

	if result != HTTPRequest.RESULT_SUCCESS:
		response_label.text = "[Server tidak merespons. Pastikan ai_server.exe berjalan.]"
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null:
		response_label.text = "[Error parsing respon server]"
		return

	var respon        = parsed.get("respon", "...")
	var skor_mati     = parsed.get("skor_mati", 0.0)
	var skor_emosional = parsed.get("skor_emosional", 0.0)
	var kategori      = parsed.get("kategori", "?")

	score_label.text = "[ skor_mati: %.2f | skor_emosional: %.2f | kategori: %s ]" % [
		skor_mati, skor_emosional, kategori
	]

	_start_typewriter(respon)

func _start_typewriter(text: String) -> void:
	full_response      = text
	char_index         = 0
	is_typing          = true
	response_label.text = ""

func _process(delta: float) -> void:
	if not is_typing:
		return

	typing_timer += delta
	if typing_timer >= TYPING_SPEED:
		typing_timer = 0.0
		if char_index < full_response.length():
			response_label.text += full_response[char_index]
			char_index          += 1
		else:
			is_typing = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if server_pid != -1:
			OS.kill(server_pid)
			print("[DeathGod] Server dihentikan.")
		get_tree().quit()
