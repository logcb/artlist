# Exports cryptography credentials for the THE ARTLIST webserver.
#
# These transport layer security parameters include one 2048-bit RSA secret key,
# one X.509 certificate and a cipher list that specifies the encryption protocols
# we would like to use.
#
# THE ARTLIST prefers `HIGH` grade ciphers with key lengths larger than 128 bits
# (and some cipher suites with 128-bit keys to accomodate older devices).
#
# `!MD5` prohibits cipher suites using using MD5 because they are too weak.
#
# `!aNull` prohibits cipher suites that offer no authentication. This includes
# the anonymous DH algorithms and anonymous ECDH algorithms. Unauthenticated
# suites are disabled because they are vulnerable to man in the middle attacks.
#
# Waiting for Elliptic Curve Diffie-Hellman (ECDH) ciphers in Node.js version 12
# to provide forward secrecy...

{readFileSync} = require "fs"
hostname = "artlist" + (if process.env.NODE_ENV is "production" then ".website" else ".dev")

module.exports =
  cert: readFileSync "webserver/#{hostname}.certificates.pem"
  key:  readFileSync "webserver/#{hostname}.secret.key"
  ciphers: "HIGH:!MD5:!aNull"
  honorCipherOrder: yes
