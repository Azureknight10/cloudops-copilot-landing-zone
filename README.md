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

## Landing Zone Security Baseline: UAMI + Key Vault

As part of the hub-and-spoke landing zone, I implemented a security baseline for application secrets using Azure Key Vault and a user-assigned managed identity (UAMI).

### IaC Implementation Notes

- Terraform module creates `cloudops-hubspoke-uami-app` and `cloudops-hubspoke-kv`.
- UAMI has only Get/List permissions on secrets via a Key Vault access policy.
- Key Vault enforces soft delete, purge protection, and public network access disabled.
- Root module exposes outputs (identity IDs, Key Vault name) for spoke/app modules to consume.

## What this does

- Centralizes application secrets (connection strings, API keys, etc.) in a locked-down Azure Key Vault (`cloudops-hubspoke-kv`) instead of in code or app settings.
- Uses a user-assigned managed identity (`cloudops-hubspoke-uami-app`) so apps can authenticate to Key Vault without storing credentials.
- Enforces least privilege by giving that identity only Get and List permissions on secrets via a Key Vault access policy.
- Protects the vault with soft delete and purge protection, and disables public network access so it is only reachable through authorized Azure paths.

## How it works (high level)

- An app in a spoke (App Service, Function, or VM) is assigned the UAMI `cloudops-hubspoke-uami-app` and runs without embedded secrets.
- At runtime, the app requests a token from Azure Entra ID using its managed identity, scoped for Key Vault.
- The app calls `cloudops-hubspoke-kv` with that token and can only read secrets (Get/List) permitted by the access policy.
- Management group/policy baselines can further enforce that all Key Vaults in this landing zone have soft delete, purge protection, and restricted network access enabled by default.

You can see the overall architecture in `cloudops-hubspoke-network-architecture.png`, and the secrets flow in `cloudops-hubspoke-uami-keyvault.png`.

![Hub-spoke overall architecture](docs/cloudops-hubspoke-network-architecture.png)

![UAMI to Key Vault secrets flow](docs/cloudops-hubspoke-uami-keyvault.png)
