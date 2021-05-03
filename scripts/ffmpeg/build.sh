#!/usr/bin/env bash

case $ANDROID_ABI in
  x86)
    # Disabling assembler optimizations, because they have text relocations
    # now it works, since EXTRA_BUILD_CONFIGURATION_FLAGS is set at the end it will be set like this
    EXTRA_BUILD_CONFIGURATION_FLAGS='--disable-asm --disable-neon --disable-inline-asm --arch=i686 --cpu=i686'
    ;;
  x86_64)
    EXTRA_BUILD_CONFIGURATION_FLAGS=--x86asmexe=${FAM_YASM}
    ;;
esac

if [ "$FFMPEG_GPL_ENABLED" = true ] ; then
    EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-gpl"
fi

# Preparing flags for enabling requested libraries
ADDITIONAL_COMPONENTS=
for LIBARY_NAME in ${FFMPEG_EXTERNAL_LIBRARIES[@]}
do
  ADDITIONAL_COMPONENTS+=" --enable-$LIBARY_NAME"
done

# Referencing dependencies without pkgconfig
DEP_CFLAGS="-I${BUILD_DIR_DEPENDS}/${ANDROID_ABI}/include"
DEP_LD_FLAGS="-L${BUILD_DIR_DEPENDS}/${ANDROID_ABI}/lib $FFMPEG_EXTRA_LD_FLAGS"

SHARED_BUILD='--enable-shared'
STATIC_BUILD='--disable-static'
if [ "$STATIC_FFMPEG" = true ] ; then # create ffmpeg binary all included
    SHARED_BUILD='--disable-shared'
    STATIC_BUILD='--enable-static'
fi

./configure \
  --enable-decoder=mpeg4_mediacodec \
  --enable-decoder=vp8_mediacodec \
  --enable-decoder=hevc_mediacodec \
  --enable-encoder=mpeg4 \
  --enable-mediacodec \
  --enable-indev=v4l2 \
  --enable-outdev=v4l2 \
  --enable-version3 \
  --enable-pic \
  --enable-jni \
  --enable-optimizations \
  --enable-swscale \
  --enable-cross-compile \
  --target-os=android \
  --disable-indevs \
  --disable-outdevs \
  --disable-openssl \
  --disable-xmm-clobber-test \
  --disable-neon-clobber-test \
  --disable-ffplay \
  --disable-postproc \
  --disable-doc \
  --disable-htmlpages \
  --disable-manpages \
  --disable-podpages \
  --disable-txtpages \
  --disable-sndio \
  --disable-schannel \
  --disable-securetransport \
  --disable-xlib \
  --disable-cuda \
  --disable-cuvid \
  --disable-nvenc \
  --disable-vaapi \
  --disable-vdpau \
  --disable-videotoolbox \
  --disable-audiotoolbox \
  --disable-appkit \
  --disable-alsa \
  --disable-cuda \
  --disable-cuvid \
  --disable-nvenc \
  --disable-vaapi \
  --disable-vdpau \
  --prefix=${BUILD_DIR_FFMPEG}/${ANDROID_ABI} \
  --arch=${TARGET_TRIPLE_MACHINE_BINUTILS} \
  --sysroot=${SYSROOT_PATH} \
  --cc=${FAM_CC} \
  --cxx=${FAM_CXX} \
  --ld=${FAM_LD} \
  --ar=${FAM_AR} \
  --as=${FAM_CC} \
  --nm=${FAM_NM} \
  --ranlib=${FAM_RANLIB} \
  --strip=${FAM_STRIP} \
  --extra-cflags="-O3 -fPIC $DEP_CFLAGS -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd" \
  --extra-ldflags="$DEP_LD_FLAGS" \
  ${SHARED_BUILD} \
  ${STATIC_BUILD} \
  --pkg-config=${PKG_CONFIG_EXECUTABLE} \
  ${EXTRA_BUILD_CONFIGURATION_FLAGS} \
  $ADDITIONAL_COMPONENTS || exit 1

# not sure -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd is needed
# since optimizations are enabled

${MAKE_EXECUTABLE} clean
${MAKE_EXECUTABLE} -j${HOST_NPROC}
${MAKE_EXECUTABLE} install
