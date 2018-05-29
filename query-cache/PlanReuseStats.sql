SELECT TOP 5000
        cp.usecounts 
        ,cp.cacheobjtype
        ,st.dbid
        ,COALESCE(DB_NAME(st.dbid),DB_NAME(CAST(pa.value AS INT))+'*','Resource') AS [DatabaseName]
		,qs.total_elapsed_time AS 'TotalTime'
		,qs.total_worker_time AS 'TotalWorkerTime'
		,qs.total_worker_time/qs.execution_count AS 'AvgWorkerTime'
		,qs.total_logical_reads AS 'TotalLogicalReads'
		,qs.total_physical_reads AS 'TotalPhysicalReads'
		,qs.execution_count/DATEDIFF(Second, qs.creation_time, GETDATE()) AS 'Calls/Second'
		,st.text
        ,SUBSTRING(st.text,qs.statement_start_offset/2,
             (case when qs.statement_end_offset = -1
            then len(convert(nvarchar(max), st.text)) * 2
            else qs.statement_end_offset end - qs.statement_start_offset)/2)
        as statement
        ,qp.query_plan
        ,st.objectid
        ,qs.sql_handle 
        ,qs.plan_handle 
FROM sys.dm_exec_query_stats qs 
cross apply sys.dm_exec_sql_text(qs.sql_handle) as st 
inner join sys.dm_exec_cached_plans as cp on qs.plan_handle=cp.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
OUTER APPLY sys.dm_exec_plan_attributes(cp.plan_handle) pa
where cp.plan_handle=qs.plan_handle --and st.dbid = db_id() -- put the database ID here 
--ORDER BY [Usecounts] ASC --Lowest reuse
ORDER BY [Usecounts] DESC --Highest reuse
