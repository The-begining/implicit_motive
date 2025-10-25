# Implicit Motive Analyzer - Project Documentation

## 🎯 What This Website Does

The **Implicit Motive Analyzer** is a web application that analyzes text to reveal underlying psychological motives using advanced AI models. It identifies three key motivational patterns:

- **🎯 Achievement Motive**: Drive to excel, accomplish, and master challenges
- **💙 Affiliation Motive**: Desire for connection, belonging, and positive relationships
- **👑 Power Motive**: Aspiration to influence, lead, and make an impact

### Key Features:

- **Text Analysis**: Paste any text/story and get detailed motive analysis
- **Picture Story Test**: Alternative analysis method using images
- **Sentence-by-Sentence Breakdown**: See how each sentence contributes to different motives
- **Percentile Rankings**: Understand your scores relative to others
- **Real-time Analysis**: Instant results with detailed explanations

## 🏗️ How It Works

### Architecture Overview:

```
Frontend (Port 3000) → Python Backend (Port 8000) → R Server (Port 8001)
     ↓                        ↓                           ↓
  HTML/JS Interface    FastAPI Server              Plumber R API
     ↓                        ↓                           ↓
  User Interface    CORS + Request Handling    ML Model Processing
```

### Data Flow:

1. **User Input**: User enters text in the frontend
2. **API Request**: Frontend sends JSON to Python backend
3. **R Processing**: Backend forwards request to R server
4. **ML Analysis**: R server processes text through 3 ML models
5. **Results**: Scores flow back through the chain to user

## 🚀 How to Run the Application

### Prerequisites:

- **R** with required packages
- **Python 3.10+** with pip
- **Web browser**

### Step 1: Install R Dependencies

```r
# In R console:
install.packages(c("plumber", "jsonlite", "text", "dplyr", "stringr"))
```

### Step 2: Install Python Dependencies

```powershell
cd backend
pip install -r requirements.txt
```

### Step 3: Start All Services (3 Terminal Windows)

#### Terminal 1 - R Server (Port 8001):

```powershell
cd C:\Users\softe\implicit_motive\backend
Rscript start_r_server.R
```

#### Terminal 2 - Python Backend (Port 8000):

```powershell
cd C:\Users\softe\implicit_motive\backend
python -m uvicorn main:app --reload --port 8000
```

#### Terminal 3 - Frontend (Port 3000):

```powershell
cd C:\Users\softe\implicit_motive\frontend
python -m http.server 3000
```

### Step 4: Access the Application

- **Website**: http://localhost:3000
- **API Documentation**: http://localhost:8000/docs
- **R Server Health**: http://localhost:8001/health

## 📁 Project Components

### Backend (`/backend/`)

- **`main.py`**: FastAPI server handling HTTP requests
- **`r_server.R`**: R Plumber API with ML models
- **`start_r_server.R`**: R server startup script
- **`requirements.txt`**: Python dependencies
- **`*.rds`**: Pre-trained ML model files
- **`Dockerfile`**: Python backend container
- **`Dockerfile.r`**: R server container

### Frontend (`/frontend/`)

- **`index.html`**: Main text analysis interface
- **`picture-test.html`**: Picture story test interface
- **`*.jpg`**: Test images for picture analysis

### Configuration Files

- **`docker-compose.yml`**: Multi-service container orchestration
- **`start_servers.bat`**: Windows batch script (has issues)
- **`start_server.bat`**: Single service startup script

## 🔧 Making Changes

### Changing ML Models

#### 1. Update Model Configuration in `r_server.R`:

```r
MODEL_CONFIG <- list(
  achievement = list(
    model_id = "your_new_achievement_model",
    name = "Achievement",
    icon = "🎯",
    color = "#28a745",
    description = "Your custom description"
  ),
  # Add new motives here
  new_motive = list(
    model_id = "your_new_model_id",
    name = "New Motive",
    icon = "🆕",
    color = "#your_color",
    description = "Description"
  )
)
```

#### 2. Update Python Backend in `main.py`:

```python
# Add new motive to the response model
class MotiveScores(BaseModel):
    # ... existing fields ...
    new_motive: dict  # Add new motive field

# Update the analyze endpoint
for motive_name in ["power", "achievement", "affiliation", "new_motive"]:
    if motive_name in result:
        response_data[motive_name] = result[motive_name]
```

#### 3. Update Frontend in `index.html`:

```javascript
// Add new motive to the display functions
function updateStorySummary(data) {
  // Add handling for new_motive
  const newMotivePercent =
    parseFloat(data.new_motive.percentage_story_level) || 0;
  // ... update UI elements
}
```

### Modifying Backend Logic

#### API Endpoints (`main.py`):

- **`/analyze`**: Main text analysis endpoint
- **`/health`**: Health check
- **`/models`**: Get available models

#### R Server Endpoints (`r_server.R`):

- **`/predict`**: Text analysis with ML models
- **`/health`**: R server health check
- **`/models`**: Available model information

### Frontend Customization

#### Styling (`index.html`):

- **CSS Variables**: Update colors, fonts, layout
- **Responsive Design**: Modify media queries
- **Component Styling**: Customize cards, buttons, progress bars

#### Functionality:

- **`analyzeStory()`**: Main analysis function
- **`displayResults()`**: Results rendering
- **`updateStorySummary()`**: Summary display logic

## 🐳 Docker Deployment

### Using Docker Compose (Recommended):

```bash
docker-compose up --build
```

### Individual Container Commands:

#### R Server Container:

```bash
cd backend
docker build -f Dockerfile.r -t r-server .
docker run -p 8001:8001 r-server
```

#### Python Backend Container:

```bash
cd backend
docker build -f Dockerfile -t python-backend .
docker run -p 8000:8000 python-backend
```

#### Frontend Container:

```bash
cd frontend
# Create Dockerfile for frontend
docker build -t frontend .
docker run -p 3000:3000 frontend
```

### Production Docker Setup:

#### 1. Create Frontend Dockerfile:

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
```

#### 2. Update docker-compose.yml for Production:

```yaml
version: "3.8"
services:
  rserver:
    build:
      context: ./backend
      dockerfile: Dockerfile.r
    ports:
      - "8001:8001"
    environment:
      - R_ENV=production

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    depends_on:
      - rserver
    environment:
      - PYTHON_ENV=production

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    depends_on:
      - backend
```

## 🔗 Service Connections

### R Server ↔ Python Backend:

- **Connection**: HTTP requests to `http://127.0.0.1:8001/predict`
- **Data Format**: JSON with `{"text": "user_input"}`
- **Response**: JSON with motive scores and metadata

### Python Backend ↔ Frontend:

- **Connection**: HTTP requests to `http://localhost:8000/analyze`
- **CORS**: Enabled for all origins in development
- **Data Format**: JSON with `{"story": "user_input"}`

### Key Integration Points:

1. **`main.py` line 36**: R server URL configuration
2. **`r_server.R` line 107**: API endpoint definition
3. **`index.html` line 678**: Backend API URL

## 🛠️ Troubleshooting

### Common Issues:

#### 1. R Server Won't Start:

```powershell
# Check if R packages are installed
Rscript -e "library(plumber)"
```

#### 2. Python Backend Connection Error:

- Verify R server is running on port 8001
- Check firewall settings
- Ensure CORS is properly configured

#### 3. Frontend Can't Connect:

- Verify Python backend is running on port 8000
- Check browser console for errors
- Ensure all services are started in correct order

#### 4. Model Loading Errors:

- Verify R model files (\*.rds) are present
- Check `textrpp_initialize()` in r_server.R
- Ensure sufficient memory for model loading

### Debug Commands:

```powershell
# Check running services
netstat -an | findstr "8000 8001 3000"

# Test R server
curl http://localhost:8001/health

# Test Python backend
curl http://localhost:8000/health

# Check logs
# R server: Check terminal output
# Python: Check uvicorn logs
# Frontend: Check browser console
```

## 📊 Model Information

### Current Models:

- **Achievement**: `implicitachievement_roberta_ft_nilsson2024`
- **Affiliation**: `implicitaffiliation_roberta_ft_nilsson2024`
- **Power**: `implicitpower_roberta_ft_nilsson2024`

### Model Files:

- `schone_training_rob_la_l23_to_achievement_open.rds`
- `schone_training_rob_la_l23_to_affiliation_open.rds`
- `schone_training_rob_la_l23_to_power_open.rds`

### Adding New Models:

1. Add model file to `/backend/` directory
2. Update `MODEL_CONFIG` in `r_server.R`
3. Update frontend display logic
4. Test with sample text

## 🚀 Deployment Options

### Local Development:

- Use the 3-terminal approach
- Use `start_servers.bat` (if fixed)

### Docker Development:

- Use `docker-compose up --build`
- Individual container development

### Production Deployment:

- Use Docker Compose with production settings
- Configure reverse proxy (nginx)
- Set up SSL certificates
- Configure environment variables

## 📝 Development Workflow

### 1. Making Changes:

1. Edit code in respective files
2. Restart affected services
3. Test changes in browser
4. Check logs for errors

### 2. Adding Features:

1. Update R server for new models/endpoints
2. Update Python backend for new API logic
3. Update frontend for new UI/functionality
4. Test end-to-end functionality

### 3. Debugging:

1. Check service logs
2. Test individual components
3. Verify data flow between services
4. Check browser network tab

---

**Last Updated**: $(date)
**Version**: 1.0.0
**Maintainer**: Development Team
