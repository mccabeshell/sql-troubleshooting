--Version 1.1 (Added cross apply to sys.index_columns to get index col cnt & included col cnt)
--SET STATISTICS IO ON
SELECT
	f.name AS FileGroupName,
	DB_NAME(s.database_id) + '.' + SCHEMA_NAME(o.Schema_ID) + '.' + OBJECT_NAME(s.[object_id]) AS TableName,
	i.index_id AS IndexID,
	i.name AS IndexName,
	i.type_desc,
	i.fill_factor,
	p.[data_compression_desc],
	8 * SUM(a.used_pages) / 1024 AS [Indexsize(MB)],
	SUM(a.used_pages) AS UsedPages,
	s.user_updates AS [UserUpdates],
	s.user_seeks + s.user_scans + s.user_lookups AS [UserUsage],
	s.system_seeks + s.system_scans + s.system_lookups AS [SystemUsage]
	, CASE WHEN app.IndexCols IS NULL THEN 0 ELSE app.IndexCols END AS IndexCols
	, CASE WHEN app.IncludedCols IS NULL THEN 0 ELSE app.IncludedCols END AS IncludedCols
FROM sys.indexes AS i
	INNER JOIN sys.dm_db_index_usage_stats AS s ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id AND s.database_id = DB_ID()
	CROSS APPLY(SELECT COUNT(c.is_included_column) - SUM(CAST(c.is_included_column AS tinyint)) AS IndexCols, SUM(CAST(c.is_included_column AS tinyint)) AS IncludedCols
		FROM sys.index_columns AS c WHERE i.object_id = c.object_id and i.index_id = c.index_id) AS app
	INNER JOIN sys.objects AS o ON i.object_id = O.object_id
	INNER JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
	INNER JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
	INNER JOIN sys.filegroups AS f ON i.data_space_id = f.data_space_id
WHERE
	   OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
	   --AND s.database_id = DB_ID('MPPNews')
	   --AND i.type = 1 --0=Heap, 1=Clustered, 2=NonClustered
	   --AND i.Name = 'IX_tArticle_intAgreementId_dteProcessed_bitDisabled_Includes29'
	   --AND OBJECT_NAME(s.[object_id]) = 'tMPPSource'
	   --AND (i.type = 1 AND (i.fill_factor > 0 AND i.fill_factor < 100))
GROUP BY	f.name, s.database_id, o.Schema_ID, s.[object_id], i.index_id, i.name, i.fill_factor, i.type_desc,p.[data_compression_desc],
			s.user_updates,s.system_seeks,s.system_scans,s.system_lookups,s.user_seeks,s.user_scans,s.user_lookups,app.IndexCols, app.IncludedCols
----HAVING 8 * SUM(a.used_pages) > 1000000
ORDER BY UserUsage
GO
