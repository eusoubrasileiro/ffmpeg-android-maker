echo pwd
echo "Building motion same settings of ffmpeg"
echo "Sysroot"
echo ${SYSROOT_PATH}

# Only choose one of these, depending on your device...
export TARGET=${TARGET}
# Configure and build.
export AR=${FAM_AR}
export CC=${FAM_CC}
export CP=${FAM_CC}
export AS=${FAM_CC}
export CXX=${FAM_CXX}
export LD=${FAM_LD}
export RANLIB=${FAM_RANLIB}
export STRIP=${FAM_STRIP}

echo "LD ${FAM_LD}"

# PKG_CONFIG_PATH already exported with dependencies
# MUST use sudo apt-get install pkg-config NOT pkgconf package
# echo ${PKG_CONFIG_PATH}
# PKG_CONFIG NOT WORKING! better use CFLAGS, LDFLAGS
CFLAGS="-O3 -fPIC -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd"
export CFLAGS="${CFLAGS} -I${INSTALL_DIR}/include/"
export LDFLAGS="-L${INSTALL_DIR}/lib/"


sudo autoreconf -fiv # SUDO otherwise libtoolize error on copying to m4
sudo chown andre:andre -R *

./configure  \
  --prefix=${INSTALL_DIR} \
  --with-ffmpeg=${BUILD_DIR_FFMPEG}/${ANDROID_ABI} \
  --host=${TARGET} \
  --with-sysroot=${SYSROOT_PATH} \
  --enable-static \
  --with-pic \
  CC=${FAM_CC} \
  AR=${FAM_AR} \
  RANLIB=${FAM_RANLIB} || exit 1

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install
