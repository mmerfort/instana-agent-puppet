# @summary Install and configure the Instana agent
#
# @example Basic usage
#   class { 'instana_agent':
#     key => '<key>',
#   }
# @param key
#   Instana license key
# @param endpoint_host
#   Url of the Instana endpoint host
# @param endpoint_port
#   Port of the endpoint host
# @param flavor
#   Agent flavor
#   For more information see `https://docs.instana.io/quick_start/agent_automation/#flavors`
# @param mode
#   Agent mode
# @param tags
#   Agent tags
# @param zone
#   Availability zone
# @param update_pin
#   The update PIN
# @param update_enabled
#   Whether to do automatic updates of the agent
# @param update_interval
#   How often updates should be done
# @param update_time
#   Time of day where the updates should be done
# @param cpu_limited
#   Whether to set a cpu limit for the agent process
# @param cpu_quota
#   Set the CPU quota for the agent process if limiting is enabled
# @param memory_limited
#   Whether to set a memory limit for the agent process
# @param memory_quota
#   Maximum amount of memory in MiB to use for the agent if limiting is enabled
# @param proxy_enabled
#   Whether to enable the proxy
# @param proxy_type
#   The type of proxy to use
# @param proxy_host
#   Url to the proxy server
# @param proxy_port
#   Port of the proxy server
# @param proxy_dns
#   If set to true, no local DNS resolution is attempted
# @param proxy_username
#   Username for the proxy service
# @param proxy_password
#   Password for the proxy service
# @param mirror_enabled
#   Whether a local maven mirror should be used
# @param mirror_auth_enabled
#   Whether authentication is required for the mirror
# @param mirror_auth_username
#   Username for the maven mirror
# @param mirror_auth_password
#   Password for the maven mirror
# @param mirror_urls_release
#   Url for the release mirror
# @param mirror_urls_shared
#   Url for the shared mirror
# @param manage_repository
#   Enable and disable repository management
# @param scheduler_threads
#   Number of scheduler threads to use
# @param http_threads
#   Number of http threads to use
# @param use_cloud_provider_id
#   Whether to use the id of the cloud provider
#
class instana_agent(
  String                           $key,
  String                           $endpoint_host         = 'saas-us-west-2.instana.io',
  Stdlib::Port                     $endpoint_port         = 443,
  Enum['dynamic','static']         $flavor                = 'static',
  String                           $mode                  = 'APM',
  Array[String]                    $tags                  = [],
  String                           $zone                  = '',
  String                           $update_pin            = '',
  Boolean                          $update_enabled        = true,
  Instana_agent::Every             $update_interval       = 'DAY',
  String                           $update_time           = '04:30',
  Boolean                          $cpu_limited           = true,
  Float                            $cpu_quota             = 0.5,
  Boolean                          $memory_limited        = true,
  Numeric                          $memory_quota          = 512,
  Boolean                          $proxy_enabled         = false,
  Enum['http', 'socks4', 'socks5'] $proxy_type            = 'http',
  String                           $proxy_host            = '',
  Numeric                          $proxy_port            = 3128,
  Boolean                          $proxy_dns             = true,
  String                           $proxy_username        = '',
  String                           $proxy_password        = '',
  Boolean                          $mirror_enabled        = false,
  Boolean                          $mirror_auth_enabled   = false,
  String                           $mirror_auth_username  = '',
  String                           $mirror_auth_password  = '',
  String                           $mirror_urls_release   = '',
  String                           $mirror_urls_shared    = '',
  Boolean                          $manage_repository     = true,
  Integer                          $scheduler_threads     = 4,
  Integer                          $http_threads          = 4,
  Boolean                          $use_cloud_provider_id = true
) {
  contain instana_agent::install
  contain instana_agent::config
  contain instana_agent::required_config
  contain instana_agent::service

  Class['instana_agent::install']
  -> Class['instana_agent::config']
  -> Class['instana_agent::service']
  -> Class['instana_agent::required_config']
}
