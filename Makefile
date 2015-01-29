SCREENS = \
	index.html \
	share.html \
	comedy.html \
	community.html \
	dance.html \
	film.html \
	food.html \
	literature.html \
	music.html \
	theatre.html \
	visual_art.html \

default: .git assets/artlist.js index.json.js $(SCREENS)

webserver/artlist.dev.secret.key:
	openssl genrsa 2048 > webserver/artlist.dev.secret.key

webserver/artlist.dev.crt: webserver/artlist.dev.secret.key
	./bin/certify-artlist.dev

assets/artlist.js: assets/artlist.coffee
	coffee --compile --print $< > $@

index.json.js: index.json
	echo "Artlist.index.set(" > index.json.js
	cat index.json >> index.json.js
	echo ");" >> index.json.js

%.html: templates/%.html templates/head.html templates/header.html templates/list.html
	render $< > $@

2014-11-28/001.html: 2014-11-28/001.cson
	render-event 2014-11-28/001

.git:
	git init
	git remote add origin git@github.com:logcb/artlist.git
	git remote add artlist.website core@artlist.website:artlist.git

deploy:
	git push origin deploy:gh-pages
	git push artlist.website deploy:deploy

review:
	git push origin deploy:gh-pages
