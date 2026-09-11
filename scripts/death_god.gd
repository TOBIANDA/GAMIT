extends CanvasLayer

signal death_god_closed
signal afterlife_ascended

const SERVER_URL = "http://127.0.0.1:8000"
const TYPING_SPEED = 0.03

var is_active: bool = false
var current_question_idx: int = 0
var correct_answers_count: int = 0
var is_ending_screen: bool = false
var anim_time: float = 0.0

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

# Standoff Face-to-Face Chibi Elements
var standoff_panel: Control
var mc_chibi_rect: TextureRect
var grim_chibi_rect: TextureRect
var altar_rect: TextureRect
var altar_aura_glow: ColorRect
var altar_label: Label
var mc_aura_glow: ColorRect
var grim_aura_glow: ColorRect
var mc_label: Label
var grim_label: Label
var vs_symbol_label: Label
var mc_base_y: float = 0.0
var grim_base_y: float = 0.0
var altar_base_y: float = 0.0
var _last_standoff_w: float = -1.0

# Middle content container
var content_hb: HBoxContainer

# NLP freeform mode toggle
var nlp_panel: VBoxContainer
var input_field: LineEdit
var submit_btn: Button
var score_label: Label
var loading_label: Label

var afterlife_audio: AudioStreamPlayer

const QUESTIONS = [
	{
		"q": "Pertanyaan Pertama:
Jam berapa jarum waktu kota membeku saat detik terakhir hidupmu?",
		"options": [
			{"text": "A. Pukul 12:00 Siang", "correct": false},
			{"text": "B. Pukul 16:04 Sore", "correct": true},
			{"text": "C. Pukul 19:30 Malam", "correct": false}
		],
		"correct_feedback": "✦ Tepat (+25 Poin). Pukul 16:04... saat itulah denyut jantungmu di dunia fana berhenti berdetak.",
		"wrong_feedback": "✦ Keliru (+0 Poin). Jarum jam yang membeku di kota sesungguhnya menunjukkan pukul 16:04 sore..."
	},
	{
		"q": "Pertanyaan Kedua:
Mengapa orang-orang yang kau sapa di jalanan bergidik dingin dan tak menyahut?",
		"options": [
			{"text": "A. Karena warga kota sedang terburu-buru", "correct": false},
			{"text": "B. Karena ragamu sudah tiada — mereka hanya merasakan hawa dingin arwahmu", "correct": true},
			{"text": "C. Karena angin musim gugur bertiup kencang", "correct": false}
		],
		"correct_feedback": "✦ Benar (+25 Poin). Manusia fana hanya merasakan hawa dingin menusuk saat arwahmu melintas.",
		"wrong_feedback": "✦ Keliru (+0 Poin). Mereka menggigil bukan karena cuaca, melainkan hawa dingin arwahmu yang telah tiada..."
	},
	{
		"q": "Pertanyaan Ketiga:
Siapakah sosok korban sebenarnya yang tercetak di foto peron dan terbaring di peti jenazah rumah sakit?",
		"options": [
			{"text": "A. Penumpang kereta asing yang tak dikenal", "correct": false},
			{"text": "B. Inspektur Marcus dari kepolisian", "correct": false},
			{"text": "C. Diriku sendiri... Detektif Benedict", "correct": true}
		],
		"correct_feedback": "✦ Tepat (+25 Poin). Kau berani mengakui kenyataan bahwa seluruh penyelidikanmu adalah pencarian atas jasadmu sendiri.",
		"wrong_feedback": "✦ Keliru (+0 Poin). Jasad bernomor 040 yang terbaring kaku di ruang jenazah itu sesungguhnya adalah dirimu sendiri, Benedict..."
	},
	{
		"q": "Pertanyaan Terakhir (Penerimaan Jiwa):
Bagaimana sikapmu sekarang terhadap takdir kematianmu?",
		"options": [
			{"text": "A. Aku ikhlas menerima kematianku. Tugas dan penyelidikanku telah tuntas, aku siap beristirahat dalam damai.", "correct": true},
			{"text": "B. Aku masih menolak dan ingin kembali ke dunia orang hidup.", "correct": false}
		],
		"correct_feedback": "✦ Ikhlas dan Damai (+25 Poin). Ikatan penyesalan di dunia fana kini terlepas selamanya...",
		"wrong_feedback": "✦ Masih Terikat (+0 Poin). Jiwamu masih menyimpan sisa penolakan... Namun benang takdir dunia fana telah terputus."
	}
]

func _ready() -> void:
	_ensure_ui()
	visible = false

func _ensure_ui() -> void:
	layer = 20
	if bg != null:
		return
	_setup_audio()
	_build_ui()

func _setup_audio() -> void:
	afterlife_audio = AudioStreamPlayer.new()
	afterlife_audio.name = "AfterlifePlayer"
	if ResourceLoader.exists("res://sound/Afterlife.mp3"):
		afterlife_audio.stream = load("res://sound/Afterlife.mp3")
		afterlife_audio.volume_db = -5.0
	add_child(afterlife_audio)

func _build_ui() -> void:
	# 1. Background HITAM PEKAT MURNI
	bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	margin.add_child(vb)

	# --- A. HEADER ---
	var header = HBoxContainer.new()
	vb.add_child(header)

	title_label = Label.new()
	title_label.text = "✦ ALAM KEABADIAN — PENGHAKIMAN DEWA KEMATIAN ✦"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_color_override("font_color", Color(0.88, 0.75, 1.0))
	title_label.add_theme_font_size_override("font_size", 18)
	header.add_child(title_label)

	close_btn = Button.new()
	close_btn.text = "Kembali ke Dunia [ESC]"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close_interface)
	header.add_child(close_btn)

	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.45, 0.3, 0.65, 0.8))
	vb.add_child(sep)

	# --- B. STANDOFF PANEL (KOMPOSISI FRAME 2: ALTAR DI TENGAH, GRIM CHIBI DI ATAS ALTAR, MC CHIBI DI BAWAH MENGHADAP KE ATAS) ---
	standoff_panel = Control.new()
	standoff_panel.custom_minimum_size = Vector2(0, 480)
	standoff_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	standoff_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(standoff_panel)

	# 1. Altar Kematian Gothic di Tengah Layar
	altar_rect = TextureRect.new()
	altar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	altar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	altar_rect.custom_minimum_size = Vector2(330, 400)
	altar_rect.size = Vector2(330, 400)
	var tex_altar = load("res://Environment/altar_kematian.png")
	altar_rect.texture = tex_altar
	standoff_panel.add_child(altar_rect)

	# 2. Chibi Dewa Kematian (Grim Reaper) Berdiri di Atas Altar (Menghadap ke Bawah/Depan)
	grim_chibi_rect = TextureRect.new()
	grim_chibi_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grim_chibi_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	grim_chibi_rect.custom_minimum_size = Vector2(110, 140)
	grim_chibi_rect.size = Vector2(110, 140)
	var tex_grim = load("res://grimChibi/depan.png")
	grim_chibi_rect.texture = tex_grim
	standoff_panel.add_child(grim_chibi_rect)

	# 3. Chibi MC (Benedict) Berdiri di Kaki Altar (Menghadap ke Atas/Belakang dengan Tali Suspender)
	mc_chibi_rect = TextureRect.new()
	mc_chibi_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mc_chibi_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mc_chibi_rect.custom_minimum_size = Vector2(85, 115)
	mc_chibi_rect.size = Vector2(85, 115)
	var tex_mc = load("res://posisi mc/back.png")
	if not tex_mc:
		tex_mc = load("res://posisi mc/front.png")
	mc_chibi_rect.texture = tex_mc
	standoff_panel.add_child(mc_chibi_rect)

	# Aura halus opsional
	altar_aura_glow = ColorRect.new()
	altar_aura_glow.color = Color(0.25, 0.65, 0.95, 0.0)
	standoff_panel.add_child(altar_aura_glow)
	mc_aura_glow = ColorRect.new()
	mc_aura_glow.color = Color(0.2, 0.5, 0.9, 0.0)
	standoff_panel.add_child(mc_aura_glow)
	grim_aura_glow = ColorRect.new()
	grim_aura_glow.color = Color(0.60, 0.20, 0.90, 0.0)
	standoff_panel.add_child(grim_aura_glow)

	# Layout positioning untuk standoff panel
	standoff_panel.resized.connect(_update_standoff_positions)

	# --- C. MIDDLE CONTENT: GRIM PORTRAIT CARD + QUESTION BOX ---
	content_hb = HBoxContainer.new()
	content_hb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_hb.add_theme_constant_override("separation", 20)
	vb.add_child(content_hb)

	# Left: Grim Non-Chibi Portrait Card
	var grim_card = PanelContainer.new()
	grim_card.custom_minimum_size = Vector2(210, 0)
	var gc_style = StyleBoxFlat.new()
	gc_style.bg_color = Color(0.04, 0.02, 0.08, 0.95)
	gc_style.border_color = Color(0.65, 0.45, 0.9, 0.8)
	gc_style.set_border_width_all(2)
	gc_style.set_corner_radius_all(10)
	grim_card.add_theme_stylebox_override("panel", gc_style)
	content_hb.add_child(grim_card)

	var gc_vb = VBoxContainer.new()
	gc_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	gc_vb.add_theme_constant_override("separation", 8)
	grim_card.add_child(gc_vb)

	# Non-chibi Grim Reaper visual novel portrait
	grim_portrait_rect = TextureRect.new()
	if ResourceLoader.exists("res://karakter/grim.png"):
		grim_portrait_rect.texture = load("res://karakter/grim.png")
	elif ResourceLoader.exists("res://grimChibi/depan.png"):
		grim_portrait_rect.texture = load("res://grimChibi/depan.png")
	grim_portrait_rect.custom_minimum_size = Vector2(170, 210)
	grim_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grim_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gc_vb.add_child(grim_portrait_rect)

	var grim_name_lbl = Label.new()
	grim_name_lbl.text = "Sang Dewa Kematian"
	grim_name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grim_name_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0))
	grim_name_lbl.add_theme_font_size_override("font_size", 13)
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
	qb_style.bg_color = Color(0.05, 0.03, 0.09, 0.95)
	qb_style.border_color = Color(0.5, 0.35, 0.75, 0.7)
	qb_style.set_border_width_all(2)
	qb_style.set_corner_radius_all(10)
	qb_style.set_content_margin_all(18)
	question_box.add_theme_stylebox_override("panel", qb_style)
	content_hb.add_child(question_box)

	var q_vb = VBoxContainer.new()
	q_vb.add_theme_constant_override("separation", 12)
	question_box.add_child(q_vb)

	prompt_label = Label.new()
	prompt_label.text = "Memulai review bukti kematian..."
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.add_theme_color_override("font_color", Color(0.95, 0.92, 1.0))
	prompt_label.add_theme_font_size_override("font_size", 15)
	q_vb.add_child(prompt_label)

	options_container = VBoxContainer.new()
	options_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	options_container.add_theme_constant_override("separation", 8)
	q_vb.add_child(options_container)

	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
	feedback_label.add_theme_font_size_override("font_size", 13)
	q_vb.add_child(feedback_label)

	# --- D. NLP INPUT PANEL ---
	nlp_panel = VBoxContainer.new()
	nlp_panel.add_theme_constant_override("separation", 6)
	vb.add_child(nlp_panel)

	var nlp_hb = HBoxContainer.new()
	nlp_hb.add_theme_constant_override("separation", 10)
	nlp_panel.add_child(nlp_hb)

	input_field = LineEdit.new()
	input_field.placeholder_text = "Opsi Tambahan: Ketik bebas pesan/pengakuan terakhirmu kepada Dewa Kematian..."
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.custom_minimum_size = Vector2(0, 38)
	var if_style = StyleBoxFlat.new()
	if_style.bg_color = Color(0.08, 0.06, 0.14)
	if_style.border_color = Color(0.5, 0.35, 0.7, 0.8)
	if_style.set_border_width_all(1)
	if_style.set_corner_radius_all(6)
	if_style.set_content_margin_all(8)
	input_field.add_theme_stylebox_override("normal", if_style)
	nlp_hb.add_child(input_field)

	submit_btn = Button.new()
	submit_btn.text = "Kirim Pesan"
	submit_btn.custom_minimum_size = Vector2(120, 38)
	submit_btn.pressed.connect(_on_nlp_submit)
	nlp_hb.add_child(submit_btn)

	input_field.text_submitted.connect(func(_t): _on_nlp_submit())

	loading_label = Label.new()
	loading_label.text = ""
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_label.add_theme_color_override("font_color", Color(0.65, 0.6, 0.8))
	loading_label.add_theme_font_size_override("font_size", 12)
	nlp_panel.add_child(loading_label)

func _get_standoff_width() -> float:
	if is_instance_valid(standoff_panel) and standoff_panel.size.x >= 300.0:
		return standoff_panel.size.x
	var vp = get_viewport()
	if is_instance_valid(vp):
		var vpw = vp.get_visible_rect().size.x
		if vpw > 300.0:
			return vpw - 96.0
	return 1184.0

func _update_standoff_positions() -> void:
	if not is_instance_valid(standoff_panel):
		return
	var w = _get_standoff_width()
	_last_standoff_w = w

	var altar_w: float = 330.0
	var altar_h: float = 400.0
	var altar_x: float = (w - altar_w) * 0.5
	altar_base_y = 60.0

	var grim_w: float = 110.0
	var grim_h: float = 140.0
	var grim_x: float = altar_x + (altar_w - grim_w) * 0.5
	grim_base_y = altar_base_y + 82.0

	var mc_w: float = 85.0
	var mc_h: float = 115.0
	var mc_x: float = altar_x + (altar_w - mc_w) * 0.5
	mc_base_y = altar_base_y + 265.0

	if is_instance_valid(altar_rect):
		altar_rect.position = Vector2(altar_x, altar_base_y)
		altar_rect.size = Vector2(altar_w, altar_h)
	if is_instance_valid(grim_chibi_rect):
		grim_chibi_rect.custom_minimum_size = Vector2(grim_w, grim_h)
		grim_chibi_rect.size = Vector2(grim_w, grim_h)
		grim_chibi_rect.position = Vector2(grim_x, grim_base_y)
	if is_instance_valid(mc_chibi_rect):
		mc_chibi_rect.custom_minimum_size = Vector2(mc_w, mc_h)
		mc_chibi_rect.size = Vector2(mc_w, mc_h)
		mc_chibi_rect.position = Vector2(mc_x, mc_base_y)

	if is_instance_valid(mc_label): mc_label.visible = false
	if is_instance_valid(grim_label): grim_label.visible = false
	if is_instance_valid(altar_label): altar_label.visible = false
	if is_instance_valid(mc_aura_glow): mc_aura_glow.visible = false
	if is_instance_valid(grim_aura_glow): grim_aura_glow.visible = false
	if is_instance_valid(altar_aura_glow): altar_aura_glow.visible = false
	if is_instance_valid(vs_symbol_label): vs_symbol_label.visible = false

func _process(delta: float) -> void:
	if not visible:
		return

	var current_w = standoff_panel.size.x if is_instance_valid(standoff_panel) else 0.0
	if abs(current_w - _last_standoff_w) > 4.0 and current_w >= 300.0:
		_update_standoff_positions()

	anim_time += delta
	# Animasi melayang Chibi Dewa Kematian
	if is_instance_valid(grim_chibi_rect):
		var grim_bob = sin(anim_time * 2.5) * 6.0
		grim_chibi_rect.position.y = grim_base_y + grim_bob
	if is_instance_valid(grim_aura_glow):
		grim_aura_glow.color.a = 0.30 + 0.15 * sin(anim_time * 3.0)

	# Animasi nafas halus Chibi Benedict
	if is_instance_valid(mc_chibi_rect):
		var mc_bob = sin(anim_time * 2.0) * 2.5
		mc_chibi_rect.position.y = mc_base_y + mc_bob
	if is_instance_valid(mc_aura_glow):
		mc_aura_glow.color.a = 0.25 + 0.10 * sin(anim_time * 2.0)
	if is_instance_valid(altar_aura_glow):
		altar_aura_glow.color.a = 0.30 + 0.15 * sin(anim_time * 3.2)

func open_interface() -> void:
	_ensure_ui()
	is_active = true
	is_ending_screen = false
	current_question_idx = 0
	correct_answers_count = 0
	visible = true
	feedback_label.text = ""
	_update_standoff_positions()
	_play_afterlife_sound()

	# Sembunyikan question box dan header agar bersih menampilkan Frame 2 (Standoff)
	if is_instance_valid(title_label) and is_instance_valid(title_label.get_parent()):
		title_label.get_parent().visible = false
	if is_instance_valid(content_hb):
		content_hb.visible = false
	if is_instance_valid(nlp_panel):
		nlp_panel.visible = false

	# Tampilkan Frame 2 sejenak (1.5 detik) agar pemain menikmati tatap-tatapan di depan altar, lalu mulai dialog Frame 1 & 3
	var tw = create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(_start_intro_confrontation_dialog)

func _start_intro_confrontation_dialog() -> void:
	var dlg = null
	var main_node = get_parent()
	if is_instance_valid(main_node):
		dlg = main_node.get_node_or_null("DialogBox")

	if is_instance_valid(dlg) and dlg.has_method("start_dialogue_sequence"):
		# Sembunyikan question box dan header agar bersih sesuai Frame 1, 2, 3
		if is_instance_valid(title_label) and is_instance_valid(title_label.get_parent()):
			title_label.get_parent().visible = false
		content_hb.visible = false
		nlp_panel.visible = false

		var confrontation_dialogue: Array = [
			{
				"speaker": "Detektif Benedict",
				"badge": "[ BATAS TAKDIR ]",
				"portrait": "res://karakter/MC_Biasa.png",
				"text": "Tempat apa ini...? Dan sosok berjubah di atas altar itu..."
			},
			{
				"speaker": "Sang Dewa Kematian",
				"badge": "[ BATAS KEABADIAN ]",
				"portrait": "res://karakter/grim.png",
				"text": "Akhirnya kau tiba di altar ini, wahai jiwa yang tersesat..."
			},
			{
				"speaker": "Detektif Benedict",
				"badge": "[ KEBINGUNGAN BATIN ]",
				"portrait": "res://karakter/MC_Kaget.png",
				"text": "Altar ini... dan sosok berjubah di hadapanku... Siapa kau sebenarnya? Mengapa orang-orang di kota tak ada yang menyahut panggilanku?!"
			},
			{
				"speaker": "Sang Dewa Kematian",
				"badge": "[ HAKIKAT KEMATIAN ]",
				"portrait": "res://karakter/grim.png",
				"text": "Aku adalah Sang Dewa Kematian. Alasan mereka tak menyahutmu... adalah karena ragamu telah terpisah dari dunia orang hidup."
			},
			{
				"speaker": "Detektif Benedict",
				"badge": "[ PENYELIDIKAN AKHIR ]",
				"portrait": "res://karakter/MC_Sedih.png",
				"text": "Ragaku telah tiada...? Berarti jam dinding yang membeku di 16:04... dan jasad bernomor 040 di ruang jenazah itu..."
			},
			{
				"speaker": "Sang Dewa Kematian",
				"badge": "[ KEBENARAN MUTLAK ]",
				"portrait": "res://karakter/grim.png",
				"text": "Benar, Benedict. Korban yang kau selidiki selama ini adalah jasadmu sendiri. Jiwamu terjebak dalam penolakan akan takdir ini."
			},
			{
				"speaker": "Detektif Benedict",
				"badge": "[ PENERIMAAN TAKDIR ]",
				"portrait": "res://karakter/MC_Biasa.png",
				"text": "Kematianku sendiri... Jadi penyelidikan ini adalah jalan bagiku untuk menyadari takdirku. Lalu apa yang harus kulakukan di altar ini?"
			},
			{
				"speaker": "Sang Dewa Kematian",
				"badge": "[ PENGHAKIMAN AKHIR ]",
				"portrait": "res://karakter/grim.png",
				"text": "Tataplah altar ini. Buktikan jiwamu telah ikhlas melepaskan dunia fana. Jawablah pertanyaanku, dan masuklah ke dalam keabadian yang damai."
			}
		]

		# Hook signal agar chibi yang sedang berbicara bereaksi/menyorot
		var on_line_change = func(entry: Dictionary):
			var spk: String = entry.get("speaker", "")
			if spk.contains("Dewa Kematian"):
				if is_instance_valid(grim_aura_glow):
					grim_aura_glow.color = Color(0.8, 0.35, 1.0, 0.65)
				if is_instance_valid(mc_aura_glow):
					mc_aura_glow.color = Color(0.2, 0.5, 0.9, 0.20)
			else:
				if is_instance_valid(mc_aura_glow):
					mc_aura_glow.color = Color(0.3, 0.7, 1.0, 0.65)
				if is_instance_valid(grim_aura_glow):
					grim_aura_glow.color = Color(0.6, 0.2, 0.9, 0.20)

		if dlg.has_signal("dialogue_line_started") and not dlg.dialogue_line_started.is_connected(on_line_change):
			dlg.dialogue_line_started.connect(on_line_change)

		dlg.start_dialogue_sequence(confrontation_dialogue, true)

		var on_done_called = false
		var on_done = func():
			if on_done_called:
				return
			on_done_called = true
			if dlg.has_signal("dialogue_line_started") and dlg.dialogue_line_started.is_connected(on_line_change):
				dlg.dialogue_line_started.disconnect(on_line_change)
			# Kembalikan pendaran glow normal
			if is_instance_valid(grim_aura_glow):
				grim_aura_glow.color = Color(0.60, 0.20, 0.90, 0.40)
			if is_instance_valid(mc_aura_glow):
				mc_aura_glow.color = Color(0.2, 0.5, 0.9, 0.35)
			if is_instance_valid(title_label) and is_instance_valid(title_label.get_parent()):
				title_label.get_parent().visible = true
			if is_instance_valid(content_hb):
				content_hb.visible = true
				content_hb.modulate.a = 1.0
			if is_instance_valid(nlp_panel):
				nlp_panel.visible = true
				nlp_panel.modulate.a = 1.0
			_display_current_question()

		dlg.monologue_finished.connect(on_done, CONNECT_ONE_SHOT)
		if not dlg.dialog_closed.is_connected(on_done):
			dlg.dialog_closed.connect(on_done, CONNECT_ONE_SHOT)
	elif is_instance_valid(dlg) and dlg.has_method("start_monologue"):
		content_hb.modulate.a = 0.0
		nlp_panel.modulate.a = 0.0
		var intro_lines: Array[String] = [
			"Akhirnya... kabut penolakanmu telah tersingkap di hadapan altar ini, wahai arwah pengelana.",
			"Waktumu di dunia manusia telah terhenti di jam 16:04. Mayat di peti rumah sakit itu adalah jasadmu yang tertinggal.",
			"Kau bukan lagi detektif yang mencari pembunuh... Kau adalah korban yang enggan melepaskan dunia.",
			"Sekarang, tataplah altar ini dan jawablah pertanyaanku... agar jiwamu dapat beristirahat dalam damai."
		]
		dlg.start_monologue(intro_lines, "✦ Dewa Kematian ✦", "[ PENGHAKIMAN AKHIR ]", "res://karakter/grim.png")
		var on_done_called = false
		var on_done = func():
			if on_done_called:
				return
			on_done_called = true
			if is_instance_valid(content_hb) and content_hb.modulate.a < 0.9:
				var tw_show = create_tween()
				tw_show.tween_property(content_hb, "modulate:a", 1.0, 0.45)
				tw_show.parallel().tween_property(nlp_panel, "modulate:a", 1.0, 0.45)
			_display_current_question()

		dlg.monologue_finished.connect(on_done, CONNECT_ONE_SHOT)
		if not dlg.dialog_closed.is_connected(on_done):
			dlg.dialog_closed.connect(on_done, CONNECT_ONE_SHOT)
	else:
		content_hb.modulate.a = 1.0
		nlp_panel.modulate.a = 1.0
		_display_current_question()

func close_interface() -> void:
	is_active = false
	visible = false
	if is_instance_valid(afterlife_audio) and afterlife_audio.playing:
		afterlife_audio.stop()
	death_god_closed.emit()

func _play_afterlife_sound() -> void:
	if is_inside_tree() and is_instance_valid(afterlife_audio) and afterlife_audio.stream:
		if not afterlife_audio.playing:
			afterlife_audio.play()

func _display_current_question() -> void:
	if current_question_idx >= QUESTIONS.size():
		_show_peaceful_ascension()
		return

	var q_data = QUESTIONS[current_question_idx]
	prompt_label.text = q_data["q"]
	progress_label.text = "✦ Pertanyaan %d dari %d • Poin Jiwa: %d / 100 ✦" % [current_question_idx + 1, QUESTIONS.size(), correct_answers_count * 25]
	feedback_label.text = ""

	for child in options_container.get_children():
		child.queue_free()

	for opt in q_data["options"]:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.custom_minimum_size = Vector2(0, 42)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(0.10, 0.07, 0.18, 0.95)
		b_style.border_color = Color(0.45, 0.35, 0.65, 0.8)
		b_style.set_border_width_all(1)
		b_style.set_corner_radius_all(8)
		b_style.content_margin_left = 14
		b_style.content_margin_right = 14
		btn.add_theme_stylebox_override("normal", b_style)

		var h_style = b_style.duplicate()
		h_style.bg_color = Color(0.22, 0.14, 0.35, 0.98)
		h_style.border_color = Color(0.75, 0.55, 1.0, 1.0)
		btn.add_theme_stylebox_override("hover", h_style)

		var is_corr: bool = opt.get("correct", false)
		var c_fb: String = q_data.get("correct_feedback", "")
		var w_fb: String = q_data.get("wrong_feedback", "")
		btn.pressed.connect(func(): _on_option_selected(is_corr, c_fb, w_fb))
		options_container.add_child(btn)

func _on_option_selected(is_correct: bool, feedback: String, wrong_feedback: String = "") -> void:
	# Kunci semua tombol opsi agar pemain tidak bisa spam klik
	for btn in options_container.get_children():
		if btn is Button:
			btn.disabled = true

	if is_correct:
		correct_answers_count += 1
		feedback_label.text = feedback
		feedback_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
	else:
		feedback_label.text = wrong_feedback if not wrong_feedback.is_empty() else "✦ Keliru (+0 Poin). Dewa Kematian mencatat keraguan jiwamu..."
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.50, 0.50))

	progress_label.text = "✦ Pertanyaan %d dari %d • Poin Jiwa: %d / 100 ✦" % [current_question_idx + 1, QUESTIONS.size(), correct_answers_count * 25]

	# Tetap maju ke pertanyaan berikutnya baik jawaban benar maupun salah!
	var tw = create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(func():
		current_question_idx += 1
		_display_current_question()
	)

func _show_peaceful_ascension() -> void:
	is_ending_screen = true
	for child in options_container.get_children():
		child.queue_free()

	var total_q: int = QUESTIONS.size()
	var total_points: int = correct_answers_count * 25
	var score_pct: int = int((float(correct_answers_count) / float(total_q)) * 100.0)

	var eval_title: String = ""
	var eval_desc: String = ""
	var badge_color: Color = Color(1.0, 0.85, 0.4)

	if correct_answers_count == total_q:
		eval_title = "PENERIMAAN SEMPURNA"
		eval_desc = "'Seluruh misteri telah kau urai dengan sempurna, Benedict. Kau telah memecahkan teka-teki terakhirmu: kematian dirimu sendiri tanpa ada keraguan sedikit pun.\n\nTidak ada lagi penyesalan, tidak ada lagi belenggu fana. Jiwamu murni, ikhlas, dan damai seutuhnya. Melangkahlah menuju cahaya peristirahatan abadi.'"
		badge_color = Color(0.4, 0.95, 0.6)
	elif correct_answers_count >= 2:
		eval_title = "PENERIMAAN BAIK"
		eval_desc = "'Sebagian besar bukti telah kau pahami dengan baik, Benedict. Walau ada keraguan yang sempat melintas, jiwamu pada akhirnya mampu menerima kebenaran ini.\n\nTugas penyelidikanmu di dunia orang hidup telah purna. Damailah jiwamu di alam keabadian.'"
		badge_color = Color(0.95, 0.85, 0.4)
	else:
		eval_title = "PENERIMAAN DENGAN KERAGUAN"
		eval_desc = "'Jiwamu masih diliputi rasa bingung dan penolakan atas apa yang menimpa dirimu. Namun waktu fana tak lagi dapat diputar kembali.\n\nDewa Kematian membimbingmu melangkah melewati pintu keabadian untuk melepaskan sisa beban duniawi.'"
		badge_color = Color(1.0, 0.60, 0.60)

	progress_label.text = "✦ Penghakiman Jiwa Selesai ✦"
	prompt_label.text = "✦ KEPUTUSAN SANG DEWA KEMATIAN ✦\n\n• Skor Investigasi Jiwa: %d / 100 Poin (%d dari %d Soal Benar — %d%%)\n• Status Penerimaan: %s\n\n%s" % [
		total_points,
		correct_answers_count,
		total_q,
		score_pct,
		eval_title,
		eval_desc
	]

	feedback_label.text = "TOTAL POIN INVESTIGASI: %d / 100 POIN (%s)" % [total_points, eval_title]
	feedback_label.add_theme_color_override("font_color", badge_color)

	var victory_btn = Button.new()
	victory_btn.text = "MELANGKAH MENUJU AFTERLIFE DENGAN DAMAI ✦"
	victory_btn.custom_minimum_size = Vector2(0, 50)
	var vb_style = StyleBoxFlat.new()
	vb_style.bg_color = Color(0.25, 0.18, 0.42, 0.98)
	vb_style.border_color = badge_color
	vb_style.set_border_width_all(2)
	vb_style.set_corner_radius_all(10)
	victory_btn.add_theme_stylebox_override("normal", vb_style)
	victory_btn.pressed.connect(_finish_game_afterlife)
	options_container.add_child(victory_btn)

	afterlife_ascended.emit()

func _finish_game_afterlife() -> void:
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
	for c in get_children():
		if c != afterlife_audio:
			c.queue_free()

	var end_bg = ColorRect.new()
	end_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_bg.color = Color(0.02, 0.02, 0.04, 1.0)
	add_child(end_bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vb = VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 16)
	center.add_child(vb)

	var t1 = Label.new()
	t1.text = "✦ KASUS TERAKHIR SELESAI ✦"
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t1.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	t1.add_theme_font_size_override("font_size", 26)
	vb.add_child(t1)

	var t2 = Label.new()
	t2.text = "Detektif Benedict telah menerima takdirnya dan melangkah ke alam berikutnya dalam damai."
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t2.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	t2.add_theme_font_size_override("font_size", 15)
	vb.add_child(t2)

	var t_score = Label.new()
	var total_points: int = correct_answers_count * 25
	t_score.text = "Skor Akhir Investigasi Jiwa: %d / 100 Poin (%d/%d Benar)" % [total_points, correct_answers_count, QUESTIONS.size()]
	t_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_score.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	t_score.add_theme_font_size_override("font_size", 17)
	vb.add_child(t_score)

	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(380, 20)
	vb.add_child(sep)

	var restart_btn = Button.new()
	restart_btn.text = "Mulai Ulang Investigasi"
	restart_btn.custom_minimum_size = Vector2(260, 46)
	restart_btn.pressed.connect(func():
		var main_node = get_parent()
		if is_instance_valid(main_node) and main_node.has_method("reset_game_to_start"):
			main_node.reset_game_to_start()
		var main_script = load("res://scripts/main.gd")
		if main_script:
			main_script.cutscene_played = false
		get_tree().paused = false
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
	http.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
		loading_label.text = ""
		if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
			feedback_label.text = "Dewa Kematian menatapmu dalam hening: 'Kata-katamu terserap dalam kegelapan...'"
			feedback_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
			http.queue_free()
			return

		var json = JSON.new()
		var parse_err = json.parse(body.get_string_from_utf8())
		if parse_err != OK:
			feedback_label.text = "Dewa Kematian mengangguk perlahan..."
			http.queue_free()
			return

		var data = json.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			var respon = data.get("respon", "Aku mendengarmu...")
			feedback_label.text = "Dewa Kematian: '" + respon + "'"
			feedback_label.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0))
		http.queue_free()
	)

	var json_body = JSON.stringify({"teks": teks})
	var headers = ["Content-Type: application/json"]
	var err = http.request(SERVER_URL + "/analisis", headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		loading_label.text = ""
		feedback_label.text = "Dewa Kematian menatap dalam hening..."
		http.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			close_interface()
			get_viewport().set_input_as_handled()
