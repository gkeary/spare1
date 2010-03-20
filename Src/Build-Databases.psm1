
function Initialize() {

	## load SMO assemblies
	$null = [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo")
	$null = [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum")
	$null = [reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

	## load db array 
	$a = @( `
	@{db='dispatch_ct'; usr= 'ctuser'}, `
	@{db='dispatch_sutton'; usr= 'mauser'},`
	@{db='dispatch_me'; usr= 'meuser'},`
	@{db='dispatch_production'; usr= 'nhuser'},`
	@{db='dispatch_vt'; usr= 'vtuser'}`
	)
	$sites = "CT","PRODUCTION","sutton","VT", "ME"
	if (pwd -match "Y:") {
		$backdir = 'Y:\HotSpare\BACKUP\'
		$datadir = 'Y:\Program Files\Microsoft SQL Server\MSSQL10.SX\MSSQL\DATA\'
	}else {
		$backdir = 'C:\HotSpare\BACKUP\'
		$datadir = 'c:\Program Files\Microsoft SQL Server\MSSQL10.SX\MSSQL\DATA\'
	}
	$SS = Get-Server

}

function get-latest($site = 'NH') {
	$r = get-childitem -Path "${backdir}dispatch_${s}*.bak" | sort $_.LastwriteTime | select -First 1 
	return $r
}

function get-server {
	$h = hostname
	if ($h -eq "DispatchSpare1") { 
		$hroot = "DISPATCHSPARE1\" 
	} else { 
		$hroot = "DISPATCHSPARE2\"
	} 
	return $hroot + "SX"
}


function create-5Databases {
	#$SS = get-server

## set an SMO as well as a server object
	$Smo = "Microsoft.SqlServer.Management.Smo."

	$server = new-object ($Smo + 'server') $SS

	foreach ($i in 0..4) {
		$dbname = $($a[$i].db) 
		$db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, $dbname)
		$db.Create() 
	} 

}

function create-logins {
	sqlcmd -S $S -U sa -P 123ross321 -i ./dbscripts/create_5_logins.sql 
}

function restore-databases {
	sqlcmd -S $S -U sa -P 123ross321 -i ./dbscripts/restore_5_databases.sql 
}
function create-users {
	#sqlcmd -S $S -U sa -P 123ross321 -i ./dbscripts/create_5_users.sql 
}

function test_getlatest () {
	foreach($s in $sites) { 
		write "${backdir}$(get-latest($s))" 
	}
}

function test-Array () {
	foreach($s in $sites) { 
		'db is: {0,10} user is:{1,7}' -f $( $a[$i].db), $a[$i].usr 
	}
}

function Test-RestoreParams() {
	write-host "Backdir: $backdir"
	write-host "DataDir: $datadir"
	write "Server: $SS" 

	Write-host "Valuses for sql RESTORE command:"
	$format = '|{0,-25}|{1,20}|{2,-23}|{3,10}|{4,10}|{5,10}|' 
	$format -f "RestoreDB", "MOVE1","MOVE2","mdfFile", "ldffile","BACKFILE" # print a heading  
	foreach ($s in $sites) {
	} 
}
function load($s = "NH") {
	$backfile = "$(get-latest($s))" 
	$sourcedb = "dispatch_${$s}" 
	$restoredb = "dispatch_$s"

	$mdf = $datadir + "dispatch_$s.mdf"
	$ldf = $datadir + "dispatch_$s.ldf"

	# following is untested  "ME" may not work
	if ($s -eq "ME") { 
		$move1 = "dispatch_VT"
		$move2 = "dispatch_VT_log" 
	} else {
		$move1 = "dispatch_$s"
		$move2 = "dispatch_$s" + "_log" 
	} 
}
function write-sql(){
	foreach ($s in $sites) {
		$sql = @"
RESTORE DATABASE [$restoredb] 
FROM  DISK = N'$backfile' 
   WITH  FILE = 1,  
    MOVE N'$move1' 
     TO N'$mdf',  
    MOVE N'$move2' 
     TO N'$ldf',  
     NOUNLOAD,  REPLACE,  STATS = 10
GO
"@
		write $sql
		write "/*************/"
	}
}
function restore-FromBackup {
	#$SS = get-server
	foreach($s in $sites) { 
		load($s) 
		$sql = @"
RESTORE DATABASE [$restoredb] 
FROM  DISK = N'$backfile' 
   WITH  FILE = 1,  
    MOVE N'$move1' 
     TO N'$mdf',  
    MOVE N'$move2' 
     TO N'$ldf',  
     NOUNLOAD,  REPLACE,  STATS = 10
GO
"@
		#write $sql

		sqlcmd -S $SS -U sa -P 123ross321 -Q $sql

	}

}
function drop-databases {
	foreach ($i in 0..4) {
		$dbname = $($a[$i].db) 
		sqlcmd -S $SS -U sa -P 123ross321 -Q "use master; drop database $dbname;"
	}
}

Initialize 
test-Array
Test-RestoreParams
write-sql 
Test-Getlatest 



