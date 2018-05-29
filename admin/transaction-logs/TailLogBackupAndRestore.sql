EXEC sp_MSforeachdb N'
PRINT ''BACKUP LOG [?] TO DISK = N''''\\uncpath\Tail Log Backups\SQLSERVER\?.trn'''' WITH NORECOVERY;''';
GO

EXEC sp_MSforeachdb N'
PRINT ''RESTORE DATABASE [?] WITH RECOVERY;'''

RESTORE DATABASE [AdventureWorks2012] FROM DISK = N'full database backup' WITH NORECOVERY;
RESTORE DATABASE [AdventureWorks2012] FROM DISK = N'full_differential_backup' WITH NORECOVERY;
RESTORE LOG [AdventureWorks2012] FROM DISK = N'log_backup' WITH NORECOVERY;
--Repeat this restore-log step for each additional log backup.
RESTORE DATABASE [AdventureWorks2012] WITH RECOVERY;


--From MSDN
USE master;
--Create tail-log backup.
BACKUP LOG AdventureWorks2012 
TO DISK = 'Z:\SQLServerBackups\AdventureWorksFullRM.bak'  
   WITH NORECOVERY; 
GO
--Restore the full database backup (from backup set 1).
RESTORE DATABASE AdventureWorks2012 
  FROM DISK = 'Z:\SQLServerBackups\AdventureWorksFullRM.bak' 
  WITH FILE=1, 
    NORECOVERY;
GO

--Restore the regular log backup (from backup set 2).
RESTORE LOG AdventureWorks2012 
  FROM DISK = 'Z:\SQLServerBackups\AdventureWorksFullRM.bak' 
  WITH FILE=2, 
    NORECOVERY;
GO

--Restore the tail-log backup (from backup set 3).
RESTORE LOG AdventureWorks2012 
  FROM DISK = 'Z:\SQLServerBackups\AdventureWorksFullRM.bak'
  WITH FILE=3, 
    NORECOVERY;
GO
--recover the database:
RESTORE DATABASE AdventureWorks2012 WITH RECOVERY;
GO
