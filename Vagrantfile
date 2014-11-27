# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.define "192.168.33.10" do |box|
    box.vm.box = "ubuntu/trusty64"
    box.vm.network "private_network", ip: "192.168.33.10"
    box.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize [ 'modifyvm', :id, '--natdnshostresolver1', 'on' ]
    end
  end

  config.ssh.forward_agent = true

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'site.yml'
    ansible.inventory_path = 'development'
    ansible.verbose = 'vvv'
    ansible.extra_vars = {
        user: 'vagrant',
        app_name: ENV['APP_NAME'] || 'demo_app'
    }
  end


end
