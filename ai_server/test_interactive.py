"""
Test interaktif NLP Dewa Kematian
Ketik jawaban bebas dan lihat bagaimana AI menilainya
"""
import requests
import time

SERVER = "http://127.0.0.1:8000"

def tunggu_server():
    print("Menunggu server NLP siap...")
    for i in range(30):
        try:
            r = requests.get(f"{SERVER}/ping", timeout=2)
            if r.status_code == 200:
                print(f"Server siap! {r.json()['message']}\n")
                return True
        except:
            print(f"  [{i+1}/30] Belum siap, coba lagi...")
            time.sleep(1)
    print("Server tidak bisa dihubungi!")
    return False

def analisis(teks):
    r = requests.post(f"{SERVER}/analisis", json={"teks": teks}, timeout=10)
    return r.json()

def tampilkan_hasil(d, teks):
    print("\n" + "="*60)
    print(f"Input      : {teks}")
    print(f"Skor Mati  : {d['skor_mati']:.3f} (threshold 0.68) {'OK' if d['skor_mati'] >= 0.68 else 'KURANG'}")
    print(f"Skor Emosi : {d['skor_emosional']:.3f} (threshold 0.58) {'OK' if d['skor_emosional'] >= 0.58 else 'KURANG'}")
    print(f"Kategori   : {d['kategori']}")
    print(f"\nDEWA KEMATIAN:\n{d['respon']}")
    print("="*60)

def main():
    print("=== TEST NLP - DEWA KEMATIAN (Game IPB) ===\n")
    
    if not tunggu_server():
        return

    print("[TEST OTOMATIS]\n")
    
    test_cases = [
        ("SEMPURNA", "Aku sudah mati. Mayat itu adalah diriku sendiri. Ada pesan yang belum sempat kukirim."),
        ("HANYA MATI", "Korban yang mati itu adalah aku sendiri."),
        ("HAMPIR", "Sepertinya protagonisnya sudah meninggal di awal cerita."),
        ("TIDAK PAHAM", "Sepertinya ada pembunuh di sekitar sini."),
    ]
    
    for label, teks in test_cases:
        print(f"\n--- [{label}] ---")
        d = analisis(teks)
        tampilkan_hasil(d, teks)
        time.sleep(0.5)

    print("\n\n[MODE INTERAKTIF]")
    print("Ketik jawaban bebas (Bahasa Indonesia), atau 'q' untuk keluar.\n")
    
    while True:
        teks = input("Jawaban kamu: ").strip()
        if teks.lower() in ("q", "quit", "exit", "keluar"):
            print("Sampai jumpa!")
            break
        if not teks:
            continue
        d = analisis(teks)
        tampilkan_hasil(d, teks)

if __name__ == "__main__":
    main()
