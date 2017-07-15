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

class cspace_user::env (
  $heira_configured_ant_opts              = hiera('collectionspace::ant_opts'),
  $heira_configured_catalina_home         = hiera('collectionspace::catalina_home'),
  $heira_configured_catalina_opts         = hiera('collectionspace::catalina_opts'),
  $heira_configured_catalina_pid          = hiera('collectionspace::catalina_pid'),
  $heira_configured_cspace_instance_id    = hiera('collectionspace::cspace_instance_id'),
  $heira_configured_cspace_jeeserver_home = hiera('collectionspace::cspace_jeeserver_home'),
  $heira_configured_jee_port              = hiera('collectionspace::jee_port'),
  $heira_configured_db_admin_user         = hiera('collectionspace::db_admin_user'),
  # This and several other password values, if not present in the local environment or in Hiera
  # configuration, default to values returned by the 'generate_password.rb' custom function
  $heira_configured_db_admin_password     = hiera('collectionspace::db_admin_password', generate_password()),
  $heira_configured_db_csadmin_user       = hiera('collectionspace::db_csadmin_user'),
  $heira_configured_db_csadmin_password   = hiera('collectionspace::db_csadmin_password', generate_password()),
  $heira_configured_db_cspace_password    = hiera('collectionspace::db_cspace_password', generate_password()),
  $heira_configured_db_host               = hiera('collectionspace::db_host'),
  $heira_configured_db_nuxeo_password     = hiera('collectionspace::db_nuxeo_password', generate_password()),
  $heira_configured_db_port               = hiera('collectionspace::db_port'),
  $heira_configured_cspace_core_create_disabled_opt = hiera('collectionspace::cspace_core_create_disabled_opt'),
  $heira_configured_db_reader_password    = hiera('collectionspace::db_reader_password', generate_password()),
  $heira_configured_lc_all                = hiera('collectionspace::lc_all'),
  $heira_configured_maven_opts            = hiera('collectionspace::maven_opts'),
  )

 {
  
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

  # Obtain values from the local host's environment variables, if present,
  # or if not, use values configured in Hiera.
  #
  # The environment variables below have been added as custom Facter facts
  # via the lib/facter/env.rb script in this module, which then makes them
  # available for use within Puppet.

  if ( ($::env_ant_opts != undef) and (! empty($::env_ant_opts)) ) {
    $ant_opts = $::env_ant_opts
  }
  else {
    $ant_opts = $heira_configured_ant_opts
  }

  if ( ($::env_catalina_home != undef) and (! empty($::env_catalina_home)) ) {
    $catalina_home = $::env_catalina_home
  }
  else {
    $catalina_home = $heira_configured_catalina_home
  }

  if ( ($::env_catalina_opts != undef) and (! empty($::env_catalina_opts)) ) {
    $catalina_opts = $::env_catalina_opts
  }
  else {
    $catalina_opts = $heira_configured_catalina_opts
  }

  if ( ($::env_catalina_pid != undef) and (! empty($::env_catalina_pid)) ) {
    $catalina_pid = $::env_catalina_pid
  }
  else {
    $catalina_pid = $heira_configured_catalina_pid
  }
  
  if ( ($::env_cspace_instance_id != undef) and (! empty($::env_cspace_instance_id)) ) {
    $cspace_instance_id = $::env_cspace_instance_id
  }
  else {
    $cspace_instance_id = $heira_configured_cspace_instance_id
  }

  if ( ($::env_cspace_jeeserver_home != undef) and (! empty($::env_cspace_jeeserver_home)) ) {
    $cspace_jeeserver_home = $::env_cspace_jeeserver_home
  }
  else {
    $cspace_jeeserver_home = $heira_configured_cspace_jeeserver_home
  }
  
  if ( ($::env_jee_port != undef) and (! empty($::env_jee_port)) ) {
    $jee_port = $::env_jee_port
  }
  else {
    $jee_port = $heira_configured_jee_port
  }
  
  if ( ($::env_db_admin_user != undef) and (! empty($::env_db_admin_user)) ) {
    $db_admin_user = $::env_db_admin_user
  } else {
    $db_admin_user = $heira_configured_db_admin_user
  }
  
  if ( ($::env_db_admin_password != undef) and (! empty($::env_db_admin_password)) ) {
    $db_admin_password = $::env_db_admin_password
  } else {
    $db_admin_password = $heira_configured_db_admin_password
  }
  
  if ( ($::env_db_csadmin_user != undef) and (! empty($::env_db_csadmin_user)) ) {
    $db_csadmin_user = $::env_db_csadmin_user
  } else {
    $db_csadmin_user = $heira_configured_db_csadmin_user
  }
  
  if ( ($::env_db_csadmin_password != undef) and (! empty($::env_db_csadmin_password)) ) {
    $db_csadmin_password = $::env_db_csadmin_password
  }
  else {
    $db_csadmin_password = $heira_configured_db_csadmin_password
  }

  if ( ($::env_db_cspace_password != undef) and (! empty($::env_db_cspace_password)) ) {
    $db_cspace_password = $::env_db_cspace_password
  }
  else {
    $db_cspace_password = $heira_configured_db_cspace_password
  }

  if ( ($::env_db_host != undef) and (! empty($::env_db_host)) ) {
    $db_host = $::env_db_host
  }
  else {
    $db_host = $heira_configured_db_host
  }

  if ( ($::env_db_nuxeo_password != undef) and (! empty($::env_db_nuxeo_password)) ) {
    $db_nuxeo_password = $::env_db_nuxeo_password
  }
  else {
    $db_nuxeo_password = $heira_configured_db_nuxeo_password
  }
  
  if ( ($::env_db_port != undef) and (! empty($::env_db_port)) ) {
    $db_port = $::env_db_port
  }
  else {
    $db_port = $heira_configured_db_port
  }
  
  if ( ($::env_cspace_core_create_disabled_opt != undef) and (! empty($::env_cspace_core_create_disabled_opt)) ) {
    $cspace_core_create_disabled_opt = $::env_cspace_core_create_disabled_opt
  }
  else {
    $cspace_core_create_disabled_opt = $heira_configured_cspace_core_create_disabled_opt
  }
  
  if ( ($::env_db_reader_password != undef) and (! empty($::env_db_reader_password)) ) {
    $db_reader_password = $::env_db_reader_password
  }
  else {
    $db_reader_password = $heira_configured_db_reader_password
  }
  
  # Uses the value returned by the 'java_home.rb' custom function
  $java_home = java_home()
  
  if ( ($::env_lc_all != undef) and (! empty($::env_lc_all)) ) {
    $lc_all = $::env_lc_all
  }
  else {
    $lc_all = $heira_configured_lc_all
  }

  if ( ($::env_maven_opts != undef) and (! empty($::env_maven_opts)) ) {
    $maven_opts = $::env_maven_opts
  }
  else {
    $maven_opts = $heira_configured_maven_opts
  }

  $cspace_env = {
    'ANT_OPTS'              => $ant_opts,
    'CATALINA_HOME'         => $catalina_home,
    'CATALINA_OPTS'         => $catalina_opts,
    'CATALINA_PID'          => $catalina_pid,
    'CSPACE_INSTANCE_ID'    => $cspace_instance_id,
    'CSPACE_JEESERVER_HOME' => $cspace_jeeserver_home,
    'JEE_PORT'              => $jee_port,
    'DB_ADMIN_USER'         => $db_admin_user,
    'DB_ADMIN_PASSWORD'     => $db_admin_password,
    'DB_CSADMIN_USER'       => $db_csadmin_user,
    'DB_CSADMIN_PASSWORD'   => $db_csadmin_password,
    'DB_CSPACE_PASSWORD'    => $db_cspace_password,
    'DB_HOST'               => $db_host,
    'DB_NUXEO_PASSWORD'     => $db_nuxeo_password,
    'DB_PORT'               => $db_port,
	'CSPACE_CORE_CREATE_DISABLED_OPT' => $cspace_core_create_disabled_opt,
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
