/****** TechNet:  http://technet.microsoft.com/en-us/library/ms179881.aspx ******/
--------------------------------------------------------------------------------------------
--This has a full list of connections with more info (good for filtering in WHERE clause) --
--------------------------------------------------------------------------------------------
SELECT N'--kill ' + cast(spid as nvarchar(10)), SPID,Status,Loginame,Program_Name,HostName,DB_NAME(dbid) AS DBName
		,Cmd,CPU AS 'CPUTime',Physical_IO AS DiskIO,Blocked,LastWaitType,WaitResource
FROM sys.sysprocesses AS p
WHERE dbid > 0 AND spid > 50 AND spid <> @@SPID
	--AND [program_name] LIKE 'Microsoft SQL Server Management Studio%'
	--AND hostname LIKE 'vmmpplus09%'
	--AND loginame like 'PRECISE-MEDIA\abdulm.helpdesk%'
	--AND [status] = 'running' --and [status] <> 'Sleeping'
	--AND DB_NAME(dbid) LIKE 'SpotlightPlaybackDatabase'
	--AND spid in (401)
	--AND program_name like 'sql server profiler%'
ORDER BY spid DESC


--------------------------------------
-- Count of Connections by Database --
--------------------------------------

SELECT DB_NAME(dbid) as DBName, 
       COUNT(dbid) as NumberOfConnections
FROM sys.sysprocesses s
WHERE dbid > 0 AND spid > 50 --and loginame like '%amoulton%'
GROUP BY DB_NAME(dbid)

--------------------------------------------------------
-- Quick one to count connections (gives an overview) --
--------------------------------------------------------

SELECT SPID, s.sid, DB_NAME(dbid) as DBName, 
       COUNT(dbid) as NumberOfConnections, 
       loginame as LoginName
FROM sys.sysprocesses s
WHERE dbid > 0 AND spid > 50 --and loginame like '%amoulton%'
GROUP BY SPID, s.sid, dbid, loginame
ORDER BY DBName,COUNT(dbid) DESC
