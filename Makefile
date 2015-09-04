setup: storage/index.json storage/permits.json

# Create the storage folder.
storage:
	mkdir -p storage

# Download a copy of index.json from the website and save it to storage.
storage/index.json: storage
	curl https://theartlist.ca/index.json > storage/index.json

# Create an empty list of permits and save it to storage.
storage/permits.json: storage
	echo "[]" > storage/permits.json


# ------------------------------------------
# SSL files for https://theartlist.ca

# PEM encoded file that includes theartlist.ca certificate and the intermediate certificates from GoDaddy.
webserver/crypto/theartlist.ca.certificates.pem:
	rm -f webserver/crypto/theartlist.ca.certificates.pem
	touch webserver/crypto/theartlist.ca.certificates.pem
	cat webserver/crypto/fa2214863c4f2253.crt >> webserver/crypto/theartlist.ca.certificates.pem
	cat webserver/crypto/gd_bundle-g2-g1.crt >> webserver/crypto/theartlist.ca.certificates.pem

# Make certificate signing request for theartlist.ca with the secret key.
webserver/crypto/theartlist.ca.csr: secrets/theartlist.ca.secret.key
	openssl req -new -key secrets/theartlist.ca.secret.key -out webserver/crypto/theartlist.ca.csr -subj "/CN=theartlist.ca"
	openssl req -noout -text -in webserver/crypto/theartlist.ca.csr

# Generate a secret key for theartlist.ca
secrets/theartlist.ca.secret.key:
	openssl genrsa -out secrets/theartlist.ca.secret.key 2048


# ------------------------------------------
# SSL files for https://artlist.website

# PEM encoded file that includes the artlist.website certificate and the intermediate certificate.
webserver/crypto/artlist.website.certificates.pem: webserver/crypto/artlist.website.crt webserver/crypto/GandiStandardSSLCA.pem
	rm -f webserver/crypto/artlist.website.certificates.pem
	touch webserver/crypto/artlist.website.certificates.pem
	cat webserver/crypto/artlist.website.crt >> webserver/crypto/artlist.website.certificates.pem
	cat webserver/crypto/GandiStandardSSLCA.pem >> webserver/crypto/artlist.website.certificates.pem

# Make certificate signing request for artlist.website
webserver/crypto/artlist.website.csr: secrets/artlist.website.secret.key
	openssl req -new -key secrets/artlist.website.secret.key -out webserver/crypto/artlist.website.csr -subj "/CN=artlist.website"
	openssl req -noout -text -in webserver/crypto/artlist.website.csr

# Make secret key for artlist.website
secrets/artlist.website.secret.key:
	openssl genrsa -out secrets/artlist.website.secret.key 2048

# Download intermediate certificate from Gandi.
webserver/crypto/GandiStandardSSLCA.pem:
	curl -O https://www.gandi.net/static/CAs/GandiStandardSSLCA.pem > webserver/crypto/GandiStandardSSLCA.pem


# ----------------------------------------
# SSL files for https://artlist.dev

# PEM encoded file that includes the artlist.dev certificate and any intermediate certificates.
webserver/crypto/artlist.dev.certificates.pem: webserver/crypto/artlist.dev.crt
	cat webserver/crypto/artlist.dev.crt > webserver/crypto/artlist.dev.certificates.pem

# Make self-signed certificate for artlist.dev
webserver/crypto/artlist.dev.crt: secrets/artlist.dev.secret.key
	./bin/certify-artlist.dev

# Make secret key for artlist.dev
secrets/artlist.dev.secret.key:
	openssl genrsa 2048 > secrets/artlist.dev.secret.key
