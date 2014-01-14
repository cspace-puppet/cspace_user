include cspace_environment::osfamily
include stdlib

class { 'cspace_user::env': }

$env_vars = join( sort($cspace_user::env::cspace_env_vars), "\n" )
notice( "CollectionSpace-relevant environment variables consist of:\n${env_vars}" )
