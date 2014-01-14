# Script to add a value for a Java home directory path as a custom Facter fact,
# deriving that value via the /usr/libexec/java_home command under OS X.
#
# This directory path may, in turn, be suitable as a candidate value for the JAVA_HOME
# environment variable: for instance, if that variable hasn't already been set, or
# if its current value has been identified to be invalid.

# See also "Custom Facts":
# http://docs.puppetlabs.com/guides/custom_facts.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

Facter.add("java_home_osx") do
  setcode do
    confine :kernel => "Darwin"
    if File.exists?("/usr/libexec/java_home")
      java_home_val = %x{/usr/libexec/java_home}
      java_home_val_stripped = java_home_val.strip # remove leading and trailing whitespace, if any
    end
  end
end


