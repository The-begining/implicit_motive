# Hosting and Database Solutions for Implicit Motive Analyzer

## 🎯 Overview

This document provides practical solutions for hosting your Implicit Motive Analyzer application and implementing user story storage using local database options. Since you want to host from your local system and use a local database, here are the best approaches.

## 🏠 Local Hosting Solutions

### Option 1: Local Development Server (Current Setup)

**Best for**: Development and testing

- **Pros**: Simple, no configuration needed
- **Cons**: Only accessible from your machine
- **Access**: http://localhost:3000

### Option 2: Local Network Hosting

**Best for**: Team/office use

```powershell
# Make frontend accessible on local network
cd frontend
python -m http.server 3000 --bind 0.0.0.0

# Make backend accessible on local network
cd backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000

# Make R server accessible on local network
# Update r_server.R to use host='0.0.0.0'
```

**Access**: http://[YOUR_IP]:3000 (e.g., http://192.168.1.100:3000)

### Option 3: Windows IIS (Internet Information Services)

**Best for**: Professional local hosting

#### Setup Steps:

1. **Enable IIS**:

   - Control Panel → Programs → Turn Windows features on/off
   - Check "Internet Information Services"

2. **Create Website**:

   - Open IIS Manager
   - Right-click "Sites" → Add Website
   - Physical path: `C:\Users\softe\implicit_motive\frontend`
   - Port: 80 (or custom port)

3. **Configure Reverse Proxy** (for API calls):
   - Install URL Rewrite module
   - Configure proxy rules for `/api/*` to backend

### Option 4: Nginx Local Server

**Best for**: Production-like local setup

#### Install Nginx:

```powershell
# Download nginx for Windows
# Extract to C:\nginx
# Run: C:\nginx\nginx.exe
```

#### Nginx Configuration (`nginx.conf`):

```nginx
server {
    listen 80;
    server_name localhost;

    # Frontend
    location / {
        root C:/Users/softe/implicit_motive/frontend;
        index index.html;
    }

    # API Proxy
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🗄️ Local Database Solutions

### Option 1: SQLite (Recommended for Local Use)

**Best for**: Simple, file-based database

#### Setup SQLite Database:

```python
# Create database.py in backend/
import sqlite3
import json
from datetime import datetime
from pathlib import Path

class DatabaseManager:
    def __init__(self, db_path="stories.db"):
        self.db_path = Path(db_path)
        self.init_database()

    def init_database(self):
        """Initialize database with stories table"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS stories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT,
                story_text TEXT NOT NULL,
                analysis_results TEXT,  -- JSON string
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                ip_address TEXT,
                session_id TEXT
            )
        ''')

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT UNIQUE,
                first_visit TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                total_stories INTEGER DEFAULT 0,
                last_analysis TIMESTAMP
            )
        ''')

        conn.commit()
        conn.close()

    def save_story(self, user_id, story_text, analysis_results, ip_address=None, session_id=None):
        """Save story and analysis to database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute('''
            INSERT INTO stories (user_id, story_text, analysis_results, ip_address, session_id)
            VALUES (?, ?, ?, ?, ?)
        ''', (user_id, story_text, json.dumps(analysis_results), ip_address, session_id))

        # Update user stats
        cursor.execute('''
            INSERT OR REPLACE INTO users (user_id, total_stories, last_analysis)
            VALUES (?,
                COALESCE((SELECT total_stories FROM users WHERE user_id = ?), 0) + 1,
                CURRENT_TIMESTAMP)
        ''', (user_id, user_id))

        conn.commit()
        conn.close()
        return cursor.lastrowid

    def get_user_stories(self, user_id, limit=10):
        """Get user's previous stories"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute('''
            SELECT story_text, analysis_results, created_at
            FROM stories
            WHERE user_id = ?
            ORDER BY created_at DESC
            LIMIT ?
        ''', (user_id, limit))

        results = cursor.fetchall()
        conn.close()

        return [{
            'story': row[0],
            'analysis': json.loads(row[1]),
            'date': row[2]
        } for row in results]

    def get_analytics(self):
        """Get basic analytics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()

        cursor.execute('SELECT COUNT(*) FROM stories')
        total_stories = cursor.fetchone()[0]

        cursor.execute('SELECT COUNT(DISTINCT user_id) FROM stories')
        unique_users = cursor.fetchone()[0]

        cursor.execute('''
            SELECT DATE(created_at) as date, COUNT(*) as count
            FROM stories
            GROUP BY DATE(created_at)
            ORDER BY date DESC
            LIMIT 30
        ''')
        daily_stats = cursor.fetchall()

        conn.close()

        return {
            'total_stories': total_stories,
            'unique_users': unique_users,
            'daily_stats': [{'date': row[0], 'count': row[1]} for row in daily_stats]
        }
```

#### Update main.py to use database:

```python
# Add to main.py
from database import DatabaseManager
import uuid
from fastapi import Request

# Initialize database
db = DatabaseManager()

@app.post("/analyze", response_model=MotiveScores)
async def analyze_story(request: StoryRequest, http_request: Request):
    story = request.story

    # Generate user ID (you can implement proper user management later)
    user_id = str(uuid.uuid4())
    session_id = http_request.headers.get('session-id', str(uuid.uuid4()))
    ip_address = http_request.client.host

    # Get analysis from R server
    result = query_r_model(story)
    if "error" in result:
        raise HTTPException(status_code=400, detail=result["error"])

    # Save to database
    story_id = db.save_story(
        user_id=user_id,
        story_text=story,
        analysis_results=result,
        ip_address=ip_address,
        session_id=session_id
    )

    # Add story ID to response
    response_data = {
        "story_id": story_id,
        "sentences": result["sentences"],
        "total_words": extract_value(result["total_words"]),
        "total_sentences": extract_value(result["total_sentences"]),
        "text_length_chars": extract_value(result["text_length_chars"])
    }

    # Add motive results
    for motive_name in ["power", "achievement", "affiliation"]:
        if motive_name in result:
            response_data[motive_name] = result[motive_name]

    return response_data

@app.get("/user/{user_id}/stories")
async def get_user_stories(user_id: str, limit: int = 10):
    """Get user's previous stories"""
    stories = db.get_user_stories(user_id, limit)
    return {"stories": stories}

@app.get("/analytics")
async def get_analytics():
    """Get basic analytics"""
    return db.get_analytics()
```

### Option 2: PostgreSQL (Local Installation)

**Best for**: More robust local database

#### Install PostgreSQL:

1. Download PostgreSQL for Windows
2. Install with default settings
3. Remember the password for 'postgres' user

#### Setup Database:

```sql
-- Connect to PostgreSQL and run:
CREATE DATABASE implicit_motive;
CREATE USER motive_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE implicit_motive TO motive_user;
```

#### Python Integration:

```python
# Install: pip install psycopg2-binary
import psycopg2
from psycopg2.extras import RealDictCursor

class PostgreSQLManager:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="localhost",
            database="implicit_motive",
            user="motive_user",
            password="your_password"
        )
        self.init_database()

    def init_database(self):
        cursor = self.conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS stories (
                id SERIAL PRIMARY KEY,
                user_id VARCHAR(255),
                story_text TEXT NOT NULL,
                analysis_results JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                ip_address VARCHAR(45),
                session_id VARCHAR(255)
            )
        ''')
        self.conn.commit()
```

### Option 3: MySQL (Local Installation)

**Best for**: Familiar database system

#### Install MySQL:

1. Download MySQL Community Server
2. Install with MySQL Workbench
3. Create database and user

#### Python Integration:

```python
# Install: pip install mysql-connector-python
import mysql.connector

class MySQLManager:
    def __init__(self):
        self.conn = mysql.connector.connect(
            host="localhost",
            database="implicit_motive",
            user="motive_user",
            password="your_password"
        )
```

## 🌐 Advanced Hosting Solutions

### Option 1: Cloudflare Tunnel (Free)

**Best for**: Secure external access without port forwarding

#### Setup:

1. Install Cloudflare Tunnel
2. Create tunnel: `cloudflared tunnel create implicit-motive`
3. Configure tunnel: `cloudflared tunnel route dns implicit-motive your-domain.com`
4. Run tunnel: `cloudflared tunnel run implicit-motive`

### Option 2: ngrok (Free/Paid)

**Best for**: Quick external access

#### Setup:

1. Install ngrok
2. Create account and get auth token
3. Run: `ngrok http 3000`
4. Use provided URL (e.g., https://abc123.ngrok.io)

### Option 3: Local Network with Dynamic DNS

**Best for**: Permanent external access

#### Setup:

1. Configure router port forwarding (3000, 8000, 8001)
2. Use dynamic DNS service (No-IP, DuckDNS)
3. Access via: http://your-domain.ddns.net:3000

## 🔧 Implementation Steps

### Step 1: Choose Database Solution

```bash
# For SQLite (simplest)
# No installation needed, just use the DatabaseManager class above

# For PostgreSQL
# Download and install PostgreSQL
# Create database and user

# For MySQL
# Download and install MySQL
# Create database and user
```

### Step 2: Update Backend

1. Add database manager to backend/
2. Update main.py with database integration
3. Install required packages:

```bash
pip install sqlite3  # Built-in with Python
# OR
pip install psycopg2-binary  # For PostgreSQL
# OR
pip install mysql-connector-python  # For MySQL
```

### Step 3: Update Frontend

```javascript
// Add to index.html - save user ID in localStorage
function generateUserId() {
  let userId = localStorage.getItem("implicit_motive_user_id");
  if (!userId) {
    userId =
      "user_" + Date.now() + "_" + Math.random().toString(36).substr(2, 9);
    localStorage.setItem("implicit_motive_user_id", userId);
  }
  return userId;
}

// Update analyzeStory function
async function analyzeStory() {
  const userId = generateUserId();
  const story = document.getElementById("storyInput").value.trim();

  const response = await fetch("http://localhost:8000/analyze", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Session-ID": generateSessionId(),
    },
    body: JSON.stringify({
      story: story,
      user_id: userId,
    }),
  });
  // ... rest of function
}
```

### Step 4: Add User History Feature

```html
<!-- Add to index.html -->
<div id="user-history" style="display: none;">
  <h3>Your Previous Analyses</h3>
  <div id="history-list"></div>
</div>

<script>
  async function loadUserHistory() {
    const userId = generateUserId();
    const response = await fetch(
      `http://localhost:8000/user/${userId}/stories`
    );
    const data = await response.json();

    const historyDiv = document.getElementById("history-list");
    historyDiv.innerHTML = "";

    data.stories.forEach((story) => {
      const storyDiv = document.createElement("div");
      storyDiv.innerHTML = `
            <div class="story-item">
                <p><strong>Date:</strong> ${new Date(
                  story.date
                ).toLocaleString()}</p>
                <p><strong>Story:</strong> ${story.story.substring(
                  0,
                  100
                )}...</p>
                <button onclick="loadPreviousAnalysis('${
                  story.story
                }')">Re-analyze</button>
            </div>
        `;
      historyDiv.appendChild(storyDiv);
    });
  }
</script>
```

## 📊 Database Schema

### Stories Table:

```sql
CREATE TABLE stories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    story_text TEXT NOT NULL,
    analysis_results TEXT,  -- JSON string
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address TEXT,
    session_id TEXT
);
```

### Users Table:

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT UNIQUE,
    first_visit TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_stories INTEGER DEFAULT 0,
    last_analysis TIMESTAMP
);
```

### Analytics Table (Optional):

```sql
CREATE TABLE analytics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE,
    total_stories INTEGER,
    unique_users INTEGER,
    avg_achievement REAL,
    avg_affiliation REAL,
    avg_power REAL
);
```

## 🚀 Deployment Checklist

### Local Hosting:

- [ ] Choose hosting method (IIS, Nginx, or simple Python server)
- [ ] Configure firewall rules
- [ ] Test local network access
- [ ] Set up external access (if needed)

### Database Setup:

- [ ] Choose database solution (SQLite recommended)
- [ ] Install database software (if not SQLite)
- [ ] Create database and tables
- [ ] Test database connection
- [ ] Implement data saving
- [ ] Add user history feature

### Security:

- [ ] Implement input validation
- [ ] Add rate limiting
- [ ] Secure database credentials
- [ ] Add CORS restrictions for production

## 🔍 Monitoring and Analytics

### Basic Analytics Dashboard:

```python
@app.get("/admin/analytics")
async def admin_analytics():
    """Admin analytics endpoint"""
    analytics = db.get_analytics()
    return {
        "total_stories": analytics['total_stories'],
        "unique_users": analytics['unique_users'],
        "daily_stats": analytics['daily_stats'],
        "top_motives": get_top_motives(),
        "average_scores": get_average_scores()
    }
```

### Logging Setup:

```python
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

# Log each analysis
@app.post("/analyze")
async def analyze_story(request: StoryRequest):
    logger.info(f"Analysis request: {len(request.story)} characters")
    # ... rest of function
```

## 💡 Recommendations

### For Development:

- **Database**: SQLite (simple, no setup)
- **Hosting**: Local Python servers
- **Access**: localhost only

### For Team Use:

- **Database**: SQLite or PostgreSQL
- **Hosting**: Nginx with reverse proxy
- **Access**: Local network

### For External Access:

- **Database**: PostgreSQL or MySQL
- **Hosting**: Cloudflare Tunnel or ngrok
- **Access**: Secure external URLs

### For Production:

- **Database**: PostgreSQL with proper backup
- **Hosting**: Professional hosting service
- **Access**: Custom domain with SSL

---

**Next Steps**: Choose your preferred database solution and hosting method, then follow the implementation steps above. SQLite + local Python servers is the easiest way to get started!
