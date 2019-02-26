# @summary Agent configuration
#
# @api private
#
class instana_agent::config {
  assert_private()

  $dir = '/opt/instana/agent/etc/instana/'

  if $instana_agent::flavor != 'static' and
    $instana_agent::update_enabled {
    $update_string = 'AUTO'
  } else {
    $update_string = 'OFF'
  }

  file { "${dir}configuration.yaml":
    ensure  => 'file',
    content => epp('instana_agent/agent_configuration.epp', {
      'tags' => $instana_agent::tags,
      'zone' => $instana_agent::zone,
    }),
    group   => 'root',
    mode    => '0640',
    owner   => 'root',
  }

  file { "${dir}com.instana.agent.main.config.Agent.cfg":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('instana_agent/com.instana.agent.main.config.Agent.cfg', {
      'scheduler_threads'     => $instana_agent::scheduler_threads,
      'http_threads'          => $instana_agent::http_threads,
      'use_cloud_provider_id' => $instana_agent::use_cloud_provider_id,
      'mode'                  => $instana_agent::mode,
    }),
    notify  => Service['instana-agent'],
  }

  file { "${dir}com.instana.agent.main.config.UpdateManager.cfg":
    ensure  => 'file',
    content => epp('instana_agent/agent_updates.epp', {
      'update_enabled'  => $update_string,
      'update_interval' => $instana_agent::update_interval,
      'update_time'     => $instana_agent::update_time,
    }),
    group   => 'root',
    mode    => '0640',
    owner   => 'root',
  }

  file { "${dir}com.instana.agent.bootstrap.AgentBootstrap.cfg":
    ensure  => 'file',
    content => epp('instana_agent/agent_sensorpin.epp', {
      'version' => $instana_agent::update_pin
    }),
    group   => 'root',
    mode    => '0640',
    owner   => 'root',
  }
}
