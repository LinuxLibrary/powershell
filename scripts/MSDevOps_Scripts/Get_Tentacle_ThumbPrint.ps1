$file = "C:\Octopus\Tentacle.config"
$xml = [xml](Get-Content $file)
$Tentacle_ThumbPrint = ($xml.'octopus-settings'.set | Where-Object {$_.key -eq 'Tentacle.CertificateThumbprint'}).'#text'
$Tentacle_ThumbPrint