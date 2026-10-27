TARGET := iphone:clang:latest:15.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LucidX

LucidX_FILES = Tweak.x
LucidX_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
LucidX_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
