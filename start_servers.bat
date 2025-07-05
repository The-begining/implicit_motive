@echo off
echo Starting Implicit Motive Analyzer Servers...
echo.

echo Starting R server on port 8001...
start "R Server" cmd /k "cd backend && Rscript -e \"library(plumber); pr <- plumb('r_server.R'); pr$run(port=8001)\""

echo Waiting 5 seconds for R server to start...
timeout /t 5 /nobreak > nul

echo Starting Python server on port 8000...
start "Python Server" cmd /k "cd backend && python -m uvicorn main:app --reload --port 8000"

echo.
echo Servers are starting...
echo R Server: http://localhost:8001
echo Python Server: http://localhost:8000
echo Frontend: http://localhost:3000
echo.
echo Press any key to close this window...
pause > nul 