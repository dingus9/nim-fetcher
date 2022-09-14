#!/bin/bash

installMusl() {
  if ! [[ -d "${MUSL_CROSS}" ]];
  then
    if ! [[ -f "${MUSL_CROSS}.tgz" ]]
    then
      curl -LO "${MUSL_REPO}/${MUSL_CROSS}".tgz
    fi
  tar -xzf "${MUSL_CROSS}.tgz"
  fi
}

buildOpenssl() {
  if [[ -d ${SSL_SRC_DIR} ]];
  then
    echo "Removing dirty openssl build dir ${SSL_SRC_DIR}"
    rm -rf "${SSL_SRC_DIR}"
  fi
  tar -xzf "${SSL_SRC_DIR}.tar.gz"

  ( cd "${SSL_SRC_DIR}" || exit 1;
    # shellcheck disable=SC2030
    CC="${CC} -static"
    export C_INCLUDE_PATH="${SSL_INCLUDE_DIR}"
    echo "${SSL_INSTALL_DIR}"
    echo "${CC}"

    ./Configure "${SSL_TARGET}" no-shared no-zlib no-async -fPIC -DOPENSSL_NO_SECURE_MEMORY --prefix="${SSL_INSTALL_DIR}"
    make -j8 depend
    make -j8
    make install_sw
  ) || exit 1
}

fetchUPX() {
  if ! [[ -f bin/upx ]];
  then
    local pkg;
    curl -L -O "${UPX_PACKAGE}";
    pkg="$(basename "${UPX_PACKAGE}")"
    xz -d "${pkg}"
    tar -xf "${pkg/.xz/}"
    cp "${pkg/.tar.xz/}/upx" bin/upx
    chmod u+x bin/upx;
  fi
}

optimizeBinary() {

  fetchUPX
  ./bin/upx "${1}"

}

# putEnv("CC", "musl-gcc -static -idirafter /usr/include/ -idirafter /usr/include/x86_64-linux-gnu/")
# putEnv("C_INCLUDE_PATH", libreSslIncludeDir)

MUSL_REPO="https://musl.cc"

export SSL_VERSION=1.1.1
export SSL_SRC_DIR=openssl-${SSL_VERSION}
export UPX_PACKAGE=https://github.com/upx/upx/releases/download/v3.96/upx-3.96-i386_linux.tar.xz

export SSL_URL="https://www.openssl.org/source/openssl-1.1.1.tar.gz"

case ${1} in
  mipssf)
    export MUSL_CROSS=mips-linux-muslsf-cross
    export SSL_INSTALL_DIR="${PWD}/openssl-${MUSL_CROSS}"
    export SSL_TARGET=linux-mips32
    export CPU_TARGET=i386
    # shellcheck disable=SC2031
    export CC="${PWD}/${MUSL_CROSS}/bin/mips-linux-muslsf-cc"
    export CC_STRIP=${PWD}/${MUSL_CROSS}/bin/mips-linux-muslsf-strip
    installMusl
  ;;
  linux-x86_64)
    export MUSL_CROSS=x86_64-linux-musl-native
    export SSL_INSTALL_DIR=${PWD}/openssl-linux-x86_64
    export CPU_TARGET=amd64
    export SSL_TARGET="linux-x86_64"
    export CC="${PWD}/${MUSL_CROSS}/bin/x86_64-linux-musl-cc"
    export CC_STRIP=${PWD}/${MUSL_CROSS}/bin/strip
    installMusl
  ;;
  *)
    echo "supported targets:"
    echo "mipssf"
    echo "linux-x86_64"
    exit 1
  ;;

esac

export SSL_INCLUDE_DIR=${SSL_INSTALL_DIR}/include/openssl

if ! [[ -d ${SSL_INSTALL_DIR}/lib ]];
then
  if ! [[ -f "${SSL_SRC_DIR}.tar.gz" ]];
  then
     curl -O "${SSL_URL}"
  fi
  buildOpenssl
fi

nim compile -o:bin/ \
  --passC="-I${SSL_INCLUDE_DIR}" \
  --passL="-L${SSL_INSTALL_DIR}/lib" \
  --passL="-lssl" \
  --passL="-lcrypto" \
  --passL:"-static" \
  --dynlibOverride=libssl \
  --dynlibOverride=libcrypto \
  --gcc.exe:"${CC}" \
  --gcc.linkerexe:"${CC}" \
  --opt:size \
  -d:release \
  -d:ssl \
  --opt:size \
  --cpu:${CPU_TARGET} \
  src/fetch.nim || exit 1

$CC_STRIP -s bin/fetch || exit 1

mv bin/fetch bin/fetch-"${1}"

file bin/fetch-"${1}"

optimizeBinary bin/fetch-"${1}"
