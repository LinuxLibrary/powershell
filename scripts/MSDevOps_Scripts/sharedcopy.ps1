
$source = "\\150.150.150.78\ftp"
$destination = "c:\FTPFiles"

robocopy $source $destination /MIR /E /FFT

move-item -path C:\FTPFiles\a-cf-validator.pem -destination C:\chef\.chef\a-cf-validator.pem
move-item -path C:\FTPFiles\client.rb -destination C:\chef\client.rb
move-item -path C:\FTPFiles\knife.rb -destination C:\chef\knife.rb
move-item -path C:\FTPFiles\sri321.pem -destination C:\chef\sri321.pem

$path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
$Npath=$path+’;C:\opscode\chef\bin’
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $Npath