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


### App Service Monitoring Integration

The dev App Service (`dev-spoke-app`) is wired for centralized monitoring using Azure Log Analytics and Terraform.

- **Diagnostic setting:** Configured on `dev-spoke-app` to send logs and metrics to Log Analytics ([docs](https://learn.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)).
- **Workspace:** All logs and metrics are sent to `log-cloudops-platform-dev`, enabling KQL queries, alerts, and dashboards ([docs](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/appservicehttplogs)).
- **Log types:**
	- `AppServiceHTTPLogs`: Access logs (requests, status codes, latency)
	- `AppServiceConsoleLogs`: Stdout/stderr output (e.g., `console.log`, `ILogger`)
	- `AppServiceAppLogs`: Application-level logs and exceptions
- **Metrics:** All platform metrics (CPU, memory, requests, errors) are sent to Log Analytics ([docs](https://docs.azure.cn/en-us/app-service/tutorial-troubleshoot-monitor)).
- **Terraform import:** Existing diagnostic setting imported into Terraform state for declarative management ([docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting)).
- **Retention:** Retention settings are honored as-is; future changes will use workspace/storage policies ([support](https://support.hashicorp.com/hc/en-us/articles/26764939614995-How-to-enable-Storage-Read-Write-or-Delete-Diagnostic-Settings-for-Azure-Blob-File-Queue-and-Table-using-Terraform)).

#### Practical Benefits

- **Centralized observability:** One workspace for HTTP logs, console/app logs, and metrics from `dev-spoke-app` ([docs](https://docs.azure.cn/en-us/azure-monitor/platform/tutorial-resource-logs)).
- **IaC control:** Diagnostic wiring is Terraform-driven; new environments can be set up with `plan/apply` ([notes](https://notes.kodekloud.com/docs/AZ-204-Developing-Solutions-for-Microsoft-Azure/Configuring-Web-App-Settings/Configuring-Diagnostic-Logging)).
- **Ready for KQL:** Query logs and metrics in Log Analytics for debugging and monitoring ([stackoverflow](https://stackoverflow.com/questions/67107019/azure-log-analytics-how-to-display-appserviceconsolelogs-and-appservicehttplogs)).

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
