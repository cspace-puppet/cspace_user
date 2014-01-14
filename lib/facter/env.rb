# Script to add the values of environment variables as custom Facter facts
#
# These values are then accessible via variables of the form
# "${env_environmentvariablenamehere}"; e.g. "${env_home}" for the
# HOME environment variable.

# Written by Valentin Höbel:
# http://www.xenuser.org/open-source-development/using-environment-variables-in-puppet/
# As Valentin notes, "Please do not forget that you have to place that ruby script
# (env.rb) on every Puppet agent system."

# See also "Custom Facts":
# http://docs.puppetlabs.com/guides/custom_facts.html
# and "Plugins in Modules"
# http://docs.puppetlabs.com/guides/plugins_in_modules.html

# Note: when running under Ruby 1.8.7, reading the ENV hash yields this error:
# "Warning: importenv is deprecated after Ruby 1.8.1 (no replacement)"
#
# However, the ENV hash is documented as working through at least through Ruby 2.1
# (see http://ruby-doc.org/core-2.1.0/ENV.html), so doing this still appears
# to be safe. Perhaps there may later be a different underlying API call
# for obtaining the values in that hash? 

ENV.each do |k,v|
    Facter.add("env_#{k.downcase}".to_sym) do
        setcode do
            v
        end
    end
end
