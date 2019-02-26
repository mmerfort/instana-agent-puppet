# frozen_string_literal: true

require 'spec_helper'

describe 'Instana_agent::Every' do
  values = ['DAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']
  it do
    is_expected.to allow_values(*values)
  end

  it do
    is_expected.not_to allow_values(['PETER', '1', '?'])
  end
end
