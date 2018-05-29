USE [master]
GO

PRINT N'/*** Drop Logins on ''' + CAST(SERVERPROPERTY ('MachineName') AS nvarchar) + N'\' + CAST(SERVERPROPERTY ('InstanceName') AS nvarchar) + N''' Script generated on ' + CONVERT (varchar, GETDATE()) + N' ***/'
PRINT N'/*** WARNING: Double-check Groups before dropping them. ***/'
PRINT N''

CREATE TABLE #dbusers
( 
  sid VARBINARY(85)
);
GO

EXEC sp_MSforeachdb 
  'insert #dbusers select sid from [?].sys.database_principals where type <> ''R''';
GO

DECLARE @name nvarchar(128), @type char(1);
DECLARE logins_cursor CURSOR FOR
    SELECT p.name, p.type
    FROM   sys.server_principals AS p
	   INNER JOIN sys.syslogins AS l ON p.sid = l.sid
    WHERE  p.sid IN (   SELECT sid 
				    FROM   sys.server_principals 
				    WHERE  TYPE <> 'R' 
					   AND name NOT LIKE ('##%##') AND name NOT LIKE ('NT Service%') AND name NOT LIKE ('BUILTIN%')
				    EXCEPT 
				    SELECT DISTINCT sid 
				    FROM   #dbusers) 
    AND l.sysadmin = 0 AND l.securityadmin = 0 AND l.serveradmin = 0 AND l.setupadmin = 0
    AND l.processadmin = 0 AND l.diskadmin = 0 AND l.dbcreator = 0 AND l.bulkadmin = 0
    ORDER BY p.type_desc, p.name;

OPEN logins_cursor

FETCH NEXT FROM logins_cursor INTO @name, @type

    WHILE @@FETCH_STATUS = 0
    BEGIN

	   IF @type = 'G'
		  BEGIN
			 PRINT N'DROP LOGIN [' + @name + N']'
		  END
	   ELSE
		  BEGIN
			 PRINT N'ALTER LOGIN [' + @name + N'] DISABLE'
		  END
	   
	   PRINT N'GO'

	   FETCH NEXT FROM logins_cursor INTO @name, @type

    END
GO

CLOSE logins_cursor;
DEALLOCATE logins_cursor;
GO

DROP TABLE #dbusers;
GO
