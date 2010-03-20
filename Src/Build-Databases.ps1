


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
	if ($myinvocation.mycommand.Definition  -match "Y:") {
		$backdir = 'Y:\HotSpare\BACKUP\'
		$datadir = 'Y:\Program Files\Microsoft SQL Server\MSSQL10.SX\MSSQL\DATA\'
	}else {
		$backdir = 'C:\HotSpare\BACKUP\'
		$datadir = 'c:\Program Files\Microsoft SQL Server\MSSQL10.SX\MSSQL\DATA\'
	}
	$SS = Get-Server
	$backdir = "y:\HotSpare\BACKUP"
	#$s="FOO"
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

function get-latest($site = 'NH') {
	$r = get-childitem -Path "${$backdir}*${site}*" | sort $_.LastwriteTime | select -First 1 
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
	$Smo = "Microsoft.SqlServer.Management.Smo."
	$server = new-object ($Smo + 'server') $SS

	foreach ($i in 0..4) {
		$dbname = $($a[$i].db) 
		$db = New-Object Microsoft.SqlServer.Management.Smo.Database($server, $dbname)
		$db.Create() 
	} 
}

function create-logins {
	sqlcmd -S $SS -U sa -P 123ross321 -i ./dbscripts/create_5_logins.sql 
}

function restore-databases {
	sqlcmd -S $SS -U sa -P 123ross321 -i ./dbscripts/restore_5_databases.sql 
}
function create-users {
	#sqlcmd -S $SS -U sa -P 123ross321 -i ./dbscripts/create_5_users.sql 
}

function test-getlatest () {
	foreach($s in $sites) { 
		write "${backdir}$(get-latest($s))" 
	}
}

function test-Array () {
	foreach($i in 0..4) { 
		'db is: {0,10} user is:{1,7}' -f $( $a[$i].db), $a[$i].usr 
	}
}

function Test-RestoreParams() {
	write-host "Backdir: $backdir"
	write-host "DataDir: $datadir"
	write "Server: $SS" 

	Write-host "Values for sql RESTORE command:"
	$format = '|{0,-25}|{1,20}|{2,-23}|{3,10}|{4,10}|{5,10}|' 
	$format -f "RestoreDB", "MOVE1","MOVE2","mdfFile", "ldffile","BACKFILE" # print a heading  
	foreach ($s in $sites) {
		load($s)
		$format -f $restoredb, $move1, $move2,$mdf,$ldf,$backfile # print a row 
	} 
}
function load($s = "default") {
    $b = get-latest($s) 
    $l = @{ "backfile" = "xxx"+$b;`
	        "sourcedb" = "dispatch_$s";`
            "restoredb" = "dispatch_$s";`
            "mdf" = $datadir + "dispatch_$s.mdf";`
			"ldf" = $datadir + "dispatch_$s.ldf";`
			"move1" = "dispatch_$s";`
			"move2" = "dispatch_$s" + "_log" 
    }

	# following is untested  "ME" may not work
	if ($s -eq "ME") { 
		$l["move1"] = "dispatch_VT"		
		$l["move2"] = "dispatch_VT_log" 
	} 
    return $l
}

function write-sql(){
	foreach ($s in $sites) {
    $l = @{}
    $l = load($S)
	$sql = @"
			RESTORE DATABASE $l["restoredb"] 
			FROM  DISK = N'$l["backfile"]' 
			WITH  FILE = 1,  
				MOVE N'$l["move1"]' 
				TO N'$l["mdf"]',  
				MOVE N'$l["move2"]' 
				TO N'$l["ldf"]',  
				NOUNLOAD,  REPLACE,  STATS = 10
			GO
"@
		write $l
		write "/*************/"
	}
}
function restore-FromBackup {
	#$SS = get-server
	foreach($s in $sites) { 
    $hash= load($s)
	 
		$sql = @"
RESTORE DATABASE [$hash.restoredb] 
FROM  DISK = N'$hash.backfile' 
   WITH  FILE = 1,  
    MOVE N'$hash.move1' 
     TO N'$hash.mdf',  
    MOVE N'$hash.move2' 
     TO N'$hash.ldf',  
     NOUNLOAD,  REPLACE,  STATS = 10
GO
"@
		sqlcmd -S $SS -U sa -P 123ross321 -Q $sql
	}
}
function drop-databases {
	foreach ($i in 0..4) {
		$dbname = $($a[$i].db) 
		sqlcmd -S $SS -U sa -P 123ross321 -Q "use master; drop database $dbname;"
	}
}

#Initialize 
#test-Array
#Test-RestoreParams
#write-sql 
Test-Getlatest 



