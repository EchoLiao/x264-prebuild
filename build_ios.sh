#!/bin/sh

# http://www.videolan.org/developers/x264.html
# ftp.videolan.org/pub/videolan/x264/snapshots/
# http://ffmpegmac.net/HowTo/

major=20130220
minor=2245
micro=1

SDK_VERS=8.1
XCD_ROOT="/Applications/Xcode.app/Contents/Developer"
TOL_ROOT="${XCD_ROOT}/Toolchains/XcodeDefault.xctoolchain"
SDK_ROOT="${XCD_ROOT}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDK_VERS}.sdk"
SDK_SML_ROOT="${XCD_ROOT}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDK_VERS}.sdk"

export PATH=$TOL_ROOT/usr/bin:$PATH

work=`pwd`
srcs=$work/src
buid=$work/build
insl=$buid/install
name=x264-snapshot-${major}-${minor}-stable
pakt=${name}.tar.bz2
dest=$work/x264-iOS-${major}.${minor}.${micro}-stable.tgz

rm -rf $srcs $buid $dest
mkdir -p $srcs $buid $dist

[[ ! -e $pakt ]] && {
  wget -c ftp://ftp.videolan.org/pub/videolan/x264/snapshots/$pakt
}

tar xvjf $pakt -C $srcs
cd $srcs/$name
perl -i -pe "s| -falign-loops=16||" configure

archs="armv7 armv7s arm64 i386"

for a in $archs; do
  case $a in
    arm*)
      sys_root=${SDK_ROOT}
      host=arm-apple-darwin9
      ;;
    i386)
      sys_root=${SDK_SML_ROOT}
      host=i686-apple-darwin9
      ;;
  esac
  prefix=$insl/$a && rm -rf $prefix && mkdir -p $prefix
  ./configure \
    --sysroot=${sys_root} \
    --extra-cflags="-arch ${a} -isysroot ${sys_root} -miphoneos-version-min=7.0" \
    --extra-ldflags="-arch ${a} -isysroot ${sys_root} -miphoneos-version-min=7.0" \
    --host=$host \
    --cross-prefix= \
    --prefix=${prefix} \
    --disable-asm \
    --disable-cli \
    --enable-pic \
    --enable-static \
    && make clean \
    && make -j 4 \
    && make install \
    && make install-lib-static
  lipo_archs="$lipo_archs $prefix/lib/libx264.a"
done

univ=$insl/universal && mkdir -p $univ/lib
cp -r $prefix/include $univ/
lipo $lipo_archs -create -output $univ/lib/libx264.a
ranlib $univ/lib/libx264.a
strip -S $univ/lib/libx264.a

cd $univ && tar cvzf $dest *
