# 🤝 PANDUAN KONTRIBUSI TIM (CONTRIBUTING GUIDE)
## Game: *Kasus Terakhir Benedict*

Panduan ini ditujukan bagi seluruh anggota tim (programmer, game designer, audio designer, dan artist) agar kolaborasi pengembangan game berjalan lancar tanpa konflik merge scene (*scene merge conflict*) dan menjaga kode tetap bersih.

---

## 1. Alur Kerja Git (Branching Strategy)

Kami menerapkan **GitHub Flow** sederhana yang teruji untuk tim game indie:

```
(main) ────●────────────────────────●───────────────●─── (Selalu Stabil & Playable)
            \                      /               /
(feature)    ●────●────● (PR Review)              /
                                                 /
(fix)                                 ●────●────● (PR Review)
```

1. **Branch `main`**:
   - Selalu berstatus **stabil dan dapat dijalankan (runnable)** kapan saja.
   - Jangan pernah melakukan commit langsung fitur eksperimental ke `main`.
2. **Branch Fitur (`feature/<nama-fitur>`)**:
   - Contoh: `feature/hospital-minigame`, `feature/afterlife-particles`, `feature/car-sfx`.
   - Dibuat dari cabang `main` terbaru.
3. **Branch Perbaikan (`fix/<nama-bug>`)**:
   - Contoh: `fix/player-stuck-wall`, `fix/dialog-box-scale`.

---

## 2. Aturan Emas Menghindari Konflik Scene (`.tscn`)

Konflik merge pada file scene Godot (`.tscn`) adalah masalah paling sering terjadi dalam tim jika tidak dikelola dengan benar. Patuhi aturan berikut:

> [!IMPORTANT]
> **Aturan 1: Pecah Scene Menjadi Sub-Scene Kecil (Modularization)**
> Jangan memasukkan semua logika dan visual ke dalam satu scene raksasa (`main.tscn`). Pisahkan UI, dialog, minigame, dan karakter ke file scene mereka sendiri (misal `dialog_box.tscn`, `minigame_safe.tscn`).

> [!TIP]
> **Aturan 2: Komunikasikan Kepemilikan Scene (Soft Lock)**
> Sebelum mengedit scene bersama seperti `main.tscn`, beri tahu anggota tim di grup obrolan (Discord/Slack/WhatsApp): *"Saya sedang mengedit tata letak jalan di `main.tscn` selama 1 jam ke depan."*

> [!WARNING]
> **Aturan 3: Jangan Pernah Menyimpan Perubahan Tak Disengaja**
> Jika Anda hanya membuka scene untuk melihat-lihat, gunakan *Revert* atau *Discard Changes* di Git jika file `.tscn` tersebut tidak sengaja terubah oleh editor Godot.

---

## 3. Standar Pesan Commit (Conventional Commits)

Format pesan commit mengikuti standar industri:
```
<tipe>(<lingkup-opsional>): <deskripsi singkat dalam bahasa aktif>
```

### Jenis Tipe:
- `feat:` Penambahan fitur atau mekanik gameplay baru.
  - Contoh: `feat(morgue): tambahkan sistem inspeksi kasur mayat di rumah sakit`
- `fix:` Perbaikan bug atau kesalahan logika/tampilan.
  - Contoh: `fix(dialog): perbaiki penyesuaian skala potret karakter di layar fullscreen`
- `docs:` Pembaruan atau penambahan dokumentasi proyek.
  - Contoh: `docs: perbarui GDD alur cerita 6 bab dan panduan kolaborasi tim`
- `refactor:` Restrukturisasi kode tanpa mengubah fungsionalitas eksternal.
  - Contoh: `refactor(main): pisahkan penanganan POI ke helper functions modular`
- `style:` Pembersihan format kode, spasi, atau indentasi.
- `asset:` Penambahan atau penggantian aset visual/audio.
  - Contoh: `asset(sound): tambahkan audio Afterlife.mp3 dan HOSPITAL.mp3`
- `chore:` Pemeliharaan dependensi, .gitignore, atau build scripts.

---

## 4. Konvensi Penamaan Aset & File

1. **Nama File & Folder**: Gunakan huruf kecil dengan garis bawah (**`snake_case`**).
   - Benar: `karakter/mc_kaget.png`, `sound/door_open.mp3`, `scripts/morgue_inspection.gd`.
   - Hindari: `Karakter/MC Kaget (1).PNG`, `Sound/Door Open Baru!.mp3`.
2. **Format Aset**:
   - Gambar UI / Sprite: `.png` transparan atau `.svg` vektor.
   - Musik Latar & SFX Panjang: `.mp3` atau `.ogg`.
   - SFX Pendek & UI Klik: `.wav` atau `.mp3`.
3. **Penyimpanan**:
   - Simpan aset bersama di folder kategori yang sesuai (`UI/`, `Environment/`, `sound/`, `karakter/`).
   - Hapus aset duplikat jika ada versi baru yang lebih baik.

---

## 5. Checklist Sebelum Membuat Pull Request (PR)

- [ ] Kode lulus kompilasi tanpa error di Godot 4 (`--check-only` lolos).
- [ ] Tidak ada file cache `.godot/` atau file sampah `.tmp` yang tersenggol ke staging.
- [ ] Fitur telah diuji coba dan berfungsi sesuai GDD.
- [ ] Tidak merusak mekanik atau scene yang sudah ada sebelumnya.
- [ ] Pesan commit deskriptif dan mudah dipahami oleh anggota tim lainnya.
