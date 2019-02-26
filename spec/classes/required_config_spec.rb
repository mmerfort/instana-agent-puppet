# frozen_string_literal: true

require 'spec_helper'

describe 'instana_agent::required_config' do
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