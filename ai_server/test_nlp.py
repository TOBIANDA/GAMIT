import requests

def test(label, teks):
    r = requests.post('http://127.0.0.1:8000/analisis', json={"teks": teks})
    d = r.json()
    print(f"\n=== {label} ===")
    print(f"Input    : {teks}")
    print(f"Kategori : {d['kategori']}")
    print(f"Skor mati: {d['skor_mati']} | Skor emosional: {d['skor_emosional']}")
    print(f"Respon   :\n{d['respon']}")
    print("-" * 60)

# Test 1: Jawaban sempurna (mati + emosional)
test(
    "JAWABAN SEMPURNA",
    "Aku sudah mati. Mayat itu adalah diriku sendiri. Ada pesan yang belum sempat kukirim."
)

# Test 2: Hanya fakta, tidak sebut emosional
test(
    "HANYA FAKTA",
    "Korban yang mati itu adalah aku sendiri, aku adalah mayatnya."
)

# Test 3: Belum paham
test(
    "BELUM PAHAM",
    "Sepertinya ada pembunuh di sekitar sini."
)
