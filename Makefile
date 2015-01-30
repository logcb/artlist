setup: .git index.json webserver/artlist.dev.crt

deploy:
	git push artlist.website deploy:deploy

.git:
	git init
	git remote add origin git@github.com:logcb/artlist.git
	git remote add artlist.website core@artlist.website:artlist.git

index.json:
	echo "[]" > index.json

webserver/artlist.dev.secret.key:
	openssl genrsa 2048 > webserver/artlist.dev.secret.key

webserver/artlist.dev.crt: webserver/artlist.dev.secret.key
	./bin/certify-artlist.dev
