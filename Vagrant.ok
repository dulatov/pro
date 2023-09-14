# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
    :proxy => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.56.41', adapter: 2, netmask: "255.255.255.0",  virtualbox__intnet: "int-net"},
                   {ip: '192.168.58.100', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "vboxnet1"}
                ]
    }, 
 :websrv1 => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.56.42', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "int-net"}
                ]
    }, 
    :websrv2 => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.56.43', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "int-net"},
                ]
    },
    :alert => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.56.44', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "int-net"},
                ]
    },
    :log => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.56.45',  adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "int-net"}
                ]
    },
    :zabbix => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.56.46', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "int-net"},
                   {ip: '192.168.58.101', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "vboxnet1"}
                ]
    }
}

Vagrant.configure("2") do |config|
    MACHINES.each do |boxname, boxconfig|
        config.vm.define boxname do |box|
		    box.vm.provider :vmware
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
             boxconfig[:net].each do |ipconf|
              box.vm.network "private_network", ip: ipconf[:ip], netmask: ipconf[:nemask], adapter: ipconf[:adapter], virtualbox_intnet: ipconf[:virtualbox_intnet]
             end
        end
    end
    #MACHINES
end 
#Vagrant.config
