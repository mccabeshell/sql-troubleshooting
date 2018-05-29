CREATE TABLE #TempSizesTable (object_id int, DatabaseName nvarchar(128), TableName NVARCHAR(128), CreatedDate datetime
		, ModifiedDate datetime, NumRows bigint, TotalSpaceGB int, UsedSpaceGB int, TotalSpaceMB int, UsedSpaceMB int, UnusedSpaceMB int)


EXEC sp_MSforeachdb
'USE [?]
INSERT INTO #TempSizesTable
SELECT 
	t.object_id, ''?'' AS DatabaseName, t.NAME AS TableName, t.create_date, t.modify_date, p.rows AS RowCounts,
	((SUM(a.total_pages) * 8) / 1024) / 1024 AS TotalSpaceGB,  ((SUM(a.used_pages) * 8) / 1024) / 1024 AS UsedSpaceGB,
    SUM(a.total_pages) * 0.008 AS TotalSpaceMB, SUM(a.used_pages) * 0.008 AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 0.008 AS UnusedSpaceMB
FROM sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    t.NAME NOT LIKE ''dt%'' AND t.is_ms_shipped = 0 AND i.OBJECT_ID > 255 
GROUP BY 
    t.object_id, t.Name,t.create_date,t.modify_date, p.Rows
ORDER BY t.Name'

SELECT * FROM #TempSizesTable ORDER BY TotalSpaceMB DESC

DROP TABLE #TempSizesTable
