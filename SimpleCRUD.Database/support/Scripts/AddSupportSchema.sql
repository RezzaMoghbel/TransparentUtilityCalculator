/* ============================================================================
   Script: AddSupportSchema.sql
   Purpose: Creates the support schema for ticketing + announcements.
   Notes:   - Idempotent (safe to rerun).
            - Requires existing dbo.AspNetUsers and dbo.Buildings tables.
============================================================================ */

/* 0. Create schema --------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'support')
    EXEC('CREATE SCHEMA [support] AUTHORIZATION [dbo];');
GO

/* 1. Lookup Tables --------------------------------------------------------- */
IF OBJECT_ID('support.IssueCategory', 'U') IS NULL
BEGIN
    CREATE TABLE support.IssueCategory
    (
        Id   INT IDENTITY(1,1) CONSTRAINT PK_IssueCategory PRIMARY KEY,
        Code NVARCHAR(50)  NOT NULL CONSTRAINT UQ_IssueCategory_Code UNIQUE,
        Name NVARCHAR(100) NOT NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM support.IssueCategory WHERE Code = 'MAINTENANCE')
    INSERT INTO support.IssueCategory (Code, Name) VALUES ('MAINTENANCE', 'Maintenance / Repairs');
IF NOT EXISTS (SELECT 1 FROM support.IssueCategory WHERE Code = 'BILLING')
    INSERT INTO support.IssueCategory (Code, Name) VALUES ('BILLING', 'Billing & Payments');
IF NOT EXISTS (SELECT 1 FROM support.IssueCategory WHERE Code = 'USAGE')
    INSERT INTO support.IssueCategory (Code, Name) VALUES ('USAGE', 'Usage & Meter Readings');
IF NOT EXISTS (SELECT 1 FROM support.IssueCategory WHERE Code = 'GENERAL')
    INSERT INTO support.IssueCategory (Code, Name) VALUES ('GENERAL', 'General Question');
IF NOT EXISTS (SELECT 1 FROM support.IssueCategory WHERE Code = 'OTHER')
    INSERT INTO support.IssueCategory (Code, Name) VALUES ('OTHER', 'Other');
GO

IF OBJECT_ID('support.TicketStatus', 'U') IS NULL
BEGIN
    CREATE TABLE support.TicketStatus
    (
        Id   INT IDENTITY(1,1) CONSTRAINT PK_TicketStatus PRIMARY KEY,
        Code NVARCHAR(50)  NOT NULL CONSTRAINT UQ_TicketStatus_Code UNIQUE,
        Name NVARCHAR(100) NOT NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM support.TicketStatus WHERE Code = 'OPEN')
    INSERT INTO support.TicketStatus (Code, Name) VALUES ('OPEN', 'Open');
IF NOT EXISTS (SELECT 1 FROM support.TicketStatus WHERE Code = 'IN_PROGRESS')
    INSERT INTO support.TicketStatus (Code, Name) VALUES ('IN_PROGRESS', 'In Progress');
IF NOT EXISTS (SELECT 1 FROM support.TicketStatus WHERE Code = 'RESOLVED')
    INSERT INTO support.TicketStatus (Code, Name) VALUES ('RESOLVED', 'Resolved');
IF NOT EXISTS (SELECT 1 FROM support.TicketStatus WHERE Code = 'CLOSED')
    INSERT INTO support.TicketStatus (Code, Name) VALUES ('CLOSED', 'Closed');
GO

IF OBJECT_ID('support.TicketPriority', 'U') IS NULL
BEGIN
    CREATE TABLE support.TicketPriority
    (
        Id   INT IDENTITY(1,1) CONSTRAINT PK_TicketPriority PRIMARY KEY,
        Code NVARCHAR(50)  NOT NULL CONSTRAINT UQ_TicketPriority_Code UNIQUE,
        Name NVARCHAR(100) NOT NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM support.TicketPriority WHERE Code = 'LOW')
    INSERT INTO support.TicketPriority (Code, Name) VALUES ('LOW', 'Low');
IF NOT EXISTS (SELECT 1 FROM support.TicketPriority WHERE Code = 'MEDIUM')
    INSERT INTO support.TicketPriority (Code, Name) VALUES ('MEDIUM', 'Medium');
IF NOT EXISTS (SELECT 1 FROM support.TicketPriority WHERE Code = 'HIGH')
    INSERT INTO support.TicketPriority (Code, Name) VALUES ('HIGH', 'High');
IF NOT EXISTS (SELECT 1 FROM support.TicketPriority WHERE Code = 'CRITICAL')
    INSERT INTO support.TicketPriority (Code, Name) VALUES ('CRITICAL', 'Critical');
GO

IF OBJECT_ID('support.AnnouncementScope', 'U') IS NULL
BEGIN
    CREATE TABLE support.AnnouncementScope
    (
        Id   INT IDENTITY(1,1) CONSTRAINT PK_AnnouncementScope PRIMARY KEY,
        Code NVARCHAR(50)  NOT NULL CONSTRAINT UQ_AnnouncementScope_Code UNIQUE,
        Name NVARCHAR(100) NOT NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM support.AnnouncementScope WHERE Code = 'BUILDING')
    INSERT INTO support.AnnouncementScope (Code, Name) VALUES ('BUILDING', 'Single building');
IF NOT EXISTS (SELECT 1 FROM support.AnnouncementScope WHERE Code = 'GLOBAL')
    INSERT INTO support.AnnouncementScope (Code, Name) VALUES ('GLOBAL', 'All buildings / global');
GO

/* 2. Ticket Table ---------------------------------------------------------- */
IF OBJECT_ID('support.Ticket', 'U') IS NULL
BEGIN
    CREATE TABLE support.Ticket
    (
        Id                INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Ticket PRIMARY KEY,
        Title             NVARCHAR(200)  NOT NULL,
        Description       NVARCHAR(MAX)  NOT NULL,
        StatusId          INT            NOT NULL,
        PriorityId        INT            NOT NULL,
        CategoryId        INT            NOT NULL,
        CreatedByUserId   NVARCHAR(450)  NOT NULL,
        AssignedToUserId  NVARCHAR(450)  NULL,
        RelatedUserId     NVARCHAR(450)  NULL,
        BuildingId        INT            NOT NULL,
        AnnouncementId    INT            NULL,
        CreatedAt         DATETIME2      NOT NULL CONSTRAINT DF_Ticket_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt         DATETIME2      NULL,
        ResolvedAt        DATETIME2      NULL,
        IsArchived        BIT            NOT NULL CONSTRAINT DF_Ticket_IsArchived DEFAULT 0,
        CONSTRAINT FK_Ticket_Status       FOREIGN KEY (StatusId)     REFERENCES support.TicketStatus (Id),
        CONSTRAINT FK_Ticket_Priority     FOREIGN KEY (PriorityId)   REFERENCES support.TicketPriority (Id),
        CONSTRAINT FK_Ticket_Category     FOREIGN KEY (CategoryId)   REFERENCES support.IssueCategory (Id),
        CONSTRAINT FK_Ticket_CreatedBy    FOREIGN KEY (CreatedByUserId) REFERENCES dbo.AspNetUsers (Id),
        CONSTRAINT FK_Ticket_AssignedTo   FOREIGN KEY (AssignedToUserId) REFERENCES dbo.AspNetUsers (Id),
        CONSTRAINT FK_Ticket_RelatedUser  FOREIGN KEY (RelatedUserId) REFERENCES dbo.AspNetUsers (Id),
        CONSTRAINT FK_Ticket_Building     FOREIGN KEY (BuildingId)   REFERENCES dbo.Buildings (Id)
        -- Announcement FK added after support.Announcement exists
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Ticket_CreatedByUserId' AND object_id = OBJECT_ID('support.Ticket'))
    CREATE NONCLUSTERED INDEX IX_Ticket_CreatedByUserId ON support.Ticket (CreatedByUserId);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Ticket_AssignedToUserId' AND object_id = OBJECT_ID('support.Ticket'))
    CREATE NONCLUSTERED INDEX IX_Ticket_AssignedToUserId ON support.Ticket (AssignedToUserId);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Ticket_BuildingId' AND object_id = OBJECT_ID('support.Ticket'))
    CREATE NONCLUSTERED INDEX IX_Ticket_BuildingId ON support.Ticket (BuildingId);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Ticket_StatusId' AND object_id = OBJECT_ID('support.Ticket'))
    CREATE NONCLUSTERED INDEX IX_Ticket_StatusId ON support.Ticket (StatusId);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Ticket_CreatedAt' AND object_id = OBJECT_ID('support.Ticket'))
    CREATE NONCLUSTERED INDEX IX_Ticket_CreatedAt ON support.Ticket (CreatedAt DESC);
GO

/* 3. TicketMessage --------------------------------------------------------- */
IF OBJECT_ID('support.TicketMessage', 'U') IS NULL
BEGIN
    CREATE TABLE support.TicketMessage
    (
        Id              INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_TicketMessage PRIMARY KEY,
        TicketId        INT            NOT NULL,
        Body            NVARCHAR(MAX)  NOT NULL,
        CreatedByUserId NVARCHAR(450)  NOT NULL,
        CreatedAt       DATETIME2      NOT NULL CONSTRAINT DF_TicketMessage_CreatedAt DEFAULT SYSUTCDATETIME(),
        IsInternal      BIT            NOT NULL CONSTRAINT DF_TicketMessage_IsInternal DEFAULT 0,
        CONSTRAINT FK_TicketMessage_Ticket FOREIGN KEY (TicketId)
            REFERENCES support.Ticket (Id) ON DELETE CASCADE,
        CONSTRAINT FK_TicketMessage_User FOREIGN KEY (CreatedByUserId)
            REFERENCES dbo.AspNetUsers (Id)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TicketMessage_TicketId' AND object_id = OBJECT_ID('support.TicketMessage'))
    CREATE NONCLUSTERED INDEX IX_TicketMessage_TicketId ON support.TicketMessage (TicketId, CreatedAt);
GO

/* 4. Announcement ---------------------------------------------------------- */
IF OBJECT_ID('support.Announcement', 'U') IS NULL
BEGIN
    CREATE TABLE support.Announcement
    (
        Id              INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Announcement PRIMARY KEY,
        Title           NVARCHAR(200)  NOT NULL,
        Body            NVARCHAR(MAX)  NOT NULL,
        CategoryId      INT            NULL,
        ScopeId         INT            NOT NULL,
        BuildingId      INT            NULL,
        SourceTicketId  INT            NULL,
        CreatedByUserId NVARCHAR(450)  NOT NULL,
        CreatedAt       DATETIME2      NOT NULL CONSTRAINT DF_Announcement_CreatedAt DEFAULT SYSUTCDATETIME(),
        PublishedAt     DATETIME2      NULL,
        IsActive        BIT            NOT NULL CONSTRAINT DF_Announcement_IsActive DEFAULT 1,
        IsArchived      BIT            NOT NULL CONSTRAINT DF_Announcement_IsArchived DEFAULT 0,
        CONSTRAINT FK_Announcement_Category   FOREIGN KEY (CategoryId)     REFERENCES support.IssueCategory (Id),
        CONSTRAINT FK_Announcement_Scope      FOREIGN KEY (ScopeId)       REFERENCES support.AnnouncementScope (Id),
        CONSTRAINT FK_Announcement_Building   FOREIGN KEY (BuildingId)    REFERENCES dbo.Buildings (Id),
        CONSTRAINT FK_Announcement_SourceTicket FOREIGN KEY (SourceTicketId) REFERENCES support.Ticket (Id),
        CONSTRAINT FK_Announcement_CreatedBy  FOREIGN KEY (CreatedByUserId) REFERENCES dbo.AspNetUsers (Id)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Announcement_BuildingId' AND object_id = OBJECT_ID('support.Announcement'))
    CREATE NONCLUSTERED INDEX IX_Announcement_BuildingId
        ON support.Announcement (BuildingId, ScopeId, CreatedAt DESC);
GO

/* 4b. Add FK from Ticket to Announcement (after both tables exist) --------- */
IF OBJECT_ID('support.Ticket', 'U') IS NOT NULL
   AND OBJECT_ID('support.Announcement', 'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Ticket_Announcement')
BEGIN
    ALTER TABLE support.Ticket
        ADD CONSTRAINT FK_Ticket_Announcement
            FOREIGN KEY (AnnouncementId) REFERENCES support.Announcement (Id);
END;
GO

/* 5. AnnouncementUpdate ---------------------------------------------------- */
IF OBJECT_ID('support.AnnouncementUpdate', 'U') IS NULL
BEGIN
    CREATE TABLE support.AnnouncementUpdate
    (
        Id               INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AnnouncementUpdate PRIMARY KEY,
        AnnouncementId   INT            NOT NULL,
        Body             NVARCHAR(MAX)  NOT NULL,
        CreatedByUserId  NVARCHAR(450)  NOT NULL,
        CreatedAt        DATETIME2      NOT NULL CONSTRAINT DF_AnnouncementUpdate_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AnnouncementUpdate_Announcement FOREIGN KEY (AnnouncementId)
            REFERENCES support.Announcement (Id) ON DELETE CASCADE,
        CONSTRAINT FK_AnnouncementUpdate_CreatedBy FOREIGN KEY (CreatedByUserId)
            REFERENCES dbo.AspNetUsers (Id)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AnnouncementUpdate_AnnouncementId' AND object_id = OBJECT_ID('support.AnnouncementUpdate'))
    CREATE NONCLUSTERED INDEX IX_AnnouncementUpdate_AnnouncementId
        ON support.AnnouncementUpdate (AnnouncementId, CreatedAt);
GO

/* End of script ----------------------------------------------------------- */

