# Function to identify the probable location of the JAVA_HOME directory, if present.

# See also "Custom Functions":
# http://docs.puppetlabs.com/guides/custom_functions.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

module Puppet::Parser::Functions
  newfunction(:java_home, :type => :rvalue, :doc => <<-ENDDOC
Identifies the probable location of the JAVA_HOME directory, if present,
using heuristics to identify that location.

*Examples:*

    java_home()

will return a String containing the fully qualified path to the JAVA_HOME
directory, or an empty String if that directory is not found. For instance,
on certain RedHat Linux-based systems on which Oracle Java 7 is present,
this function will return the String:

    '/usr/java/latest'
ENDDOC
  ) do |args|
    
    # Any arguments passed to this function are ignored.
    
    os_family             = lookupvar('osfamily')
    relative_path_to_java = '/bin/java'

    # Returns the value of the JAVA_HOME environment variable
    # for the effective current user.
    def env_java_home_value()
      env_java_home_val = ''
      env_java_home     = ENV[ 'JAVA_HOME' ]
      if env_java_home.to_s.strip.length > 0
        if File.executable?( "#{env_java_home}#{relative_path_to_java}" )
          env_java_home_val = env_java_home
        end
      end
      return env_java_home_val
    end
    
    case os_family
      
      when 'Debian'
        java_home = ''
        
      when 'RedHat'
        
        java_home = ''
        
        # Use the default directory for Oracle Java installations, if present.
        # Oracle's convention for Java SE 7 on RedHat Linux-based systems appears to be to create
        # a '/usr/java/latest' symlink which will always point to the latest Java version.
        # See http://www.oracle.com/technetwork/java/javase/install-linux-rpm-137089.html
        # (The corresponding 64-bit JDK installation page doesn't mention this convention,
        # but the same behavior was observed with Oracle's Java SE 64-bit RPM packages.)
        JAVA_HOME_DEFAULT = '/usr/java/latest'
        if File.executable?( "#{JAVA_HOME_DEFAULT}/bin/java" )
          java_home = `#{JAVA_HOME_DEFAULT}`
        end
        
        # Fall back to the value of the JAVA_HOME environment variable, if present.
        if java_home.to_s.strip.length == 0
          java_home = env_java_home_value()
        end
                
      # OS X
      when 'Darwin'
    
        java_home = ''
        
        # Default to returning the value provided by the 'java_home' OS X utility, which
        # "returns the path to a Java home directory from the current user's settings."
        JAVA_HOME_UTILITY_PATH = '/usr/libexec/java_home'
        if File.executable?( "#{JAVA_HOME_UTILITY_PATH}" )
          java_home_candidate = `#{JAVA_HOME_UTILITY_PATH}`
          # For this test, see http://stackoverflow.com/a/251644
          if java_home_candidate.to_s.strip.length > 0
            java_home_candidate = java_home_candidate.strip # remove trailing EOL char
            if File.executable?( "#{java_home_candidate}#{relative_path_to_java}" )
              java_home = java_home_candidate
            end
          end
        end
        
        # Fall back to the value of the JAVA_HOME environment variable, if present.
        if java_home.to_s.strip.length == 0
          java_home = env_java_home_value()
        end
                
      # Microsoft Windows
      when 'windows'
        java_home = ''
        
      # Default
      else
        java_home = ''
        
    end # case
    
    return java_home
    
    
  #       confine :kernel => "Linux"
  #       if File.exists?("/usr/sbin/alternatives")
  #         %x{/usr/sbin/alternatives  --display java | /bin/grep best | cut -f 5 -d ' ' } \
  #           .sub(/\/bin\/java.$/,"") \
  #           .chomp
  #       end
  #   
  #   confine :kernel => "Darwin"

  #   
  #   if FileTest.directory?(dirpath)
  #     returnval = true
  #   else
  #     returnval = false
  #   end
  #   return returnval
  
  end
end