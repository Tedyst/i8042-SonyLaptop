KERNELRELEASE	?= `uname -r`
KERNEL_DIR	?= /lib/modules/$(KERNELRELEASE)/build
PWD		:= $(shell pwd)
obj-m		:= i8042.o

PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin
MANDIR  = $(PREFIX)/share/man
MAN1DIR = $(MANDIR)/man1
INSTALL = install
INSTALL_PROGRAM = $(INSTALL) -p -m 755
INSTALL_DIR     = $(INSTALL) -p -m 755 -d
INSTALL_DATA    = $(INSTALL) -m 644

MODULE_OPTIONS = devices=2

##########################################
# note on build targets
#
# module-assistant makes some assumptions about targets, namely
#  <modulename>: must be present and build the module <modulename>
#                <modulename>.ko is not enough
# install: must be present (and should only install the module)
#
# we therefore make <modulename> a .PHONY alias to <modulename>.ko
# and remove utils-installation from 'install'
# call 'make install-all' if you want to install everything
##########################################


.PHONY: all install clean distclean
.PHONY: install-all install-utils install-man
.PHONY: modprobe i8042

# we don't control the .ko file dependencies, as it is done by kernel
# makefiles. therefore i8042.ko is a phony target actually
.PHONY: i8042.ko

all: i8042.ko
i8042: i8042.ko
i8042.ko:
	@echo "Building v4l2-loopback driver..."
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

install-all: install install-utils install-man
install:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules_install
	@echo ""
	@echo "SUCCESS (if you got 'SSL errors' above, you can safely ignore them)"
	@echo ""

install-utils: utils/i8042-ctl
	$(INSTALL_DIR) "$(DESTDIR)$(BINDIR)"
	$(INSTALL_PROGRAM) $< "$(DESTDIR)$(BINDIR)"

install-man: man/i8042-ctl.1
	$(INSTALL_DIR) "$(DESTDIR)$(MAN1DIR)"
	$(INSTALL_DATA) $< "$(DESTDIR)$(MAN1DIR)"

clean:
	rm -f *~
	rm -f Module.symvers Module.markers modules.order
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean

distclean: clean
	rm -f man/i8042-ctl.1

modprobe: i8042.ko
	chmod a+r i8042.ko
	sudo modprobe videodev
	-sudo rmmod i8042
	sudo insmod ./i8042.ko $(MODULE_OPTIONS)

man/i8042-ctl.1: utils/i8042-ctl
	help2man -N --name "control v4l2 loopback devices" $^ > $@

.clang-format:
	curl "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/.clang-format" > $@

.PHONY: clang-format
clang-format: .clang-format
	clang-format -i *.c *.h
