using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// Key Vault integration
var keyVaultName = builder.Configuration["KEY_VAULT_NAME"];
if (!string.IsNullOrEmpty(keyVaultName))
{
    var kvUri = new Uri($"https://{keyVaultName}.vault.azure.net/");
    var credential = new DefaultAzureCredential();
    var client = new SecretClient(kvUri, credential);
    builder.Configuration.AddAzureKeyVault(client, new AzureKeyVaultConfigurationOptions());
}

// Swagger for dev
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/", () => "DevSpokeApp running");

app.MapGet("/secret", (IConfiguration config) =>
{
    // Example: secret named "TestSecret" in Key Vault
    var value = config["TestSecret"];
    return Results.Ok(value ?? "Secret not found");
});

app.Run();
