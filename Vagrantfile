# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Global Settings
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
  end

  config.vm.synced_folder "backups", "/backups"
  config.vm.synced_folder "chef", "/tmp/chef"

  # Master node to take backups
  config.vm.define "master" do |master|
    master.vm.box = "centos-67"
    master.vm.box_url = "https://github.com/CommanderK5/packer-centos-template/releases/download/0.6.7/vagrant-centos-6.7.box"
    master.vm.network "private_network", ip: "192.168.50.2"
    # Install the same version of chef on both for fun
    master.vm.provision "shell", inline: <<-SHELL
     sudo yum update all
     sudo yum install -y wget
     if [ ! -f /tmp/chef/chef-server-core-12.0.0.rpm ]; then
        echo "Chef Server File not found, Downloading!"
        wget https://packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.0.8-1.el6.x86_64.rpm/download -O /tmp/chef/chef-server-core-12.0.0.rpm &> /dev/null
     fi
     if ! rpm -q chef-server-core-12.0.0
      then
        sudo rpm -Uvh /tmp/chef/chef-server-core-12.0.0.rpm
        echo "Chef Server installed now"
     fi

     if [ ! -f /tmp/chef/opscode-manage-1.6.2.rpm ]; then
        echo "opscode Manage File not found, Downloading!"
        wget https://packagecloud.io/chef/stable/packages/el/6/opscode-manage-1.6.2-1.el6.x86_64.rpm/download -O /tmp/chef/opscode-manage-1.6.2.rpm &> /dev/null
     fi
     if ! rpm -q opscode-manage-1.6.2
      then
        sudo rpm -Uvh /tmp/chef/opscode-manage-1.6.2.rpm
        echo "Opscode Manage installed now"
     fi
     sudo chef-server-ctl reconfigure
     sudo opscode-manage-ctl reconfigure

     # Setup the user
     if ! sudo chef-server-ctl user-show test &> /dev/null
      then
        echo "User not created, creating test user"
        sudo chef-server-ctl user-create test test test test@example.com 'password' --filename /tmp/chef/master/test.pem
        sudo chef-server-ctl user-show test
     fi

     # Setup the organization
     if ! sudo chef-server-ctl org-show test &> /dev/null
      then
        echo "Org not created, creating test organization"
        sudo chef-server-ctl org-create test 'Test Org' --association_user test --filename /tmp/chef/master/test-validator.pem
        sudo chef-server-ctl org-show test
     fi
    SHELL
  end

  config.vm.define "client" do |client|
    client.vm.box = "centos-7"
    client.vm.box_url = "https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box"

    client.vm.provision "chef_client" do |chef|
      chef.chef_server_url = "https://192.168.50.2/organizations/test"
      chef.node_name = "sample-client"
      chef.validation_key_path = "./chef/master/test-validator.pem"
      chef.validation_client_name = "test-validator"
      chef.environment = "production"
      chef.add_role "hello"
    end
  end

  # DR node to restore backups
  config.vm.define "dr" do |dr|
    dr.vm.box = "centos-7"
    dr.vm.box_url = "https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box"
    dr.vm.network "private_network", ip: "192.168.50.4"
    dr.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = "2048"
    end
    dr.vm.provision "shell", inline: <<-SHELL
     sudo yum update all
     sudo yum install -y wget
     if [ ! -f /tmp/chef/chef-server-core-12.4.1.rpm ]; then
        echo "Chef Server File not found, Downloading!"
        wget https://packagecloud.io/chef/stable/packages/el/7/chef-server-core-12.4.1-1.el7.x86_64.rpm/download -O /tmp/chef/chef-server-core-12.4.1.rpm &> /dev/null
     fi
     if ! rpm -q chef-server-core-12.4.1
      then
        sudo rpm -Uvh /tmp/chef/chef-server-core-12.4.1.rpm
        echo "Chef Server installed now"
     fi

     if [ ! -f /tmp/chef/chef-manage-2.2.0.rpm ]; then
        echo "opscode Manage File not found, Downloading!"
        wget https://packagecloud.io/chef/stable/packages/el/7/chef-manage-2.2.0-1.el7.x86_64.rpm/download -O /tmp/chef/chef-manage-2.2.0.rpm &> /dev/null
     fi
     if ! rpm -q chef-manage-2.2.0
      then
        sudo rpm -Uvh /tmp/chef/chef-manage-2.2.0.rpm
        echo "Opscode Manage installed now"
     fi

     if [ ! -f /tmp/chef/opscode-reporting-1.5.6.rpm ]; then
        echo "opscode reporting File not found, Downloading!"
        wget https://packagecloud.io/chef/stable/packages/el/7/opscode-reporting-1.5.6-1.el7.x86_64.rpm/download -O /tmp/chef/opscode-reporting-1.5.6.rpm &> /dev/null
     fi
     if ! rpm -q opscode-reporting-1.5.6
      then
        sudo rpm -Uvh /tmp/chef/opscode-reporting-1.5.6.rpm
        echo "Opscode reporting installed now"
     fi
     sudo chef-server-ctl reconfigure
     sudo chef-manage-ctl reconfigure
     sudo opscode-reporting-ctl reconfigure

     # Setup the user
     if ! sudo chef-server-ctl user-show test &> /dev/null
      then
        echo "User not created, creating test user"
        sudo chef-server-ctl user-create test test test test@example.com 'password' --filename /tmp/chef/dr/test.pem
        sudo chef-server-ctl user-show test
     fi

     # Setup the organization
     if ! sudo chef-server-ctl org-show test &> /dev/null
      then
        echo "Org not created, creating test organization"
        sudo chef-server-ctl org-create test 'Test Org' --association_user test --filename /tmp/chef/dr/test-validator.pem
        sudo chef-server-ctl org-show test
     fi

     # Disable Firewall
     if sudo systemctl status firewalld &> /dev/null
      then
        echo "Firewall is running, disabling and stopping"
        sudo systemctl disable firewalld
        sudo systemctl stop firewalld
     fi
    SHELL
  end

  config.vm.define "client-new" do |client|
    client.vm.box = "centos-7"
    client.vm.box_url = "https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box"

    client.vm.provision "chef_client" do |chef|
      chef.chef_server_url = "https://192.168.50.4/organizations/test"
      chef.node_name = "sample-client-new"
      chef.validation_key_path = "./chef/master/test-validator.pem"
      chef.validation_client_name = "test-validator"
      chef.environment = "production"
      chef.add_role "hello"
    end
  end
end
