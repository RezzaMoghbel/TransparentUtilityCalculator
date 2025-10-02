using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using SimpleCRUD.Components;
using SimpleCRUD.Components.Account;
using SimpleCRUD.Data.Infrastructure;
using SimpleCRUD.Data.Models;
using SimpleCRUD.Data.Repositories;
using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.Engine.Identity;
using SimpleCRUD.Engine.Test;
using SimpleCRUD.Services;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog with fallback options for IIS
var logPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "logs");
var fallbackLogPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "application-log-.txt");
var tempLogPath = Path.Combine(Path.GetTempPath(), "SimpleCRUD-log-.txt");

Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File(
        path: Path.Combine(logPath, "log-.txt"),
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30,
        fileSizeLimitBytes: 10 * 1024 * 1024, // 10MB
        rollOnFileSizeLimit: true,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
    // Fallback: Write to application root if logs folder fails
    .WriteTo.File(
        path: fallbackLogPath,
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 7,
        fileSizeLimitBytes: 5 * 1024 * 1024, // 5MB
        rollOnFileSizeLimit: true,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
    // Fallback: Write to Windows temp folder
    .WriteTo.File(
        path: tempLogPath,
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 7,
        fileSizeLimitBytes: 5 * 1024 * 1024, // 5MB
        rollOnFileSizeLimit: true,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
    .CreateLogger();

builder.Host.UseSerilog();

// Immediate logging test
Log.Information("=== APPLICATION STARTING ===");
Log.Information("Current Directory: {Directory}", Directory.GetCurrentDirectory());
Log.Information("Application Base Path: {BasePath}", AppDomain.CurrentDomain.BaseDirectory);
Log.Information("Temp Directory: {TempPath}", Path.GetTempPath());
Log.Information("Primary Logs Directory: {LogsPath}", logPath);
Log.Information("Fallback Log Path: {FallbackPath}", fallbackLogPath);
Log.Information("Temp Log Path: {TempLogPath}", tempLogPath);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddCascadingAuthenticationState();
builder.Services.AddScoped<IdentityUserAccessor>();
builder.Services.AddScoped<IdentityRedirectManager>();
builder.Services.AddScoped<AuthenticationStateProvider, IdentityRevalidatingAuthenticationStateProvider>();

builder.Services.AddAuthentication(options =>
    {
        options.DefaultScheme = IdentityConstants.ApplicationScheme;
        options.DefaultSignInScheme = IdentityConstants.ExternalScheme;
    })
    .AddIdentityCookies();


var envName = builder.Environment.EnvironmentName;

// Set connection string based on environment
string connectionString = envName.ToLowerInvariant() switch
{
    "development" => "Server=DEV-SERVER;Database=DevDatabase;User Id=DevUser;Password=DUMMY_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True",
    "staging" => "Server=STAGING-SERVER\\SQLEXPRESS;Database=StagingDatabase;User Id=StagingUser;Password=DUMMY_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True",
    "production" => "Server=PROD-SERVER\\SQLEXPRESS;Database=ProdDatabase;User Id=ProdUser;Password=DUMMY_PASSWORD;MultipleActiveResultSets=true;TrustServerCertificate=True",
    _ => throw new InvalidOperationException($"Unknown environment: {envName}")
};

Log.Information("=== CONNECTION STRING CONFIGURATION ===");
Log.Information("Environment: {Environment}", envName);
Log.Information("Using Connection String: {ConnectionString}", connectionString);

var csb = new SqlConnectionStringBuilder(connectionString);
Log.Information("Application starting - ENV={Environment} SERVER={Server} DB={Database}", envName, csb.DataSource, csb.InitialCatalog);
Log.Information("Encrypt Setting: {Encrypt}", csb.Encrypt);
Log.Information("TrustServerCertificate Setting: {TrustServerCertificate}", csb.TrustServerCertificate);
Console.WriteLine($"ENV={envName}  SERVER={csb.DataSource}  DB={csb.InitialCatalog}");
Console.WriteLine($"Connection String: {connectionString}");

//Registering a factory that hands out SqlConnection instances
builder.Services.AddSingleton<ISqlConnectionFactory>(
    _ => new SqlConnectionFactory(connectionString));

//Registering generic CRUD repository
builder.Services.AddScoped(typeof(ICRUD<>), typeof(CRUD<>));
builder.Services.AddScoped(typeof(IdentityAccessLevelHandler<>));
builder.Services.AddScoped(typeof(IdentityUserHandler<>));
builder.Services.AddScoped(typeof(UtilityReadingHandler<>));
builder.Services.AddScoped(typeof(UtilityReportHandler<>));


try
{
    Log.Information("Configuring database context...");
    builder.Services.AddDbContext<ApplicationDbContext>(options =>
        options.UseSqlServer(connectionString));
    builder.Services.AddDatabaseDeveloperPageExceptionFilter();
    Log.Information("Database context configured successfully");

    Log.Information("Configuring Identity services...");
    builder.Services.AddIdentityCore<ApplicationUser>(options => options.SignIn.RequireConfirmedAccount = true)
        .AddEntityFrameworkStores<ApplicationDbContext>()
        .AddSignInManager()
        .AddDefaultTokenProviders();
    Log.Information("Identity services configured successfully");
}
catch (Exception ex)
{
    Log.Fatal(ex, "Failed to configure database or identity services");
    throw;
}

builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityNoOpEmailSender>();
builder.Services.AddSingleton<ToastService>();
builder.Services.AddHttpClient();
builder.Services.AddScoped<SignInManager<ApplicationUser>, CustomSignInManager>();
// IP Whitelist Service - COMMENTED OUT FOR TROUBLESHOOTING
// builder.Services.AddScoped<IIPWhitelistService, IPWhitelistService>();

Log.Information("Building application...");
var app = builder.Build();
Log.Information("Application built successfully");

// Configure the HTTP request pipeline.
Log.Information("Configuring HTTP request pipeline for {Environment}", app.Environment.EnvironmentName);
if (app.Environment.IsDevelopment())
{
    Log.Information("Using development configuration - enabling migrations endpoint");
    app.UseMigrationsEndPoint();
}
else
{
    Log.Information("Using production configuration - enabling exception handler and HSTS");
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseAuthentication(); //This must be before IP check

//IP Whitelist Middleware - COMMENTED OUT FOR TROUBLESHOOTING
/*
app.Use(async (context, next) =>
{
    try
    {
        Log.Debug("IP Whitelist middleware processing request for {Path} from IP {IP}", 
            context.Request.Path, context.Connection.RemoteIpAddress?.ToString());

        var ipService = context.RequestServices.GetRequiredService<IIPWhitelistService>();
        var userManager = context.RequestServices.GetRequiredService<UserManager<ApplicationUser>>();

        var anyIPsExist = await ipService.AnyWhitelistConfiguredAsync(); //check if list exists
        if (!anyIPsExist)
        {
            Log.Debug("No IP whitelist configured, allowing request");
            await next(); // Skip filtering
            return;
        }

        var ip = context.Connection.RemoteIpAddress?.ToString() ?? string.Empty;
        Log.Debug("Checking IP {IP} against whitelist", ip);

        var user = context.User.Identity?.IsAuthenticated == true
            ? await userManager.GetUserAsync(context.User)
            : null;

        var allowed = await ipService.IsIPAllowedAsync(ip, user?.Id);

        if (!allowed)
        {
            Log.Warning("Access denied for IP {IP} to path {Path}", ip, context.Request.Path);
            context.Response.StatusCode = 403;
            await context.Response.WriteAsync("Access Denied: Your IP is not whitelisted.");
            return;
        }

        Log.Debug("IP {IP} allowed, proceeding to next middleware", ip);
        await next();
    }
    catch (Exception ex)
    {
        Log.Error(ex, "Error in IP whitelist middleware for IP {IP} and path {Path}", 
            context.Connection.RemoteIpAddress?.ToString(), context.Request.Path);
        context.Response.StatusCode = 500;
        await context.Response.WriteAsync("Internal server error in IP whitelist middleware.");
    }
});
*/

app.UseAuthorization();

app.UseAntiforgery();

try
{
    Log.Information("Mapping application endpoints...");
    app.MapStaticAssets();
    app.MapRazorComponents<App>()
        .AddInteractiveServerRenderMode();

    app.MapAdditionalIdentityEndpoints();
    Log.Information("Application endpoints mapped successfully");

    Log.Information("Starting application...");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application failed to start");
    throw;
}
finally
{
    Log.CloseAndFlush();
}
