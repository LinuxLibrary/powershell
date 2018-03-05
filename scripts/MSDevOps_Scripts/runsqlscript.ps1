### Import the required modules
Import-Module SQLPS -DisableNameChecking


### Give the DB name to connect it to it 
##$instanceName = "(localdb)\MSSQLLocalDB"
##$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName

### create a new SQL DB 

$localDBInstance = "TestDB"
$command = "SQLLocalDB create `"$($localDBInstance)`""

#execute the command
Invoke-Expression $command

#confirm by listing all instances
$command = "SQLLocalDB i"
Invoke-Expression $command

### Run the SQL comparison Script

### copy the sql script from FTP server and place it it in c:\sqlscripts\sqlcompare.sql

Invoke-Sqlcmd -InputFile "c:\sqlscripts\sqlcompare.sql" -Database $localDBInstance -Username "admin" -Password "admin"

### check script run in SSMS 