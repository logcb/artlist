FROM l3iggs/archlinux
CMD cd artlist; npm start
EXPOSE 80
EXPOSE 443
MAINTAINER girafe en bois

# Set the locale.
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen

# Refresh, upgrade and install software packages.
RUN pacman-db-upgrade
RUN pacman --refresh --refresh --sync --sysupgrade --noconfirm
RUN pacman --sync git nodejs python2 --noconfirm

# Define the node environment.
ENV NODE_ENV production
ENV NODE_PATH /artlist
ENV NODE_HOSTNAME artlist.website

# Clone source code.
RUN git clone https://github.com/logcb/artlist.git

# Set the file system to 22ccc0619db0dffe63478736abd1c53f9330288e.
RUN cd artlist; git fetch --all; git reset --hard 22ccc0619db0dffe63478736abd1c53f9330288e

# Install slowpost dependencies.
RUN cd artlist; npm install

# Add secret key and certificate for the web server.
ADD artlist.website.secret.key /artlist/webserver/crypto/artlist.website.secret.key
