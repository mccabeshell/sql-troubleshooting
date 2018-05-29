SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT TOP 100
	DB_NAME() AS DatabaseName
	, SCHEMA_NAME(o.Schema_ID) AS SchemaName
	, OBJECT_NAME(s.[object_id]) AS [TableName]
	, i.name AS IndexName
	, s.user_updates
	, s.system_seeks + s.system_scans + s.system_lookups AS [System usage]
	, s.user_seeks + s.user_scans + s.user_lookups AS [User usage]
FROM sys.dm_db_index_usage_stats s
	INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
	INNER JOIN sys.objects o ON i.object_id = O.object_id
WHERE s.database_id = DB_ID()
	AND OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
	AND s.user_seeks < 10
	AND s.user_scans < 10
	AND s.user_lookups < 10
	AND i.name IS NOT NULL
	--AND i.name not like 'PK%'
	--AND OBJECT_NAME(s.[object_id]) = 'tTable'
ORDER BY [tablename] --s.user_seeks + s.user_scans + s.user_lookups
