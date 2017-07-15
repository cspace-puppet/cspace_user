#
# puppet apply tests/generate_password.pp --noop --modulepath=..
#
notify { 'Generate password with default length':
  message => generate_password(),
}

notify { 'Generate password with non-integer length value':
  message => generate_password( 'foobar' ),
}

notify { 'Generate password with whitespace-only length value':
  message => generate_password( '  ' ),
}

notify { 'Generate password with provided length value':
  message => generate_password( '20' ),
}