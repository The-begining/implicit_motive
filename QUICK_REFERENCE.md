# Implicit Motive Analyzer - Quick Reference

## 🚀 Quick Start Commands

### 1. Start All Servers (Windows)

```bash
cd C:\Users\softe\implicit_motive
start_servers.bat
```

### 2. Manual Start (3 Terminals)

**Terminal 1 - R Server:**

```bash
cd backend
Rscript start_r_server.R
```

**Terminal 2 - Python Backend:**

```bash
cd backend
python -m uvicorn main:app --reload --port 8000
```

**Terminal 3 - Frontend:**

```bash
cd frontend
python -m http.server 3000
```

### 3. Docker Start

```bash
docker-compose up --build
```

## 🌐 Access Points

- **Frontend**: http://localhost:3000
- **Python API**: http://localhost:8000
- **R API**: http://localhost:8001
- **API Docs**: http://localhost:8000/docs

## 📝 API Usage

### PowerShell Test

```powershell
$body = @{
    story = "I worked hard to achieve my goals."
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/analyze" -Method POST -ContentType "application/json" -Body $body
```

### Python Test

```python
import requests
response = requests.post(
    "http://localhost:8000/analyze",
    json={"story": "I worked hard to achieve my goals."}
)
print(response.json())
```

### JavaScript Test

```javascript
const response = await fetch("http://localhost:8000/analyze", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ story: "I worked hard to achieve my goals." }),
});
const data = await response.json();
```

## 🔧 Health Checks

```powershell
# Check R server
Invoke-RestMethod -Uri "http://localhost:8001/health" -Method GET

# Check Python backend
Invoke-RestMethod -Uri "http://localhost:8000/health" -Method GET
```

## 📊 Response Format

```json
{
  "sentences": ["I worked hard to achieve my goals."],
  "sentence_achievement": [0.8956],
  "sentence_affiliation": [0.0071],
  "sentence_power": [0.0643],
  "sentence_word_counts": [7],
  "person_achievement": 0.8956,
  "person_affiliation": 0.0071,
  "person_power": 0.0643,
  "corrected_achievement": 0.8256,
  "corrected_affiliation": 0.0,
  "corrected_power": 0.0,
  "total_sentences": 1,
  "total_words": 7
}
```

## 🛠️ Troubleshooting

### R Server Issues

```r
# In R console
library(text)
textrpp_initialize()
```

### Port Conflicts

```bash
# Check if ports are in use
netstat -ano | findstr :8000
netstat -ano | findstr :8001
netstat -ano | findstr :3000
```

### Dependencies

```bash
# Python
pip install -r backend/requirements.txt

# R
install.packages(c("plumber", "jsonlite", "text", "dplyr"))
```

## 📁 Key Files

- `backend/r_server.R` - R analysis server
- `backend/main.py` - Python FastAPI backend
- `frontend/index.html` - Web interface
- `docker-compose.yml` - Docker configuration
- `start_servers.bat` - Windows startup script

## 🎯 Models Used

- **Achievement**: `implicitachievement_roberta23_nilsson2024`
- **Affiliation**: `implicitaffiliation_roberta23_nilsson2024`
- **Power**: `implicitpower_roberta23_nilsson2024`

## ⚡ Performance

- **Response Time**: 2-5 seconds
- **Memory**: 2-4GB RAM
- **Models**: Loaded once per R session

---

**For detailed documentation, see**: `PROJECT_DOCUMENTATION.md`
