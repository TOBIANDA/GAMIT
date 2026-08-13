@echo off
echo ============================================
echo   Build NLP Server - Dewa Kematian
echo ============================================

echo.
echo [1/3] Install dependencies...
pip install -r ai_server\requirements.txt
pip install pyinstaller

echo.
echo [2/3] Download model (jika belum ada)...
python ai_server\download_model.py

echo.
echo [3/3] Build ai_server.exe...
pyinstaller --onefile ^
  --add-data "ai_server\responses.json;." ^
  --add-data "ai_server\model_cache;model_cache" ^
  --name ai_server ^
  --hidden-import sentence_transformers ^
  --hidden-import uvicorn ^
  --hidden-import fastapi ^
  ai_server\main.py

echo.
echo ============================================
echo   Selesai! File ada di: dist\ai_server.exe
echo   Copy ke folder game sebelum dikumpulkan.
echo ============================================
pause
