pkgname=bash-libs
pkgver=0.1
pkgrel=1
pkgdesc="A collection of bash libraries that I tend to use in my scripts"
arch=(any)
changelog=CHANGELOG.md
license=('GPLv3')
depends=()
makedepends=('git')
source=(
	"${pkgname}::git+https://github.com/ayakael/${pkgname}.git"
)

sha256sums=(
	"SKIP"
)

prepare(){
	cd ${srcdir}/${pkgname}
	git checkout ${pkgver}
}

package() {

	# Install the scripts
    for libs in $(find ${srcdir}/bash-libs/libs/. -type f -printf %f); do
  	    install -Dm644 "${srcdir}/bash-libs/libs/${libs}" "${pkgdir}/usr/lib/bash-libs/$(echo ${libs} | sed 's|.sh||')"
    done
}
