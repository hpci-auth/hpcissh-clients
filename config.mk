prefix = /usr/local
bindir = ${prefix}/bin
pkglibexecdir = ${prefix}/libexec
datadir = ${prefix}/share
pkgdatadir = ${datadir}/hpcissh
bash_path = /bin/bash

SED = sed
MKDIR_P = mkdir -p
RMDIR = rmdir
RM = rm
INSTALL = install -c
INSTALL_SCRIPT = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

do_subst = $(SED) -e 's,[@]bindir[@],$(bindir),g' \
		-e 's,[@]pkglibexecdir[@],${pkglibexecdir},g' \
		-e 's,[@]bash_path[@],$(bash_path),g'

.PHONY: all build install uninstall test clean
