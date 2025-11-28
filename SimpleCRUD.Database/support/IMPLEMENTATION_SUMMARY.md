# Support System Implementation Summary

## Overview

This document summarizes the complete implementation of the Support system (Tickets + Announcements) for the Utility Calculator application.

## Implementation Date

January 2025

## Architecture

### Database Layer

- **Schema**: `support`
- **Tables**:
  - Lookup tables: `IssueCategory`, `TicketStatus`, `TicketPriority`, `AnnouncementScope`
  - Main tables: `Ticket`, `TicketMessage`, `Announcement`, `AnnouncementUpdate`
- **Stored Procedures**: All CRUD operations implemented in `support` schema
- **Location**: `SimpleCRUD.Database/support/`

### Application Layer

- **DTOs**: `SimpleCRUD.DTO/Support/`
- **Handlers**: `SimpleCRUD.Engine/Support/`
- **Services**: `SimpleCRUD/Services/Support/`
- **UI Components**: `SimpleCRUD/Components/Pages/Support/`

## Files Created/Modified

### Database

1. **Schema & Tables** (`SimpleCRUD.Database/support/`)
   - `Scripts/AddSupportSchema.sql` - Main schema creation script
   - `Tables/*.sql` - Individual table definitions
   - `Stored Procedures/*.sql` - All CRUD stored procedures

### DTOs (`SimpleCRUD.DTO/Support/`)

1. `IssueCategory.cs` - Lookup DTO
2. `TicketStatus.cs` - Lookup DTO
3. `TicketPriority.cs` - Lookup DTO
4. `AnnouncementScope.cs` - Lookup DTO
5. `SupportTicket.cs` - Main ticket entity
6. `SupportTicketMessage.cs` - Ticket message entity
7. `SupportAnnouncement.cs` - Announcement entity
8. `SupportAnnouncementUpdate.cs` - Announcement update entity
9. `TicketCreateRequest.cs` - Create request DTO
10. `TicketUpdateRequest.cs` - Update request DTO
11. `TicketListRequest.cs` - List/filter request DTO
12. `TicketArchiveRequest.cs` - Archive request DTO
13. `TicketMessageCreateRequest.cs` - Message create DTO
14. `TicketMessageListRequest.cs` - Message list DTO
15. `AnnouncementCreateRequest.cs` - Announcement create DTO
16. `AnnouncementUpdateRequest.cs` - Announcement update DTO
17. `AnnouncementListRequest.cs` - Announcement list DTO
18. `AnnouncementUpdateCreateRequest.cs` - Announcement update create DTO
19. `BuildingOption.cs` - Building dropdown option DTO

### Handlers (`SimpleCRUD.Engine/Support/`)

1. `SupportTicketHandler.cs` - Ticket CRUD operations
2. `SupportTicketMessageHandler.cs` - Message operations
3. `SupportAnnouncementHandler.cs` - Announcement CRUD operations
4. `SupportLookupHandler.cs` - Lookup table operations

### Services (`SimpleCRUD/Services/Support/`)

1. `SupportPermissionService.cs` - Permission checking service
2. `SupportPermissionOptions.cs` - Permission configuration options

### UI Components - User Pages (`SimpleCRUD/Components/Pages/Support/`)

1. `Tickets/MyTickets.razor` - User ticket list page
2. `Tickets/Create.razor` - User ticket creation page
3. `Tickets/View.razor` - User ticket detail page
4. `Announcements/Index.razor` - User announcements list
5. `Announcements/View.razor` - User announcement detail

### UI Components - Admin Pages (`SimpleCRUD/Components/Pages/Support/Admin/`)

1. `Tickets/Index.razor` - Admin ticket management list
2. `Tickets/Create.razor` - Admin ticket creation
3. `Tickets/View.razor` - Admin ticket detail with full controls
4. `Announcements/Index.razor` - Admin announcement management list
5. `Announcements/Create.razor` - Admin announcement creation
6. `Announcements/Edit.razor` - Admin announcement editing
7. `Announcements/View.razor` - Admin announcement detail with updates

### Configuration Files

1. `SimpleCRUD/Program.cs` - DI registration for handlers and services
2. `SimpleCRUD/appsettings.json` - Permission configuration section
3. `SimpleCRUD/Components/_Imports.razor` - Global using statements
4. `SimpleCRUD/Components/Layout/AuthorizedMenu.razor` - Navigation menu updates

## Routes

### User Routes

- `/support/my-tickets` - My Tickets list
- `/support/my-tickets/create` - Create ticket
- `/support/my-tickets/{id}` - View ticket (user)
- `/support/announcements` - Announcements list
- `/support/announcements/{id}` - View announcement (user)

### Admin Routes

- `/support/admin/tickets` - Manage tickets
- `/support/admin/tickets/create` - Create ticket (admin)
- `/support/admin/tickets/{id}` - View/edit ticket (admin)
- `/support/admin/announcements` - Manage announcements
- `/support/admin/announcements/create` - Create announcement
- `/support/admin/announcements/{id}/edit` - Edit announcement
- `/support/admin/announcements/{id}` - View announcement (admin)

## Permissions System

### Permission Structure

The Support module uses a permission-based access control system that works alongside the existing `AccessLevel` infrastructure:

- **AccessLevels**: User (1), Admin (2), SuperAdmin (3), System (4)
- **Support Permissions**:
  - `Support.Tickets.Read`
  - `Support.Tickets.Create`
  - `Support.Tickets.Update`
  - `Support.Tickets.Delete` (archive)
  - `Support.Announcements.Read`
  - `Support.Announcements.Create`
  - `Support.Announcements.Update`
  - `Support.Announcements.Delete` (archive)

### Permission Configuration

Permissions are configured in `appsettings.json`:

```json
{
  "SupportPermissions": {
    "User": {
      "Tickets": {
        "Read": true,
        "Create": true,
        "Update": false,
        "Delete": false
      },
      "Announcements": {
        "Read": true,
        "Create": false,
        "Update": false,
        "Delete": false
      }
    },
    "Admin": {
      "Tickets": {
        "Read": true,
        "Create": true,
        "Update": true,
        "Delete": true
      },
      "Announcements": {
        "Read": true,
        "Create": true,
        "Update": true,
        "Delete": true
      }
    }
  }
}
```

### Permission Service

- **Service**: `SupportPermissionService`
- **Location**: `SimpleCRUD/Services/Support/SupportPermissionService.cs`
- **Usage**: Injected into pages and components to check permissions
- **Method**: `GetPermissionsAsync(ClaimsPrincipal user)` returns permission flags based on user's `AccessLevelId`

### Access Control Rules

#### User (Tenant) Rules

- **Tickets**:

  - Can create tickets about their own issues
  - Can read ONLY their own tickets (`CreatedByUserId` or `RelatedUserId`)
  - Can post messages on their own tickets
  - Cannot see internal notes (`IsInternal = 1`)
  - Cannot change status/priority/category/assignment or archive tickets
  - Can edit ticket if no admin has commented yet
  - Can mark ticket as resolved or soft-delete if not needed

- **Announcements**:
  - Read-only access
  - Can see announcements for their building and global announcements
  - Cannot create/update/archive announcements or add updates

#### Admin Rules

- **Tickets**:

  - Full CRUD access (based on permissions)
  - Can see all tickets with filtering
  - Can see internal notes
  - Can assign tickets to admins
  - Can convert tickets to announcements

- **Announcements**:
  - Full CRUD access (based on permissions)
  - Can create announcements from tickets
  - Can add updates to announcements
  - Can archive/unarchive announcements

## Key Features

### Tickets

1. **User Features**:

   - Create tickets with Title, Description, Category, Priority
   - View own tickets with status and priority
   - Add messages to own tickets
   - Mark tickets as resolved
   - Soft-delete tickets

2. **Admin Features**:
   - View all tickets with filtering (Building, Status, Priority, Search)
   - Update ticket details (Status, Priority, Category, Assignment)
   - Add messages (public or internal notes)
   - Assign tickets to admins
   - Archive tickets
   - Convert tickets to announcements

### Announcements

1. **User Features**:

   - View announcements for their building and global announcements
   - View announcement timeline/updates

2. **Admin Features**:
   - Create announcements (Building or Global scope)
   - Edit announcements
   - Add updates to announcements
   - Archive/unarchive announcements
   - Convert tickets to announcements

## Data Access

All database access is performed via:

- **Dapper** through the `ICRUD<T>` repository pattern
- **Stored Procedures** in the `support` schema
- **Handlers** in `SimpleCRUD.Engine/Support/` that wrap stored procedure calls

## UI/UX Patterns

The implementation follows existing application patterns:

- **Toast Notifications**: Success/error messages via `ToastService`
- **Pagination**: Server-side paging for lists
- **Filtering**: Status, Priority, Building, Search filters
- **Modals**: Confirmation modals for destructive actions
- **Access Control**: `AccessLevelView` component for page-level protection
- **Permission Checks**: UI elements hidden/disabled based on permissions

## Navigation

Support links are added to the side menu (`AuthorizedMenu.razor`):

- **User Links** (shown if user has `Tickets.Read` or `Announcements.Read`):

  - "My Tickets" → `/support/my-tickets`
  - "Announcements" → `/support/announcements`

- **Admin Links** (shown if admin has any update/delete/create permissions):
  - "Manage Tickets" → `/support/admin/tickets`
  - "Manage Announcements" → `/support/admin/announcements`

## Configuration Points

### 1. Permission Configuration

**File**: `SimpleCRUD/appsettings.json`
**Section**: `SupportPermissions`
**Action**: Modify permission flags for User/Admin roles

### 2. Access Level Assignment

**File**: Database `dbo.AspNetUsers` table
**Column**: `AccessLevelId`
**Values**:

- 1 = User (tenant)
- 2 = Admin
- 3 = SuperAdmin
- 4 = System

### 3. Building Assignment

**File**: Database `dbo.AspNetUsers` table
**Column**: `BuildingId`
**Action**: Assign users to buildings for building-scoped announcements

## Testing Checklist

- [ ] User can create tickets
- [ ] User can view only their own tickets
- [ ] User can add messages to their tickets
- [ ] User cannot see internal notes
- [ ] User can mark tickets as resolved
- [ ] Admin can view all tickets
- [ ] Admin can filter tickets
- [ ] Admin can update ticket details
- [ ] Admin can assign tickets
- [ ] Admin can add internal notes
- [ ] Admin can archive tickets
- [ ] Admin can convert tickets to announcements
- [ ] User can view announcements for their building
- [ ] User can view global announcements
- [ ] Admin can create announcements
- [ ] Admin can edit announcements
- [ ] Admin can add updates to announcements
- [ ] Admin can archive announcements
- [ ] Permissions are enforced server-side
- [ ] UI elements are hidden/disabled based on permissions

## Notes

1. **No Breaking Changes**: The implementation does not modify existing permissions or behavior outside the Support module.

2. **Idempotent SQL**: All database scripts are idempotent and safe to rerun.

3. **Scalability**: The system is designed to handle 200+ flats with server-side paging and filtering.

4. **Soft Deletes**: Tickets and announcements use `IsArchived` flags for soft deletion.

5. **Internal Notes**: Ticket messages can be marked as internal (`IsInternal = 1`) and are hidden from users.

6. **Ticket-to-Announcement Conversion**: Admins can convert tickets to announcements, linking them via `AnnouncementId` on the ticket.

## Future Enhancements

Potential future improvements:

- Email notifications for ticket updates
- Ticket assignment notifications
- Announcement read tracking
- Ticket priority escalation
- Ticket SLA tracking
- Bulk operations for admins
- Ticket templates
- File attachments
