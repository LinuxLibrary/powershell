## Download functions to bypass proxy errors

function Get-Downloader {
param (
  [string]$url
 )

  $downloader = new-object System.Net.WebClient

  $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
  if ($defaultCreds -ne $null) {
    $downloader.Credentials = $defaultCreds
  }

  $ignoreProxy = $env:ChefIgnoreProxy
  if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
    Write-Debug "Explicitly bypassing proxy due to user environment variable"
    $downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
  } else {
    # check if a proxy is required
    $explicitProxy = $env:ChefProxyLocation
    $explicitProxyUser = $env:ChefchocolateyProxyUser
    $explicitProxyPassword = $env:ChefProxyPassword
    if ($explicitProxy -ne $null -and $explicitProxy -ne '') {
      # explicit proxy
      $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
      if ($explicitProxyPassword -ne $null -and $explicitProxyPassword -ne '') {
        $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
        $proxy.Credentials = New-Object System.Management.Automation.PSCredential ($explicitProxyUser, $passwd)
      }

      Write-Debug "Using explicit proxy server '$explicitProxy'."
      $downloader.Proxy = $proxy

    } elseif (!$downloader.Proxy.IsBypassed($url)) {
      # system proxy (pass through)
      $creds = $defaultCreds
      if ($creds -eq $null) {
        Write-Debug "Default credentials were null. Attempting backup method"
        $cred = get-credential
        $creds = $cred.GetNetworkCredential();
      }

      $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
      Write-Debug "Using system proxy server '$proxyaddress'."
      $proxy = New-Object System.Net.WebProxy($proxyaddress)
      $proxy.Credentials = $creds
      $downloader.Proxy = $proxy
    }
  }

  return $downloader
}

function Download-String {
param (
  [string]$url
 )
  $downloader = Get-Downloader $url

  return $downloader.DownloadString($url)
}

function Download-File {
param (
  [string]$url,
  [string]$file
 )
  #Write-Output "Downloading $url to $file"
  $downloader = Get-Downloader $url

  $downloader.DownloadFile($url, $file)
}

## Error Logging function 

function logdata {
param (
  [string]$data
)
  $logpath = "C:\Chef\chefboot.log"
  $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
  $lognote = [string]::Join(" ", $Stamp,$data)
  add-content -Path $logpath -Value $lognote -Force
} 

## URL can be obtanied from the chef official site https://downloads.chef.io/chef#windows ##
## Network MSI file should be specified in the download file client url if using network installer##
## Download the Chef client

$clientURL = 'https://packages.chef.io/files/stable/chef/13.7.16/windows/2016/chef-client-13.7.16-1-x64.msi' 
$clientDestination = "C:\\Windows\\Temp\\chef.msi"

Try{
	logdata ([string]::Join(" ",'Downloading File from', $clientURL))
	Download-File $clientURL $clientDestination
	logdata "Downloading Successful"
}
catch{
	logdata "Download Failed, please check the URL and download destination"
}


## Install the chef-client

Try{
	logdata "Starting Installation"
	Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\Windows\Temp\chef-log.txt', '/i C:\\Windows\\Temp\\chef.msi', 'ADDLOCAL="ChefClientFeature,ChefSchTaskFeature,ChefPSModuleFeature"') -NoNewWindow -Wait
	logdata "Installation Completed"
}
catch{
	logdata "Installation Failed, Please check the downloaded file"
}
### Add the following chef path to env variables $Env:Path ###

$Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
$OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path

## Add the chef path installed directory ## 

$NewPath = $OldPath + ’;’ + 'C:\opscode\chef\bin'+';'+'C:\opscode\chef\embedded\bin'

try{
	Set-ItemProperty -Path "$Reg" -Name PATH –Value $NewPath -Confirm:$false
	logdata "Added Chef to Path variables"
}
catch{
	logdata "Updating path variables FAILED, please check privileges"
}

## Get the Chef-server pem key ## 
#$clientURL = 'https://packages.chef.io/files/stable/chef/13.7.16/windows/2016/chef-client-13.7.16-1-x64.msi' 
#$clientDestination = "C:\\Windows\\Temp\\chef.msi"

#Try{
#	logdata ([string]::Join(" ",'Downloading File from', $clientURL))
#	Download-File $clientURL $clientDestination
#	logdata "Downloading Successful"
#}
#catch{
#	logdata "Download Failed, please check the URL and download destination"
#}

#New-Item -ItemType directory -Path C:\chef\.chef\
#$WebClient = New-Object System.Net.WebClient
#$WebClient.DownloadFile(“ftp://150.150.150.85/sri321.pem”,“C:\chef\sri231.pem”)
#$WebClient.DownloadFile(“ftp://150.150.150.85/.chef/a-cf-validator.pem”,“C:\chef\.chef\a-cf-validator.pem”)

#

# $keyurl = 'Address where the pem file is stored\organisation.pem'
# $keylocation = 'C:\\chef\\.chef\\atmecs-validator.pem'

# try{
# 	logdata ([string]::Join(" ",'Downloading key from', $keyurl))
# 	Download-File $keyurl $keylocation
# 	logdata "Successfully Downloaded organisation key"
# }
# catch{
# 	logdata "Downloading organisation key failed please check the url"
# }

## Set host file so the instance knows where to find chef-server

$hosts = "https://api.chef.io/organizations/a-cf"
$file = "C:\Windows\System32\drivers\etc\hosts"
$hosts | Add-Content $file

## Createm .pem file 

New-Item -ItemType directory -Path C:\chef\.chef\
$sri = {
  "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEArEtavLBGWCDRlMzw5nJUoJKOmnVmLIC7ibKBLze3j5FGLltU
hc2XW+5MxkNAhOeorHz5843Z/pIe/XcJEs1xPSqiwHwHcwh+93gHkCc/2EDJdzW+
LsCAPQLNdTkbgEzYU620b3beQfBFB8c72F918EVbtpjSEe9pYn0r30ox8i38eO3D
UjF5PLZZ8aN7ptsLSFWeYXeQCcJo2NbF+uMqZaqFnnLgi2yCLjX1Z2UpNZ9DjncF
7nhIYYXJLBhYXPvKNERLzbkNYF8ATsYQW8d1feyHU4UcXrlwBbhIbCNF14oyAn4e
9yJAY1/I1jECzhU0soXtCNFdlnE1Kv5WxK+1QQIDAQABAoIBAAH1ZVWpx1LvJJLF
daOY/x9IKzjURtIQsJETJ2bLAlouc5bJUP+oY6UW42aJky0vmPpE/W5oWWcMcC+/
b6n4DeZ9GpaHkmobWZ4kjil0WMRzkBa71KqhY5PN+VnwyUA/H2JsIhX2SvaC7bX1
7Nc71pJhp3Y+7HxptU/6TkpehIzVNjQaDL9zkMah6Oiv/jPeoGQDaktGAEl8bz0f
yj54oHyJITzRMDmJI0nu/+UHtSYdapwdWO6nN6ahu40wG12KNM6PdANdVCsbmV+k
C+ANyWjnBGHplK9BsL+Pszxp34gncfEU+g6c3KUX1OVhtOs0RXxiKZv9BOzWEpwM
XDLMBfUCgYEA49Sfw0etdhOKK5BVeLmUuBjyGawNruwHxYBU/4fT/wNhCgtisORC
eIR9Cbba7hE8Za9bZaYfLQEsLFLKjHI7F/bjYyMrsQifxMZhDbYktJPKcusWG8uF
J/fW99OfwYzOrhzphK/nfTvw+/8P2a2B/feA6+3JCdzvcfFk5MIEGosCgYEAwZjg
x4O1Eo5OW4iC96JsYLXP/31NKnv6TZdhWRZTOLq69ORbFPHzHkGBUASFW9jwMNiY
AH9GylU458lFXART/erRw54QcSdgOhNrBKyf2GNJJ6zT0pXTCL2pX60X+y0wUIQE
64O8OFhoRmj2crGE41k1HTseAU30CUhiuW4mBOMCgYAb0yf/7Y0d0p0ZXPNTXzbu
lP1cbUruhh0c3eODoc8eYgdD9sgC2p3TojqzKQXr9Wbu9E+xRmygTnhaoXHjXUAi
WSDERtNbN7Zrjd7kkc5Bz5r2FggJNP36N6aldc8ZEF1dnmJWtjULcnqoDCqfZzVt
EwFHzy6yaa1EuTqdRaTCqQKBgAcWMIw9HwC54tZo7dpgwLTdkuqYTJ3UgfobI34e
WheGhld2kHr4zFx8K16he7w7+bbgBthl0FKRwg6CCJ7wrZ5q3RjbDWEG/vfBRDac
lxFVuRTRt8NKprn4L14IOQuBwPYBjyiL3vT1D4QcTYEvTF0CI/aY9mU31EoOs0Z0
aMHfAoGAVw3Rsz/ciOQw0b7TOT95wBUUlKTe8txx3eesdPCZ+y1VeMDef2PM34Tb
V0ntKloOSUJ+hmisckZSfaZ6XSCj9uN4iqdScH5vU6xpMz20jMe8BlmABwHbI2Ww
2Fjfj0mvIoX19avRAbSkaftuyrvOrYIm1IXAjdMVlQzif1vszb4=
-----END RSA PRIVATE KEY-----
"
}

Set-Content -Path c:\chef\.chef\sri321.pem -Value $sri

## Create first-boot.json
$firstboot = @{
   "run_list" = @("role[base]")
}
Set-Content -Path c:\chef\first-boot.json -Value ($firstboot | ConvertTo-Json -Depth 10)

## Create client.rb

$nodeName = "Chef-Client-Node-{0}" -f (-join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_}))

$clientrb = @"
chef_server_url        'https://api.chef.io/organizations/a-cf'
validation_client_name 'a-cf-validator'
validation_key         'C:\chef\.chef\a-cf-validator.pem'
node_name              '{0}'
"@ -f $nodeName

Set-Content -Path c:\chef\client.rb -Value $clientrb

## Create knife.rb

$kniferb = @"
client_key               "C:\chef\sri321.pem"
chef_server_url          "https://api.chef.io/organizations/a-cf"
node_name                '{0}'
"@ -f $nodeName

Set-Content -Path c:\chef\knife.rb -Value $kniferb
## Run Chef
C:\opscode\chef\bin\chef-client.bat -j C:\chef\first-boot.json