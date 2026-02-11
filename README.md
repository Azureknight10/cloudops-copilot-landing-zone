# CloudOps Copilot Landing Zone Tracker

A simple, static progress tracker for the CloudOps Copilot Landing Zone roadmap. It loads data from a JSON file and renders a clickable task tracker with local progress saved in your browser.

## What is included

- A home page with a link to the tracker
- The tracker UI and logic
- A JSON data file that drives the roadmap

## Run locally

Because the tracker loads a JSON file, you should serve it from a local web server.

Option 1: VS Code Live Server
1. Open the workspace in VS Code
2. Install the Live Server extension if needed
3. Right-click `index.html` and choose "Open with Live Server"

Option 2: Python
```
python -m http.server 5500
```
Then open:
```
http://localhost:5500/index.html
```

## Data file

The tracker reads its roadmap from:

- `data/cloudops_landing_zone_tracker.json`

## Notes

Progress is saved to `localStorage` in your browser. Clearing site data resets progress.
