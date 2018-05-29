select i.[object_id], o.[name] AS [TableName], i.[name] AS [IndexName], i.[index_id], i.[type], i.[type_desc], i.[data_space_id], f.[name] AS [FileGroupName],(SUM(s.[used_page_count]) * 8)/1024 AS IndexSizeMB
from sys.indexes AS i
inner join sys.filegroups AS f ON i.data_space_id = f.data_space_id
INNER JOIN sys.objects AS o ON i.[object_id] = o.[object_id]
INNER JOIN sys.dm_db_partition_stats AS s ON s.[object_id] = i.[object_id] AND s.[index_id] = i.[index_id]
WHERE o.[type] = 'U'
--AND o.[name] = 'TableName'
--AND i.[type] = 2
--AND i.[data_space_id] NOT IN (1,4)
GROUP BY i.[object_id], o.[name], i.[name], i.[index_id], i.[type], i.[type_desc], i.[data_space_id], f.[name]
ORDER BY IndexSizeMB desc, o.name, i.name;
