Add-PSSnapin VMware*
Connect-VIServer -Server "150.150.150.17" -User "administrator@vsphere.local" -Password "Atmecs@123"
$TentacleIP = (Get-VM DevOps-Dev-Dep1).Guest.IPAddress.Get(0)
$UserName = "Administrator"
$Password = "devops@123"
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
$OctopusAPI = "API-TWVCWHKQNRF21RLHCYWFM5TO2G"
$OctopusServerURL = "http://150.150.150.88/"
$OctoEnv = "Dev"
$OctoRole = "webserver"
$TentacleThumbPrint = Invoke-Command -ComputerName $TentacleIP -FilePath "C:\MSDevOps\GitLabs\PS-Scripts\Get_Tentacle_ThumbPrint.ps1" -Credential $Cred
$OctopusThumbPrint = Invoke-Command -ComputerName $TentacleIP -FilePath "C:\MSDevOps\GitLabs\PS-Scripts\Get_Octopus_ThumbPrint.ps1" -Credential $Cred
Invoke-Command -ComputerName $TentacleIP -ScriptBlock {C:\MSDevOps\GitLabs\PS-Scripts\ListeningTentacle.bat} -Credential $Cred
Invoke-Command -ComputerName $TentacleIP -FilePath "C:\MSDevOps\GitLabs\PS-Scripts\DepTarget.ps1" -Credential $Cred
