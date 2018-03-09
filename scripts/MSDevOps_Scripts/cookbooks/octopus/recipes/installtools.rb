powershell_script "installtools" do
  code <-EOH
    ############### Install tentacle ##################
    
    Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\tentacle-log.txt', '/i C:\FTPFiles\Tentacle.msi') -NoNewWindow -Wait
    
    ##########Install  Nuget Octoposh #################
    
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    start-sleep 30
    Install-Module -Name Octoposh -force
    start-sleep 40
    
    ###################################################
    
    ################# Install IIS #####################
    
    Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\FTPFiles\IIS-log.txt', '/i C:\FTPFiles\iisexpress.msi') -NoNewWindow -Wait
    
    ###################################################
  EOH
end
