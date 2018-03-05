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
$script1 = "robocopy $source $destination /MIR /E /FFT"
$script2 = "Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\chef-log.txt', '/i C:\FTPFiles\chefclient.msi') -NoNewWindow -Wait"
$script3 = "New-Item -ItemType Directory -Path C:\chef\.chef
Copy-Item C:\FTPFiles\a-cf-validator.pem C:\chef\.chef\
Copy-Item C:\FTPFiles\sri321.pem C:\chef\
Copy-Item C:\FTPFiles\knife.rb C:\chef\
Copy-Item C:\FTPFiles\client.rb C:\chef\"
$old_path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$new_path = $old_path + ';' + 'C:\opscode\chef\bin\'
$script4 = "Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value '$new_path'"
Invoke-VMScript -ScriptText $script1 -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 60
Invoke-VMScript -ScriptText $script2 -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 300
Invoke-VMScript -ScriptText $script3 -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 10
Invoke-VMScript -ScriptText $script4 -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 10
Invoke-Command -ComputerName $myIP -ScriptBlock {C:\opscode\chef\bin\chef-client.bat} -Credential $cred