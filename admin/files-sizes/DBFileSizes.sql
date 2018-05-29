IF OBJECT_ID('tempdb..#DBFiles','U') IS NOT NULL
	DROP TABLE #DBFiles

CREATE TABLE #DBFiles
(
	[DatabaseName] nvarchar(128), [Name] nvarchar(128) null, [type_desc] nvarchar(60) null, [FileName] nvarchar(260) null,
	[is_percent_growth] bit null, [SizeMB] DECIMAL(10,0) null, [AvailableSpaceMB] DECIMAL(10,0) null, [PercentFreeMB] DECIMAL(10,2) null
);

EXEC sp_MSforeachdb '
USE [?]; INSERT INTO #DBFiles
SELECT	''?'' AS [DatabaseName], df.name, df.type_desc, sf.filename, df.is_percent_growth
		, CAST(df.size/128.0 AS DECIMAL(10,0)) AS [SizeMB]
		, CAST(df.size/128.0 AS DECIMAL(10,2)) - CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS DECIMAL(10,2))/128 AS [AvailableSpaceMB]
		, CASE df.size/128 WHEN 0 THEN 0 ELSE 100.00 - (CAST((CAST(FILEPROPERTY(df.name, ''SpaceUsed'')/128.0 AS DECIMAL(10,2)) / CAST(df.size/128.0 AS DECIMAL(10,2)))*100 AS DECIMAL(10,2)))
		  END AS [PercentFreeMB]
FROM sys.database_files df LEFT OUTER JOIN sys.sysfiles sf ON df.file_id = sf.fileid';

-- Data Files: Aggregated DB Size

SELECT DatabaseName, SUM(SizeMB) AS SizeMB, (SUM(SizeMB) - SUM(AvailableSpaceMB)) AS UsedSpaceMB , SUM(AvailableSpaceMB) AS AvailableSpaceMB
	   , CAST(SUM(AvailableSpaceMB)/SUM(SizeMB) * 100 AS DECIMAL(10,2)) AS PercentFree
FROM #DBFiles WHERE type_desc = 'ROWS'
GROUP BY DatabaseName ORDER BY SizeMB DESC;

-- Data Files: All data files
SELECT * FROM #DBFiles WHERE type_desc = 'ROWS' AND DatabaseName <> 'tempdb'
ORDER BY SizeMB DESC;

-- Log Files Only
SELECT DatabaseName, SUM(SizeMB) AS SizeMB, SUM(AvailableSpaceMB) AS AvailableSpaceMB, CAST(SUM(AvailableSpaceMB)/SUM(SizeMB) * 100 AS DECIMAL(10,2)) AS PercentFree
FROM #DBFiles WHERE type_desc = 'LOG' GROUP BY DatabaseName ORDER BY DatabaseName;

DROP TABLE #DBFiles;
