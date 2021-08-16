require 'yaml'

Vagrant.configure('2') do |config|
  if File.file?('remote.yaml')
    REMOTE_HOST = YAML.load_file('remote.yaml')['remote_host']
    config.vm.provider :libvirt do |libvirt|
      libvirt.host = REMOTE_HOST
      libvirt.connect_via_ssh = true
    end
    config.ssh.proxy_command = "ssh -W %h:%p root@#{REMOTE_HOST}"
  end
end

IP_ADDRESSES = YAML.load_file('ips.yaml')
NETWORK = IP_ADDRESSES.delete('_network_')
IP_ADDRESSES.transform_values! { |ip| NETWORK + ip.to_s }
IP_ADDRESSES['_network_'] = NETWORK

Dir.glob('vagrant/**/Vagrantfile').each do |f|
  load File.expand_path(f) if File.exist?(f)
end
