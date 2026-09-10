# 🕵️ Kasus Terakhir Benedict: Detektif & Sang Dewa Kematian
> *Sebuah game naratif investigasi misteri supranatural berbasis Godot 4.*

[![Godot 4.x](https://img.shields.io/badge/Engine-Godot%204.x-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)](#)
[![License](https://img.shields.io/badge/License-MIT-green)](#)

---

## 📖 Sinopsis Cerita
Detektif Benedict menyusuri jalanan kota berkabut menuju rumah seorang korban pembunuhan misterius. Di sepanjang jalan, kejanggalan tak kasat mata mulai menyapanya: jam kota membeku di **16:04**, dan setiap orang yang disapa justru menggigil ketakutan tanpa menyahut.

Penyelidikan yang ia jalani membawanya menelusuri rumah korban, menguntit Inspektur Marcus di kantor polisi, mengamankan rol foto di stasiun kereta api, hingga mencuci foto di kamar gelap forensik. Saat foto ke-4 selesai dicuci dan menampakkan wajah dirinya sendiri, Benedict yang menolak percaya segera menyelinap ke kamar mayat rumah sakit.

Di balik kain penutup jasad, kenyataan mutlak terungkap: tubuh yang terbaring kaku di atas ranjang adalah dirinya sendiri. Benedict telah tiada sejak awal. Di hadapan Sang Dewa Kematian (*Grim*), jiwanya harus menjawab pertanyaan-pertanyaan refleksi bukti kematiannya untuk meraih keikhlasan dan melangkah damai menuju *Afterlife*.

---

## 🎮 Kontrol Permainan (Controls)

| Tombol | Aksi |
|---|---|
| **W, A, S, D** / **Tombol Panah** | Menggerakkan Benedict / Mengemudi Mobil |
| **Shift** | Berlari cepat (*Sprint* - memakan energi/stamina) |
| **F / E / Spasi / Enter** | Berinteraksi dengan POI, Membaca Foto, Buka Pintu |
| **J** | Membuka / Menutup Jurnal Bukti Kasus (*Clue Journal*) |
| **ESC / P** | Membuka Menu Jeda (*Pause Menu*) / Keluar Dialog |
| **F11 / Alt + Enter** | Mengaktifkan / Menonaktifkan Layar Penuh (*Fullscreen*) |
| **Scroll Mouse** | Mengatur Zoom Penglihatan Kamera (0.8x - 2.5x) |
| **1, 2, 3, 4** | Pintasan Cepat Uji Coba Minigame (Dev Mode) |

---

## 🧩 6 Bab Alur Permainan (Story Progression)

1. **Prolog & Jalanan Kota**: Memeriksa jam jalan yang terhenti di 16:04 dan menyapa warga yang bergidik dingin.
2. **Rumah Korban**: Menemukan foto polaroid ibu dan anak (`polaroidIbu.png`) dengan pesan rahasia brankas (1-6-4) yang membuka misi opsional.
3. **Kantor Polisi & Menguntit Marcus**: Menguntit Inspektur Marcus dengan menjaga jarak aman via audio percakapan latar.
4. **Stasiun & Kamar Gelap Forensik**: Menemukan amplop foto di stasiun, mencuci foto dengan cairan pengembang & QTE bilasan. Foto 4 menyingkap wajah Benedict!
5. **Rumah Sakit & Kamar Jenazah**: Ditolak oleh resepsionis, menyelinap ke kamar jenazah, menyingkap kain mayat, dan menyadari jasad tersebut adalah dirinya sendiri.
6. **Pengadilan Dewa Kematian**: Ditarik ke alam baka, menjawab 4 kuis bukti kematian bersama Sang Dewa Maut, dan melangkah damai ke Afterlife.

---

## 📁 Struktur Direktori & Best Practice Tim

```
game ipb/
├── scenes/                 # File Scene Modular (.tscn)
│   ├── main.tscn           # Scene Utama Dunia Kota
│   ├── dialog_box.tscn     # Antarmuka Kotak Dialog & Monolog
│   └── opening_cutscene.tscn# Scene Cutscene Pembuka
├── scripts/                # Kode GDScript (.gd) Terstruktur & Bertipe
│   ├── main.gd             # Orkestrator Game & State Transition
│   ├── player.gd           # Kontroler Pemain, Gerak, & Kamera
│   ├── npc.gd              # Karakter NPC Kota & Marcus
│   ├── investigation_manager.gd # State Machine Kasus & Jurnal Bukti
│   ├── morgue_inspection.gd# Sistem Kamar Jenazah & Penyingkapan Mayat
│   ├── death_god.gd        # Kuis Dewa Kematian & Afterlife
│   ├── minigame_tailgate.gd# Minigame Menguntit Marcus
│   ├── minigame_photo_wash.gd# Minigame Cuci Foto Polaroid
│   ├── minigame_safe.gd    # Minigame Brankas Ibu (1-6-4)
│   └── ...
├── sound/                  # Audio Terorganisir (BGM, Afterlife, Hospital, Flashback)
├── karakter/               # Potret Resolusi Tinggi Karakter (Biasa, Bingung, Kaget, Sedih, Grim)
├── UI/                     # Komponen UI, Potret, & Polaroid
├── Environment/            # Sprite Bangunan, Jalan, & Perabot
├── data/                   # Data JSON Konfigurasi Perabot & Kredit
├── docs/                   # Dokumentasi Lengkap Kolaborasi Tim:
│   ├── GDD.md              # Game Design Document Resmi
│   ├── ARCHITECTURE.md     # Arsitektur Teknis & Pola Desain
│   ├── CONTRIBUTING.md     # Panduan Git, Branching, & Scene Merge
│   └── STYLE_GUIDE.md      # Standar Format Penulisan GDScript
└── ai_server/              # Backend NLP Opsional (FastAPI + SentenceTransformers)
```

---

## 🚀 Panduan Memulai (Developer Setup)

### 1. Menjalankan Game di Godot
1. Unduh dan buka **Godot Engine 4.x** (disarankan 4.3 atau 4.7+).
2. Klik **Import** -> Pilih file `project.godot` di root folder proyek ini.
3. Tekan **F5** (atau tombol Play di pojok kanan atas) untuk menjalankan game.

### 2. Menjalankan Uji Otomatis Headless (Headless Testing)
Untuk memverifikasi keabsahan sintaks seluruh skrip tanpa membuka editor:
```powershell
godot --headless --check-only -s "res://scripts/main.gd"
```

### 3. Menjalankan Server AI NLP Opsional (Dewa Kematian)
Game dilengkapi kuis bawaan interaktif (*offline built-in*), namun jika ingin mengaktifkan pemrosesan bahasa alami bebas:
```bash
pip install -r ai_server/requirements.txt
python ai_server/main.py
```

---

## 📚 Dokumentasi Lanjutan Tim
- 📖 [Game Design Document (GDD)](docs/GDD.md)
- 🏛️ [Arsitektur Perangkat Lunak](docs/ARCHITECTURE.md)
- 🤝 [Panduan Kontribusi & Git Workflow](docs/CONTRIBUTING.md)
- 📝 [GDScript Style Guide](docs/STYLE_GUIDE.md)

---

## 👥 Tim Pengembang & Kredit
- **Game Engine**: Godot Engine 4.7
- **Genre**: Narrative Detective Adventure / Mystery Psychological
- **Aset & Audio**: Lisensi audio tertera pada `data/List of Credits.docx`.
