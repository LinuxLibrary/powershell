Import-Module "E:\WIS_FOLDER\Automation\Scripts\Modules.ps1"
Try{
	if (Get-PSDrive Z 2>&1 | Out-Null){
		Remove-PSDrive Z -Force
	}
}
Finally{
	Write-Host ""
}
   $RUser = "wkelms\rao.besetti"
   $RPasswd = "ArjunWK_119"
   $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
   $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
   New-PSDrive -Name Z -PSProvider FileSystem -Root "\\HOUT3P1WEB01\WIS_FOLDER" -Credential $RCred > $null
$File = Get-Content "Z:\Automation\Conf\SList.json" -Raw
$JsonObject = $File | ConvertFrom-Json
$name = hostname
foreach ($Server in $JsonObject.Servers){
    $RComp = $Server.Name
    Write-Host $RComp
    $RUser = "wkelms\rao.besetti"
    $RPasswd = "ArjunWK_119"
    $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
    $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
#	Invoke-Command -ComputerName $RComp -ScriptBlock ${Function:StopServices} -Credential $RCred
	Invoke-Command -ComputerName $RComp -ScriptBlock ${Function:CreateFolders} -Credential $RCred
#	Invoke-Command -ComputerName $RComp -ScriptBlock ${Function:StartServices} -Credential $RCred
}

foreach ($Server in $JsonObject.Servers){
    $RComp = $Server.Name
#    Write-Host $RComp
    $RUser = "wkelms\rao.besetti"
    $RPasswd = "ArjunWK_119"
    $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
    $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
#	Invoke-Command -ComputerName $RComp -ScriptBlock ${Function:VerifyServices} -Credential $RCred
}