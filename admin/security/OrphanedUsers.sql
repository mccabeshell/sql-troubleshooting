DECLARE @principal_id int, @username nvarchar(128);
DECLARE @DBName nvarchar(128) = DB_NAME();
DECLARE user_cursor CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
    SELECT principal_id, name
    FROM sys.database_principals AS dp
    WHERE principal_id > 4 --Ignore built-in SQL users
    AND ( SELECT sid FROM sys.syslogins AS sl WHERE sl.sid = dp.sid ) IS NULL
    AND type IN ('S','U','G')
    --AND name NOT IN ('devjira') --Change this to exclude users you want to keep
    ;


OPEN user_cursor;

IF @@CURSOR_ROWS <> 0
    BEGIN
	   PRINT N'/*** Drop Users in ''' + DB_NAME() + N''' Script generated on ' + CONVERT (varchar, GETDATE()) + N' on ' + @@SERVERNAME + N' ***/'
	   PRINT N'/*** WARNING: This script may contain Drop Schema statements, you must verify ok to drop before running this script. ***/'
	   PRINT N''
	   PRINT N'USE [' + @DBName + N']'
	   PRINT N'GO'
	   PRINT N''
    END
ELSE
    BEGIN
	   PRINT N'No Orphaned Users found in ''' + DB_NAME() + N''' database as of ' + CONVERT (varchar, GETDATE()) + N' on ' + @@SERVERNAME
    END

FETCH NEXT FROM user_cursor INTO @principal_id, @username;

WHILE @@FETCH_STATUS = 0
    BEGIN
	   
	   -- First check if the user owns any schemas & create optional scripts for schemas --

	   DECLARE @schema nvarchar(128);
	   DECLARE schema_cursor CURSOR FOR
		  SELECT name
		  FROM sys.schemas
		  WHERE principal_id = @principal_id;

	   OPEN schema_cursor;

	   FETCH NEXT FROM schema_cursor INTO @schema;

	   WHILE @@FETCH_STATUS = 0
		  BEGIN

			 PRINT N'/* WARNING: This user owns a schema - Please read the scripts below & select the appropriate action*/'
			 PRINT N'-- Use this statement to find objects under the schema: SELECT * FROM sys.objects WHERE schema_id = SCHEMA_ID(''' + @schema + N''') --'
			 PRINT N'-- If the schema should not exist, then run the DROP SCHEMA Statement --'
			 PRINT N'/*'
			 PRINT N'IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE schema_id = SCHEMA_ID(''' + @schema + N'''))'
			 PRINT N'BEGIN'
			 PRINT N'	   DROP SCHEMA [' + @schema + N'];'
			 PRINT N'END;'
			 PRINT N'GO'
			 PRINT N'*/'
			 PRINT N'-- If the schema should exist but should be owned by another principal, then use ALTER AUTHORIZATION --'
			 PRINT N'-- First you must check the below script to ensure it is altering the schema to a valid/desired principal --'
			 PRINT N'--ALTER AUTHORIZATION'
			 PRINT N'--ON SCHEMA::' + @schema + N' TO ' + @schema
			 PRINT N'--GO'

			 FETCH NEXT FROM schema_cursor INTO @schema

		  END;
		  
	   CLOSE schema_cursor;
	   DEALLOCATE schema_cursor;

	   -- Now create text to drop the user --

	   PRINT N'DROP USER [' + @username + N']';
	   PRINT N'GO';

	   FETCH NEXT FROM user_cursor INTO @principal_id, @username;

    END;

CLOSE user_cursor;
DEALLOCATE user_cursor;
GO
