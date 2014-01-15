class { 'cspace_user::env_java_home': }

$default_home = $cspace_user::env_java_home::default_java_home
notice( "Default value of JAVA_HOME environment variable is ${default_home}" )
