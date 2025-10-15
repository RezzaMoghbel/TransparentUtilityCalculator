-- Migration Script: Convert DirectDebits ProviderName to UtilityProviderId FK
-- This script migrates existing DirectDebits data to use the new UtilityProviders FK structure
-- Run this script AFTER updating the stored procedures and application code

PRINT 'Starting DirectDebits migration to UtilityProviders FK...';

BEGIN TRANSACTION;

BEGIN TRY
    -- Step 1: Add new UtilityProviderId column (if not exists)
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('[utility].[DirectDebits]') AND name = 'UtilityProviderId')
    BEGIN
        PRINT 'Adding UtilityProviderId column...';
        ALTER TABLE [utility].[DirectDebits] ADD [UtilityProviderId] INT NULL;
        PRINT 'UtilityProviderId column added successfully.';
    END
    ELSE
    BEGIN
        PRINT 'UtilityProviderId column already exists.';
    END

    -- Step 2: Insert unique provider names into UtilityProviders (if not already exist)
    PRINT 'Migrating unique provider names to UtilityProviders table...';
    
    INSERT INTO [dbo].[UtilityProviders] ([Name], [IsActive])
    SELECT DISTINCT [ProviderName], 1
    FROM [utility].[DirectDebits]
    WHERE [ProviderName] IS NOT NULL
      AND [ProviderName] != ''
      AND [ProviderName] NOT IN (SELECT [Name] FROM [dbo].[UtilityProviders]);
    
    DECLARE @NewProviders INT = @@ROWCOUNT;
    PRINT CONCAT('Inserted ', @NewProviders, ' new providers into UtilityProviders table.');

    -- Step 3: Update DirectDebits with UtilityProviderId
    PRINT 'Updating DirectDebits with UtilityProviderId...';
    
    UPDATE dd
    SET dd.[UtilityProviderId] = up.[Id]
    FROM [utility].[DirectDebits] dd
    INNER JOIN [dbo].[UtilityProviders] up ON dd.[ProviderName] = up.[Name]
    WHERE dd.[ProviderName] IS NOT NULL
      AND dd.[ProviderName] != '';
    
    DECLARE @UpdatedRecords INT = @@ROWCOUNT;
    PRINT CONCAT('Updated ', @UpdatedRecords, ' DirectDebits records with UtilityProviderId.');

    -- Step 4: Show summary of migration
    PRINT 'Migration Summary:';
    PRINT CONCAT('- Total DirectDebits records: ', (SELECT COUNT(*) FROM [utility].[DirectDebits]));
    PRINT CONCAT('- Records with ProviderName: ', (SELECT COUNT(*) FROM [utility].[DirectDebits] WHERE [ProviderName] IS NOT NULL AND [ProviderName] != ''));
    PRINT CONCAT('- Records now with UtilityProviderId: ', (SELECT COUNT(*) FROM [utility].[DirectDebits] WHERE [UtilityProviderId] IS NOT NULL));
    PRINT CONCAT('- Records without provider (NULL): ', (SELECT COUNT(*) FROM [utility].[DirectDebits] WHERE [UtilityProviderId] IS NULL));

    -- Step 5: Add FK constraint
    PRINT 'Adding foreign key constraint...';
    
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_DirectDebits_UtilityProviders')
    BEGIN
        ALTER TABLE [utility].[DirectDebits]
        ADD CONSTRAINT [FK_DirectDebits_UtilityProviders] 
            FOREIGN KEY ([UtilityProviderId]) REFERENCES [dbo].[UtilityProviders] ([Id]);
        PRINT 'Foreign key constraint added successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Foreign key constraint already exists.';
    END

    -- Step 6: Drop old columns (COMMENTED OUT FOR SAFETY - UNCOMMENT WHEN READY)
    /*
    PRINT 'Dropping old columns...';
    ALTER TABLE [utility].[DirectDebits] DROP COLUMN [ProviderName];
    ALTER TABLE [utility].[DirectDebits] DROP COLUMN [PeriodMonth];
    PRINT 'Old columns dropped successfully.';
    */

    PRINT 'Migration completed successfully!';
    PRINT 'IMPORTANT: Uncomment the column drop section above when ready to remove old columns.';
    
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    
    PRINT 'Migration failed!';
    PRINT CONCAT('Error: ', @ErrorMessage);
    PRINT 'Transaction rolled back.';
    
    THROW;
END CATCH;

-- Verification queries (run these after migration to verify results)
PRINT 'Verification queries:';
PRINT '1. Check DirectDebits with providers:';
SELECT COUNT(*) as 'DirectDebits with providers' 
FROM [utility].[DirectDebits] dd 
INNER JOIN [dbo].[UtilityProviders] up ON dd.[UtilityProviderId] = up.[Id];

PRINT '2. Check DirectDebits without providers:';
SELECT COUNT(*) as 'DirectDebits without providers' 
FROM [utility].[DirectDebits] 
WHERE [UtilityProviderId] IS NULL;

PRINT '3. Sample of migrated data:';
SELECT TOP 5 
    dd.[Id], 
    dd.[Amount], 
    dd.[PaymentDate], 
    up.[Name] as 'ProviderName',
    dd.[PaymentStatus]
FROM [utility].[DirectDebits] dd
LEFT JOIN [dbo].[UtilityProviders] up ON dd.[UtilityProviderId] = up.[Id]
ORDER BY dd.[Id] DESC;

