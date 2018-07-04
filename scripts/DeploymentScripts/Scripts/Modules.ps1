Function StopServices {
	Try{
		if (Get-PSDrive Z 2>&1 | Out-Null){
			Remove-PSDrive Z -Force
		}
	}
	Finally{
		Write-Host ""
	}
    $RUser = "lldev\vmsnivas"
    $RPasswd = "XX-PASS-XX"
    $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
    $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\LLDEV3P1WEB01\WIS_FOLDER" -Credential $RCred > $null
	$File = Get-Content "Z:\Automation\Conf\SList.json" -Raw
	$JsonObject = $File | ConvertFrom-Json
	$name = hostname
	foreach ($Server in $JsonObject.Servers){
		$Services = $Server.Services
        $RComp = $Server.Name
		if ($Services -ne $null) {
			if ($Server.Name -eq $name) {
				foreach ($Service in $Services){
					Write-Host "Stopping $Service on $Computer"
					Stop-Service "$Service" -Force
				}
			}
		}
	}
}


Function CreateFolders {
	Try{
		if (Get-PSDrive Z 2>&1 | Out-Null){
			Remove-PSDrive Z -Force
		}
	}
	Finally{
		Write-Host ""
	}
    $RUser = "lldev\vmsnivas"
    $RPasswd = "XX-PASS-XX"
    $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
    $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\LLDEV3P1WEB01\WIS_FOLDER" -Credential $RCred > $null
	$File = Get-Content "Z:\Automation\Conf\SList.json" -Raw
	$JsonObject = $File | ConvertFrom-Json
	$name = hostname
	foreach ($Server in $JsonObject.Servers){
		$Folders = $Server.Folders
        $Drive = (Get-PSDrive -PSProvider FileSystem).Name[-2]
		$Path = Write-Output $Drive":"
        $RComp = $Server.Name
		if ($RComp -eq $name){
			foreach ($Folder in $Folders){
				$FolderName = $Folder.Name
				$SrcPath = $Folder.Src
				$DestPath = $Folder.Dest
                Write-Host "$RComp - $FolderName - $Path\$DestPath"
				try{
					if (Test-Path -Path "$Path\$DestPath") {
						Write-Host "INFO: Cleaning up $Path\$DestPath ..."
						Remove-Item "$Path\$DestPath" -Recurse -Force
					}
				}
				catch{
					Write-Host "$Path\$DestPath does not exists. Proceeding with creation..."
					New-Item -Path "$Path\" -Name "$DestPath" -ItemType "directory" > $null
				}
				if (!(Test-Path -Path $Path\$DestPath)){
					New-Item -Path "$Path\" -Name "$DestPath" -ItemType "directory" > $null
				}
				Write-Host "Copying data from DropLocation to $Path\$DestPath"
                New-PSDrive -Name Y -PSProvider FileSystem -Root $SrcPath -Credential $RCred > $null
				Copy-Item Y:\* -Destination "$Path\$DestPath\" -Recurse > $null
                Remove-PSDrive Y -Force
		    }
	    }
    }
}

Function StartServices {
	Try{
		if (Get-PSDrive Z 2>&1 | Out-Null){
			Remove-PSDrive Z -Force
		}
	}
	Finally{
		Write-Host ""
	}
    $RUser = "lldev\vmsnivas"
    $RPasswd = "XX-PASS-XX"
    $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
    $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\LLDEV3P1WEB01\WIS_FOLDER" -Credential $RCred > $null
	$File = Get-Content "Z:\Automation\Conf\SList.json" -Raw
	$JsonObject = $File | ConvertFrom-Json
	$name = hostname
	foreach ($Server in $JsonObject.Servers){
		$Services = $Server.Services
		$RComp = $Server.Name
		if ($Services -ne $null){
			if ($RComp -eq $name) {
				foreach ($Service in $Services){
					Write-Host "Starting $Service on $Computer"
					Start-Service "$Service"
				}
			}
		}
	}
}

Function VerifyServices {
	Try{
		if (Get-PSDrive Z 2>&1 | Out-Null){
			Remove-PSDrive Z -Force
		}
	}
	Finally{
		Write-Host ""
	}
    $RUser = "lldev\vmsnivas"
    $RPasswd = "XX-PASS-XX"
    $RPass = ConvertTo-SecureString -AsPlainText $RPasswd -Force
    $RCred = New-Object System.Management.Automation.PSCredential -ArgumentList $RUser,$RPass
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\LLDEV3P1WEB01\WIS_FOLDER" -Credential $RCred > $null
	$File = Get-Content "Z:\Automation\Conf\SList.json" -Raw
	$JsonObject = $File | ConvertFrom-Json
	$name = hostname
	foreach ($Server in $JsonObject.Servers){
		$Services = $Server.Services
		$RComp = $Server.Name
		if ($Services -ne $null){
			$name = hostname
			if ($RComp -eq $name) {
				foreach ($Service in $Services){
					$Status = (Get-Service -Name $Service).Status
					if ($Status -ne "Running"){
						Write-Host "ERROR: $RComp - $Service not running"
					}
					else {
						Write-Host "$RComp - $Service - $Status"
					}
				}
			}
		}
	}
}
