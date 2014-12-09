# Class: cspace_user::env
#
# Manages environment variables used during the build and deployment
# of a CollectionSpace server instance.
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#

include stdlib # for 'empty()'

class cspace_user::env {
  
  include cspace_environment::osfamily
  $os_family = $cspace_environment::osfamily::os_family

  # ---------------------------------------------------------
  # Declare environment variables
  # ---------------------------------------------------------

  # Declare default values

  # FIXME: The values below should be reviewed and changed as needed.
  # In particular, password values below are set to easily-guessable
  # defaults and MUST be changed before production use.
  #
  # We might instead consider generating per-execution values for
  # password defaults that are pseudo-random and not easily guessed.
  #
  # One simple way - compatible with at least some Linux distros and OS X,
  # and reliant only on 'uuidgen', 'tr', and 'cut', rather than on the
  # presence of any particular hash utility - is by extracting a slice from
  # a Type 4 UUID and incorporating into a generated password; e.g.:
  # "uuidgen | tr '[:upper:]' '[:lower:]' | cut -c 1-8"

  # FIXME: the values below are hard-coded global defaults. They
  # could more flexibly be read in from a per-node Environment,
  # from other external configuration, or from Heira.
  #
  # See, for instance:
  # http://puppetlabs.com/blog/the-problem-with-separating-data-from-puppet-code
  # and specifically:
  # http://docs.puppetlabs.com/guides/environment.html
  # http://docs.puppetlabs.com/hiera/1/
  
  $default_ant_opts              = '-Xmx1024m -XX:MaxPermSize=512m'
  $default_catalina_home         = '/usr/local/share/apache-tomcat-6.0.33'
  $default_catalina_opts         = '-Xmx1536m -XX:MaxPermSize=512m'
  $default_catalina_pid          = "${default_catalina_home}/bin/tomcat.pid"
  $default_cspace_jeeserver_home = $default_catalina_home
  $default_db_admin_user         = 'postgres'
  $default_db_admin_password     = 'postgres'
  $default_db_csadmin_user       = 'csadmin'
  $default_db_csadmin_password   = 'csadmin'
  $default_db_cspace_password    = 'cspace'
  $default_db_nuxeo_password     = 'nuxeo'
  $default_db_reader_password    = 'reader'
  $default_lc_all                = 'en_US.utf8'
  $default_maven_opts            =
    '-Xmx768m -XX:MaxPermSize=512m -Dfile.encoding=UTF-8'

  # Pick up environment values from values already present in the environment,
  # if available, or use defaults if not.
  #
  # The environment variables below have been added as custom Facter facts
  # via the lib/facter/env.rb script in this module.

  if ( ($::env_ant_opts != undef) and (! empty($::env_ant_opts)) ) {
    $ant_opts = $::env_ant_opts
  }
  else {
    $ant_opts = $default_ant_opts
  }

  if ( ($::env_catalina_home != undef) and (! empty($::env_catalina_home)) ) {
    $catalina_home = $::env_catalina_home
  }
  else {
    $catalina_home = $default_catalina_home
  }

  if ( ($::env_catalina_opts != undef) and (! empty($::env_catalina_opts)) ) {
    $catalina_opts = $::env_catalina_opts
  }
  else {
    $catalina_opts = $default_catalina_opts
  }

  if ( ($::env_catalina_pid != undef) and (! empty($::env_catalina_pid)) ) {
    $catalina_pid = $::env_catalina_pid
  }
  else {
    $catalina_pid = $default_catalina_pid
  }

  if ( ($::env_cspace_jeeserver_home != undef) and (! empty($::env_cspace_jeeserver_home)) ) {
    $cspace_jeeserver_home = $::env_cspace_jeeserver_home
  }
  else {
    $cspace_jeeserver_home = $default_cspace_jeeserver_home
  }
  
  # The following value is not currently read from an environment variable
  $db_admin_user = $default_db_admin_user
  
  # The following value is not currently read from an environment variable
  $db_admin_password = $default_db_admin_password
  
  # The following value is not currently read from an environment variable
  $db_csadmin_user = $default_db_csadmin_user
  
  if ( ($::env_db_csadmin_password != undef) and (! empty($::env_db_csadmin_password)) ) {
    $db_csadmin_password = $::env_db_csadmin_password
  }
  else {
    $db_csadmin_password = $default_db_csadmin_password
  }

  if ( ($::env_db_cspace_password != undef) and (! empty($::env_db_cspace_password)) ) {
    $db_cspace_password = $::env_db_cspace_password
  }
  else {
    $db_cspace_password = $default_db_cspace_password
  }

  if ( ($::env_db_nuxeo_password != undef) and (! empty($::env_db_nuxeo_password)) ) {
    $db_nuxeo_password = $::env_db_nuxeo_password
  }
  else {
    $db_nuxeo_password = $default_db_nuxeo_password
  }
  
  if ( ($::env_db_reader_password != undef) and (! empty($::env_db_reader_password)) ) {
    $db_reader_password = $::env_db_reader_password
  }
  else {
    $db_reader_password = $default_db_reader_password
  }
  
  # Uses the value returned by the 'java_home.rb' custom function
  $java_home = java_home()
  
  if ( ($::env_lc_all != undef) and (! empty($::env_lc_all)) ) {
    $lc_all = $::env_lc_all
  }
  else {
    $lc_all = $default_lc_all
  }

  if ( ($::env_maven_opts != undef) and (! empty($::env_maven_opts)) ) {
    $maven_opts = $::env_maven_opts
  }
  else {
    $maven_opts = $default_maven_opts
  }

  $cspace_env = {
    'ANT_OPTS'              => $ant_opts,
    'CATALINA_HOME'         => $catalina_home,
    'CATALINA_OPTS'         => $catalina_opts,
    'CATALINA_PID'          => $catalina_pid,
    'CSPACE_JEESERVER_HOME' => $cspace_jeeserver_home,
    'DB_ADMIN_USER'         => $db_admin_user,
    'DB_ADMIN_PASSWORD'     => $db_admin_password,
    'DB_CSADMIN_USER'       => $db_csadmin_user,
    'DB_CSADMIN_PASSWORD'   => $db_csadmin_password,
    'DB_CSPACE_PASSWORD'    => $db_cspace_password,
    'DB_NUXEO_PASSWORD'     => $db_nuxeo_password,
    'DB_READER_PASSWORD'    => $db_reader_password,
    'JAVA_HOME'             => $java_home,
    'LC_ALL'                => $lc_all,
    'MAVEN_OPTS'            => $maven_opts,
  }
  
  # 'Clone' the hash above as an array, whose values consist
  # of keys joined to values via equal signs ('=').
  # E.g. [ 'ANT_OPTS=value', 'CATALINA_HOME=value', ...]
  $cspace_env_vars = join_keys_to_values( $cspace_env, '=' )

}
