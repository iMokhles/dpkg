# Include all the Makefiles that define variables that can be useful
# within debian/rules

dpkg_datadir = /Users/imokhles/Downloads/dpkg/ios-build/platform/x86_64-sim/share/dpkg
include $(dpkg_datadir)/architecture.mk
include $(dpkg_datadir)/buildflags.mk
include $(dpkg_datadir)/pkg-info.mk
include $(dpkg_datadir)/vendor.mk
