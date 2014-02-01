# Class: cspace_environment::user
#
# Manages the admin user account for a CollectionSpace server instance.
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#

include cspace_environment::osfamily
include stdlib # for file_line

class cspace_user::user {

  $os_family = $cspace_environment::osfamily::os_family
  
  include cspace_user::env
  $env_vars  = $cspace_user::env::cspace_env # hash
  
  include cspace_user
  $user_acct = $cspace_user::user_acct_name
  
  # ---------------------------------------------------------
  # Ensure presence of CollectionSpace server admin account
  # ---------------------------------------------------------
  
  # FIXME: Need to specify initial passwords for these user accounts.
  # See requirements for each OS here:
  # http://docs.puppetlabs.com/references/latest/type.html#user-attribute-password

  case $os_family {
    
    # Supported Linux OS families
    RedHat, Debian: {
      user { 'Ensure Linux user account':
        ensure     => present,
        name       => $user_acct,
        comment    => 'CollectionSpace server admin',
        home       => "/home/${user_acct}",
        managehome => true,
        system     => false,
        # FIXME: Verify that this ID is unused
        uid        => '595',
        shell      => '/bin/bash',
      }
    }
    
    # OS X
    darwin: {
      user { 'Ensure OS X user account':
        ensure   => present,
        name     => $user_acct,
        home     => "/Users/${user_acct}",
        system   => false,
        # FIXME: Verify that this ID is unused
        # possibly via 'dscl . -list /Users UniqueID'
        #
        # From experimentation, uid may need to be >= 501
        # for home directory creation to succeed.
        # 'system => false' doesn't appear to be sufficient
        # to ensure a uid is assigned in that range.
        uid      => '595',
        shell    => '/bin/bash',
      }
      # See Nigel Kersten's remarks on creating OS X home directories:
      # https://groups.google.com/d/msg/puppet-users/dykZSWMqO9w/BsiGsGp0gyYJ
      #
      # Note: the user's home directory is not automatically removed when the
      # account is removed by setting 'ensure => absent' in the 'user' resource
      # above. And OS X's 'directoryservice' provider does not support the
      # 'managehome' attribute that would automatically remove it.
      exec { 'Create home directory for OS X user':
        command => "/usr/sbin/createhomedir -c -u ${user_acct}",
        # Check first if the home directory already exists.
        unless  => "/bin/test -d /Users/${user_acct}",
        require => User[ 'Ensure OS X user account' ]
      }
    }
    
    # Microsoft Windows
    windows: {
    }
    
    default: {
    }
    
  }
  
  # ---------------------------------------------------------
  # Manage environment variables in server admin account
  # ---------------------------------------------------------
  
  case $os_family {
    
    RedHat, Debian: {
      
      # TODO: Find a way to get builds to continue to work in the cspace_source module
      # when environment variables are declared (in order of preference) in .profile
      # or in .bash_profile, rather than directly within .bashrc
      # Both of those files are preferable locations for those declarations than .bashrc 
      # See https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
      $bash_config_file = "/home/${user_acct}/.bashrc"
      file { 'Ensure presence of bashrc file':
        path    => $bash_config_file,
        ensure  => file,
        owner   => $user_acct,
        group   => $user_acct,
        require => User[ 'Ensure Linux user account' ],
      }
      
    }
    # OS X
    darwin: {
      
      # TODO: See comment above re using a profile file rather than .bashrc.
      $bash_config_file = "/Users/${user_acct}/.bashrc"
      file { 'Ensure presence of bashrc file':
        path    => $bash_config_file,
        ensure  => file,
        owner   => $user_acct,
        group   => 'staff',
        require => User[ 'Ensure OS X user account' ],
      }
      
    }
    # Microsoft Windows
    windows: {
    }
    default: {
    }
  }
  
  case $os_family {
    
    RedHat, Debian, darwin: {
      
      $starting_delimiter = '# Start of environment variable declarations inserted by Puppet code'
      $ending_delimiter   = '# End of environment variable declations inserted by Puppet code'
      # The 'env_vars.erb' template, invoked below, expects to find an $env_vars hash,
      # which is instantiated above, near the top of this class's code block
      file_line { 'Write environment variables to bash config file':
        ensure  => present,
        path    => $bash_config_file,
        line    => template('cspace_user/env_vars.erb'),
        require => File[ 'Ensure presence of bashrc file' ],
      }
    
      $java_home_script_name = 'set_java_home_env_var.rb'
      $java_home_script_path = "/tmp/${java_home_script_name}"
      file { 'Create script to write JAVA_HOME environment variable to bash config file':
        ensure => present,
        path   => $java_home_script_path,
        owner  => 'root',
        mode   => '0744',
        source => "puppet:///modules/cspace_user/${java_home_script_name}",
        require => File_line[ 'Write environment variables to bash config file' ],
      }
      exec { 'Write JAVA_HOME environment variable to bash config file':
        command => "${java_home_script_path} ${bash_config_file}",
        require => File[ 'Create script to write JAVA_HOME environment variable to bash config file' ],
      }

    }
    # Microsoft Windows
    windows: {
    }
    default: {
    }
  }
  

}
