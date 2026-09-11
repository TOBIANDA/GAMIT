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
