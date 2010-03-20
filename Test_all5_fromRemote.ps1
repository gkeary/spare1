"nhuser","mauser","ctuser","vtuser","meuser" | % { `
   sqlcmd -S DispatchSpare1\SX -U $_ -P 123ross321 -Q `
   'set nocount on; select top 2 RouteName from route2;' `
   }
   