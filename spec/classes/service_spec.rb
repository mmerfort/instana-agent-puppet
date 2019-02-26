# frozen_string_literal: true

require 'spec_helper'

describe 'instana_agent::install' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:pre_condition) do
        <<-PUP
          class { 'instana_agent':
            key => 'testkey',
         }
        PUP
      end

      it do
        is_expected.to compile
      end

      it do
        is_expected.to contain_service('instana-agent')
      end

      if facts['systemd']
        context 'With systemd used' do
          it do
            is_expected.to contain_class('systemd::systemctl::daemon_reload')
          end

          it do
            is_expected.to contain_file('/etc/systemd/system/instana-agent.service.d').with(
              ensure: 'directory',
              group: 'root',
              owner: 'root',
              mode: '0750',
            )
          end

          it do
            is_expected.to contain_file(
              '/etc/systemd/system/instana-agent.service.d/10-resources.conf',
            ).with(
              ensure: 'file',
              group: 'root',
              owner: 'root',
              mode: '0640',
              content: <<~CFG,
                [Service]
                CPUAccounting=true
                CPUQuota=50%
                MemoryAccounting=true
                MemoryMax=512
              CFG
            ).that_notifies('Class[systemd::systemctl::daemon_reload]')
          end
        end
      end
    end
  end
end
