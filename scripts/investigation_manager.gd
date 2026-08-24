extends Node

# ── Investigation Manager (Sistem Alur Cerita & Kasus Sesuai GDD) ───────────
# Mengatur tahapan cerita dari awal sampai akhir, inventaris bukti, desaturasi dunia,
# dan trigger 3 Minigame + Side Quest Brankas Ibu Medeline.

signal phase_changed(new_phase: int, phase_title: String)
signal clue_collected(clue_id: String, clue_title: String)
signal desaturation_updated(amount: float)
signal notification_displayed(message: String)

enum Phase {
	PROLOGUE_HOME = 0,         # Di rumah Benedict: baca surat tugas & foto ibu
	INVESTIGATION_1_POLICE = 1, # Kantor Polisi & Minigame 1: Tailgating Marcus
	INVESTIGATION_2_STATION = 2,# Stasiun Kereta & Minigame 2: Hidden Objects
	INVESTIGATION_3_PHOTO = 3,  # Rumah Benedict & Minigame 3: Cuci Foto Forensik
	INVESTIGATION_4_HOSPITAL = 4,# RS & Kamar Mayat: Menemukan mayat diri sendiri
	FINAL_DEATH_GOD = 5         # Kuil Dewa Kematian: Evaluasi Jiwa & True Ending
}

var current_phase: Phase = Phase.PROLOGUE_HOME
var desaturation_level: float = 0.0 # 0.0 (Warna Normal) s.d 1.0 (Monokrom Pucat)

# ── Status Barang Bukti & Clue Log ──────────────────────────────────────────
var clues: Dictionary = {
	"anonymous_letter": {
		"unlocked": false,
		"title": "✉️ Surat Tugas Misterius",
		"desc": "Surat anonim di meja rumah memintaku menyelidiki kematian seseorang. Petunjuk awal: temui Inspektur Marcus di Kantor Polisi.",
		"phase": 0
	},
	"mother_photo_riddle": {
		"unlocked": false,
		"title": "🖼️ Foto Masa Kecil Bersama Ibu",
		"desc": "Foto bersama Ibu Medeline. Di balik foto tertulis pesan: 'Jemput hadiahmu di brankas rumah ibu. Kuncinya adalah waktu yang membeku (1-6-4)'.",
		"phase": 0
	},
	"police_eavesdrop": {
		"unlocked": false,
		"title": "🎙️ Percakapan Rahasia Polisi",
		"desc": "Menguping Marcus: Korban terakhir terlihat berjalan ke Stasiun Kereta Api untuk ke luar kota.",
		"phase": 1
	},
	"train_ticket": {
		"unlocked": false,
		"title": "🎫 Tiket Kereta Api Terakhir",
		"desc": "Tiket sekali jalan atas nama seorang detektif yang tergeletak di bangku peron stasiun.",
		"phase": 2
	},
	"broken_pocket_watch": {
		"unlocked": false,
		"title": "⏱️ Jam Saku Rusak (16:04)",
		"desc": "Jam saku berbahan perak yang kacanya retak, jarumnya berhenti tepat di pukul 16:04.",
		"phase": 2
	},
	"photo_envelope": {
		"unlocked": false,
		"title": "📁 Amplop Foto TKP",
		"desc": "Amplop tersegel berisi rol film foto korban sebelum meninggal. Perlu dicuci di kamar gelap rumah.",
		"phase": 2
	},
	"developed_photos": {
		"unlocked": false,
		"title": "📷 Foto Forensik Mayat (Wajah Sendiri)",
		"desc": "Setelah dicuci dengan hati-hati, foto korban menampakkan wajah yang sangat kukenal... wajahku sendiri (Benedict).",
		"phase": 3
	},
	"autopsy_corpse": {
		"unlocked": false,
		"title": "🩺 Jasad di Kamar Mayat RS",
		"desc": "Menyelinap ke RS dan melihat mayat di meja otopsi. Tidak diragukan lagi, korban yang kucari adalah diriku sendiri yang telah mati.",
		"phase": 4
	},
	"mother_emotional_locket": {
		"unlocked": false,
		"title": "💎 Liontin Kenangan Ibu Medeline (Emotional Item)",
		"desc": "Hadiah kasih sayang dari Ibu Medeline yang tersimpan di brankas. Kunci untuk menenangkan jiwa dan meraih True Ending di hadapan Sang Dewa.",
		"phase": 0
	}
}

# ── Progress Tracker ────────────────────────────────────────────────────────
var safe_unlocked: bool = false
var has_tailgated_marcus: bool = false
var has_cleared_station: bool = false
var has_developed_photos: bool = false
var has_inspected_morgue: bool = false

func _ready() -> void:
	# Unlock clue awal saat game dimulai
	unlock_clue("anonymous_letter")
	unlock_clue("mother_photo_riddle")
	_update_desaturation()

# ── Fungsi Pengelolaan Fase Cerita ──────────────────────────────────────────
func set_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	_update_desaturation()
	
	var title = get_current_objective_title()
	phase_changed.emit(current_phase, title)
	notification_displayed.emit("📌 TUJUAN BARU: " + title)

func get_current_objective_title() -> String:
	match current_phase:
		Phase.PROLOGUE_HOME:
			return "Periksa Meja Kerja & Pergi ke Kantor Polisi"
		Phase.INVESTIGATION_1_POLICE:
			return "Temui / Kuntit Inspektur Marcus di Kantor Polisi"
		Phase.INVESTIGATION_2_STATION:
			return "Selidiki Bukti di Stasiun Kereta Api Ujung Timur"
		Phase.INVESTIGATION_3_PHOTO:
			return "Kembali ke Rumah & Cuci Foto di Kamar Gelap"
		Phase.INVESTIGATION_4_HOSPITAL:
			return "Menyelinap ke Kamar Mayat Rumah Sakit"
		Phase.FINAL_DEATH_GOD:
			return "Menuju ke Altar Kuil Dewa Kematian di Ruang Suci"
	return "Lanjutkan Penyelidikan Kasus"

func get_current_objective_desc() -> String:
	match current_phase:
		Phase.PROLOGUE_HOME:
			return "Kamu menemukan surat tugas misterius di meja dan foto masa kecil bersama Ibu Medeline. Clue pertama memintamu pergi ke Kantor Polisi di barat."
		Phase.INVESTIGATION_1_POLICE:
			return "Inspektur Marcus sedang bergerak. Ikuti dia (Tailgate) dengan menjaga jarak aman dan jangan sampai membuat warga sekitar panik."
		Phase.INVESTIGATION_2_STATION:
			return "Stasiun kereta api menyimpan jejak terakhir korban. Cari amplop foto, tiket kereta, dan jam saku rusak sebelum waktu habis."
		Phase.INVESTIGATION_3_PHOTO:
			return "Bawa rol film ke bak cairan kimia di rumahmu. Rendam dan bilas dengan hati-hati untuk mengungkap identitas korban."
		Phase.INVESTIGATION_4_HOSPITAL:
			return "Foto menunjukkan fakta ganjil. Pergilah ke Rumah Sakit di bagian selatan untuk memverifikasi jasad korban secara langsung."
		Phase.FINAL_DEATH_GOD:
			return "Kebenaran telah terungkap: kamu sedang menyelidiki kematian dirimu sendiri. Bicaralah kepada Dewa Kematian di Altar Suci."
	return ""

# ── Pengelolaan Clue ────────────────────────────────────────────────────────
func unlock_clue(clue_id: String) -> void:
	if clues.has(clue_id):
		if not clues[clue_id]["unlocked"]:
			clues[clue_id]["unlocked"] = true
			clue_collected.emit(clue_id, clues[clue_id]["title"])
			notification_displayed.emit("🔍 BUKTI BARU: " + clues[clue_id]["title"])
			_update_desaturation()

func is_clue_unlocked(clue_id: String) -> bool:
	if clues.has(clue_id):
		return clues[clue_id]["unlocked"]
	return false

func has_emotional_item() -> bool:
	return is_clue_unlocked("mother_emotional_locket")

# ── Update Desaturasi Dunia Bertahap Sesuai GDD ──────────────────────────────
func _update_desaturation() -> void:
	# Menghitung desaturasi berdasarkan progres fase dan clue
	var count = 0
	for k in clues.keys():
		if clues[k]["unlocked"]:
			count += 1
	
	# Desaturasi bertahap dari 0.0 (Normal) sampai 0.88 (Monokrom Dingin)
	var target = float(current_phase) * 0.16 + (float(count) / float(clues.size())) * 0.20
	desaturation_level = clampf(target, 0.0, 0.90)
	desaturation_updated.emit(desaturation_level)

func get_investigation_progress_percent() -> int:
	var count = 0
	for k in clues.keys():
		if clues[k]["unlocked"]:
			count += 1
	return int((float(count) / float(clues.size())) * 100.0)
