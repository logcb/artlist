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
RUN pacman --sync git --noconfirm
RUN pacman --sync nodejs --noconfirm

# Define the node environment.
ENV NODE_ENV production
ENV NODE_HOSTNAME artlist.website

# Clone source code.
RUN git clone https://github.com/logcb/artlist.git

# Set the file system to ea8edbffbaf55adf6ae177a2cab33747e6e6f780.
RUN cd artlist; git fetch --all; git reset --hard ea8edbffbaf55adf6ae177a2cab33747e6e6f780

# Install slowpost dependencies.
RUN cd artlist; npm install

# Add secret key and certificate for the web server.
ADD artlist.website.secret.key /artlist/webserver/artlist.website.secret.key
ADD artlist.website.certificates.pem /artlist/webserver/artlist.website.crt
