# Serilog Configuration for IIS Deployment

## What has been added:

### 1. Serilog Packages Added:

- `Serilog.AspNetCore` (8.0.2)
- `Serilog.Sinks.File` (6.0.0)
- `Serilog.Sinks.Console` (6.0.0)
- `Serilog.Settings.Configuration` (8.0.2)

### 2. Logging Configuration:

- **Console logging** for development
- **File logging** with daily rotation
- **Different log levels** per environment
- **Comprehensive error logging** throughout the application

### 3. Log Files Location:

- **Development**: `logs/log-YYYY-MM-DD.txt`
- **Production**: `logs/production-log-YYYY-MM-DD.txt`
- **Staging**: `logs/staging-log-YYYY-MM-DD.txt`

## Deployment Steps:

### 1. Build and Publish:

```bash
dotnet publish -c Production -o ./publish
```

### 2. IIS Configuration:

- Ensure the application pool has **write permissions** to the application directory
- Create a `logs` folder in your application directory
- Grant **IIS_IUSRS** full control to the `logs` folder

### 3. Log Files Location:

- **Primary**: `logs/log-YYYY-MM-DD.txt` (in application directory)
- **Fallback 1**: `application-log-YYYY-MM-DD.txt` (in application root)
- **Fallback 2**: `C:\Windows\Temp\SimpleCRUD-log-YYYY-MM-DD.txt` (Windows temp folder)

### 4. Test Logging:

- Navigate to `/log-test` page after deployment
- Click the test buttons to generate log entries
- The page will show you exactly where log files are located
- Check all three locations for log files

## When Logs Are Generated:

### Immediate Logging (Application Startup):

- **As soon as the application starts** - logs are created immediately
- **Before any requests** - logging begins during Program.cs execution
- **Startup sequence** - logs show each step of application initialization

### Request-Based Logging:

- **Every HTTP request** - detailed request processing logs
- **Authentication events** - login/logout attempts
- **Database operations** - all database calls are logged
- **Errors and exceptions** - immediate logging of any errors

### Log File Creation:

- **First log entry** creates the file
- **Daily rotation** - new file created each day
- **Multiple locations** - if one fails, others will work
- **Automatic cleanup** - old files are automatically removed

## Troubleshooting 500 Errors:

### Common Issues to Check:

1. **Database Connection**:

   - Verify connection string in `appsettings.Production.json`
   - Check if SQL Server is accessible from IIS server
   - Verify database user permissions

2. **File Permissions**:

   - Application pool identity needs write access to `logs` folder
   - Check IIS_IUSRS permissions on application directory

3. **Missing Dependencies**:

   - Ensure all NuGet packages are published
   - Check if Entity Framework migrations are applied

4. **IP Whitelist Issues**:
   - Check if IP whitelist service is causing database connection issues
   - Verify IPWhitelists table exists and is accessible

### Log Analysis:

The logs will show:

- Application startup sequence
- Database connection attempts
- IP whitelist checks
- Any exceptions with full stack traces
- Request processing details

### Quick Fixes:

1. **✅ IP Whitelist DISABLED** - The IP whitelist middleware and service registration have been commented out in Program.cs
2. **Check database connectivity** by testing connection string
3. **Verify file permissions** on the application directory
4. **Check IIS logs** in addition to application logs

### IP Whitelist Status:

- **Middleware**: Commented out (lines 118-166 in Program.cs)
- **Service Registration**: Commented out (line 95 in Program.cs)
- **Reason**: Eliminating IP whitelist as potential cause of 500 errors

## Log File Locations on IIS Server:

- Application root: `C:\inetpub\wwwroot\YourAppName\logs\`
- Or wherever your application is deployed

## Next Steps:

1. Deploy the updated application
2. Check the log files for detailed error information
3. Use the log details to identify the root cause of the 500 errors
4. Apply appropriate fixes based on log findings

## Re-enabling IP Whitelist (After Fixing 500 Errors):

To re-enable IP whitelist functionality:

1. Uncomment the IP whitelist service registration (line 95 in Program.cs)
2. Uncomment the IP whitelist middleware (lines 118-166 in Program.cs)
3. Ensure the IPWhitelists table exists and is accessible
4. Test thoroughly before deploying to production
