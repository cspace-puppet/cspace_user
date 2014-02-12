# Function to return a crypt-generated, salted SHA512 hash of a password string.
#
# These salted hashes can be used when creating or updating passwords for Linux
# system users, on any Linux distribution where crypt can use SHA512 hashes.

# See also "Custom Functions":
# http://docs.puppetlabs.com/guides/custom_functions.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

# ---------------------------------------------------
# Constants
# ---------------------------------------------------

SHA_512_PREFIX = '$6$'

# ---------------------------------------------------
# Main code block
# ---------------------------------------------------

module Puppet::Parser::Functions
  newfunction(:sha512_salted_hash, :type => :rvalue, :doc => <<-ENDDOC
Returns a crypt-generated, salted SHA512 hash of a password string.

*Examples:*

    sha512_salted_hash( 'my%346passwo_rd' )

will return a crypt-generated, salted SHA512 hash of the password
string, 'my%346passwo_rd'.

ENDDOC
  ) do |args|
    
    raise(Puppet::ParseError, "sha512_salted_hash(): Wrong number of arguments " +
      " (got #{args.size} arguments but expected 1)") if (args.size != 1)
    
    password = args[0]
    hash = ''
    
    if password.nil?
      return ''
    elsif !password.is_a? String
      return ''
    else
      # Invoke the generate_password function to return a 32-character salt value.
      # See http://docs.puppetlabs.com/guides/custom_functions.html#calling-functions-from-functions
      Puppet::Parser::Functions.autoloader.loadall
      salt = function_generate_password( [ '32' ] )
      # See http://apidock.com/ruby/String/crypt#1075-String-crypt-uses-your-platform-s-native-implementation
      hash = password.crypt( SHA_512_PREFIX + salt );
    end
    
    return hash
    
  end
end