setup: \
	storage/index.json \
	webserver/crypto/artlist.dev.certificates.pem \
	webserver/crypto/artlist.website.certificates.pem


# Storage folder.
storage:
	mkdir -p storage

# Download a copy of the index and save it to storage.
storage/index.json: storage
	curl https://artlist.website/index.json > storage/index.json


# PEM encoded file that includes the artlist.dev certificate and any intermediate certificates.
webserver/crypto/artlist.dev.certificates.pem: webserver/crypto/artlist.dev.crt
	cat webserver/crypto/artlist.dev.crt > webserver/crypto/artlist.dev.certificates.pem

# Make self-signed certificate for artlist.dev
webserver/crypto/artlist.dev.crt: webserver/crypto/artlist.dev.secret.key
	./bin/certify-artlist.dev

# Make secret key for artlist.dev
webserver/crypto/artlist.dev.secret.key:
	openssl genrsa 2048 > webserver/crypto/artlist.dev.secret.key


# PEM encoded file that includes the artlist.website certificate and the intermediate certificate.
webserver/crypto/artlist.website.certificates.pem: webserver/crypto/artlist.website.crt webserver/crypto/GandiStandardSSLCA.pem
	rm -f webserver/crypto/artlist.website.certificates.pem
	touch webserver/crypto/artlist.website.certificates.pem
	cat webserver/crypto/artlist.website.crt >> webserver/crypto/artlist.website.certificates.pem
	cat webserver/crypto/GandiStandardSSLCA.pem >> webserver/crypto/artlist.website.certificates.pem

# Make certificate signing request for artlist.website
webserver/crypto/artlist.website.csr: webserver/crypto/artlist.website.secret.key
	openssl req -new -key webserver/crypto/artlist.website.secret.key -out webserver/crypto/artlist.website.csr -subj "/CN=artlist.website"
	openssl req -noout -text -in webserver/crypto/artlist.website.csr

# Make secret key for artlist.website
webserver/crypto/artlist.website.secret.key:
	openssl genrsa -out artlist.website.secret.key 2048

# Download intermediate certificate from Gandi.
webserver/crypto/GandiStandardSSLCA.pem:
	curl -O https://www.gandi.net/static/CAs/GandiStandardSSLCA.pem > webserver/crypto/GandiStandardSSLCA.pem
