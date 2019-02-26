# @summary Additional configuration for the agent
#
# @api private
#
class instana_agent::required_config {
  assert_private()
  $dir = '/opt/instana/agent/etc/'

  file { "${$dir}instana/com.instana.agent.main.sender.Backend.cfg":
    ensure  => 'file',
    content => epp('instana_agent/agent_backend.epp', {
      'agent_key'      => $instana_agent::key,
      'endpoint_host'  => $instana_agent::endpoint_host,
      'endpoint_port'  => $instana_agent::endpoint_port,
      'proxy_enabled'  => $instana_agent::proxy_enabled,
      'proxy_type'     => $instana_agent::proxy_type,
      'proxy_host'     => $instana_agent::proxy_host,
      'proxy_port'     => $instana_agent::proxy_port,
      'proxy_dns'      => $instana_agent::proxy_dns,
      'proxy_username' => $instana_agent::proxy_username,
      'proxy_password' => $instana_agent::proxy_password,
    }),
    group   => 'root',
    mode    => '0640',
    owner   => 'root',
  }

  file { "${$dir}mvn-settings.xml":
    ensure  => 'file',
    content => epp('instana_agent/mvn-settings.epp', {
      'agent_key'            => $instana_agent::key,
      'mirrors_enabled'      => $instana_agent::mirror_enabled,
      'mirrors_require_auth' => $instana_agent::mirror_auth_enabled,
      'mirrors_username'     => $instana_agent::mirror_auth_username,
      'mirrors_password'     => $instana_agent::mirror_auth_password,
      'release_repourl'      => $instana_agent::mirror_urls_release,
      'shared_repourl'       => $instana_agent::mirror_urls_shared,
      'proxy_enabled'        => $instana_agent::proxy_enabled,
      'proxy_type'           => $instana_agent::proxy_type,
      'proxy_host'           => $instana_agent::proxy_host,
      'proxy_port'           => $instana_agent::proxy_port,
      'proxy_username'       => $instana_agent::proxy_username,
      'proxy_password'       => $instana_agent::proxy_password,
    }),
    group   => 'root',
    mode    => '0640',
    owner   => 'root',
  }

  file { "${$dir}org.ops4j.pax.url.mvn.cfg":
    ensure  => 'file',
    content => epp('instana_agent/pax-mvn-cfg.epp', {
      'flavor' => $instana_agent::flavor
    }),
    group   => 'root',
    mode    => '0640',
    owner   => 'root',
  }
}
