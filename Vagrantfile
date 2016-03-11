# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Master node to take backups
  config.vm.define "master" do |master|
    master.vm.box = "centos/7"
    # master.vm.network "forwarded_port", guest: 80, host: 8080
    # master.vm.network "private_network", ip: "192.168.33.10"
  end

  # DR node to restore backups
  config.vm.define "dr" do |dr|
    dr.vm.box = "centos/7"
    # dr.vm.network "forwarded_port", guest: 80, host: 8080
    # dr.vm.network "private_network", ip: "192.168.33.10"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
  end

  config.vm.synced_folder "backups", "/backups"
  # config.vm.network "public_network"

  # Install the same version of chef on both for fun
  config.vm.provision "shell", inline: <<-SHELL
     sudo yum update all
     sudo yum install -y wget
     if [ ! -f /tmp/chef-server-core-12.1.0.rpm ]; then
        echo "File not found Downloading!"
        wget https://packagecloud.io/chef/stable/packages/el/7/chef-server-core-12.1.0-1.el7.x86_64.rpm/download -O /tmp/chef-server-core-12.1.0.rpm
     fi
     if ! rpm -q chef-server-core-12.1.0
      then
        sudo rpm -Uvh /tmp/chef-server-core-12.1.0.rpm
     fi 
     sudo chef-server-ctl reconfigure
  SHELL
end
