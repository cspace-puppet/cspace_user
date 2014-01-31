#!/usr/bin/env ruby

# Script to write the probable location of the JAVA_HOME directory, if present,
# to a user's .bashrc file.

# See also "Custom Functions":
# http://docs.puppetlabs.com/guides/custom_functions.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

# Requires the Facter Ruby Gem, typically installed with Puppet.
require 'facter'
# TODO: Test whether the following is actually needed. See:
# https://groups.google.com/forum/#!topic/puppet-users/DV_tzOvPRSw
ENV['FACTERLIB'] = "/var/lib/puppet/lib/facter:/var/lib/puppet/facts"

# ---------------------------------------------------
# Utility functions
# ---------------------------------------------------

# Returns the value of the JAVA_HOME environment variable
# for the effective current user.
def env_java_home()
  env_java_home_val = ''
  env_java_home     = ENV[ 'JAVA_HOME' ]
  # Re this 'nil or empty' test, see http://stackoverflow.com/a/251644
  if env_java_home.to_s.strip.length > 0
    # Ensure that this candidate path contains a 'java' executable file
    if FileTest.executable?( "#{env_java_home}#{RELATIVE_PATH_TO_JAVA}" )
      env_java_home_val = env_java_home
    end
  end
  return env_java_home_val
end

# Returns the current alternative path to the 'java' executable via
# the Linux 'alternatives' system. (For a summary of that system,
# see, for example, http://linux.about.com/library/cmd/blcmdl8_alternatives.htm)
def java_alternatives_path()
  java_alternatives_val = ''
  # Run the relevant alternatives command, retrieve the output
  # line containing "link currently points to", extract the path 
  # from that line, and strip off the trailing '/bin/java' and any
  # surrounding whitespace from that path, to yield a candidate
  # directory path.
  if FileTest.executable?( "#{ALTERNATIVES_COMMAND}" )
    alternatives_cmd_output = \
      `#{ALTERNATIVES_COMMAND} --display java`
    alternatives_cmd_output =~ /\s*link currently points to(.*)/
    java_alternatives_candidate = ''
    if alternatives_cmd_output.to_s.strip.length > 0
      java_alternatives_candidate = $1.sub(/\/bin\/java/,"").strip
    end
  end
  if java_alternatives_candidate.to_s.strip.length > 0
    if FileTest.executable?( "#{java_alternatives_candidate}#{RELATIVE_PATH_TO_JAVA}" )
      java_alternatives_val = java_alternatives_candidate
    end
  end
  return java_alternatives_val
end

# FIXME: This isn't the safest way to substitute text within, or append to, a file,
# as it may fail messily when too little space is left in a filesystem, etc.
# For on a more involved, but more robust, approach, see:
# http://stackoverflow.com/a/4174125
# and especially:
# http://stackoverflow.com/a/2192010
def replace_or_append_text_in_file( file, find_regex, replacement_text )
  filetext = File.read file
  File.open( file, 'w+' ) { |f|
    if ( filetext.match( find_regex ) != nil )
      f << filetext.gsub( find_regex, replacement_text )
    else
      f << "#{replacement_text}\n"
    end
  }
end

# ---------------------------------------------------
# Constants
# ---------------------------------------------------

# Path to the 'alternatives' command on Debian and RedHat-based systems.
# (On RedHat-based systems, this path is an alias to '/usr/sbin/alternatives'.)
ALTERNATIVES_COMMAND     = '/usr/sbin/update-alternatives'

# Relative path to the 'java' executable within a JAVA_HOME directory
RELATIVE_PATH_TO_JAVA    = '/bin/java'

# Oracle's convention for Java SE 7 on RedHat Linux-based systems appears to be to create
# a '/usr/java/latest' symlink which will always point to the latest Java version.
# See http://www.oracle.com/technetwork/java/javase/install-linux-rpm-137089.html
# (The corresponding 64-bit JDK installation page doesn't mention this convention,
# but the same behavior was observed with Oracle's Java SE 64-bit RPM packages.)
DEFAULT_REDHAT_JAVA_HOME = '/usr/java/latest'

# The OS X utility 'java_home' "returns the path to a Java home directory from
# the current user's settings."
OSX_JAVA_HOME_UTILITY_PATH = '/usr/libexec/java_home'

# ---------------------------------------------------
# Main code block, with behavior varying by platform
# ---------------------------------------------------

filepath = ARGV[0]
if filepath.to_s.strip.length == 0
  puts "Usage: #{$0} filepath"
  exit 1
end

begin
  Facter.mysql_master
rescue
  Facter.loadfacts()
end
os_family = Facter.value('osfamily')
    
case os_family
  
  when 'Debian'
    
    java_home = ''

    # Use the value, if any, returned by the 'alternatives' command.
    if java_home.to_s.strip.length == 0
      java_home = java_alternatives_path()
    end
            
    # Fall back to the value of the JAVA_HOME environment variable, if present.
    if java_home.to_s.strip.length == 0
      java_home = env_java_home()
    end
    
  when 'RedHat'
    
    java_home = ''
    
    # Use the default directory for Oracle Java installations, if present.
    if FileTest.exists?( "#{DEFAULT_REDHAT_JAVA_HOME}#{RELATIVE_PATH_TO_JAVA}" )
      java_home = "#{DEFAULT_REDHAT_JAVA_HOME}"
    end
    
    # Next use the value, if any, returned by the 'alternatives' command.
    if java_home.to_s.strip.length == 0
      java_home = java_alternatives_path()
    end
    
    # Fall back to the value of the JAVA_HOME environment variable, if present.
    if java_home.to_s.strip.length == 0
      java_home = env_java_home()
    end
            
  # OS X
  when 'Darwin'

    java_home = ''
    
    # Use the value, if any, returned by the OS X utility 'java_home'.
    if FileTest.executable?( "#{OSX_JAVA_HOME_UTILITY_PATH}" )
      java_home_candidate = `#{OSX_JAVA_HOME_UTILITY_PATH}`
      if java_home_candidate.to_s.strip.length > 0
        java_home_candidate = java_home_candidate.strip # remove trailing EOL char
        if FileTest.executable?( "#{java_home_candidate}#{RELATIVE_PATH_TO_JAVA}" )
          java_home = java_home_candidate
        end
      end
    end
    
    # Fall back to the value of the JAVA_HOME environment variable, if present.
    if java_home.to_s.strip.length == 0
      java_home = env_java_home()
    end
            
  # Microsoft Windows
  when 'windows'
    java_home = ''
    
  # Default
  else
    java_home = ''
    
end # case

find_regex       = /export\s+JAVA_HOME\s+=\s+.*/
replacement_text = "export JAVA_HOME=\'#{java_home}'"
if FileTest.writable?(filepath)
  replace_or_append_text_in_file( filepath, find_regex, replacement_text )
end




