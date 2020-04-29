require 'yaml'

Vagrant.configure('2') do |config|
end

IP_ADDRESSES = YAML.load_file('ips.yaml')
NETWORK = IP_ADDRESSES.delete('_network_')
IP_ADDRESSES.transform_values! { |ip| NETWORK + ip.to_s }

Dir.glob('vagrant/**/Vagrantfile').each do |f|
  load File.expand_path(f) if File.exist?(f)
end
