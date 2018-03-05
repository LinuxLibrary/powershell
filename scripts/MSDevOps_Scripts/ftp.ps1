### FTP Download ####

$user = "Administrator"
$password = "devops@123"

$WebClient = New-Object System.Net.WebClient
$WebClient.Credentials = new-object System.Net.NetworkCredential($user, $pass)

### Install Chef  ###
New-Item -ItemType directory -Path C:\FTPFiles
$WebClient.DownloadFile('ftp://150.150.150.78/chefclient.msi','C:\FTPFiles\chefclient.msi')

Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\Windows\Temp\chef-log.txt', '/i C:\\FTPFiles\\chefclientmsi', 'ADDLOCAL="ChefClientFeature,ChefSchTaskFeature,ChefPSModuleFeature"') -NoNewWindow -Wait


### Download chef keys ####
New-Item -ItemType directory -Path C:\chef\.chef\
$WebClient.DownloadFile("ftp://150.150.150.78/sri321.pem","C:\chef\sri231.pem")
$WebClient.DownloadFile("ftp://150.150.150.78/.chef/a-cf-validator.pem","C:\chef\.chef\a-cf-validator.pem")
$WebClient.DownloadFile("ftp://150.150.150.78/knife.rb","C:\chef\knife.rb")

