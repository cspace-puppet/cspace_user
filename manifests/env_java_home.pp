# Class: cspace_user::env_java_home
#
# Manages the default value for the JAVA_HOME environment variable,
# used during the build and deployment of a CollectionSpace server instance.
#
# This default value will be used when setting the value of JAVA_HOME
# if that environment variable has not already been declared.
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#

class cspace_user::env_java_home {
  
  # Invokes the custom function, puppet/parser/functions/java_home.rb
  #
  # FIXME: Write this value into a script that returns an external Facter fact,
  # as an experiment in maintaining dynamic values for those facts: values that
  # can change, in turn, as Puppet modules are run to change the machine environment. 
  # (See http://docs.puppetlabs.com/guides/custom_facts.html#external-facts)
  #
  $default_java_home = java_home()
    
  $msg_no_default_java_home = join(
    [
      'Could not identify a suitable default value for the JAVA_HOME environment variable.',
      ' This could be because Java has not yet been installed.'
    ])
  if ( empty($default_java_home) ) {
    notice( "${msg_no_default_java_home}")
  }
  
}
