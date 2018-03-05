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

octo_exe_path = win_friendly_path("#{tools['home']}/octo.exe")

# download and unzip octopus tools
windows_zipfile tools['home'] do
  source tools['url'] % { version: node['octopus']['tools']['version'] }
  checksum tools['checksum']
  action :unzip
  not_if { ::File.exists?(octo_exe_path) }
end
