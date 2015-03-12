# Exports cryptography credentials for the THE ARTLIST webserver.
#
# These transport layer security parameters include one 2048-bit RSA secret key,
# one X.509 certificate and a cipher list that specifies the encryption protocols
# we would like to use.

{readFileSync} = require "fs"
hostname = "artlist" + (if process.env.NODE_ENV is "production" then ".website" else ".dev")

module.exports =
  cert: readFileSync "webserver/crypto/#{hostname}.certificates.pem"
  key:  readFileSync "secrets/#{hostname}.secret.key"
