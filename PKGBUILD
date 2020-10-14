# Maintainer: Stoica Tedy <stoicatedy@gmail.com>

pkgname=i8042-tedy-dkms
pkgver=0.1
pkgrel=1
pkgdesc="i8042 – module sources for Sony Laptop"
arch=(any)
license=(GPL2)
depends=(dkms linux-headers)
makedepends=()
sha256sums=()

package() {
  cd ..
  install -Dm644 i8042.c i8042.h i8042-x86ia64io.h dkms.conf Makefile -t "${pkgdir}"/usr/src/i8042-${pkgver}/
  install -Dm644 sony-fix.service /etc/systemd/system/
}