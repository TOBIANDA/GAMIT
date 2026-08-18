extends CanvasLayer

signal dialog_opened
signal dialog_closed

const SERVER_URL = "http://127.0.0.1:8000"
const TYPING_SPEED = 0.025

# ── Referensi Node UI ─────────────────────────────────────────────────────
@onready var root_control: Control = $RootControl
@onready var text_label: Label = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TextPanel/Margin/TextLabel
@onready var input_container: HBoxContainer = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer
@onready var input_edit: LineEdit = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer/InputEdit
@onready var submit_btn: Button = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer/SubmitBtn
@onready var status_badge: Label = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/StatusBadge
@onready var close_btn: Button = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/CloseBtn
@onready var portrait_glow: ColorRect = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/AuraGlow

var full_text: String = ""
var current_char_idx: int = 0
var typing_timer: float = 0.0
var is_typing: bool = false
var is_active: bool = false
var glow_timer: float = 0.0

func _ready() -> void:
	root_control.visible = false
	
	# Matikan focus pada tombol agar Spasi TIDAK men-trigger klik tombol (hanya Enter dan Klik Mouse)
	submit_btn.focus_mode = Control.FOCUS_NONE
	close_btn.focus_mode = Control.FOCUS_NONE
	
	submit_btn.pressed.connect(_on_submit_pressed)
	close_btn.pressed.connect(close_dialog)
	input_edit.text_submitted.connect(func(_t): _on_submit_pressed())

func _process(delta: float) -> void:
	if not is_active:
		return

	# Animasi aura portrait bernapas (pulsing)
	glow_timer += delta * 3.0
	if is_instance_valid(portrait_glow):
		var alpha = 0.35 + sin(glow_timer) * 0.2
		portrait_glow.color = Color(0.6, 0.2, 0.9, alpha)

	# Typewriter effect
	if is_typing:
		typing_timer += delta
		if typing_timer >= TYPING_SPEED:
			typing_timer = 0.0
			if current_char_idx < full_text.length():
				text_label.text += full_text[current_char_idx]
				current_char_idx += 1
			else:
				is_typing = false
				input_container.visible = true
				# Beri fokus ke LineEdit agar pemain bisa langsung mengetik termasuk spasi
				input_edit.call_deferred("grab_focus")

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_dialog()
		get_viewport().set_input_as_handled()

func open_dialog(initial_prompt: String = "") -> void:
	is_active = true
	root_control.visible = true
	status_badge.text = "✦ HADIR DI HADAPAN SANG DEWA ✦"
	status_badge.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0))
	input_container.visible = false
	input_edit.text = ""
	input_edit.editable = true
	submit_btn.disabled = false

	var intro = initial_prompt
	if intro.is_empty():
		intro = "Wahai pengelana fana... Setelah melintasi ruang hampa ini, katakan padaku apa yang telah kau pelajari tentang takdirmu?"

	_start_typewriter(intro)
	dialog_opened.emit()

func close_dialog() -> void:
	is_active = false
	is_typing = false
	root_control.visible = false
	dialog_closed.emit()

func _start_typewriter(text: String) -> void:
	full_text = text
	current_char_idx = 0
	text_label.text = ""
	is_typing = true

func _on_submit_pressed() -> void:
	var message = input_edit.text.strip_edges()
	if message.is_empty() or is_typing:
		return

	input_edit.editable = false
	submit_btn.disabled = true
	status_badge.text = "✦ MENIMBANG KEBENARAN JIWAMU... ✦"
	status_badge.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	
	_start_typewriter("Dewa Kematian terdiam sejenak menimbang ucapanmu...")

	# Panggil AI Server
	_request_ai_analysis(message)

func _request_ai_analysis(player_text: String) -> void:
	var http = HTTPRequest.new()
	http.timeout = 2.0
	add_child(http)
	http.request_completed.connect(func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		_handle_server_response(result, code, body, player_text)
	)

	var payload = JSON.stringify({"teks": player_text})
	var headers = ["Content-Type: application/json"]
	var err = http.request(SERVER_URL + "/analisis", headers, HTTPClient.METHOD_POST, payload)
	
	if err != OK:
		_use_offline_fallback(player_text)

func _handle_server_response(result: int, code: int, body: PackedByteArray, fallback_text: String) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_use_offline_fallback(fallback_text)
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed == null or not (parsed is Dictionary):
		_use_offline_fallback(fallback_text)
		return

	var respon = parsed.get("respon", "Keheninganmu telah berbicara lebih dari kata-kata.")
	var kategori = parsed.get("kategori", "")
	var skor_mati = parsed.get("skor_mati", 0.0)

	# Update status badge
	if kategori == "sadar_mati_dan_emosional":
		status_badge.text = "★ PENCERAHAN MUTLAK (Skor: %.2f) ★" % skor_mati
		status_badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	elif kategori == "sadar_mati":
		status_badge.text = "✦ KESADARAN SEJATI (Skor: %.2f) ✦" % skor_mati
		status_badge.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	elif kategori == "sebagian":
		status_badge.text = "❖ BAYANGAN KEBENARAN (Skor: %.2f) ❖" % skor_mati
		status_badge.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	else:
		status_badge.text = "✧ KEBINGUNGAN FANA ✧"
		status_badge.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))

	_start_typewriter(respon)
	input_edit.editable = true
	submit_btn.disabled = false
	input_edit.call_deferred("grab_focus")

func _use_offline_fallback(text: String) -> void:
	status_badge.text = "✦ RESONANSI GHAIB ✦"
	status_badge.add_theme_color_override("font_color", Color(0.7, 0.5, 0.9))
	
	var fallback_response: String
	var lower = text.to_lower()
	if "mati" in lower or "kematian" in lower or "wafat" in lower or "akhir" in lower:
		fallback_response = "Kematian bukanlah akhir dari segalanya, melainkan cermin bagi mereka yang benar-benar hidup. Jiwamu telah mulai memahami hakikat ini..."
	elif "sedih" in lower or "menyesal" in lower or "ikhlas" in lower or "rela" in lower or "tangis" in lower:
		fallback_response = "Rasa sakit dan penerimaan adalah dua sisi dari mata uang yang sama. Aku merasakan getaran jiwamu yang tulus..."
	else:
		fallback_response = "Kata-katamu masih berputar di alam kefanaan. Teruslah mencari keheningan di balik setiap langkahmu..."

	_start_typewriter(fallback_response)
	input_edit.editable = true
	submit_btn.disabled = false
	input_edit.call_deferred("grab_focus")
