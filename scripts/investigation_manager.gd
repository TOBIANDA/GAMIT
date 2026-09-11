extends Node

signal phase_changed(new_phase: int, phase_title: String)
signal clue_collected(clue_id: String, clue_title: String)
signal desaturation_updated(amount: float)
signal notification_displayed(message: String)

enum Phase {
	PROLOGUE_HOME = 0,
	INVESTIGATION_1_POLICE = 1,
	INVESTIGATION_2_STATION = 2,
	INVESTIGATION_3_PHOTO = 3,
	INVESTIGATION_4_HOSPITAL = 4,
	FINAL_DEATH_GOD = 5
}

var current_phase: Phase = Phase.PROLOGUE_HOME
var desaturation_level: float = 0.0

var clues: Dictionary = {
	"police_letter": {
		"unlocked": false,
		"title": "Surat Tugas Kepolisian (Kasus 404)",
		"desc": "Surat resmi penugasan: jenazah tak dikenal ditemukan di gang sempit kota. Detektif diminta menggali kebenaran dan menemui pihak di gedung tempat hukum ditegakkan.",
		"phase": 0
	},
	"victim_letter": {
		"unlocked": false,
		"title": "Surat Wasiat Korban di Rumah",
		"desc": "Surat di meja rumah korban: merasa terus diawasi, ada ketukan pintu larut malam & jejak sepatu basah. 'Kalau memang terjadi sesuatu padaku, tolong periksa Marcus lebih dulu'.",
		"phase": 0
	},
	"street_clock_freeze": {
		"unlocked": false,
		"title": "Jam Kota Membeku (16:04)",
		"desc": "Jam kota terhenti kaku tepat di pukul 16:04. Orang-orang di sekitar merinding dan ketakutan saat disapa.",
		"phase": 0
	},
	"mother_photo_riddle": {
		"unlocked": false,
		"title": "Foto Ibu dan Anak (Misi Opsional)",
		"desc": "Foto ibu bersama anaknya di meja rumah korban. Di balik foto tertulis: 'Kembalilah ke rumah ibu jika sempat... Kuncinya: waktu yang membeku (1-6-4)'.",
		"phase": 0
	},
	"police_eavesdrop": {
		"unlocked": false,
		"title": "Obrolan Rahasia Marcus",
		"desc": "Menguping Marcus: Korban terakhir terlihat berjalan terburu-buru ke Stasiun Kereta Api hendak liburan keluar kota.",
		"phase": 1
	},
	"train_ticket": {
		"unlocked": false,
		"title": "Tiket Kereta Api Terakhir",
		"desc": "Tiket sekali jalan atas nama seorang detektif yang tergeletak di bangku peron stasiun.",
		"phase": 2
	},
	"photo_envelope": {
		"unlocked": false,
		"title": "Amplop Rol Foto Korban",
		"desc": "Amplop berisi rol film foto korban sebelum meninggal yang tercecer di peron stasiun. Perlu dicuci di kamar gelap.",
		"phase": 2
	},
	"pocket_watch": {
		"unlocked": false,
		"title": "Jam Saku Korban (16:04)",
		"desc": "Jam saku logam korban yang terlempar di dekat tangga peron stasiun. Jarum jamnya terhenti di 16:04.",
		"phase": 2
	},
	"developed_photos": {
		"unlocked": false,
		"title": "Foto Forensik (Wajah Benedict Sendiri)",
		"desc": "Setelah dicuci di kamar gelap, foto ke-4 memperlihatkan fakta mengguncang: wajah korban adalah wajah Benedict sendiri!",
		"phase": 3
	},
	"autopsy_corpse": {
		"unlocked": false,
		"title": "Jasad di Kamar Mayat RS",
		"desc": "Menyelinap ke kamar mayat RS dan menyingkap kain mayat. Tak terbantahkan lagi, mayat di atas ranjang adalah diriku sendiri yang telah mati.",
		"phase": 4
	},
	"mother_emotional_locket": {
		"unlocked": false,
		"title": "Liontin Kenangan Ibu (True Ending Item)",
		"desc": "Hadiah kasih sayang abadi dari Ibu Medeline di dalam brankas rumah ibu.",
		"phase": 0
	}
}

var safe_unlocked: bool = false
var has_tailgated_marcus: bool = false
var has_cleared_station: bool = false
var has_developed_photos: bool = false
var has_inspected_morgue: bool = false

func _ready() -> void:
	_update_desaturation()

func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	_update_desaturation()
	
	var title = get_current_objective_title()
	phase_changed.emit(current_phase, title)
	notification_displayed.emit("TUJUAN BARU: " + title)

func get_current_objective_title() -> String:
	match current_phase:
		Phase.PROLOGUE_HOME:
			return "Telusuri Jalan & Selidiki Rumah Korban"
		Phase.INVESTIGATION_1_POLICE:
			return "Temui & Kuntit Inspektur Marcus di Kantor Polisi"
		Phase.INVESTIGATION_2_STATION:
			return "Selidiki Bukti di Stasiun Kereta Api Ujung Timur"
		Phase.INVESTIGATION_3_PHOTO:
			return "Cuci Rol Foto di Kamar Gelap Lab Forensik"
		Phase.INVESTIGATION_4_HOSPITAL:
			return "Menyelinap ke Kamar Mayat Rumah Sakit"
		Phase.FINAL_DEATH_GOD:
			return "Menjawab Pengadilan Dewa Kematian"
	return "Lanjutkan Penyelidikan Kasus"

func get_current_objective_desc() -> String:
	match current_phase:
		Phase.PROLOGUE_HOME:
			return "Berjalanlah di sepanjang trotoar menuju rumah korban di timur. Periksa keanehan waktu 16:04 dan cari petunjuk di dalam rumah."
		Phase.INVESTIGATION_1_POLICE:
			return "Rumah korban buntu. Temui Inspektur Marcus di Kantor Polisi barat untuk menguping petunjuk arah kepergian korban."
		Phase.INVESTIGATION_2_STATION:
			return "Marcus menyebut korban pergi ke stasiun kereta api untuk liburan. Amankan amplop rol foto korban di peron stasiun!"
		Phase.INVESTIGATION_3_PHOTO:
			return "Bawa rol film ke bak cairan kamar gelap. Rendam dan bilas dengan hati-hati untuk menyingkap wajah korban."
		Phase.INVESTIGATION_4_HOSPITAL:
			return "Wajah di foto adalah wajahmu sendiri! Izin resmi ditolak di depan, kamu harus menyelinap ke kamar mayat RS!"
		Phase.FINAL_DEATH_GOD:
			return "Kebenaran mutlak terungkap. Jiwamu ditarik ke hadapan Dewa Kematian untuk mempertanggungjawabkan seluruh temuanmu."
	return ""

func unlock_clue(clue_id: String) -> void:
	if clues.has(clue_id):
		if not clues[clue_id]["unlocked"]:
			clues[clue_id]["unlocked"] = true
			clue_collected.emit(clue_id, clues[clue_id]["title"])
			notification_displayed.emit("BUKTI BARU: " + clues[clue_id]["title"])
			_update_desaturation()

func is_clue_unlocked(clue_id: String) -> bool:
	if clues.has(clue_id):
		return clues[clue_id]["unlocked"]
	return false

func has_emotional_item() -> bool:
	return is_clue_unlocked("mother_emotional_locket")

func _update_desaturation() -> void:
	var count = 0
	for k in clues.keys():
		if clues[k]["unlocked"]:
			count += 1
	
	var target = float(current_phase) * 0.16 + (float(count) / float(clues.size())) * 0.20
	desaturation_level = clampf(target, 0.0, 0.90)
	desaturation_updated.emit(desaturation_level)

func get_investigation_progress_percent() -> int:
	var count = 0
	for k in clues.keys():
		if clues[k]["unlocked"]:
			count += 1
	return int((float(count) / float(clues.size())) * 100.0)
