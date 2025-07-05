@echo off
echo Starting Implicit Motive Analyzer Server...
echo.

echo Starting Python server on port 8000...
cd backend
python -m uvicorn main:app --reload --port 8000

echo.
echo Server is running at: http://localhost:8000
echo Frontend should be at: http://localhost:3000
echo.
pause 