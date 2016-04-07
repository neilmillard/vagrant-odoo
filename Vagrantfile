# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'resolv'

# use version 2
Vagrant.configure(2) do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "boxcutter/centos72"

  config.ssh.forward_agent = true

  # configure the proxies using https://github.com/tmatilai/vagrant-proxyconf
  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://proxy:3128/"
    config.proxy.https    = "https://proxy:3128/"
    config.proxy.no_proxy = "localhost,127.0.0.1, 192.168.33.*, 192.168.56.*, 10.10.102.*"
  end

  config.vm.provider :virtualbox do |vb|
    # This allows symlinks to be created within the /vagrant root directory,
    # which is something librarian-puppet needs to be able to do. This might
    # be enabled by default depending on what version of VirtualBox is used.
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional", "--draganddrop", "bidirectional"]
  end

  boxes = [
      { name: 'default',              role: 'odoo',      environment: 'dev',   ip: '192.168.56.10', memory: '1024', },
      { name: 'odoo1',              role: 'odoo',      environment: 'dev',   ip: '192.168.56.11', memory: '1024', },
      { name: 'dbserver1',          role: 'pgprimary', environment: 'dev',   ip: '192.168.56.12', memory: '1024', },
  ]

  boxes.each do | box |

      config.vm.define box[:name] do |box_config|

          if ENV['COMPUTERNAME'] and ENV['USERDNSDOMAIN']
            box_config.vm.hostname = "#{box[:name]}.#{ENV['COMPUTERNAME']}.#{ENV['USERDNSDOMAIN']}".downcase
          else
            box_config.vm.hostname = box[:name]
          end

          box_config.vm.provider :virtualbox do |vb|
            vb.customize [ "modifyvm", :id, "--memory", box[:memory] ]
            vb.customize [ "modifyvm", :id, "--cpus", "2"]
            vb.customize [ "modifyvm", :id, "--ioapic", "on"]
            vb.customize [ "modifyvm", :id, "--natdnshostresolver1", "on"]

          end
          # generally better than port forwarding if running multiple VMs, just access boxes on local private IP
          box_config.vm.network :private_network, ip:box[:ip]

          _args = "--role #{box[:role]} --environment #{box[:environment]}"

          # run a provisioning script
          box_config.vm.provision :shell, :path => "init.sh", :args => "#{_args}"
      end
  end
end
