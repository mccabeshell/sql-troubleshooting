SELECT 
	t.object_id, t.NAME AS TableName, t.create_date, t.modify_date, MAX(p.rows) AS RowCounts,
     (SUM(a.total_pages) * 8) / 1024 AS TotalSpaceMB, ((SUM(a.total_pages) * 8) / 1024) / 1024 AS TotalSpaceGB,
     (SUM(a.used_pages) * 8) / 1024 AS UsedSpaceMB, ((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024 AS UnusedSpaceMB
FROM sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    i.OBJECT_ID > 255
    AND t.is_ms_shipped = 0 --Exclude systems tables
    --AND t.NAME NOT LIKE 'dt%'
    --AND create_date < GETDATE() - 180
GROUP BY 
    t.object_id, t.Name,t.create_date,t.modify_date
ORDER BY TotalSpaceMB DESC
