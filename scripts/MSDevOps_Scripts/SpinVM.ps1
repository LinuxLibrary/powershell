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

######## Get VM Details #######
$myVM = (Get-VM DevOps-Dev-Dep1).ExtensionData.Guest.Hostname
$myIP = (Get-VM DevOps-Dev-Dep1).Guest.IPAddress.Get(0)
$DevDep1 = (Get-VM DevOps-Dev-Dep1).Name
$UserName = "Administrator"
$Password = "devops@123"
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username,$pass
##############################################

#### Initilization Files Location ####
$source = '\\150.150.150.78\ftp'
$destination = 'c:\FTPFiles'
$scriptcopy = "robocopy $source $destination /MIR /E /FFT"
Invoke-VMScript -ScriptText $scriptcopy -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 60
###########################

#### Install and run chef client ###########
$scriptmkd = "New-Item -ItemType Directory -Path C:\chef
New-Item -ItemType Directory -Path C:\chef\.chef"
Invoke-VMScript -ScriptText $scriptmkd -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 5

$scriptmove = "Copy-Item C:\FTPFiles\a-cf-validator.pem C:\chef\.chef\
Copy-Item C:\FTPFiles\sri321.pem C:\chef\
Copy-Item C:\FTPFiles\knife.rb C:\chef\
Copy-Item C:\FTPFiles\client.rb C:\chef
Copy-Item C:\FTPFiles\OctopusTools C:\ -recurse"
Invoke-VMScript -ScriptText $scriptmove -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 20

#### Edit client.rb to change node name ####
#$Hostname = Invoke-VMScript -ScriptText "Hostname" -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
$NodeNum = $myIP.Replace('.','')
$Random = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
#$Hostname = ($Hostname -Replace [Environment]::NewLine,"").ToString() + '-' + $Random
$TentaNode = 'Tentacle-' + $Random
#$Hostname = 'Tentacle-' + $NodeNum

$ChefNode = ('a-cf-node').ToString()
$scriptclienthost = "(Get-Content C:\chef\client.rb) -Replace '$ChefNode', '$TentaNode' | Set-Content C:\chef\client.rb"
Invoke-VMScript -ScriptText $scriptclienthost -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password


$scriptchef = "Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\chef-log.txt', '/i C:\FTPFiles\chefclient.msi') -NoNewWindow -Wait"
Invoke-VMScript -ScriptText $scriptchef -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 180

$old_path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$new_path = $old_path + ';' + 'C:\opscode\chef\bin\'+';'+'C:\Program Files\Octopus Deploy\Tentacle'
$scriptset = "Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value '$new_path'"
Invoke-VMScript -ScriptText $scriptset -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
Start-Sleep 10

###### Tentacle Install ###
#$scripttenta = "Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\tentacle-log.txt', '/i C:\FTPFiles\Tentacle.msi') -NoNewWindow -Wait"
#$octoconf = "c:\FTPFiles\octoconf.ps1"
#Invoke-VMScript -ScriptText $scripttenta -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
#Start-Sleep 50
#Invoke-VMScript -ScriptText $octoconf -VM $DevDep1 -GuestUser $UserName -GuestPassword $Password
#Start-Sleep 50

Invoke-Command -ComputerName $myIP -ScriptBlock {C:\opscode\chef\bin\chef-client.bat} -Credential $Cred
Invoke-Command -ComputerName $myIP -ScriptBlock {"knife node run_list set '$TentaNode' 'recipe['powershell-tantacle']'"} -Credential $Cred
Invoke-Command -ComputerName $myIP -ScriptBlock {C:\opscode\chef\bin\chef-client.bat} -Credential $Cred