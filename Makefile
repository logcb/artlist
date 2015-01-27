SCREENS = \
	index.html \
	share.html \
	comedy.html \
	community.html \
	dance.html \
	film.html \
	# food.html \
	# music.html \
	# theatre.html \
	# visual_art.html \

default:
	make $(SCREENS)

%.html: templates/%.html templates/head.html templates/header.html templates/list.html
	render $< > $@

# *.html: templates/*.html
# 	bin/render templates/index.html > $@

# %.html: templates/*.html
# 	bin/render templates/$% > $@
#
# comedy.html: templates/*.html
# 	bin/render templates/dance.html > $@


2014-11-28/001.html: 2014-11-28/001.cson
	render-event 2014-11-28/001
