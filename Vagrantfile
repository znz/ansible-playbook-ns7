# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = ENV['VM_HOSTNAME'] || 'ovpn.127.0.0.1.nip.io'
  config.vm.box = 'bento/debian-9.3'

  config.vm.provider 'virtualbox' do |vb|
    # Don't boot with headless mode
    vb.gui = true if ENV['VM_GUI']

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ['modifyvm', :id, '--memory', ENV['VM_MEMORY'] || '512']

    vb.cpus = 2
    vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
    vb.customize [
      'modifyvm', :id,
      '--hwvirtex', 'on',
      '--nestedpaging', 'on',
      '--largepages', 'on',
      '--ioapic', 'on',
      '--pae', 'on',
      '--paravirtprovider', 'kvm',
    ]
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'provision/playbook.yml'
    ansible.verbose = ENV['ANSIBLE_VERBOSE'] if ENV['ANSIBLE_VERBOSE']
    ansible.tags = ENV['ANSIBLE_TAGS'] if ENV['ANSIBLE_TAGS']

    ansible.galaxy_role_file = 'provision/requirements.yml'
    unless ENV['ANSIBLE_GALAXY_WITH_FORCE']
      # without --force
      ansible.galaxy_command = 'ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path}'
    end

    extra_vars = {
      stage: 'vagrant',
      postfix_relay_smtp_server: ENV['SMTP_SERVER'],
      postfix_relay_smtp_user: ENV['SMTP_USER'],
      postfix_relay_smtp_pass: ENV['SMTP_PASS'],
    }
    extra_vars[:nadoka] = [
        {
          service_name: ENV['NADOKA_SERVICE_NAME'],
          irc_host: ENV['NADOKA_IRC_HOST'],
          irc_port: ENV['NADOKA_IRC_PORT'],
          irc_pass: ENV['NADOKA_IRC_PASS'],
          irc_ssl_params: '{}',
          irc_nick: 'User',
          channel_info: ENV['NADOKA_CHANNEL_INFO'],
        },
    ] if ENV.key?('NADOKA_SERVICE_NAME')
    extra_vars[:atig] = ENV['ATIG_USERNAMES'].to_s.split(',').map.with_index { |username, idx|
      {
        username: username,
        realname: 'sid only stream',
        atig_port: 16668+idx,
        port: 26668+idx,
        host: 'nil',
        pass: '"dummy_pass"',
        acl: <<-ACL,
          deny all
          allow 127.0.0.1
          allow ::1
          allow 192.168.8.0/24
        ACL
        allow_from: "192.168.8.0/24",
      }
    }
    extra_vars[:atig_oauth] = ENV['ATIG_OAUTH']
    ansible.extra_vars = extra_vars
  end
end
