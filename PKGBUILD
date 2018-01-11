pkgname=bunc
pkgver=0.1
pkgrel=1
pkgdesc="A functional bash library"
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

build(){
    cd ${srcdir}/bunc
    bash ./build
}

package() {
	# Install the library
  	install -Dm644 "${srcdir}/bunc/bunc /usr/lib/bash/bunc"
}
