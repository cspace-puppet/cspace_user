# Function to identify whether a directory exists, given its path

# See also "Custom Functions":
# http://docs.puppetlabs.com/guides/custom_functions.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

module Puppet::Parser::Functions
  newfunction(:directory_exists, :type => :rvalue, :doc => <<-ENDDOC
Identifies whether a directory exists, given its full filesystem path
(or else the full filesystem path of a symlink that points to a directory)

*Examples:*

    directory_exists('/etc/motd')

Will return (on relevant systems):

    true
ENDDOC
  ) do |args|
    raise(Puppet::ParseError, "directory_exists(): Wrong number of arguments " +
      " (got #{args.size} but expected 1)") if (args.size != 1)
    dirpath = args[0]
    if FileTest.directory?(dirpath)
      returnval = true
    else
      returnval = false
    end
    return returnval
