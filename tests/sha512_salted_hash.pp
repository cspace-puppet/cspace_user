# notify { 'Generate hash with no provided password':
#   message => sha512_salted_hash(),
# }

notify { 'Generate password from whitespace-only string':
  message => sha512_salted_hash( '  ' ),
}

notify { 'Generate hash from provided password string':
  message => sha512_salted_hash( 'foobar' ),
}
