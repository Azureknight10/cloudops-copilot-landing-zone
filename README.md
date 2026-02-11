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

## Milestone 1 - Hub-and-Spoke Network (Completed)

- [x] Terraform scaffolding (`infra/terraform/network`) for AzureRM provider and common tags.
- [x] Deployed `rg-cloudops-hubspoke` (eastus) with:
	- Hub VNet `vnet-hub-dev (10.0.0.0/16)` + `subnet-hub-default (10.0.1.0/24)` and `nsg-hub-default`.
	- Spoke VNet `vnet-spoke-app-dev (10.1.0.0/16)` + `subnet-spoke-app (10.1.1.0/24)` and `nsg-spoke-app`.
	- Bi-directional VNet peering between hub and spoke.
- [x] Tags applied on core resources: `project=cloudops-copilot-landing-zone`, `env=dev`, `owner=shane`.
- [x] `terraform plan` shows no drift (infra matches code).

![Hub-and-spoke network diagram](docs/hub_spoke_network.png)
