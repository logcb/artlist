# Exports cryptography credentials for the [webserver](index.coffee).
#
# These transport layer security parameters include
# one 2048-bit RSA secret key,
# one X.509 certificate
# and a [cipher list](http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT)
# that specifies the encryption protocols we would like to use.
#
# Slowpost prefers `HIGH` grade ciphers with key lengths larger than 128 bits
# (and some cipher suites with 128-bit keys).
#
# `!MD5` prohibits cipher suites using using MD5 because they are too weak.
#
# `!aNull` prohibits cipher suites that offer no authentication.
# This includes the anonymous DH algorithms and anonymous ECDH algorithms.
# Unauthenticated suites are disabled because they are vulnerable to man in the middle attacks.
#
# Waiting for [Elliptic Curve Diffie-Hellman (ECDH) ciphers in Node.js version 12](https://github.com/joyent/node/commit/6e453fad87c51dc15327628aa75886d3fbb3fa1c)
# to provide forward secrecy.

hostname = "artlist.dev"
{readFileSync} = require "fs"

module.exports =
  cert: readFileSync "webserver/#{hostname}.crt"
  key: readFileSync "webserver/#{hostname}.secret.key"
  ciphers: "HIGH:!MD5:!aNull"
  honorCipherOrder: yes
