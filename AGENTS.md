# Parallel Agent Collaboration Guidelines

## Dual Agent Setup
- **Primary Workspace**: `C:\Users\kuahs\Documents\game ipb` (branch: `main`)
- **Secondary Worker Workspace**: `C:\Users\kuahs\Documents\game ipb worker2` (worktree branch: `feature/parallel-worker`)

## Mandatory Synchronization & Integration Rule
Setiap kali agent menyelesaikan suatu tugas atau sebelum mengakhiri giliran:
1. **Commit** seluruh perubahan yang ada di workspace aktif dengan pesan commit yang jelas.
2. **Sinkronisasi Dua Arah (Bi-directional Merge)**:
   - Tarik perubahan dari worker paralel (`git merge feature/parallel-worker` di `game ipb`).
   - Salurkan perubahan terbaru ke worker paralel (`git -C "C:\Users\kuahs\Documents\game ipb worker2" merge main`).
   - Selesaikan resolusi konflik (jika ada) dan pastikan kedua working tree bersih (`working tree clean`).
3. **Verifikasi**:
   - Pastikan kedua branch berada pada commit yang sama atau terintegrasi secara harmonis tanpa kehilangan fitur dari masing-masing agent.
4. **Push ke Git Remote (Wajib)**:
   - Lakukan push commit terbaru ke remote repository GitHub agar selalu tersimpan di cloud:
     - `git push origin main`
     - `git push origin feature/parallel-worker`

---

# Game IPB - Project Rules & Guidelines

## Aturan Git Pull & Sinkronisasi Kode (Git Pull Preservation Rule)

Setiap kali pengguna meminta **pull** dari remote GitHub (`origin/main`), agen **WAJIB** mempertahankan perbaikan display responsif (*Fitur Layar Tidak Terpotong*), baik untuk Main Menu maupun In-Game Map:

### 1. Prosedur Git Pull:
- Jangan lakukan `git reset --hard origin/main` tanpa menerapkan kembali commit/fitur display fix.
- Gunakan `git pull --rebase origin main` atau `git fetch origin` lalu rebase commit display fix di atas commit terbaru GitHub.
- Pastikan branch lokal selalu memuat perbaikan display setelah proses sinkronisasi selesai.

### 2. Komponen Fitur Layar Tidak Terpotong yang Wajib Dipertahankan:
1. **`project.godot`**:
   - `window/size/viewport_width = 1600`
   - `window/size/viewport_height = 900`
   - `window/size/mode = 2` (Maximized)
   - `window/size/resizable = true`
   - `window/stretch/mode = "canvas_items"`
   - `window/stretch/aspect = "keep"`
2. **`scripts/main_menu_ui.gd`**:
   - Background meja investigasi dibungkus dalam `AspectRatioContainer` dengan rasio `16.0 / 9.0` dan *center alignment*.
   - Tombol-tombol kertas (`PLAY`, `OPTIONS`, `CREDIT`, `QUIT`) menggunakan normalized anchor (`Vector4(x_min, y_min, x_max, y_max)`) agar selalu proporsional dan berada di posisi yang tepat di setiap resolusi layar (khususnya 1366x768).
3. **`scripts/player.gd` & `scripts/main.gd`**:
   - Batas kamera atas (`limit_top`) harus diatur ke `-120` (yaitu `setup_camera_limits(0, -120, 2400, 1450)`), bukan `0`.
   - Ini memastikan kamera memberikan ruang pandang yang lega saat pemain berjalan ke utara memeriksa rumah korban dan tidak memotong atap perumahan.
4. **`scripts/blueprint_map.gd`**:
   - Dasar trotoar (`COLOR_SIDEWALK`) dan garis grid digambar mulai dari `Y = -120` hingga `1311`, dilengkapi garis tepi jalan atas (*curb line*) di `Y = -120`.
5. **`scenes/main.tscn`**:
   - Node `BlueprintMap` tidak boleh memiliki offset koordinat liar (harus di posisi default `(0, 0)`).
