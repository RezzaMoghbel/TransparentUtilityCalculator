# Support schema overview

The `support` schema powers the new ticketing + announcement features that sit on top of the existing `dbo.AspNetUsers` and `dbo.Buildings` tables. Everything is created/idempotently via `support/Scripts/AddSupportSchema.sql`.

## Tables

| Table | Purpose |
| --- | --- |
| `support.IssueCategory` | Lookup for ticket/announcement categories (seeded with MAINTENANCE, BILLING, etc.). |
| `support.TicketStatus` | Lookup for ticket workflow states (OPEN, IN_PROGRESS, RESOLVED, CLOSED). |
| `support.TicketPriority` | Lookup for priority codes (LOW → CRITICAL). |
| `support.AnnouncementScope` | Lookup for scope (BUILDING or GLOBAL). |
| `support.Ticket` | Master ticket record with FK links to lookup tables, creators, related/assigned users, building, and optional linked announcement. |
| `support.TicketMessage` | Threaded updates for each ticket. `IsInternal=1` hides a note from tenants. |
| `support.Announcement` | Public announcement record (can optionally reference a source ticket). |
| `support.AnnouncementUpdate` | Timeline of follow-up notes that appear under an announcement. |

All FK relationships are defined in `AddSupportSchema.sql`. Lookups are seeded with DEFAULT data so the script is safe to run multiple times.

## Stored procedures

All Dapper calls are routed through stored procedures in `support/Stored Procedures`. Highlights:

* `Ticket_Create / Ticket_Update / Ticket_Archive / Ticket_GetById`
* `Ticket_GetForUser` – now accepts `@StatusCode`, `@PriorityCode`, `@Search`, `@PageNumber`, `@PageSize` and returns `TotalCount` for paging.
* `Ticket_GetForBuilding` – accepts building filter, assignment filter (empty string = unassigned), status/priority filters, search and paging parameters.
* `TicketMessage_Create` + `TicketMessage_GetByTicketId` (optional `@IncludeInternal`).
* `Announcement_Create / Announcement_Update / Announcement_Archive / Announcement_GetById`.
* `Announcement_GetForBuilding` – supports optional building + scope/category filters, `@IncludeArchived`, `@IsActive`, paging, and always returns both building + global notices when a building id is supplied.
* `Announcement_GetGlobal` – same filter set but forces scope = GLOBAL.
* `AnnouncementUpdate_Create / AnnouncementUpdate_GetByAnnouncementId`.
* Lookup helpers (`IssueCategory_GetAll`, `TicketStatus_GetAll`, etc.) surface data for UI drop-downs.

## Application wiring

* DTOs + handlers live under `SimpleCRUD.DTO/Support` and `SimpleCRUD.Engine/Support`. They mirror the stored-proc contracts and expose strongly typed methods that Blazor components call.
* Permissions are layered on top of the existing `AccessLevel` system via `SupportPermissionService`. The default mappings live in `appsettings.json → SupportPermissions` and can be overridden per environment/role without touching code.
* Navigation links are hidden or shown by the same service so tenants only see “My Tickets / Announcements” while admins see the management links.

## Configuration checklist

1. Run `support/Scripts/AddSupportSchema.sql` (idempotent) to ensure the schema + lookup data exist.
2. Ensure `appsettings*.json` contains a `SupportPermissions` object (the base `appsettings.json` now includes defaults for User/Admin/SuperAdmin/System). Adjust these if you need read-only admins or custom combinations.
3. No EF migration is required—the schema is maintained through the SQL script for consistency with the rest of the database project.

With the script, stored procedures, DTOs, handlers and Blazor UI in place the Support module is ready to serve both tenant and admin workflows.

