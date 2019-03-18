# @summary Configure and start the agent service
#
# @api private
#
class instana_agent::service {
  assert_private()

  if $facts['systemd'] {
    $dir = '/etc/systemd/system/instana-agent.service.d'
    include systemd::systemctl::daemon_reload

    file { $dir:
      ensure => 'directory',
      group  => 'root',
      mode   => '0750',
      owner  => 'root',
    }

    if ($instana_agent::cpu_limited or $instana_agent::memory_limited) {
      file { "${dir}/10-resources.conf":
        ensure  => 'file',
        content => epp('instana_agent/resource-override.conf.epp', {
          'cpu_limited'    => $instana_agent::cpu_limited,
          'cpu_quota'      => $instana_agent::cpu_quota,
          'memory_limited' => $instana_agent::memory_limited,
          'memory_quota'   => $instana_agent::memory_quota,
        }),
        group   => 'root',
        mode    => '0640',
        owner   => 'root',
        notify  => Class['systemd::systemctl::daemon_reload']
      }
    }
  }

  service { 'instana-agent':
    ensure => 'running',
    enable => true,
  }
}
