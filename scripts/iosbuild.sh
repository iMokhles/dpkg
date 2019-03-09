#!/bin/sh
#
# Build a fat binary for iOS

# Number of CPUs (for make -j)
NCPU=`sysctl -n hw.ncpu`
if test x$NJOB = x; then
    NJOB=$NCPU
fi

SRC_DIR=$(cd `dirname $0`/..; pwd)
if [ "$PWD" = "$SRC_DIR" ]; then
    PREFIX=$SRC_DIR/ios-build
    mkdir $PREFIX
else
    PREFIX=$PWD
fi

BUILD_I386_IOSSIM=YES
BUILD_X86_64_IOSSIM=YES

BUILD_IOS_ARMV7=YES
BUILD_IOS_ARMV7S=YES
BUILD_IOS_ARM64=YES

# 13.4.0 - Mavericks
# 14.0.0 - Yosemite
# 15.0.0 - El Capitan
DARWIN=darwin18.2.0

XCODEDIR=`xcode-select --print-path`
IOS_SDK_VERSION=`xcrun --sdk iphoneos --show-sdk-version`
MIN_SDK_VERSION=8.0

IPHONEOS_PLATFORM=`xcrun --sdk iphoneos --show-sdk-platform-path`
IPHONEOS_SYSROOT=`xcrun --sdk iphoneos --show-sdk-path`

IPHONESIMULATOR_PLATFORM=`xcrun --sdk iphonesimulator --show-sdk-platform-path`
IPHONESIMULATOR_SYSROOT=`xcrun --sdk iphonesimulator --show-sdk-path`

CC=clang
CXX=clang

SILENCED_WARNINGS="-Wno-unused-local-typedef -Wno-unused-function"

CFLAGS="${CLANG_VERBOSE} ${SILENCED_WARNINGS} -DNDEBUG -g -O0 -pipe -fPIC -fobjc-arc"

echo "PREFIX ..................... ${PREFIX}"
echo "BUILD_MACOSX_X86_64 ........ ${BUILD_MACOSX_X86_64}"
echo "BUILD_I386_IOSSIM .......... ${BUILD_I386_IOSSIM}"
echo "BUILD_X86_64_IOSSIM ........ ${BUILD_X86_64_IOSSIM}"
echo "BUILD_IOS_ARMV7 ............ ${BUILD_IOS_ARMV7}"
echo "BUILD_IOS_ARMV7S ........... ${BUILD_IOS_ARMV7S}"
echo "BUILD_IOS_ARM64 ............ ${BUILD_IOS_ARM64}"
echo "DARWIN ..................... ${DARWIN}"
echo "XCODEDIR ................... ${XCODEDIR}"
echo "IOS_SDK_VERSION ............ ${IOS_SDK_VERSION}"
echo "MIN_SDK_VERSION ............ ${MIN_SDK_VERSION}"
echo "IPHONEOS_PLATFORM .......... ${IPHONEOS_PLATFORM}"
echo "IPHONEOS_SYSROOT ........... ${IPHONEOS_SYSROOT}"
echo "IPHONESIMULATOR_PLATFORM ... ${IPHONESIMULATOR_PLATFORM}"
echo "IPHONESIMULATOR_SYSROOT .... ${IPHONESIMULATOR_SYSROOT}"
echo "CC ......................... ${CC}"
echo "CFLAGS ..................... ${CFLAGS}"
echo "CXX ........................ ${CXX}"
echo "CXXFLAGS ................... ${CXXFLAGS}"
echo "LDFLAGS .................... ${LDFLAGS}"

echo "$(tput setaf 2)"
echo "###########################"
echo "# i386 for iPhone Simulator"
echo "###########################"
echo "$(tput sgr0)"

if [ "${BUILD_I386_IOSSIM}" == "YES" ]
then
    (
        cd ${PREFIX}
        make clean
        ../configure --disable-dselect --disable-start-stop-daemon --build=x86_64-apple-${DARWIN} --host=i386-ios-${DARWIN} --disable-shared --prefix=${PREFIX}/platform/i386-sim "CFLAGS=-mios-simulator-version-min=${MIN_SDK_VERSION} -arch i386 -isysroot ${IPHONESIMULATOR_SYSROOT}" || exit 2
        make -j10 || exit 3
        make install
    ) || exit $?
fi

echo "$(tput setaf 2)"
echo "#############################"
echo "# x86_64 for iPhone Simulator"
echo "#############################"
echo "$(tput sgr0)"

if [ "${BUILD_X86_64_IOSSIM}" == "YES" ]
then
    (
        cd ${PREFIX}
        make clean
        ../configure --disable-dselect --disable-start-stop-daemon --build=x86_64-apple-${DARWIN} --host=x86_64-ios-${DARWIN} --disable-shared --prefix=${PREFIX}/platform/x86_64-sim "CFLAGS=-mios-simulator-version-min=${MIN_SDK_VERSION} -arch x86_64 -isysroot ${IPHONESIMULATOR_SYSROOT}" || exit 2
        make -j$NJOB || exit 3
        make install
    ) || exit $?
fi

echo "$(tput setaf 2)"
echo "##################"
echo "# armv7 for iPhone"
echo "##################"
echo "$(tput sgr0)"

if [ "${BUILD_IOS_ARMV7}" == "YES" ]
then
    (
        cd ${PREFIX}
        make clean
        ../configure --disable-dselect --disable-start-stop-daemon --build=x86_64-apple-${DARWIN} --host=armv7-ios-${DARWIN} --disable-shared --prefix=${PREFIX}/platform/armv7-ios "CFLAGS=-miphoneos-version-min=${MIN_SDK_VERSION} -arch armv7 -isysroot ${IPHONEOS_SYSROOT}" || exit 2
        make -j$NJOB || exit 3
        make install
    ) || exit $?
fi

echo "$(tput setaf 2)"
echo "###################"
echo "# armv7s for iPhone"
echo "###################"
echo "$(tput sgr0)"

if [ "${BUILD_IOS_ARMV7S}" == "YES" ]
then
    (
        cd ${PREFIX}
        make clean
        ../configure --disable-dselect --disable-start-stop-daemon --build=x86_64-apple-${DARWIN} --host=armv7s-ios-${DARWIN} --disable-shared --prefix=${PREFIX}/platform/armv7s-ios "CFLAGS=-miphoneos-version-min=${MIN_SDK_VERSION} -arch armv7s -isysroot ${IPHONEOS_SYSROOT}" || exit 2
        make -j$NJOB || exit 3
        make install
    ) || exit $?
fi

echo "$(tput setaf 2)"
echo "##################"
echo "# arm64 for iPhone"
echo "##################"
echo "$(tput sgr0)"

if [ "${BUILD_IOS_ARM64}" == "YES" ]
then
    (
        cd ${PREFIX}
        make clean
        ../configure --disable-dselect --disable-start-stop-daemon --build=x86_64-apple-${DARWIN} --host=arm-ios-${DARWIN} --disable-shared --prefix=${PREFIX}/platform/arm64-ios "CFLAGS=-miphoneos-version-min=${MIN_SDK_VERSION} -arch arm64 -isysroot ${IPHONEOS_SYSROOT}" || exit 2
        make -j$NJOB || exit 3
        make install
    ) || exit $?
fi

echo "$(tput setaf 2)"
echo "###################################################################"
echo "# Create Universal Libraries and Finalize the packaging"
echo "###################################################################"
echo "$(tput sgr0)"

(
    cd ${PREFIX}/platform
    mkdir -p universal
    lipo x86_64-sim/lib/libdpkg.a i386-sim/lib/libdpkg.a arm64-ios/lib/libdpkg.a armv7s-ios/lib/libdpkg.a armv7-ios/lib/libdpkg.a -create -output universal/libdpkg.a
)

(
    cd ${PREFIX}
    mkdir -p lib
    cp -r platform/universal/* lib
    #rm -rf platform
    lipo -info lib/libdpkg.a
)

echo Done!
