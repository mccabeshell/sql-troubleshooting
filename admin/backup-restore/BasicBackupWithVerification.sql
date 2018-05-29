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
