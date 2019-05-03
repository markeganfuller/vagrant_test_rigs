Vagrant.configure("2") do |config|
  # Basic stretch box
  config.vm.define 'stretch' do |v|
    v.vm.box = 'debian/contrib-stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.hostname = 'stretch'
    v.vm.network 'private_network', ip: '192.168.33.11'
  end

  # Stretch with docker installed
  config.vm.define 'stretch-docker' do |v|
    v.vm.box = 'debian/contrib-stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_docker.sh'
    v.vm.hostname = 'stretch-docker'
    v.vm.network 'private_network', ip: '192.168.33.12'
  end

  # Stretch with nginx test rig
  config.vm.define 'stretch-nginx' do |v|
    v.vm.box = 'debian/contrib-stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_nginx.sh'
    v.vm.hostname = 'stretch-nginx'
    v.vm.network 'private_network', ip: '192.168.33.13'
  end

  # Stretch with php test rig
  config.vm.define 'stretch-php' do |v|
    v.vm.box = 'debian/contrib-stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_php.sh'
    v.vm.hostname = 'stretch-php'
    v.vm.network 'private_network', ip: '192.168.33.14'
  end

  # Stretch with extra disks
  config.vm.define 'stretch-disks' do |v|
    v.vm.box = 'debian/contrib-stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.hostname = 'stretch-disks'
    v.vm.network 'private_network', ip: '192.168.33.15'

    v.vm.provider 'virtualbox' do |vbox|
      # Create 2 additional disks to be used in testing disk setup
      (0...2).each do |d|
        disk_file = "disk#{d}.vdi"
        unless File.exist?(disk_file)
          vbox.customize ['createhd', '--filename', disk_file, '--size', 2048]
        end
        # Note we connect to a port +1 as port 0 has the root disk
        vbox.customize ['storageattach', :id, '--storagectl', 'SATA Controller',
                        '--port', d + 1, '--device', 0, '--type', 'hdd',
                        '--medium', disk_file]
      end
    end
  end

  # Stretch with a software raid setup
  config.vm.define 'stretch-raid' do |v|
    v.vm.box = 'debian/contrib-stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_raid.sh'
    v.vm.hostname = 'stretch-raid'
    v.vm.network 'private_network', ip: '192.168.33.16'

    v.vm.provider 'virtualbox' do |vbox|
      # Create 9 additional disks to be used in testing RAID
      (0...9).each do |d|
        disk_file = "disk#{d}.vdi"
        unless File.exist?(disk_file)
          vbox.customize ['createhd', '--filename', disk_file, '--size', 2048]
        end
        # Note we connect to a port +1 as port 0 has the root disk
        vbox.customize ['storageattach', :id, '--storagectl', 'SATA Controller',
                        '--port', d + 1, '--device', 0, '--type', 'hdd',
                        '--medium', disk_file]
      end
    end
  end
end
