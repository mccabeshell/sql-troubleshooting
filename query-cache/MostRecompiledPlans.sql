SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT TOP 20
qs.plan_generation_num
, qs.total_elapsed_time
, qs.execution_count
, SUBSTRING (qt.text,(qs.statement_start_offset/2) + 1,((
	CASE WHEN qs.statement_end_offset = -1
	THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
	ELSE qs.statement_end_offset
	END - qs.statement_start_offset)/2) + 1) AS [Individual Query]
, qt.text AS [Parent Query]
, DB_NAME(qt.dbid) AS DatabaseName
, qs.creation_time
, qs.last_execution_time
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
ORDER BY plan_generation_num DESC;
