extends CanvasLayer

signal dialog_opened
signal dialog_closed
signal monologue_finished

const SERVER_URL = "http://127.0.0.1:8000"
const TYPING_SPEED = 0.028

@onready var root_control: Control = $RootControl
@onready var text_label: Label = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TextPanel/Margin/TextLabel
@onready var input_container: HBoxContainer = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer
@onready var input_edit: LineEdit = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer/InputEdit
@onready var submit_btn: Button = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer/SubmitBtn
@onready var name_tag: Label = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/NameTag
@onready var status_badge: Label = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/StatusBadge
@onready var close_btn: Button = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/CloseBtn
@onready var portrait_glow: ColorRect = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/AuraGlow
@onready var portrait_texture: TextureRect = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/PortraitTexture
@onready var avatar_visual_container: CenterContainer = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/CenterContainer
@onready var bottom_panel: PanelContainer = $RootControl/BottomPanel
@onready var margin_container: MarginContainer = $RootControl/BottomPanel/MarginContainer
@onready var portrait_box: VBoxContainer = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox
@onready var large_portrait: TextureRect = $RootControl/LargePortrait
@onready var continue_prompt: Label = get_node_or_null("RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TextPanel/Margin/ContinuePrompt")

var full_text: String = ""
var current_char_idx: int = 0
var typing_timer: float = 0.0
var is_typing: bool = false
var is_active: bool = false
var glow_timer: float = 0.0
var click_player: AudioStreamPlayer
var typewriter_player: AudioStreamPlayer

var is_monologue_mode: bool = false
var monologue_lines: Array[String] = []
var monologue_index: int = 0
var auto_advance_timer: float = 0.0

func _ready() -> void:
	_ensure_nodes()
	visible = false
	if is_instance_valid(root_control):
		root_control.visible = false
	
	click_player = AudioStreamPlayer.new()
	click_player.name = "DialogClickPlayer"
	var c_stream = load("res://sound/Click sound.mp3")
	if c_stream:
		click_player.stream = c_stream
		click_player.volume_db = -5.0
	add_child(click_player)

	typewriter_player = AudioStreamPlayer.new()
	typewriter_player.name = "DialogTypewriterPlayer"
	var tw_stream = load("res://sound/keyboardtype.mp3")
	if not tw_stream:
		tw_stream = load("res://keyboardtype.mp3")
	if tw_stream:
		typewriter_player.stream = tw_stream
		typewriter_player.volume_db = -2.0
	add_child(typewriter_player)

func _ensure_nodes() -> void:
	if root_control == null and has_node("RootControl"):
		root_control = $RootControl
		text_label = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TextPanel/Margin/TextLabel
		input_container = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer
		input_edit = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer/InputEdit
		submit_btn = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/InputContainer/SubmitBtn
		name_tag = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/NameTag
		status_badge = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/StatusBadge
		close_btn = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TopRow/CloseBtn
		portrait_glow = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/AuraGlow
		portrait_texture = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/PortraitTexture
		avatar_visual_container = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox/PortraitPanel/CenterContainer
		bottom_panel = $RootControl/BottomPanel
		margin_container = $RootControl/BottomPanel/MarginContainer
		portrait_box = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox
		large_portrait = $RootControl/LargePortrait
	if large_portrait == null and has_node("RootControl/LargePortrait"):
		large_portrait = $RootControl/LargePortrait
	if bottom_panel == null and has_node("RootControl/BottomPanel"):
		bottom_panel = $RootControl/BottomPanel
	if margin_container == null and has_node("RootControl/BottomPanel/MarginContainer"):
		margin_container = $RootControl/BottomPanel/MarginContainer
	if portrait_box == null and has_node("RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox"):
		portrait_box = $RootControl/BottomPanel/MarginContainer/HBoxContainer/PortraitBox
	if continue_prompt == null and has_node("RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TextPanel/Margin/ContinuePrompt"):
		continue_prompt = $RootControl/BottomPanel/MarginContainer/HBoxContainer/ContentVBox/TextPanel/Margin/ContinuePrompt

	submit_btn.focus_mode = Control.FOCUS_NONE
	close_btn.focus_mode = Control.FOCUS_NONE
	
	submit_btn.pressed.connect(func():
		_play_click()
		_on_submit_pressed()
	)
	close_btn.pressed.connect(func():
		_play_click()
		close_dialog()
	)
	input_edit.text_submitted.connect(func(_t):
		_play_click()
		_on_submit_pressed()
	)

	# Pastikan klik pada area dialog memajukan monolog seketika
	if is_instance_valid(root_control) and not root_control.gui_input.is_connected(_on_screen_gui_input):
		root_control.gui_input.connect(_on_screen_gui_input)
	if is_instance_valid(bottom_panel) and not bottom_panel.gui_input.is_connected(_on_screen_gui_input):
		bottom_panel.gui_input.connect(_on_screen_gui_input)

func _on_screen_gui_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_monologue_mode:
			advance_monologue()

func _play_click() -> void:
	if is_instance_valid(click_player) and click_player.stream:
		click_player.pitch_scale = randf_range(0.95, 1.05)
		click_player.play()

func _process(delta: float) -> void:
	if not is_active:
		return

	glow_timer += delta * 3.0
	if is_instance_valid(portrait_glow) and portrait_glow.visible:
		var alpha = 0.35 + sin(glow_timer) * 0.2
		if is_monologue_mode:
			portrait_glow.color = Color(0.2, 0.5, 0.85, alpha)
		else:
			portrait_glow.color = Color(0.6, 0.2, 0.9, alpha)

	# Efek melayang halus untuk potret Dewa Kematian saat berbicara
	if is_instance_valid(large_portrait) and large_portrait.visible:
		if not is_monologue_mode:
			var bob = sin(glow_timer * 0.8) * 5.0
			large_portrait.offset_top = -520.0 + bob
			large_portrait.offset_bottom = bob
		else:
			large_portrait.offset_top = -520.0
			large_portrait.offset_bottom = 0.0

	if is_typing:
		if is_instance_valid(continue_prompt):
			continue_prompt.visible = false
		if is_instance_valid(typewriter_player) and typewriter_player.stream and not typewriter_player.playing:
			typewriter_player.play(2.0)
		typing_timer += delta
		if typing_timer >= TYPING_SPEED:
			typing_timer = 0.0
			if current_char_idx < full_text.length():
				var ch = full_text[current_char_idx]
				text_label.text += ch
				current_char_idx += 1
			else:
				is_typing = false
				if is_instance_valid(typewriter_player) and typewriter_player.playing:
					typewriter_player.stop()
				auto_advance_timer = 0.0
				if not is_monologue_mode:
					input_container.visible = true
					input_edit.call_deferred("grab_focus")
	else:
		# Pengetikan selesai: tampilkan prompt lanjut dan hitung auto-advance santai
		if is_monologue_mode:
			if is_instance_valid(continue_prompt):
				continue_prompt.visible = true
				if monologue_index + 1 < monologue_lines.size():
					continue_prompt.text = "▶ Tekan [ E / Spasi / Enter ] untuk lanjut"
				else:
					continue_prompt.text = "▶ Tekan [ E / Spasi / Enter ] untuk selesai"
				continue_prompt.modulate.a = 0.7 + 0.3 * sin(glow_timer * 3.0)
			
			# Auto-advance opsional jika pemain AFK (5.0 detik santai)
			auto_advance_timer += delta
			if auto_advance_timer >= 5.0:
				auto_advance_timer = 0.0
				advance_monologue()
		else:
			if is_instance_valid(continue_prompt):
				continue_prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			close_dialog()
			get_viewport().set_input_as_handled()
			return

		if is_monologue_mode and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_E, KEY_F]:
			advance_monologue()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_monologue_mode:
			advance_monologue()
			get_viewport().set_input_as_handled()
			return

func advance_monologue() -> void:
	auto_advance_timer = 0.0
	if is_typing:
		# Jika sedang mengetik, selesaikan baris seketika
		text_label.text = full_text
		current_char_idx = full_text.length()
		is_typing = false
		if is_instance_valid(typewriter_player) and typewriter_player.playing:
			typewriter_player.stop()
		return

	if monologue_index + 1 < monologue_lines.size():
		monologue_index += 1
		_start_typewriter(monologue_lines[monologue_index])
	else:
		close_dialog()
		monologue_finished.emit()

func start_monologue(lines: Array[String], speaker_name: String = "Detektif Benedict", badge_text: String = "[ Monolog Batin ]", portrait_path: String = "res://karakter/MC_Biasa.png") -> void:
	_ensure_nodes()
	visible = true
	is_active = true
	is_monologue_mode = true
	monologue_lines = lines
	monologue_index = 0
	if is_instance_valid(root_control):
		root_control.visible = true

	if is_instance_valid(name_tag):
		name_tag.text = speaker_name
		name_tag.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	if is_instance_valid(status_badge):
		status_badge.text = badge_text
		status_badge.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0))

	if is_instance_valid(input_container):
		input_container.visible = false

	# Sembunyikan frame kotak potret kecil dan aura glow bawaan dialog box (tanpa frame kotak)
	if is_instance_valid(portrait_box):
		portrait_box.visible = false
	if is_instance_valid(portrait_glow):
		portrait_glow.visible = false
	if is_instance_valid(avatar_visual_container):
		avatar_visual_container.visible = false
	if is_instance_valid(portrait_texture):
		portrait_texture.visible = false

	# Beri ruang di sebelah kiri dialog box agar teks rapi di samping MC
	if is_instance_valid(margin_container):
		margin_container.add_theme_constant_override("margin_left", 440)

	# Tampilkan gambar MC 5x lipat tanpa frame kotak (cutout transparan)
	if is_instance_valid(large_portrait):
		var resolved_path = portrait_path
		if not resolved_path.begins_with("res://"):
			if not resolved_path.ends_with(".png"):
				resolved_path += ".png"
			resolved_path = "res://karakter/" + resolved_path
		
		var tex = load(resolved_path)
		if not tex and resolved_path.contains("karakter/"):
			tex = load(resolved_path.replace("res://karakter/", "res://UI/portraits/"))
		if not tex:
			tex = load("res://UI/mc_portrait.png")
		if tex:
			large_portrait.texture = tex
		large_portrait.visible = true

	dialog_opened.emit()

	if monologue_lines.size() > 0:
		_start_typewriter(monologue_lines[0])
	else:
		close_dialog()
		monologue_finished.emit()

func open_dialog(initial_prompt: String = "") -> void:
	_ensure_nodes()
	visible = true
	is_active = true
	is_monologue_mode = false
	if is_instance_valid(root_control):
		root_control.visible = true

	name_tag.text = "❖ DEWA KEMATIAN ❖"
	name_tag.add_theme_color_override("font_color", Color(0.9, 0.75, 1.0))
	status_badge.text = "✦ HADIR DI HADAPAN SANG DEWA ✦"
	status_badge.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0))

	# Sembunyikan frame kotak potret kecil dan figur dummy ColorRect
	if is_instance_valid(portrait_box):
		portrait_box.visible = false
	if is_instance_valid(portrait_glow):
		portrait_glow.visible = false
	if is_instance_valid(portrait_texture):
		portrait_texture.visible = false
	if is_instance_valid(avatar_visual_container):
		avatar_visual_container.visible = false

	# Atur margin dialog agar teks dialog dan input LineEdit tertata rapi di samping potret Dewa Kematian
	if is_instance_valid(margin_container):
		margin_container.add_theme_constant_override("margin_left", 440)

	# Tampilkan potret visual novel megah Dewa Kematian (grim.png non-chibi)
	if is_instance_valid(large_portrait):
		var grim_tex = load("res://karakter/grim.png")
		if not grim_tex:
			grim_tex = load("res://UI/portraits/grim.png")
		if not grim_tex:
			grim_tex = load("res://grim.png")
		if grim_tex:
			large_portrait.texture = grim_tex
		large_portrait.visible = true

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
	_ensure_nodes()
	visible = false
	is_active = false
	is_typing = false
	is_monologue_mode = false
	if is_instance_valid(typewriter_player) and typewriter_player.playing:
		typewriter_player.stop()
	if is_instance_valid(large_portrait):
		large_portrait.visible = false
	if is_instance_valid(margin_container):
		margin_container.add_theme_constant_override("margin_left", 16)
	if is_instance_valid(root_control):
		root_control.visible = false
	dialog_closed.emit()

func _start_typewriter(text: String) -> void:
	_ensure_nodes()
	full_text = text
	current_char_idx = 0
	if is_instance_valid(text_label):
		text_label.text = ""
	is_typing = true
	if is_instance_valid(typewriter_player) and typewriter_player.stream:
		typewriter_player.stop()
		typewriter_player.play(2.0)

func _on_submit_pressed() -> void:
	var message = input_edit.text.strip_edges()
	if message.is_empty() or is_typing:
		return

	input_edit.editable = false
	submit_btn.disabled = true
	status_badge.text = "✦ MENIMBANG KEBENARAN JIWAMU... ✦"
	status_badge.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	
	_start_typewriter("Dewa Kematian terdiam sejenak menimbang ucapanmu...")

	_request_ai_analysis(message)

func _request_ai_analysis(player_text: String) -> void:
	var http = HTTPRequest.new()
	http.timeout = 10.0
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
