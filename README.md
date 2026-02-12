# CloudOps Copilot Landing Zone Tracker

Static progress tracker and reference implementation for a hub-and-spoke Azure landing zone. The tracker reads roadmap items from JSON and stores progress in browser `localStorage`.

## Contents

- Home page with a link to the tracker
- Tracker UI and logic
- JSON data source

## Run locally

Because the tracker loads JSON, serve it from a local web server.

Option 1: VS Code Live Server
1. Open the workspace in VS Code
2. Install the Live Server extension if needed
3. Right-click `index.html` and choose "Open with Live Server"

Option 2: Python
```bash
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

Progress is saved to browser `localStorage`. Clearing site data resets progress.

## Milestone 1 - Hub-and-Spoke Network (Completed)

- [x] Terraform scaffolding (`infra/terraform/network`) for AzureRM provider and common tags
- [x] Deployed `rg-cloudops-hubspoke` (eastus) with:
	- Hub VNet `vnet-hub-dev (10.0.0.0/16)` + `subnet-hub-default (10.0.1.0/24)` and `nsg-hub-default`
	- Spoke VNet `vnet-spoke-app-dev (10.1.0.0/16)` + `subnet-spoke-app (10.1.1.0/24)` and `nsg-spoke-app`
	- Bi-directional VNet peering between hub and spoke
- [x] Tags applied on core resources: `project=cloudops-copilot-landing-zone`, `env=dev`, `owner=shane`
- [x] `terraform plan` shows no drift (infra matches code)

![Hub-and-spoke network diagram](docs/hub_spoke_network.png)

## Landing Zone Security Baseline: UAMI + Key Vault

Security baseline for application secrets using Azure Key Vault and a user-assigned managed identity (UAMI).

### IaC implementation notes

- Terraform module creates `cloudops-hubspoke-uami-app` and `cloudops-hubspoke-kv`
- UAMI has only Get/List permissions on secrets via a Key Vault access policy
- Key Vault enforces soft delete, purge protection, and public network access disabled
- Root module exposes outputs (identity IDs, Key Vault name) for spoke/app modules to consume

### What this does

- Centralizes application secrets in a locked-down Key Vault (`cloudops-hubspoke-kv`)
- Uses UAMI (`cloudops-hubspoke-uami-app`) so apps authenticate without stored credentials
- Enforces least privilege with Get/List only on secrets
- Protects the vault with soft delete, purge protection, and restricted network access

### How it works (high level)

- Spoke apps (App Service, Function, VM) use UAMI `cloudops-hubspoke-uami-app`
- The app requests a token from Azure Entra ID scoped for Key Vault
- The app calls `cloudops-hubspoke-kv` and can read only permitted secrets
- Management group/policy baselines can enforce vault protections across the landing zone

Reference diagrams:

- Overall architecture: `docs/cloudops-hubspoke-network-architecture.png`
- Secrets flow: `docs/cloudops-hubspoke-uami-keyvault.png`

![Hub-spoke overall architecture](docs/cloudops-hubspoke-network-architecture.png)

![UAMI to Key Vault secrets flow](docs/cloudops-hubspoke-uami-keyvault.png)

## DevSpokeApp – local config + Key Vault wiring

Minimal .NET 8 Web API used to test Key Vault + managed identity pattern.

- `/` returns a health string: `DevSpokeApp running`
- `/secret` reads `TestSecret` from ASP.NET Core configuration

Locally, `TestSecret` comes from `appsettings.json`.

The app is wired to use Azure Key Vault via `AddAzureKeyVault` and `DefaultAzureCredential`.
In Azure, the Web App will resolve `TestSecret` from `cloudops-hubspoke-kv` using a user-assigned managed identity (`AZURE_CLIENT_ID`).

### Local development

```bash
cd "C:\dev\Cloud Infrastructure\src\DevSpokeApp"
dotnet run
```

The app listens on the port from `Properties\launchSettings.json` (currently `http://localhost:5043`).

### Endpoints

- `/` - health check, returns `DevSpokeApp running`
- `/secret` - returns the value of `TestSecret` from configuration

### Configure TestSecret locally

Create `appsettings.json` in the project root:

```json
{
	"Logging": {
		"LogLevel": {
			"Default": "Information",
			"Microsoft.AspNetCore": "Warning"
		}
	},
	"AllowedHosts": "*",
	"TestSecret": "Hello from appsettings"
}
```

Then restart the app:

```bash
dotnet run
```

Browse to:

- `http://localhost:5043/` - `DevSpokeApp running`
- `http://localhost:5043/secret` - `Hello from appsettings`
