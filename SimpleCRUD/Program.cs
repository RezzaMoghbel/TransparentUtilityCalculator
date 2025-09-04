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

var builder = WebApplication.CreateBuilder(args);

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
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
var csb = new SqlConnectionStringBuilder(connectionString);
Console.WriteLine($"ENV={envName}  SERVER={csb.DataSource}  DB={csb.InitialCatalog}");

//Registering a factory that hands out SqlConnection instances
builder.Services.AddSingleton<ISqlConnectionFactory>(
    _ => new SqlConnectionFactory(connectionString));

//Registering generic CRUD repository
builder.Services.AddScoped(typeof(ICRUD<>), typeof(CRUD<>));
builder.Services.AddScoped(typeof(IdentityAccessLevelHandler<>));
builder.Services.AddScoped(typeof(IdentityUserHandler<>));
builder.Services.AddScoped(typeof(UtilityReadingHandler<>));
builder.Services.AddScoped(typeof(UtilityReportHandler<>));


builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));
builder.Services.AddDatabaseDeveloperPageExceptionFilter();

builder.Services.AddIdentityCore<ApplicationUser>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddSignInManager()
    .AddDefaultTokenProviders();

builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityNoOpEmailSender>();
builder.Services.AddSingleton<ToastService>();
builder.Services.AddHttpClient();
builder.Services.AddScoped<SignInManager<ApplicationUser>, CustomSignInManager>();
builder.Services.AddScoped<IIPWhitelistService, IPWhitelistService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseAuthentication(); //This must be before IP check

//IP Whitelist Middleware
app.Use(async (context, next) =>
{
    var ipService = context.RequestServices.GetRequiredService<IIPWhitelistService>();
    var userManager = context.RequestServices.GetRequiredService<UserManager<ApplicationUser>>();

    var anyIPsExist = await ipService.AnyWhitelistConfiguredAsync(); //check if list exists
    if (!anyIPsExist)
    {
        await next(); // Skip filtering
        return;
    }

    var ip = context.Connection.RemoteIpAddress?.ToString() ?? string.Empty;

    var user = context.User.Identity?.IsAuthenticated == true
        ? await userManager.GetUserAsync(context.User)
        : null;

    var allowed = await ipService.IsIPAllowedAsync(ip, user?.Id);

    if (!allowed)
    {
        context.Response.StatusCode = 403;
        await context.Response.WriteAsync("Access Denied: Your IP is not whitelisted.");
        return;
        //context.Response.Redirect("/AccessDenied.html");
        //return;
        //    context.Response.Redirect("https://insuredaily.co.uk");
        //    return;
        //}
    }

    await next();
});

app.UseAuthorization();

app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.MapAdditionalIdentityEndpoints();

app.Run();
