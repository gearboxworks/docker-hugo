#!/bin/sh

# See gearboxworks/gearbox-base for details.
test -f /build/include-me.sh && . /build/include-me.sh

c_ok "Started."

c_ok "Installing packages."
if [ -f /build/build-hugo.apks ]
then
	APKS="$(cat /build/build-hugo.apks)"
	apk update && apk add --no-cache ${APKS}; checkExit
fi

if [ ! -d /usr/local/bin ]
then
	mkdir -p /usr/local/bin; checkExit
fi

if [ ! -d /hugo ]
then
	mkdir -p /hugo; checkExit
fi

cd /usr/local/bin
wget -qO- https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz; checkExit

wget -qO- https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_extended_${VERSION}_linux-64bit.tar.gz | tar -xz; checkExit
mv -i hugo hugo-extended; checkExit

wget -qO- https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-64bit.tar.gz | tar -xz; checkExit

chmod a+x /usr/local/bin/*; checkExit

#cd /hugo/themes
#git clone https://github.com/asurbernardo/amperage.git
#rm -rf amperage/.git*
#git clone https://github.com/wildhaber/gohugo-amp.git
#rm -rf gohugo-amp/.git*

# /usr/local/bin/hugo new site /project/hugo
# /usr/local/bin/hugo -D --verbose --minify
chown -fhR gearbox:gearbox /usr/local/bin /hugo; checkExit

c_ok "Finished."
