# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    vb.cpus = 1
  end

  config.vm.box = "centos/7"
  config.vm.hostname = "server1"
  config.vm.network "private_network", ip: "192.168.10.10"
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true

  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
