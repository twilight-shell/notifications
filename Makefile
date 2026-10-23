PREFIX ?= /usr
QMLDIR ?= $(PREFIX)/lib/qt6/qml
DEST = $(DESTDIR)$(QMLDIR)/Twilight/Notifications

install:
	install -d $(DEST)
	cp -r Twilight/Notifications/. $(DEST)

uninstall:
	rm -rf $(DEST)

.PHONY: install uninstall
