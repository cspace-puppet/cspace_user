# Function to identify the probable location of the JAVA_HOME directory, if present.

# See also "Custom Functions":
# http://docs.puppetlabs.com/guides/custom_functions.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

# The SecureRandom class appears to require Ruby 1.8.7 or later.
require 'securerandom'

# ---------------------------------------------------
# Constants
# ---------------------------------------------------

MIN_LENGTH = 10
SELECTED_SPECIAL_CHARS = [ '!', '#', '$', '%', '&', '*', '+', '-', '_' ]
SPECIAL_CHARS_PRINTABLE = SELECTED_SPECIAL_CHARS.to_s

# ---------------------------------------------------
# Utility functions (methods)
# ---------------------------------------------------

# Replaces a single, pseudorandomly-selected character in a string with a new
# character, itself selected pseudorandomly from a set of special ASCII characters.
# Substitutions may be made to any single character, other than the first or last
# character of the string
def substitute_special_char( str )
  if str.nil? || to_s.strip.length == 0
    return str
  end
  if str.length < MIN_LENGTH
    return str
  end
  pos = 0
  char_to_substitute = ''
  firstpos = 0
  lastpos = str.length - 1
  begin
    # For this technique, see: http://stackoverflow.com/a/10713963
    loop do
      pos = SecureRandom.random_number( str.length )
      break if firstpos < pos && pos < lastpos
    end
    char_to_substitute = SELECTED_SPECIAL_CHARS[ SecureRandom.random_number( SELECTED_SPECIAL_CHARS.length ) ]
  rescue NotImplementedError => e
    loop do
      pos = rand( str.length - 1 )
      break if firstpos < pos && pos < lastpos
    end
    char_to_substitute = SELECTED_SPECIAL_CHARS[ rand( SELECTED_SPECIAL_CHARS.length ) ]
  end
  str[ pos ] = char_to_substitute
  return str
end

# ---------------------------------------------------
# Main code block
# ---------------------------------------------------

module Puppet::Parser::Functions
  newfunction(:generate_password, :type => :rvalue, :doc => <<-ENDDOC
Returns a generated password. The value returned is suggested for use
as a first-time password when setting up a new user account, and is not
likely to be memorable by a human.

*Examples:*

    generate_password()

will return a generated password, with a length of #{MIN_LENGTH} characters.

    generate_password(16)

will return a generated password, with a length of 16 characters.

If the argument provided to this function cannot be converted to an integer value,
or if is convertable to an integer with a value lower than #{MIN_LENGTH}, will return a
generated password, with a minimum length of #{MIN_LENGTH} characters.

The password will include at least one character from each of three character classes:
digits (0-9), lowercase letters (a-f), and a set of special characters, '#{SPECIAL_CHARS_PRINTABLE}'

ENDDOC
  ) do |args|
    
    raise(Puppet::ParseError, "generate_password(): Too many arguments " +
      " (got #{args.size} arguments but expected 0 or 1)") if (args.size > 1)
    
    requested_length = args[0]
    length = MIN_LENGTH
    
    if requested_length.nil?
      length = MIN_LENGTH
    elsif requested_length.to_s.strip.length == 0
      length = MIN_LENGTH
    elsif requested_length.is_a? Integer
      if requested_length > MIN_LENGTH
        length = requested_length
      else
        length = MIN_LENGTH
      end
    elsif requested_length.is_a? String
      begin
        requested_length_val = Integer(requested_length)
        if requested_length_val > MIN_LENGTH
          length = requested_length_val
        else
          length = MIN_LENGTH
        end        
      rescue ArgumentError => e
        length = MIN_LENGTH
      end
    else
      # Do nothing here if none of these conditions are met;
      # 'length' defaults to the initially assigned value, above.
    end
    
    generated_password = ''
    begin
      generated_password = SecureRandom.hex( length )
      if generated_password.length >= length
        # The hex string generated will contain twice as many chars as the
        # requested length. Arbitrarily take the first part of the string,
        # up to the length value, for use as the generated password.
        generated_password = generated_password[ 0, length ]
        # Substitute a special character for any one character in the password;
        # thus, by doing this three times, adding 1-3 such characters to the password.
        # (Fewer than 3 in instances where one special character overwrites another.)
        3.times do
          generated_password = substitute_special_char( generated_password )
        end
      end
    rescue NotImplementedError => e
      # Do nothing here; return an empty password
      # TODO: Use a different method of generating an acceptable password
      # here, other than via SecureRandom. For some suggestions, see:
      # http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby/1619602
    end
    
    return generated_password
    
  end
end