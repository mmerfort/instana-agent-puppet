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
        is_expected.to contain_package('instana-agent-static')
      end

      context 'Repository configuration' do
        case facts[:osfamily]
        when 'Debian'
          context 'using defaults' do
            it { is_expected.to contain_class('apt') }
            it do
              is_expected.to contain_apt__key('puppetlabs').with(
                ensure: 'present',
                id: 'B878152E2F084D46F878FA20BED2D0969BAD82DE',
                source: 'https://packages.instana.io/Instana.gpg',
              )
            end

            it do
              is_expected.to contain_apt__source('instana-agent').with(
                ensure: 'present',
                architecture: 'amd64',
                include: {
                  'src' => false,
                  'deb' => true,
                },
                location: 'https://_:testkey@packages.instana.io/agent',
                release: 'generic',
                repos: 'main',
              ).that_notifies('Package[instana-agent-static]')
            end
          end
        when 'Suse'
          it do
            is_expected.to contain_exec('import gpg key').with(
              command: '/bin/rpm --import https://packages.instana.io/Instana.gpg',
              unless: '/bin/rpm -q gpg-pubkey | grep gpg-pubkey-9bad82de-574bdebd ',
            )
          end
          it do
            is_expected.to contain_zypprepo('Instana-Agent').with(
              baseurl: 'https://_:testkey@packages.instana.io/agent/generic/x86_64',
              enabled: 1,
              name: 'Instana-Agent',
              gpgkey: 'https://packages.instana.io/Instana.gpg',
              gpgcheck: 1,
              type: 'rpm-md',
            ).that_requires('Exec[import gpg key]')
          end
        when 'RedHat'
          it do
            is_expected.to contain_yumrepo('Instana-Agent').with(
              ensure: 'present',
              assumeyes: true,
              baseurl: 'https://_:testkey@packages.instana.io/agent/generic/x86_64',
              enabled: true,
              gpgkey: 'https://packages.instana.io/Instana.gpg',
              gpgcheck: true,
              repo_gpgcheck: true,
              sslverify: true,
            )
          end
        end
      end
    end
  end
end
