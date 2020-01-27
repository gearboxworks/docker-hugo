#!/bin/sh

# See gearboxworks/gearbox-base for details.
test -f /build/include-me.sh && . /build/include-me.sh

c_ok "Started."

mkdir -p /usr/local/bin /hugo 

cd /usr/local/bin
wget -qO- https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-64bit.tar.gz | tar -xz; checkExit
wget -qO- https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz; checkExit

chmod a+x /usr/local/bin/hugo /usr/local/bin/minify; checkExit

/usr/local/bin/hugo new site /hugo

chown -fhR gearbox:gearbox /usr/local/bin /hugo

c_ok "Finished."
