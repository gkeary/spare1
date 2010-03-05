/***********
approximate rowcount for Tracker database 
(approx because it uses sysindexes)
run on NHDispatch2003 in the Comet Tracker database

******************/
--  gpsdata has 30,000,000 rows!
select top 10 * from gpsdata;
go

SELECT 
    [TableName] = so.name, 
    [RowCount] = MAX(si.rows) 
FROM 
    sysobjects so, 
    sysindexes si 
WHERE 
    so.xtype = 'U' 
    AND 
    si.id = OBJECT_ID(so.name) 
GROUP BY 
    so.name 
ORDER BY 
    2 DESC

--select top 100 * from gpsdata order by timetag desc