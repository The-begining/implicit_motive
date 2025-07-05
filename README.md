# Implicit Motive Analyzer

## Overview

This project analyzes stories or text to detect underlying psychological motives (Achievement, Affiliation, Power) using an R model, a Python FastAPI backend, and a React frontend. The workflow is:

- User submits a story in the web app (frontend)
- Python backend receives the story and sends it to the R server
- R server runs the model and returns motive scores
- Results are displayed in the frontend

---

## Prerequisites

- **Python 3.8+** (for backend)
- **Node.js & npm** (for frontend)
- **R (latest version)** (for model server)

---

## 1. Install R and Add to PATH

### A. Download and Install R

1. Go to: https://cran.r-project.org/bin/windows/base/
2. Download the latest R installer (e.g., `R-4.x.x-win.exe`).
3. Run the installer and follow the prompts.

### B. Add R to System PATH (if not done automatically)

1. Open File Explorer and go to `C:\Program Files\R\R-4.x.x\bin\x64` (replace `x.x` with your version).
2. Copy this path.
3. Press `Win + S`, type `environment variables`, and open **Edit the system environment variables**.
4. Click **Environment Variables...**
5. In **System variables**, select `Path` and click **Edit...**
6. Click **New** and paste the path you copied.
7. Click **OK** to save.
8. Open a new Command Prompt and run `R --version` to verify.

---

## 2. Install R Packages

Open **R GUI** or type `R` in Command Prompt, then run:

```r
install.packages(c("plumber", "jsonlite"))
```

If prompted to create a personal library, type `y` and press Enter. Choose a CRAN mirror close to you if asked.

---

## 3. Install Python Dependencies

Open **Command Prompt** and run:

```cmd
cd backend
pip install -r requirements.txt
```

---

## 4. Install Frontend Dependencies

Open **Command Prompt** and run:

```cmd
cd frontend
npm install
```

---

## 5. How to Run This Project (Step-by-Step)

1. **Start the R server (model API)**

   - Open Command Prompt and run:
     ```cmd
     cd backend
     Rscript -e "library(plumber); pr <- plumb('r_server.R'); pr$run(host='0.0.0.0', port=8001)"
     ```
   - Leave this window open. It should say `Listening on http://127.0.0.1:8001`.

2. **Start the Python backend**

   - Open a new Command Prompt and run:
     ```cmd
     cd backend
     python -m uvicorn main:app --reload --port 8000
     ```
   - Leave this window open. It should say `Uvicorn running on http://127.0.0.1:8000`.

3. **Start the React frontend**
   - Open a new Command Prompt and run:
     ```cmd
     cd frontend
     npm start
     ```
   - This will open the app in your browser at [http://localhost:3000](http://localhost:3000)

---

## 6. Using the App

- Paste your story in the text box and click **Analyze**.
- The frontend sends the story to the backend, which sends it to the R server for analysis.
- Motive scores are returned and displayed.

---

## 7. Troubleshooting

- **R not recognized:** Make sure R is installed and the correct path is added to your system PATH. Open a new Command Prompt and run `R --version`.
- **Failed to fetch:** Make sure all three servers (R, Python, React) are running and listening on the correct ports.
- **500 Internal Server Error:** Check the Python backend window for error details. Usually, this means the R server returned an unexpected result (e.g., a list instead of a number).
- **Port conflicts:** Make sure no other programs are using ports 8000, 8001, or 3000.

---

## 8. Project Structure

```
implicit_motive/
  backend/
    main.py           # Python FastAPI backend
    r_server.R        # R plumber API server
    requirements.txt  # Python dependencies
  frontend/
    ...               # React app
```

---

## 9. What This Does

- **Frontend:** User interface for submitting stories and viewing results.
- **Backend:** Receives stories, sends them to the R model, and returns results.
- **R Server:** Runs the actual motive analysis model and returns scores.

---

**If you have any issues, check each server window for errors and follow the troubleshooting steps above.**
