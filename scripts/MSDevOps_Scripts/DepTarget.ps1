Add-Type -Path 'Newtonsoft.Json.dll'
Add-Type -Path 'Octopus.Client.dll' 
 
$octopusApiKey = $OctopusAPI
$octopusURI = $OctopusURL

$endpoint = new-object Octopus.Client.OctopusServerEndpoint $octopusURI, $octopusApiKey
$repository = new-object Octopus.Client.OctopusRepository $endpoint

$tentacle = New-Object Octopus.Client.Model.MachineResource

$tentacle.name = Hostname
$tentacle.EnvironmentIds.Add("$OctoEnv")
$tentacle.Roles.Add("$OctoRole")

$tentacleEndpoint = New-Object Octopus.Client.Model.Endpoints.ListeningTentacleEndpointResource
$tentacle.EndPoint = $tentacleEndpoint
$tentacle.Endpoint.Uri = "https://$TentacleIP:10933"
$tentacle.Endpoint.Thumbprint = "$TentacleThumbPrint"

$repository.machines.create($tentacle)