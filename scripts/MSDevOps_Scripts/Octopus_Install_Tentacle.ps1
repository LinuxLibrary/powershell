mkdir C:\OctopusDSC
Start-Sleep 10
Save-Module -Name OctopusDSC -Path C:\OctopusDSC -RequiredVersion 3.0.169
Start-Sleep 30

Get-PackageProvider -Name "NuGet" -Force
Install-PackageProvider -Name "NuGet" -Force
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force

#$NuGetProvider = Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue
#if ( -not $NugetProvider )
#{
#    Install-PackageProvider -Name "NuGet" -Confirm:$false -Force -Verbose
#}
Start-Sleep 30
Install-Module -Name OctopusDSC -RequiredVersion 3.0.169 -Force
