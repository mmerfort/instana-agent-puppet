# frozen_string_literal: true

require 'spec_helper'

describe 'instana_agent' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      describe 'with only bare minimum parameters set' do
        let(:params) do
          {
            key: 'testkey',
          }
        end

        describe 'init' do
          it { is_expected.to compile }
          it { is_expected.to contain_class('instana_agent') }
          it { is_expected.to contain_class('instana_agent::install') }
          it do
            is_expected.to contain_class('instana_agent::config')
              .that_requires('Class[instana_agent::install]')
          end
          it do
            is_expected.to contain_class('instana_agent::service')
              .that_requires('Class[instana_agent::config]')
          end
          it do
            is_expected.to contain_class('instana_agent::required_config')
              .that_requires('Class[instana_agent::service]')
          end
        end

        describe 'main config' do
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

        describe 'Repository configuration' do
          it do
            is_expected.to contain_package('instana-agent-static')
          end

          case facts[:osfamily]
          when 'Debian'
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

        describe 'service configuration' do
          it do
            is_expected.to contain_service('instana-agent')
          end

          if facts['systemd']
            context 'with systemd used' do
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
        describe 'required config' do
          it do
            is_expected.to contain_file(
              '/opt/instana/agent/etc/instana/com.instana.agent.main.sender.Backend.cfg',
            ).with(
              ensure: 'file',
              group: 'root',
              mode: '0640',
              owner: 'root',
              content: <<~CFG
                # Configures connection to the Instana SaaS. Changes will be hot-reloaded.

                # Host and Port usually do not need to be changed, but can be modified to
                # tunnel connections.
                host=saas-us-west-2.instana.io
                port=443
                protocol=HTTP/2

                # By setting a comma separated list of certificate fingerprints, the agent will
                # refuse connection in case any other certificate is presented by the server.
                # This prevents MITM attacks, but some situations might require to accept
                # certificates other than Instana ones or even any certificate.
                # fingerprints=29:17:5A:F4:2E:35:DF:87:D6:1F:4D:C8:A8:01:D2:43:18:47:BF:6E

                # The HTTP/2 connection to Instana SaaS can be proxied.

                # Access Key for your SaaS installation. Is pre-filled during agent download.
                key=testkey
              CFG
            )
          end

          it do
            is_expected.to contain_file(
              '/opt/instana/agent/etc/mvn-settings.xml',
            ).with(
              ensure: 'file',
              group: 'root',
              owner: 'root',
              mode: '0640',
              content: <<~CFG
                <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
                          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
                  <localRepository>data/repo</localRepository>
                  <servers>
                    <server>
                      <id>features</id>
                      <username>_</username>
                      <password>testkey</password>
                    </server>
                    <server>
                      <id>shared</id>
                      <username>_</username>
                      <password>testkey</password>
                    </server>
                  </servers>

                  <!-- If you want to access the Instana repository using an HTTP/Socks proxy,
                       uncomment the proxies section and insert proxy details. -->
                  <!-- https://maven.apache.org/guides/mini/guide-proxies.html -->

                  <!-- If you want to use a company internal mirror, make sure that mirror is
                       configured to use the Instana repository, uncomment the mirrors section
                       and insert maven mirror details.
                       If the mirror also requires auth it can be added above. -->
                  <!-- https://maven.apache.org/guides/mini/guide-mirror-settings.html -->
                  <!-- Repos that need to be mirrored -->
                  <!-- feature: https://artifact-public.instana.io/artifactory/features-public -->
                  <!-- shared: https://artifact-public.instana.io/artifactory/shared -->
                </settings>
              CFG
            )
          end
          it do
            is_expected.to contain_file('/opt/instana/agent/etc/org.ops4j.pax.url.mvn.cfg').with(
              ensure: 'file',
              group: 'root',
              owner: 'root',
              mode: '0640',
            ).with_content(%r{org.ops4j.pax.url.mvn.defaultLocalRepoAsRemote=true})
          end
        end
      end
    end
  end
end
