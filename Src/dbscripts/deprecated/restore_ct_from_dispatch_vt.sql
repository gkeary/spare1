RESTORE DATABASE [dispatch_ct] 
FROM  DISK = 
  N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Backup\Dispatch_VT_FullBackup_20100221_0630_bak\Dispatch_VT_FullBackup_20100221_0630.bak' WITH  FILE = 1,  MOVE N'dispatch_VT' TO N'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\Dispatch_CT.mdf',  MOVE N'dispatch_VT_log' 
  TO 
  N'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\Dispatch_ct_log.ldf',
    NOUNLOAD,  REPLACE,  STATS = 10
GO
