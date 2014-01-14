# Script to add a value for a Java home directory path as a custom Facter fact,
# deriving that value via the Linux 'alternatives' system.
#
# This directory path may, in turn, be suitable as a candidate value for the JAVA_HOME
# environment variable: for instance, if that variable hasn't already been set, or
# if its current value has been identified to be invalid.

# Written by a 'guest' user on Pastebin.com:
# http://pastebin.com/t7guDNyU
# and adapted slightly to add the File.exists? test

# This script:
#   Takes the output from running 'alternatives --display java'.
#   Finds a line similar to "Current `best' version is {some directory path here}.".
#   Extracts and returns the fifth, space-separated field from that line,
#     one which should contain that directory path.
#   Trims the trailing "/bin/java" from the path.
#   Adds that directory path to a "java_home_alternatives" fact.

# See also "Custom Facts":
# http://docs.puppetlabs.com/guides/custom_facts.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

Facter.add("java_home_alternatives") do
  setcode do
    confine :kernel => "Linux"
    if File.exists?("/usr/sbin/alternatives")
      %x{/usr/sbin/alternatives  --display java | /bin/grep best | cut -f 5 -d ' ' } \
        .sub(/\/bin\/java.$/,"") \
        .chomp
    end
  end
end


