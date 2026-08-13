"""
NLP Server - Dewa Kematian
Game IPB - Semantic Similarity dengan SentenceTransformers

Cara kerja:
1. Pemain ketik jawaban
2. Server bandingkan dengan ground truth pakai semantic similarity
3. Return kategori respon (sadar_mati_dan_emosional / sadar_mati / sebagian / tidak_paham)
"""

import json
import random
import os
import sys
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer, util

# ── Path setup (untuk PyInstaller) ──────────────────────────────────────────
def resource_path(relative_path):
    """Dapatkan path yang benar baik saat development maupun saat jadi .exe"""
    if hasattr(sys, '_MEIPASS'):
        # Mode PyInstaller (.exe)
        base_path = sys._MEIPASS
    else:
        # Mode development
        base_path = os.path.dirname(__file__)
    return os.path.join(base_path, relative_path)

# ── Inisialisasi FastAPI ─────────────────────────────────────────────────────
app = FastAPI(title="Dewa Kematian NLP Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Load model dan responses ─────────────────────────────────────────────────
print("[NLP] Memuat model... (pertama kali mungkin perlu download ~470MB)")

# Model multilingual ringan yang support Bahasa Indonesia
# paraphrase-multilingual-MiniLM-L12-v2: ~470MB, support 50+ bahasa termasuk ID
MODEL_NAME = "paraphrase-multilingual-MiniLM-L12-v2"
model = SentenceTransformer(MODEL_NAME)

print("[NLP] Model siap!")

# Load responses dan ground truths
with open(resource_path("responses.json"), "r", encoding="utf-8") as f:
    data = json.load(f)

ground_truths = data["ground_truths"]
responses     = data["responses"]
thresholds    = data["threshold"]

# Pre-compute embeddings untuk ground truths (lebih cepat)
print("[NLP] Menghitung embeddings ground truth...")
gt_embeddings = {
    key: model.encode(sentences, convert_to_tensor=True)
    for key, sentences in ground_truths.items()
}
print("[NLP] Siap menerima input pemain!")

# ── Model Input ──────────────────────────────────────────────────────────────
class PlayerInput(BaseModel):
    teks: str

# ── Helper: hitung similarity maksimum ──────────────────────────────────────
def hitung_similarity(teks_pemain: str, kategori: str) -> float:
    """Hitung skor similarity antara input pemain dan ground truth kategori"""
    embedding_pemain = model.encode(teks_pemain, convert_to_tensor=True)
    scores = util.cos_sim(embedding_pemain, gt_embeddings[kategori])
    return float(scores.max())

# ── Endpoint utama ───────────────────────────────────────────────────────────
@app.post("/analisis")
def analisis(input: PlayerInput):
    teks = input.teks.strip()

    if not teks:
        return {
            "kategori": "tidak_paham",
            "respon": random.choice(responses["tidak_paham"]),
            "skor_mati": 0.0,
            "skor_emosional": 0.0
        }

    # Hitung similarity untuk setiap kategori
    skor_mati      = hitung_similarity(teks, "mati")
    skor_emosional = hitung_similarity(teks, "emosional")

    print(f"[NLP] Input: '{teks}'")
    print(f"[NLP] Skor mati: {skor_mati:.3f} | Skor emosional: {skor_emosional:.3f}")

    # Tentukan kategori respon
    paham_mati      = skor_mati      >= thresholds["mati"]
    paham_emosional = skor_emosional >= thresholds["emosional"]

    if paham_mati and paham_emosional:
        kategori = "sadar_mati_dan_emosional"
    elif paham_mati:
        kategori = "sadar_mati"
    elif skor_mati >= thresholds["mati"] * 0.75:
        # Hampir benar
        kategori = "sebagian"
    else:
        kategori = "tidak_paham"

    respon = random.choice(responses[kategori])

    return {
        "kategori": kategori,
        "respon": respon,
        "skor_mati": round(skor_mati, 3),
        "skor_emosional": round(skor_emosional, 3)
    }

# ── Health check ─────────────────────────────────────────────────────────────
@app.get("/ping")
def ping():
    return {"status": "ok", "message": "Dewa Kematian menunggu..."}

# ── Jalankan server ──────────────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="warning")
