# Vagrantfile for testing dev_env_automation in a clean Linux VM
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/noble64" # Ubuntu 24.04 LTS

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # Provisioning script
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git make curl wget build-essential
  SHELL
end
