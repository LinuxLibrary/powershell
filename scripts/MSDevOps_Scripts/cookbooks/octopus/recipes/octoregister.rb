powershell_script "octoregister" do
  code <-EOH
    ########## Configure Octopus #############
    Import-Module Octoposh
    
    $OctopusAPI = 'API-SZTBBJGPAVIJJKK68D5CLJGCNOO'
    $OctopusServerURL = 'http://150.150.150.88/'
    
    Set-OctopusConnectionInfo -URL $OctopusServerURL -APIKey $OctopusAPI
    $OctopusThumbPrint =  Get-OctopusServerThumbprint
    #######################################
    
    #### Get Host Details  ######
    $TentacleIP = Test-Connection -ComputerName (hostname) -Count 1  | Select IPV4Address
    ###############################
    
    ######################
    ##### Octo Config ####
    ######################
    cd "C:\Program Files\Octopus Deploy\Tentacle"
    $OctoEnv = 'Dev'
    $OctoRole = 'webserver'
     #### tentacle config generation
    .\Tentacle.exe create-instance --instance $TentacleIP --config "C:\Octopus\Tentacle.config" --console
    .\Tentacle.exe new-certificate --instance $TentacleIP --if-blank --console
    .\Tentacle.exe configure --instance $TentacleIP --reset-trust --console
    .\Tentacle.exe configure --instance $TentacleIP --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
    .\Tentacle.exe configure --instance $TentacleIP --trust $OctopusThumbPrint --console
    #"netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
    .\Tentacle.exe register-with --instance $TentacleIP --server $OctopusServerURL --apiKey=$OctopusAPI --role $OctoRole --environment $OctoEnv --comms-style TentaclePassive --console
    .\Tentacle.exe service --instance $TentacleIP --install --start --console
    
    $file = "C:\Octopus\Tentacle.config"
    $xml = [xml](Get-Content $file)
    $TentacleThumbPrint = ($xml.'octopus-settings'.set | Where-Object {$_.key -eq 'Tentacle.CertificateThumbprint'}).'#text'
    
    ##### Tentacle Registration #####
    Add-Type -Path 'Newtonsoft.Json.dll'
    Add-Type -Path 'Octopus.Client.dll'
    $endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusServerURL, $OctopusAPI
    $repository = new-object Octopus.Client.OctopusRepository $endpoint
    $tentacle = New-Object Octopus.Client.Model.MachineResource
    $tentacle.name = Hostname
    $tentacle.EnvironmentIds.Clear()
    $tentacle.EnvironmentIds.Add($OctoEnv)
    $tentacle.Roles.Clear()
    $tentacle.Roles.Add($OctoRole)
    $tentacleEndpoint = New-Object Octopus.Client.Model.Endpoints.ListeningTentacleEndpointResource
    $tentacle.EndPoint = $tentacleEndpoint
    $tentacle.Endpoint.Uri = "https://"+$TentacleIP+":10933"
    $tentacle.Endpoint.Thumbprint = $TentacleThumbPrint
    $repository.machines.create($tentacle)
  EOH
end
