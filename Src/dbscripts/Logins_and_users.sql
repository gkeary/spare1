USE [master]
GO

CREATE LOGIN [vtuser] WITH PASSWORD=N'123ross321', 
  DEFAULT_DATABASE=[dispatch_vt], 
  CHECK_EXPIRATION=OFF, 
  CHECK_POLICY=OFF
GO

USE [dispatch_vt]
GO
CREATE USER [vtuser] FOR LOGIN [vtuser] 
     WITH DEFAULT_SCHEMA=[dbo]
GO

EXEC sp_addrolemember N'db_owner', N'vtuser'
GO

CREATE LOGIN [ctuser] WITH PASSWORD=N'123ross321', DEFAULT_DATABASE=[dispatch_vt], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

CREATE LOGIN [meuser] WITH PASSWORD=N'123ross321', DEFAULT_DATABASE=[dispatch_vt], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

CREATE LOGIN [mauser] WITH PASSWORD=N'123ross321', DEFAULT_DATABASE=[dispatch_vt], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

CREATE LOGIN [nhuser] WITH PASSWORD=N'123ross321', DEFAULT_DATABASE=[dispatch_vt], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
