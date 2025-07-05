# Implicit Motive Analyzer - Backend

This backend provides a simple rule-based motive analysis. You can replace the analysis function with your actual R model logic.

## Setup

### Prerequisites

1. **Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

### Running the Server

#### Option 1: Use the batch script (Windows)

```bash
start_server.bat
```

#### Option 2: Manual startup

```bash
cd backend
python -m uvicorn main:app --reload --port 8000
```

### Integrating Your R Model

To use your actual R model instead of the simple rule-based analysis:

1. **Install R** (if not already installed):

   - Download from: https://cran.r-project.org/bin/windows/base/
   - Make sure to add R to your system PATH

2. **Install R packages:**

   ```r
   install.packages(c("plumber", "jsonlite"))
   ```

3. **Create an R server** (see `r_server.R` for example)

4. **Modify the Python backend** to call your R server instead of using the simple analysis

### Current Implementation

The current `analyze_motives_simple()` function uses a simple word-counting approach:

- **Achievement words:** achieve, success, goal, win, excel, etc.
- **Affiliation words:** friend, family, love, care, help, etc.
- **Power words:** control, influence, lead, dominate, etc.

### API Endpoints

- **POST /analyze** - Analyze text for implicit motives
- **GET /health** - Health check

### Example Usage

```bash
curl -X POST "http://localhost:8000/analyze" \
     -H "Content-Type: application/json" \
     -d '{"story": "I worked hard to achieve my goals and succeed in the competition."}'
```

### Next Steps

1. **Test the current implementation** to make sure everything works
2. **Replace the analysis function** with your actual R model logic
3. **Add more sophisticated analysis** as needed
