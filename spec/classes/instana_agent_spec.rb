# frozen_string_literal: true

require 'spec_helper'

describe 'instana_agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'with only bare minimum parameters set' do
        let(:params) do
          {
            key: 'examplekey',
          }
        end

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
    end
  end
end
