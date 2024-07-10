# Change HOST to x86_64-w64-mingw32 to build 64-bit binary
HOST=i686-w64-mingw32

sudo apt-get update && \
DEBIAN_FRONTEND="noninteractive" \
sudo apt-get install -y --no-install-recommends \
    make binutils autoconf automake autotools-dev libtool \
    patch ca-certificates perl \
    pkg-config git curl dpkg-dev gcc-mingw-w64 g++-mingw-w64 \
    autopoint libcppunit-dev libxml2-dev libgcrypt20-dev lzip \
    python3-docutils

curl -L -O https://github.com/FetheredSerpent/aria2-build-helper/releases/download/deps/gmp-6.3.0.tar.xz && \
curl -L -O https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.bz2 && \
curl -L -O https://www.sqlite.org/2023/sqlite-autoconf-3430100.tar.gz && \
curl -L -O https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz && \
curl -L -O https://github.com/c-ares/c-ares/releases/download/cares-1_19_1/c-ares-1.19.1.tar.gz && \
curl -L -O https://libssh2.org/download/libssh2-1.11.0.tar.bz2 && \
curl -L -O https://github.com/openssl/openssl/releases/download/openssl-3.3.1/openssl-3.3.1.tar.gz

sudo mkdir -p /usr/local/$HOST
sudo chmod 777 /usr/local/$HOST

tar xf gmp-6.3.0.tar.xz && \
cd gmp-6.3.0 && \
./configure \
    --disable-shared \
    --enable-static \
    --prefix=/usr/local/$HOST \
    --host=$HOST \
    --disable-cxx \
    --enable-fat \
    CFLAGS="-mtune=generic -O2 -g0" && \
make -j$(nproc) install

cd ..
tar xf expat-2.5.0.tar.bz2 && \
cd expat-2.5.0 && \
./configure \
    --disable-shared \
    --enable-static \
    --prefix=/usr/local/$HOST \
    --host=$HOST \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` && \
make -j$(nproc) install

cd ..
tar xf sqlite-autoconf-3430100.tar.gz && \
cd sqlite-autoconf-3430100 && \
./configure \
    --disable-shared \
    --enable-static \
    --prefix=/usr/local/$HOST \
    --host=$HOST \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` && \
make -j$(nproc) install

cd ..
tar xf zlib-1.3.1.tar.gz && \
cd zlib-1.3.1 && \
CC=$HOST-gcc \
AR=$HOST-ar \
LD=$HOST-ld \
RANLIB=$HOST-ranlib \
STRIP=$HOST-strip \
./configure \
    --prefix=/usr/local/$HOST \
    --libdir=/usr/local/$HOST/lib \
    --includedir=/usr/local/$HOST/include \
    --static && \
make -j$(nproc) install

cd ..
tar xf c-ares-1.19.1.tar.gz && \
cd c-ares-1.19.1 && \
./configure \
    --disable-shared \
    --enable-static \
    --without-random \
    --prefix=/usr/local/$HOST \
    --host=$HOST \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    LIBS="-lws2_32" && \
make -j$(nproc) install

cd ..
tar xf libssh2-1.11.0.tar.bz2 && \
cd libssh2-1.11.0 && \
./configure \
    --disable-shared \
    --enable-static \
    --prefix=/usr/local/$HOST \
    --host=$HOST \
    --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
    LIBS="-lws2_32" && \
make -j$(nproc) install

cd ..
tar xf openssl-3.3.1.tar.gz && \
cd openssl-3.3.1 && \
./Configure --cross-compile-prefix=$HOST- \
    --prefix=/usr/local/$HOST mingw && \
make -j$(nproc) install

ARIA2_VERSION=release-1.37.0
ARIA2_REF=refs/heads/master

cd ..
mkdir build
git clone -b $ARIA2_VERSION --depth 1 https://github.com/aria2/aria2 && \
mv mingw-config aria2 && cd aria2 && autoreconf -i && \
./mingw-config && make -j$(nproc) && \ $HOST-strip src/aria2c.exe && \
./mingw-release && mv *.zip ../build

cd ..
