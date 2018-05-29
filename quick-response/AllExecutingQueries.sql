--Taken from SQL Server DMVs (Manning Book) & adapted by James
--This shows all queries currently running, with current state, running time, cpu time & what it waiting on (if at all)
--This includes queries Running, in the Runnable Queue or in the Wait Queue
SELECT
	er.status
	, es.session_id --session_id less than 50 is a system session
	, es.host_name, es.login_name, es.program_name, DB_NAME(database_id) AS DBName
	, er.start_time, er.total_elapsed_time, er.cpu_time, er.logical_reads, er.open_transaction_count
	, er.wait_type, er.last_wait_type, er.blocking_session_id
	, er.percent_complete, er.command
	, SUBSTRING (qt.text,(er.statement_start_offset/2) + 1, ((CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 ELSE er.statement_end_offset
		END - er.statement_start_offset)/2) + 1) AS [Individual Query]
	, qt.text AS [Parent Query]
	, qp.query_plan
FROM sys.dm_exec_requests AS er
	INNER JOIN sys.dm_exec_sessions AS es ON es.session_id = er.session_id
	CROSS APPLY sys.dm_exec_sql_text( er.sql_handle ) AS qt
	CROSS APPLY sys.dm_exec_query_plan( er.plan_handle ) qp
	WHERE es.is_user_process = 1
	   AND es.session_Id NOT IN (@@SPID)
	   AND es.session_id > 50
	   --AND er.status IN ('running','runnable')
	   --AND es.[host_name] = 'VMWIN10-JAMES'
	   --AND DB_NAME(database_id) IN ('DB1','DB2')
--ORDER BY es.session_id --session_id less than 50 is a system session
ORDER BY session_id, status, cpu_time DESC

-- Individual session
SELECT * FROM sys.dm_exec_sessions AS es
LEFT OUTER JOIN sys.dm_exec_requests AS er ON es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS qt
WHERE es.session_id = 557
