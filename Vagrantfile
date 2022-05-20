require 'yaml'

DEFAULT_CPU_COUNT = 2
DEFAULT_MEMORY_SIZE = 4096

Vagrant.configure('2') do |config|
  # Handle remote libvirt hosts
  if File.file?('remote.yaml')
    REMOTE_HOST = YAML.load_file('remote.yaml')['remote_host']
    config.vm.provider :libvirt do |libvirt|
      libvirt.host = REMOTE_HOST
      libvirt.connect_via_ssh = true
    end
    config.ssh.proxy_command = "ssh -W %h:%p root@#{REMOTE_HOST}"
  end

  # Default VM size settings
  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = DEFAULT_CPU_COUNT
    libvirt.memory = DEFAULT_MEMORY_SIZE
  end

  config.vm.provider :virtualbox do |vbox|
    vbox.cpus = DEFAULT_CPU_COUNT
    vbox.memory = DEFAULT_MEMORY_SIZE
  end
end

# Handle IP address definition
IP_ADDRESSES = YAML.load_file('ips.yaml')
NETWORK = IP_ADDRESSES.delete('_network_')
IP_ADDRESSES.transform_values! { |ip| NETWORK + ip.to_s }
IP_ADDRESSES['_network_'] = NETWORK

if ARGV.length == 2 && ARGV[0] == 'up' &&  !IP_ADDRESSES.key?(ARGV[1])
  raise Vagrant::Errors::VagrantError.new, "No IP Configured for #{ARGV[1]}"
end

Dir.glob('vagrant/**/Vagrantfile').each do |f|
  load File.expand_path(f) if File.exist?(f)
end
