# CloudOps Copilot Landing Zone

Reference implementation of a hub-and-spoke Azure landing zone with Terraform plus a minimal .NET 8 app to validate Key Vault + managed identity. Includes a static progress tracker UI backed by JSON.

## Highlights

- Hub-and-spoke network with bi-directional VNet peering
- Security baseline: Key Vault + user-assigned managed identity (UAMI)
- DevSpokeApp validates secret resolution locally and in Azure
- Progress tracker reads JSON and stores state in browser `localStorage`

## Architecture

- Hub VNet `vnet-hub-dev (10.0.0.0/16)` with `subnet-hub-default (10.0.1.0/24)`
- Spoke VNet `vnet-spoke-app-dev (10.1.0.0/16)` with `subnet-spoke-app (10.1.1.0/24)`
- Key Vault `cloudops-hubspoke-kv` protected with soft delete and purge protection
- UAMI `cloudops-hubspoke-uami-app` granted Get/List only on secrets

![Hub-and-spoke network diagram](docs/hub_spoke_network.png)

## Quickstart

### Tracker UI

Serve the static site from a local web server.

Option 1: VS Code Live Server
1. Open the workspace in VS Code
2. Install the Live Server extension if needed
3. Right-click `index.html` and choose "Open with Live Server"

Option 2: Python
```bash
python -m http.server 5500
```
Open `http://localhost:5500/index.html`.

Roadmap data: `data/cloudops_landing_zone_tracker.json`

### DevSpokeApp (.NET 8)

Endpoints:

- `/` returns `DevSpokeApp running`
- `/secret` reads `TestSecret` from ASP.NET Core configuration

Local config:

```bash
cd "C:\dev\Cloud Infrastructure\src\DevSpokeApp"
dotnet run
```

Create `appsettings.json`:

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

Browse to `http://localhost:5043/` or `http://localhost:5043/secret`.

## Key Vault wiring (DevSpokeApp)

In Azure, the Web App resolves `TestSecret` from `cloudops-hubspoke-kv` via `AddAzureKeyVault` + `DefaultAzureCredential` using a user-assigned managed identity (`AZURE_CLIENT_ID`).

## Monitoring & Observability

This landing zone includes a dedicated monitoring stack for the hub-and-spoke environment.

- **Resource group:** `rg-cloudops-monitoring-dev`
- **Log Analytics workspace:** `log-cloudops-platform-dev` (East US)
- **Scope:** Central workspace for platform logs and metrics from Key Vault, App Services, VNets/NSGs, and other landing-zone resources.
- **Status:** Workspace and dev monitoring RG are provisioned via Terraform (`monitoring/dev/main.tf`). Key Vault diagnostic settings are configured to send audit logs and metrics to this workspace.

Over time this workspace will host:
- Baseline alerts for availability, performance, and security across the landing zone.
- Saved KQL queries and workbooks (see `monitoring/dev/queries` and `monitoring/dev/workbooks.md`) for day-to-day CloudOps troubleshooting and dashboards.

## Repo layout

- `infra/terraform/network` - hub-and-spoke Terraform
- `infra/app/spoke` - app IaC (spoke consumption)
- `src/DevSpokeApp` - .NET 8 test app
- `data/cloudops_landing_zone_tracker.json` - tracker roadmap data

## Reference diagrams

- `docs/cloudops-hubspoke-network-architecture.png`
- `docs/cloudops-hubspoke-uami-keyvault.png`

![Hub-spoke overall architecture](docs/cloudops-hubspoke-network-architecture.png)

![UAMI to Key Vault secrets flow](docs/cloudops-hubspoke-uami-keyvault.png)
