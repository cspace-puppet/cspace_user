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
  
  include cspace_environment::osfamily
  $os_family = $cspace_environment::osfamily::os_family

  $msg_no_java_home_default = join(
    [
      'Could not identify a suitable default value for the JAVA_HOME environment variable.',
      ' This could be because Oracle Java SE has not yet been installed.'
    ])
    
  case $os_family {
    
    Debian: {
      # The 'java_home_alternatives' variable below was added as a custom Facter fact
      # via the lib/facter/java_home_alternatives.rb script in this module.
      #
      # If the 'alternatives' system returns the default path to the 'java'
      # executable file, set JAVA_HOME to its relevant parent directory, if present.
      if (
           ($::java_home_alternatives != undef) and
           (! empty($::java_home_alternatives)) and
           (directory_exists($::java_home_alternatives))
         ) {
        $default_java_home        = $::java_home_alternatives
      }
      else {
        notice( $msg_no_java_home_default )
        $default_java_home        = ''
      }
    }
    
    RedHat: {
      # Use the default directory for Oracle Java installations, if present.
      # Oracle's convention for Java SE 7 on RedHat Linux-based systems appears to be to create
      # a '/usr/java/ symlink which will always point to the latest Java version.
      # See http://www.oracle.com/technetwork/java/javase/install-linux-rpm-137089.html
      # (The corresponding 64-bit JDK installation page doesn't mention this convention,
      # but the same behavior was observed with Oracle's Java SE 64-bit RPM packages.)
      if (directory_exists($default_oracle_java_home)) {
        $default_oracle_java_home = '/usr/java/latest'
        $default_java_home        = $default_oracle_java_home
      }
      # Otherwise, if the 'alternatives' system returns the default path to the 'java'
      # executable file, set JAVA_HOME to its relevant parent directory, if present.
      #
      # The 'java_home_alternatives' variable below was added as a custom Facter fact
      # via the lib/facter/java_home_alternatives.rb script in this module.
      elsif (
           ($::java_home_alternatives != undef) and
           (! empty($::java_home_alternatives)) and
           (directory_exists($::java_home_alternatives))
         ) {
        $default_java_home        = $::java_home_alternatives
      }
      else {
        notice( $msg_no_java_home_default )
        $default_java_home        = ''
      }
    }
    
    # OS X
    darwin: {
      # The 'java_home_osx' variable below was added as a custom Facter fact
      # via the lib/facter/java_home_osx.rb script in this module.
      if (
           ($::java_home_osx != undef) and
           (! empty($::java_home_osx)) and
           (directory_exists($::java_home_osx))
         ) {
        $default_java_home          = $::java_home_osx
      }
      else {
        notice( $msg_no_java_home_default )
        $default_java_home        = ''
      }
    }
    
    # Microsoft Windows
    windows: {
    }
    
    default: {
    }
    
  }
  
}
