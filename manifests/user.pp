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
  $env_vars  = $cspace_user::env::cspace_env # 'env_vars' is a hash
  
  include cspace_user
  $user_acct = $cspace_user::user_acct_name
  
  # Uses the value returned by the 'generate_password.rb' custom function
  $password = generate_password()
  
  $INITIAL_PASSWORD_FILENAME = 'initial_password.txt'
  
  # ---------------------------------------------------------
  # Ensure presence of CollectionSpace server admin account
  # ---------------------------------------------------------
  
  # FIXME: Need to specify initial passwords for these user accounts.
  # See requirements for each OS here:
  # http://docs.puppetlabs.com/references/latest/type.html#user-attribute-password

  case $os_family {
    
    # Supported Linux OS families
    RedHat, Debian: {
      $homedir = "/home/${user_acct}"
      # Will only work for (presumably modern) Linux systems
      # whose shadow password systems use SHA512 hashes
      $salted_hash = sha512_salted_hash( $password )
      user { 'Ensure Linux user account':
        ensure     => present,
        name       => $user_acct,
        password   => $salted_hash,
        comment    => 'CollectionSpace server admin',
        home       => $homedir,
        managehome => true,
        system     => false,
        # FIXME: Remove this fixed uid if there's no need for specifying this (or any
        # other particular uid) as an attribute value. Otherwise, verify that this
        # uid is unused, or better, invoke a function to return an unused uid.
        uid        => '595',
        shell      => '/bin/bash',
      }
      file { 'Save password for Linux user account to a file in their home directory':
        ensure  => file,
        path    => "${homedir}/${INITIAL_PASSWORD_FILENAME}",
        owner   => $user_acct,
        group   => $user_acct,
        mode    => '600', # read/write only by file owner
        content => template('cspace_user/initial_password.erb'),
        require => User[ 'Ensure Linux user account' ],
      }
    }
    
    # OS X
    darwin: {
      $homedir = "/Users/${user_acct}"
      user { 'Ensure OS X user account':
        ensure   => present,
        name     => $user_acct,
        # Creating initial passwords for this user account isn't yet working,
        # having so far tried a number of variations on creating salted password hashes.
        # The following attribute is a placeholder.  (The Ruby 'crypt'-based method used
        # for Linux systems, above, likely won't work for OS X.)
        # password => $password,
        home     => $homedir,
        system   => false,
        # FIXME: Verify that this ID is unused. One approach may be
        # to munge the output from 'dscl . -list /Users UniqueID'
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
        unless  => "/bin/test -d ${homedir}",
        require => User[ 'Ensure OS X user account' ],
      }
      # file { 'Save password for OS X user account to a file in their home directory':
      #   ensure  => file,
      #   path    => "${homedir}/${INITIAL_PASSWORD_FILENAME}",
      #   owner   => $user_acct,
      #   group   => 'staff',
      #   mode    => '600', # read/write only by file owner
      #   content => template('cspace_user/initial_password.erb'),
      #   require => Exec[ 'Create home directory for OS X user' ],
      # }
    }
    
    # Microsoft Windows
    windows: {
    }
    
    default: {
    }
    
  }
  
  # ---------------------------------------------------------
  # Ensure presence of a specified set of environment
  # variables within the CollectionSpace server admin account
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
        ensure  => file,
        path    => $bash_config_file,
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
        ensure  => file,
        path    => $bash_config_file,
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

    }
    # Microsoft Windows
    windows: {
    }
    default: {
    }
  }
  

}
