"""
NLP Server - Dewa Kematian (Enhanced Hybrid Engine)
Game IPB - Semantic Similarity + Intent & Clue Recognition
"""

import json
import random
import os
import sys
import re
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer, util

# ── Path setup ─────────────────────────────────────────────────────────────
def resource_path(relative_path):
    if hasattr(sys, '_MEIPASS'):
        base_path = sys._MEIPASS
    else:
        base_path = os.path.dirname(__file__)
    return os.path.join(base_path, relative_path)

# ── Inisialisasi FastAPI ─────────────────────────────────────────────────────
app = FastAPI(title="Dewa Kematian Smart NLP Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Load model dan responses ─────────────────────────────────────────────────
print("[NLP] Memuat model multilingual...")
MODEL_NAME = "paraphrase-multilingual-MiniLM-L12-v2"
model = SentenceTransformer(MODEL_NAME)
print("[NLP] Model siap!")

with open(resource_path("responses.json"), "r", encoding="utf-8") as f:
    data = json.load(f)

ground_truths = data["ground_truths"]
responses = data["responses"]
clue_responses = data.get("clue_responses", {})
thresholds = data["threshold"]

# Pre-compute embeddings untuk semua kategori ground truth
print("[NLP] Menghitung embeddings ground truth...")
gt_embeddings = {
    key: model.encode(sentences, convert_to_tensor=True)
    for key, sentences in ground_truths.items()
}
print("[NLP] Siap menerima input pemain!")

# Memory riwayat respon agar tidak mengulang jawaban yang sama berturut-turut
last_used_responses = set()

# ── Model Input ──────────────────────────────────────────────────────────────
class PlayerInput(BaseModel):
    teks: str

# ── Helper Analisis Semantik & Kata Kunci ──────────────────────────────────
def hitung_similarity(embedding_pemain, kategori: str) -> float:
    if kategori not in gt_embeddings:
        return 0.0
    scores = util.cos_sim(embedding_pemain, gt_embeddings[kategori])
    return float(scores.max())

def detect_clues(teks: str) -> list:
    """Deteksi elemen petunjuk tematik spesifik dalam kalimat pemain"""
    lower = teks.lower()
    clues = []
    
    # Deteksi mayat/jasad/tubuh
    if any(w in lower for w in ["mayat", "jasad", "jenazah", "bangkai", "tubuhku", "jasadku", "korban"]):
        clues.append("mayat")
    
    # Deteksi jam/waktu
    if any(w in lower for w in ["jam", "waktu", "detik", "hujan", "membeku", "berhenti"]):
        clues.append("jam_waktu")
        
    # Deteksi pesan/surat
    if any(w in lower for w in ["pesan", "surat", "kata", "ucapan", "bicara", "sampaikan", "titip"]):
        clues.append("surat_pesan")
        
    # Deteksi orang tercinta/keluarga
    if any(w in lower for w in ["ibu", "ayah", "istri", "anak", "keluarga", "cinta", "sayang", "kekasih", "teman", "menyesal", "ikhlas", "rindu"]):
        clues.append("keluarga_cinta")
        
    return clues

def get_varied_response(category: str) -> str:
    """Pilih respon secara acak dengan menghindari pengulangan kalimat yang baru digunakan"""
    options = responses.get(category, responses["tidak_paham"])
    available = [r for r in options if r not in last_used_responses]
    
    if not available:
        # Jika semua sudah terpakai, reset memory
        last_used_responses.clear()
        available = options
        
    chosen = random.choice(available)
    last_used_responses.add(chosen)
    return chosen

# ── Endpoint utama ───────────────────────────────────────────────────────────
@app.post("/analisis")
def analisis(input: PlayerInput):
    teks = input.teks.strip()

    if not teks:
        return {
            "kategori": "tidak_paham",
            "respon": get_varied_response("tidak_paham"),
            "skor_mati": 0.0,
            "skor_emosional": 0.0,
            "insights": []
        }

    # 1. Encode embedding kalimat pemain
    embedding_pemain = model.encode(teks, convert_to_tensor=True)

    # 2. Hitung kemiripan terhadap semua kategori
    skor_mati = hitung_similarity(embedding_pemain, "mati")
    skor_emosional = hitung_similarity(embedding_pemain, "emosional")
    skor_waktu = hitung_similarity(embedding_pemain, "waktu")
    detected_clues = detect_clues(teks)

    print(f"[NLP] Input: '{teks}'")
    print(f"[NLP] Skor mati: {skor_mati:.3f} | Skor emosional: {skor_emosional:.3f} | Clues: {detected_clues}")

    # 3. Hybrid scoring boost jika ada kombinasi kata kunci yang kuat
    lower = teks.lower()
    if ("aku" in lower or "saya" in lower or "gua" in lower or "gw" in lower or "diriku" in lower) and ("mati" in lower or "mayat" in lower or "korban" in lower or "wafat" in lower):
        skor_mati = max(skor_mati, 0.78)

    # 4. Tentukan kategori hasil
    paham_mati = skor_mati >= thresholds["mati"]
    paham_emosional = skor_emosional >= thresholds["emosional"] or len([c for c in detected_clues if c in ["surat_pesan", "keluarga_cinta"]]) > 0 and paham_mati

    if paham_mati and paham_emosional:
        kategori = "sadar_mati_dan_emosional"
    elif paham_mati:
        kategori = "sadar_mati"
    elif skor_mati >= thresholds["mati"] * 0.75 or len(detected_clues) > 0:
        kategori = "sebagian"
    else:
        kategori = "tidak_paham"

    # 5. Dapatkan variasi respon utama
    base_response = get_varied_response(kategori)

    # 6. Jika ada petunjuk spesifik yang menarik dan belum sadar penuh, berikan komentar tambahan
    final_response = base_response
    if kategori in ["sadar_mati", "sebagian"] and detected_clues:
        clue_key = random.choice(detected_clues)
        if clue_key in clue_responses:
            clue_text = clue_responses[clue_key]
            # Sisipkan jika belum ada di teks dasar
            if clue_text not in final_response:
                final_response = f"{final_response}\n\n✦ {clue_text}"

    return {
        "kategori": kategori,
        "respon": final_response,
        "skor_mati": round(skor_mati, 3),
        "skor_emosional": round(skor_emosional, 3),
        "clues": detected_clues
    }

# ── Health check ─────────────────────────────────────────────────────────────
@app.get("/ping")
def ping():
    return {"status": "ok", "message": "Dewa Kematian Smart NLP siap melayani..."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="warning")
