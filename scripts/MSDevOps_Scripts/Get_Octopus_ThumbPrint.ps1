Add-PSSnapin VMware*
Connect-VIServer -Server "150.150.150.17" -User "administrator@vsphere.local" -Password "Atmecs@123"
$TentacleIP = (Get-VM DevOps-Dev-Dep1).Guest.IPAddress.Get(0)
$UserName = "Administrator"
$Password = "devops@123"
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
$file = "C:\Octopus\Tentacle.config"
$xml = [xml](Get-Content $file)
$OctopusThumbPrint = (($xml.'octopus-settings'.set | Where-Object {$_.key -eq 'Tentacle.Communication.TrustedOctopusServers'}).'#text' | ConvertFrom-Json).Thumbprint
$OctopusThumbPrint