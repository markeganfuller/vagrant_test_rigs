Vagrant.configure("2") do |config|
  # Basic stretch box
  config.vm.define 'stretch' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.hostname = 'stretch'
    v.vm.network 'private_network', ip: '192.168.33.11', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3
  end

  # Stretch with docker installed
  config.vm.define 'stretch-docker' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_docker.sh'
    v.vm.hostname = 'stretch-docker'
    v.vm.network 'private_network', ip: '192.168.33.12', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3
  end

  # Stretch with nginx test rig
  config.vm.define 'stretch-nginx' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_nginx.sh'
    v.vm.hostname = 'stretch-nginx'
    v.vm.network 'private_network', ip: '192.168.33.13', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3
  end

  # Stretch with php test rig
  config.vm.define 'stretch-php' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_php.sh'
    v.vm.hostname = 'stretch-php'
    v.vm.network 'private_network', ip: '192.168.33.14', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3
  end

  # Stretch with puppetserver test rig
  config.vm.define 'stretch-puppetserver' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_puppetserver.sh'
    v.vm.hostname = 'stretch-puppetserver'
    v.vm.network 'private_network', ip: '192.168.33.15', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3

    v.vm.provider 'virtualbox' do |vbox|
      vbox.memory = 1024
    end

    v.vm.provider :libvirt do |libvirt|
      libvirt.memory = 1024
    end
  end
  #
  # Stretch with openvpn test rig
  config.vm.define 'stretch-openvpn' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_openvpn.sh'
    v.vm.hostname = 'stretch-openvpn'
    v.vm.network 'private_network', ip: '192.168.33.16', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3

    v.vm.provider 'virtualbox' do |vbox|
      vbox.memory = 1024
    end

    v.vm.provider :libvirt do |libvirt|
      libvirt.memory = 1024
    end
  end

  # Stretch with extra disks
  config.vm.define 'stretch-disks' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.hostname = 'stretch-disks'
    v.vm.network 'private_network', ip: '192.168.33.17', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3

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
    v.vm.provider :libvirt do |libvirt|
      # Create 2 additional disks to be used in testing disk setup
      libvirt.storage :file, :size => '5M'
      libvirt.storage :file, :size => '5M'
    end

  end

  # Stretch with a software raid setup
  config.vm.define 'stretch-raid' do |v|
    v.vm.box = 'debian/stretch64'
    v.vm.provision 'shell', path: 'scripts/deb_default.sh'
    v.vm.provision 'shell', path: 'scripts/stretch_raid.sh'
    v.vm.hostname = 'stretch-raid'
    v.vm.network 'private_network', ip: '192.168.33.18', libvirt__dhcp_enabled: false
    v.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 3

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

    v.vm.provider :libvirt do |libvirt|
      9.times do
      # Create 9 additional disks to be used in testing RAID
      libvirt.storage :file, :size => '5M'
      end
    end
  end
end
