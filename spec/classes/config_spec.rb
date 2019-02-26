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

      describe 'with default settings' do
        it do
          is_expected.to contain_file(
            '/opt/instana/agent/etc/instana/configuration.yaml',
          ).with(
            ensure: 'file',
            group: 'root',
            mode: '0640',
            owner: 'root',
          )
        end

        it do
          is_expected.to contain_file(
            '/opt/instana/agent/etc/instana/com.instana.agent.main.config.Agent.cfg',
          ).with(
            ensure: 'file',
            owner: 'root',
            group: 'root',
            mode: '0640',
            content: <<~CFG,
              # This file is managed by Puppet
              # Internal Instana Agent configuration.
              scheduler.threads = 4
              http.threads = 4
              use-cloud-provider-id = true
              mode = APM
            CFG
          ).that_notifies('Service[instana-agent]')
        end

        it do
          is_expected.to contain_file(
            '/opt/instana/agent/etc/instana/com.instana.agent.main.config.UpdateManager.cfg',
          ).with(
            ensure: 'file',
            group: 'root',
            owner: 'root',
            mode: '0640',
            content: <<~CFG,
              # This file is managed by Puppet

              # Instana Update Manager configuration.
              # AUTO for automatic updates with given schedule. OFF for no automatic updates.
              mode = OFF
              # DAY for daily, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
              every = DAY
              # Time is hh:mm in 24 hours format.
              at = 04:30
            CFG
          )
        end

        it do
          is_expected.to contain_file(
            '/opt/instana/agent/etc/instana/com.instana.agent.bootstrap.AgentBootstrap.cfg',
          ).with(
            ensure: 'file',
            group: 'root',
            owner: 'root',
            mode: '0640',
            content: <<~CFG,
              # To prevent automatic updates and use a fixed version of the agent set it here


              # Provide the source of agent installation in the log output for debugging purposes
              origin = public_puppet
            CFG
          )
        end
      end
    end
  end
end
