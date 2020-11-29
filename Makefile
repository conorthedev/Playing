INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.0:12.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Playing

$(TWEAK_NAME)_FILES = Tweak.x Playing+UIImage.m
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote BulletinBoard
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei
$(TWEAK_NAME)_LIBRARIES = playing applist

SUBPROJECTS += libplaying Preferences Application ShortLook

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-all::
	cd libplaying && make && cd ..
