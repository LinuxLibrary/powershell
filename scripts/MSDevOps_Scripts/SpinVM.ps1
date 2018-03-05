Add-PSSnapin VMware*
Connect-VIServer -Server "150.150.150.17" -User "administrator@vsphere.local" -Password "Atmecs@123"
New-VM -Name DevOps-Dev-Dep1 -Template DevOps_Template -VMHost "150.150.150.9"
Start-VM -VM DevOps-Dev-Dep1
start-sleep 180
$vm = Get-VM -Name DevOps-Dev-Dep1
ping $vm.Guest.IPAddress.Get(0)

#Stop-VM -VM DevOps-Dev-Dep1 -Confirm:$false

# Create Snapshot
$snapName = (get-date -uformat %Y%m%d%H%M%S).ToString() + '_' + (hostname).ToString()
$desc = "DevOps-Dev-Dep1 snapshot - " + (get-date).ToString()
New-Snapshot -Name $snapName -Description $desc -VM DevOps-Dev-Dep1
start-sleep 20
$vm.PowerState
#$snap = get-vm devops-dev-dep1 | get-snapshot | sort-object -Property Created -Descending | Select -First 1
#set-vm -vm devops-dev-dep1 -snap $snap -Confirm:$false
#start-vm -vm devops-dev-dep1
#start-sleep 60

$myVM = (Get-VM DevOps-Dev-Dep1).ExtensionData.Guest.Hostname
$myIP = (Get-VM DevOps-Dev-Dep1).Guest.IPAddress.Get(0)
$DevDep1 = (Get-VM DevOps-Dev-Dep1).Name
$UserName = "Administrator"
$Password = "devops@123"
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
$source = '\\150.150.150.78\ftp'
$destination = 'c:\FTPFiles'
$scriptcopy = "robocopy $source $destination /MIR /E /FFT"
$scriptchef = "Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\chef-log.txt', '/i C:\FTPFiles\chefclient.msi') -NoNewWindow -Wait"
$scriptmkd = "New-Item -ItemType Directory -Path C:\chef
New-Item -ItemType Directory -Path C:\chef\.chef
New-Item -ItemType Directory -Path  c:\OctopusDSC"
$scripttenta = "Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\tentacle-log.txt', '/i C:\FTPFiles\Tentacle.msi') -NoNewWindow -Wait"
$scriptnug = "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force"
$scriptOcto = "Save-Module -Name OctopusDSC -Path c:\OctopusDSC -RequiredVersion 3.0.169
Install-Module -Name OctopusDSC -RequiredVersion 3.0.169 -force "
$scriptmove = "Copy-Item C:\FTPFiles\a-cf-validator.pem C:\chef\.chef\
Copy-Item C:\FTPFiles\sri321.pem C:\chef\
Copy-Item C:\FTPFiles\knife.rb C:\chef\
Copy-Item C:\FTPFiles\client.rb C:\chef
Copy-Item C:\FTPFiles\OctopusTools C:\ -recurse"
$octoconf = "c:\FTPFiles\octoconf.ps1"

$old_path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$new_path = $old_path + ';' + 'C:\opscode\chef\bin\'+';'+'C:\Program Files\Octopus Deploy\Tentacle'

$scriptset = "Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value '$new_path'"

Invoke-VMScript -ScriptText $scriptcopy -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 60
Invoke-VMScript -ScriptText $scriptmkd -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 10
Invoke-VMScript -ScriptText $scriptmove -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 20
Invoke-VMScript -ScriptText $scriptchef -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 300
Invoke-VMScript -ScriptText $scripttenta -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 40
Invoke-VMScript -ScriptText $scriptnug -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 30
Invoke-VMScript -ScriptText $scriptOcto -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
#Start-Sleep 40
Invoke-VMScript -ScriptText $octoconf -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
#Start-Sleep 30
Invoke-VMScript -ScriptText $scriptset -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
#Start-Sleep 20
Invoke-Command -ComputerName $myIP -FilePath "C:\MSDevOps\GitLabs\PS-Scripts\Octopus_Config_Tentacle.ps1" -Credential $Cred
#Start-Sleep 60
Invoke-Command -ComputerName $myIP -ScriptBlock {C:\opscode\chef\bin\chef-client.bat} -Credential $Cred
