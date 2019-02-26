# @summary Install repositories, keys and the agent package
#
# @api private
#
class instana_agent::install {
  assert_private()
  if $instana_agent::manage_repository {
    $pkg_src   = "https://_:${$instana_agent::key}@packages.instana.io/agent"

    case $facts['os']['family'] {
      'Debian': {
        include apt

        apt::key { 'puppetlabs':
          ensure => 'present',
          id     => 'B878152E2F084D46F878FA20BED2D0969BAD82DE',
          source => 'https://packages.instana.io/Instana.gpg',
        }

        apt::source { 'instana-agent':
          ensure       => 'present',
          architecture => 'amd64',
          include      => {
            'src' => false,
            'deb' => true,
          },
          location     => $pkg_src,
          release      => 'generic',
          repos        => 'main',
        }
        Apt::Source['instana-agent']
        ~> Package["instana-agent-${$instana_agent::flavor}"]
      }
      'Suse': {
        exec { 'import gpg key':
          command => '/bin/rpm --import https://packages.instana.io/Instana.gpg',
          unless  => '/bin/rpm -q gpg-pubkey | grep gpg-pubkey-9bad82de-574bdebd ',
        }

        zypprepo { 'Instana-Agent':
          baseurl  => "${$pkg_src}/generic/x86_64",
          enabled  => 1,
          name     => 'Instana-Agent',
          gpgkey   => 'https://packages.instana.io/Instana.gpg',
          gpgcheck => 1,
          type     => 'rpm-md',
          require  => Exec['import gpg key'],
        }
        Zypprepo['Instana-Agent']
        ~> Package["instana-agent-${$instana_agent::flavor}"]
      }
      'RedHat': {
        yumrepo { 'Instana-Agent':
          ensure        => 'present',
          assumeyes     => true,
          baseurl       => "${$pkg_src}/generic/x86_64",
          enabled       => true,
          gpgkey        => 'https://packages.instana.io/Instana.gpg',
          gpgcheck      => true,
          repo_gpgcheck => true,
          sslverify     => true,
        }
        Yumrepo['Instana-Agent']
        ~> Package["instana-agent-${$instana_agent::flavor}"]
      }
      default: {
        fail("OS family '${facts['os']['family']}' not supported.")
      }
    }
  }
  package { "instana-agent-${$instana_agent::flavor}":
    ensure => 'installed',
  }
}
