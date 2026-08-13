"""
Script untuk pre-download model sebelum build PyInstaller.
Jalankan ini SEKALI sebelum build:
    python download_model.py
"""
from sentence_transformers import SentenceTransformer
import os

MODEL_NAME = "paraphrase-multilingual-MiniLM-L12-v2"
CACHE_DIR  = os.path.join(os.path.dirname(__file__), "model_cache")

print(f"[Setup] Mendownload model '{MODEL_NAME}'...")
print(f"[Setup] Ukuran: ~470MB — mohon tunggu...")

model = SentenceTransformer(MODEL_NAME, cache_folder=CACHE_DIR)

print(f"[Setup] Model berhasil didownload ke: {CACHE_DIR}")
print("[Setup] Sekarang kamu bisa build dengan PyInstaller.")
