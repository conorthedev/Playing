ARCHS = arm64 arm64e
TARGET = iphone:clang:13.0:12.4
GO_EASY_ON_ME=1

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libplaying

libplaying_FILES = PlayingManager.m PlayingNotificationManager.m PlayingPreferences.m
libplaying_CFLAGS = -fobjc-arc
libplaying_EXTRA_FRAMEWORKS = Cephei
libplaying_PRIVATE_FRAMEWORKS = MediaRemote BulletinBoard

include $(THEOS_MAKE_PATH)/library.mk

all::
	mkdir -p $(THEOS)/include/Playing
	cp -r *.h $(THEOS)/include/Playing
	cp -r internal $(THEOS)/include/Playing
	cp ../.theos/obj/debug/libplaying.dylib $(THEOS)/lib/libplaying.dylib