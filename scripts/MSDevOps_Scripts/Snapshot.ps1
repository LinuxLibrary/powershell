$snapName = (get-date -uformat %Y%m%d%H%M%S).ToString() + '_' + (hostname).ToString()
$desc = "DevOps-Dev-Dep1 snapshot - " + (get-date).ToString()
New-Snapshot -Name $snapName -Description $desc -VM DevOps-Dev-Dep1
start-sleep 20
stop-vm -vm devops-dev-dep1 -Confirm:$false
start-sleep 60
start-vm -vm devops-dev-dep1
start-sleep 60
(get-vm devops-dev-dep1).guest.ipaddress.get(0)
$snap = get-vm devops-dev-dep1 | get-snapshot | sort-object -Property Created -Descending | Select -First 1
set-vm -vm devops-dev-dep1 -snap $snap -Confirm:$false