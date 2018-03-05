cd "C:\Program Files\Octopus Deploy\Tentacle"

Tentacle.exe create-instance --instance "$TentacleIP" --config "C:\Octopus\Tentacle.config" --console
Tentacle.exe new-certificate --instance "$TentacleIP" --if-blank --console
Tentacle.exe configure --instance "$TentacleIP" --reset-trust --console
Tentacle.exe configure --instance "$TentacleIP" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
Tentacle.exe configure --instance "$TentacleIP" --trust "$OctopusThumbPrint" --console
#"netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
Tentacle.exe register-with --instance "$TentacleIP" --server "$OctopusServerURL" --apiKey="$OctopusAPI" --role "$OctoRole" --environment "$OctoEnv" --comms-style TentaclePassive --console
Tentacle.exe service --instance "$TentacleIP" --install --start --console