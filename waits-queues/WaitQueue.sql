--What is currently in the Wait Queue (dm_os_waiting_tasks)
USE [master];
GO
SELECT
	wt.session_id --session_id less than 50 is a system session
	, es.host_name
	, es.program_name
	, es.login_name
	--, USER_NAME(er.user_id) AS SQLUser
	, wt.wait_type
	, er.last_wait_type AS last_wait_type
	, wt.wait_duration_ms
	, wt.blocking_session_id --session_id less than 50 is a system session
	, esb.host_name AS blocking_host_name
	, esb.login_name AS blocking_login_name
	, wt.blocking_exec_context_id
	, resource_description
FROM sys.dm_os_waiting_tasks wt
INNER JOIN sys.dm_exec_sessions es ON wt.session_id = es.session_id 
INNER JOIN sys.dm_exec_requests er ON wt.session_id = er.session_id
LEFT OUTER JOIN sys.dm_exec_sessions esb ON wt.blocking_session_id = esb.session_id
WHERE es.is_user_process = 1  --Only show user processes (system processes often wait by design & should not be amended)
--AND es.host_name = 'PC-JAMES'
--and wt.blocking_session_id = 100
--AND wt.wait_type <> 'SLEEP_TASK'
--and es.login_name like 'mccabeshell'
--AND wt.session_id = 169
ORDER BY program_name, session_id, wt.wait_duration_ms DESC
