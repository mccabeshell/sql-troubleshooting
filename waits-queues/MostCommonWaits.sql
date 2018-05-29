--Most common wait types since SQL restarted (dm_os_wait_stats)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT TOP 100 wait_type
	, wait_time_ms AS [Total Wait in ms]
	, signal_wait_time_ms AS [CPU Wait in MS]
	, waiting_tasks_count
	, wait_time_ms - signal_wait_time_ms AS RealWait
	, CONVERT(DECIMAL(12,2), wait_time_ms * 100.0 / SUM(wait_time_ms) OVER()) AS [% of TotalWaitTime] --i.e. % of all the time spent waiting across all queries
	, CONVERT(DECIMAL(12,2), (wait_time_ms - signal_wait_time_ms) * 100.0 / SUM(wait_time_ms) OVER()) AS [% RealWait(Non-CPUWait)] --same as above just factoring out cpu wait time
FROM sys.dm_os_wait_stats
--WHERE --wait_type NOT LIKE '%SLEEP%' AND wait_type != 'WAITFOR'
WHERE wait_type NOT IN ('%SLEEP%', 'CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
ORDER BY wait_time_ms DESC
