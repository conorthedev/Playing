ARCHS = arm64 arm64e
TARGET = iphone:clang:13.0:12.4
GO_EASY_ON_ME=1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libplaying

libplaying_FILES = libplaying.m
libplaying_CFLAGS = -fobjc-arc
libplaying_PRIVATE_FRAMEWORKS = MediaRemote BulletinBoard
libplaying_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/library.mk

stage::
	mkdir -p $(THEOS)/include/Playing
	cp -r libplaying.h $(THEOS)/include/Playing
	cp $(THEOS_STAGING_DIR)/usr/lib/libplaying.dylib $(THEOS)/lib/libplaying.dylib