# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV['BOX_NAME'] || "DjangoDevelEnv"
BOX_URI = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vbox.box"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = BOX_NAME
    config.vm.box_url = BOX_URI

    #Redis
    config.vm.network "forwarded_port", guest: 6379, host: 6379
    #Memcached
    config.vm.network "forwarded_port", guest: 11211, host: 11211
    #MySQL
    config.vm.network "forwarded_port", guest: 3306, host: 3306
    #Sentry
    config.vm.network "forwarded_port", guest: 9000, host: 9000
    #Shipyard
    #config.vm.network "forwarded_port", guest: 8005, host: 8005

    config.vm.provider :vmware_fusion do |f, override|
        override.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vmwarefusion.box"
    end

    if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?
        # Install Docker
        pkg_cmd = "wget -q -O - https://get.docker.io/gpg | apt-key add -;" \
          "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list;" \
          "apt-get update -qq; apt-get install -q -y --force-yes lxc-docker; "
        # Add vagrant user to the docker group
        pkg_cmd << "usermod -a -G docker vagrant; "

        pkg_cmd << "ln -s /vagrant/bin/.bash_profile /home/vagrant/.bash_profile;"
        pkg_cmd << "chmod +x /vagrant/bin/*;"
        pkg_cmd << "sh /vagrant/bin/build-images.sh;"

        config.vm.provision :shell, :inline => pkg_cmd
    end
end