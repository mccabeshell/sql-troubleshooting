USE [master];
GO
BACKUP DATABASE [DB1] --Change the database name
    TO DISK = '\\uncpath\DB1.bak' --Change this Path
	WITH COPY_ONLY, CHECKSUM, COMPRESSION;
GO

USE [master];
GO
RESTORE VERIFYONLY
	FROM DISK = '\\uncpath\DB1.bak' --Change this Path
GO

--------------------------------------
-- Create scripts for all Databases --
--------------------------------------

EXEC sp_MSforeachdb N'
IF ''?'' NOT IN (''tempdb'',''model'')
DECLARE @DB nvarchar(128), @Today varchar(10)
SET @DB = UPPER(''?'')
SET @Today = CAST(CAST(SYSDATETIME() AS date) AS VARCHAR)
PRINT
''BACKUP DATABASE [?] TO DISK = ''''\\uncpath\'' + @DB + ''\?_'' + @Today + ''.bak''''
	WITH COPY_ONLY, COMPRESSION, CHECKSUM;
GO
RESTORE VERIFYONLY
	FROM DISK = ''''\\uncpath\'' + @DB + ''\?_'' + @Today + ''.bak''''
GO'''


EXEC sp_MSforeachdb N'
IF ''?'' NOT IN (''tempdb'',''model'')
PRINT
''BACKUP DATABASE [?] TO DISK = ''''\\uncpath\?_'' + CAST(CAST(SYSDATETIME() AS date) AS VARCHAR) + ''.bak''''
	WITH COPY_ONLY, COMPRESSION, CHECKSUM;
GO
RESTORE VERIFYONLY
	FROM DISK = ''''\\uncpath\?_'' + CAST(CAST(SYSDATETIME() AS date) AS VARCHAR) + ''.bak''''
GO'''
