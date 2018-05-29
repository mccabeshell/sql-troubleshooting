SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT *
FROM sys.procedures s
LEFT OUTER JOIN sys.dm_exec_procedure_stats d
ON s.object_id = d.object_id
WHERE is_ms_shipped = 0
	AND d.object_id IS NULL
	--AND name not like 'x%'
ORDER BY s.name
