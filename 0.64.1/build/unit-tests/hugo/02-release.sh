#!/bin/bash
# Created on 2020-02-18T21:29:56+1100, using template:02-release.sh.tmpl and json:gearbox.json

p_info "hugo-0.64.1" "Release test started."

if id -u gearbox
then
	c_ok "Gearbox user found."
else
	c_err "Gearbox user NOT found."
fi

if id -g gearbox
then
	c_ok "Gearbox group found."
else
	c_err "Gearbox group NOT found."
fi

p_info "hugo-0.64.1" "Release test finished."
