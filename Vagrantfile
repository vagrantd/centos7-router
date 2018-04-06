# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "lot/centos7-netlab"
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |v|
    v.name = "build_centos7_router"
  end

  config.vm.provision "shell", path: "install.sh"
end
