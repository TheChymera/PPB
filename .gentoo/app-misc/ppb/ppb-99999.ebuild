# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The Personal Pastebin"
HOMEPAGE="https://github.com/TheChymera/ppb"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64"

DEPEND="app-text/ansifilter"
RDEPEND=""

src_install() {
	dobin "bin/ppb"

	insinto "/etc/"
	doins config/ppb.conf
}

src_unpack() {
	cp -r -L "$DOTGENTOO_PACKAGE_ROOT" "$S"
}
