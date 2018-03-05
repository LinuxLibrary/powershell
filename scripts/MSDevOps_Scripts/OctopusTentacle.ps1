mkdir c:\OctopusDSC
Save-Module -Name OctopusDSC -Path c:\OctopusDSC -RequiredVersion 3.0.169
Install-Module -Name OctopusDSC -RequiredVersion 3.0.169
Configuration SampleConfig
{
    param ($ApiKey, $OctopusServerUrl, $Environments, $Roles, $ListenPort)

    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cTentacleAgent OctopusTentacle
        {
            Ensure = "Present"
            State = "Started"

            # Tentacle instance name. Leave it as 'Tentacle' unless you have more
            # than one instance
            Name = "Tentacle"

            # Registration - all parameters required
            ApiKey = $ApiKey
            OctopusServerUrl = $OctopusServerUrl
            Environments = $Environments
            Roles = $Roles

            # Optional settings
            ListenPort = $ListenPort
            DefaultApplicationDirectory = "C:\Applications"
        }
    }
}

# Execute the configuration above to create a mof file
SampleConfig -ApiKey "API-TWVCWHKQNRF21RLHCYWFM5TO2G" -OctopusServerUrl "http://150.150.150.88/" -Environments @("Dev") -Roles @("web") -ListenPort 10933

# Run the configuration
Start-DscConfiguration .\SampleConfig -Verbose -wait

# Test the configuration ran successfully
Test-DscConfiguration