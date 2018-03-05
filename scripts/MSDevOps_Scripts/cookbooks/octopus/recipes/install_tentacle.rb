#
# Cookbook Name:: octopus
# Recipe:: install_tentacle
#


tentacle = node['octopus']['tentacle']
tools = node['octopus']['tools']

# download and install the tentacle service
windows_package tentacle['package_name'] do
  source tentacle['url'] % { version: node['octopus']['tentacle']['version'] }
  checksum tentacle['checksum']
  options "INSTALLLOCATION=\"#{tentacle['install_dir']}\""
  action :install
end

#octo_exe_path = win_friendly_path("#{tools['home']}/octo.exe")
octo_exe_path = "#{tools['home']}\octo.exe"

# download and unzip octopus tools
#windows_zipfile tools['home'] do
#  source tools['url'] % { version: node['octopus']['tools']['version'] }
#  checksum tools['checksum']
#  action :unzip
#  not_if { ::File.exists?(octo_exe_path) }
#end

powershell_script "octopus_tools" do
  code <-EOH
    # Download Octopus tools zip file
    $clnt = new-object System.Net.WebClient
    $file = "#{tools['home']}\OctopusTools.#{tools['version']}.zip"
    $url = "#{tools['url']}"
    $clnt.DownloadFile($url,$file)

    # Unzip Octopus tools
    $shell_app = new-object -com shell.application
    $filename = "#{tools['home']}\OctopusTools.#{tools['version']}.zip"
    $destination = "#{tools['home']}"
    $destination.Copyhere($filename.items())
  EOH
  not_if { ::File.exists?(octo_exe_path) }
end
