require 'spec_helper'

describe 'pbis' do
  context "default" do
    let (:params) do {
        :ad_domain     => 'domain.com.ar',
        :bind_password => 'password',
        :bind_username => 'username',
        :repository    => 'http://localhost/'
    }
    end
    it { should compile }
    it { should contain_class('pbis::params') }
    it do
      is_expected.to contain_wget__fetch('http://localhost//pbis-open-8.5.0.153.linux.x86_64.rpm.sh').with(
          'destination' => '/tmp/pbis-open-8.5.0.153.linux.x86_64.rpm.sh',
          'timeout'     => 0,
          'verbose'     => false
      )
    end
    it do
      is_expected.to contain_exec('install pbis').with(
          'command' => "/bin/sh /tmp/pbis-open-8.5.0.153.linux.x86_64.rpm.sh install",
      )
    end
    it do
      is_expected.to contain_service('lwsmd').with(
          'enable' => true,
          'ensure' => 'running'
      )
    end
    it { is_expected.to contain_service('lwsmd').that_requires('exec[install pbis]') }
    it { is_expected.to contain_exec('join_domain') }
    it { is_expected.to contain_exec('join_domain').that_requires('service[lwsmd]') }
    it do
      is_expected.to contain_exec('update_DNS').with(
          'refreshonly' => true
      )
    end
    it { is_expected.to contain_exec('update_DNS').that_requires('exec[join_domain]') }
    it do
      is_expected.to contain_file('/etc/pbis/pbis.conf').with(
          'mode'     => '0644',
          'owner'    => 'root',
          'group'    => 'root',
          'ensure'   => 'file'
      )
    end
    it { is_expected.to contain_file('/etc/pbis/pbis.conf').that_requires('exec[join_domain]') }
    it { is_expected.to contain_file('/etc/pbis/pbis.conf').that_notifies('exec[clear_ad_cache]') }
    it do
      is_expected.to contain_exec('configure_pbis').with(
          'refreshonly' => true
      )
    end
    it { is_expected.to contain_exec('configure_pbis').that_subscribes_to('file[/etc/pbis/pbis.conf]') }
    it do
      is_expected.to contain_exec('clear_ad_cache').with(
          'refreshonly' => true
      )
    end
    it { is_expected.to contain_exec('clear_ad_cache').that_subscribes_to('exec[configure_pbis]') }
  end
end