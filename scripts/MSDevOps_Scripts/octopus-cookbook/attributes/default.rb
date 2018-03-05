# Octopus Tentacle attributes
default['octopus']['tentacle']['version'] = "3.17.0"
default['octopus']['tentacle']['package_name'] = "Octopus Deploy Tentacle"
default['octopus']['tentacle']['install_dir'] = 'C:\Program Files\Octopus Deploy\Tentacle'
default['octopus']['tentacle']['port'] = "10933"
default['octopus']['tentacle']['home'] = 'C:\Octopus'
default['octopus']['tentacle']['role'] = "webserver"
default['octopus']['tentacle']['name'] = "Tentacle"
default['octopus']['tentacle']['environment'] = node.chef_environment

# Octopus Tools attributes
default['octopus']['tools']['version'] = "2.5.10.39"
default['octopus']['tools']['url'] = "http://download.octopusdeploy.com/octopus-tools/%{version}/OctopusTools.%{version}.zip"
default['octopus']['tools']['checksum'] = "0790ed04518e0b50f3000093b4a2b4ad47f0f5c9af269588e82d960813abfd67"
default['octopus']['tools']['home'] = "C:\\tools\\OctopusTools.%{version}"

# replace with your octopus server thumbprint
default['octopus']['server']['thumbprint'] = "018A371AAB26B31B381322B21CCF8D62DFC53C65"

# replace with your octopus server api endpoint and key
default['octopus']['api']['uri'] = "http://150.150.150.88/api"
default['octopus']['api']['key'] = "API-QWMI1C8GX6OUFJAAFNJOKMKJBJK"

if node['kernel']['machine'] =~ /x86_64/
  default['octopus']['tentacle']['url'] = "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.%{version}-x64.msi"
  default['octopus']['tentacle']['checksum'] = "cb81f5296f7843c5c04cb20a02793bb14dad50f6453a0f264ebe859e268d8289"
else
  default['octopus']['tentacle']['url'] = "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.%{version}.msi"
  default['octopus']['tentacle']['checksum'] = "725222257424115455b4b8e38584aa5112e3be93bb30fea9345544e4ab7a2555"
end
