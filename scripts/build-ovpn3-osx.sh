#!/bin/bash

set -eo pipefail

root_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)

[[ ! -e ${root_dir}/build/bin/ovpn3-test-client ]] || \
  exit 0

#
# OpenVPN3 Build Variables
#
export OSX_ONLY=1
export O3=${root_dir}/vendor/openvpn3
export DL=${root_dir}/build/downloads

mkdir -p ${DL}
source ${O3}/core/deps/lib-versions

archive=${DL}/${ASIO_VERSION}.tar.gz
[[ -e $archive ]] || \
  curl -L https://github.com/chriskohlhoff/asio/archive/${ASIO_VERSION}.tar.gz -o $archive
[[ "$ASIO_CSUM" == "$(shasum -a 256 $archive | cut -d" " -f1)" ]] || \
  (echo "ERROR! ASIO archive checksum does not match." && exit 1)

archive=${DL}/${MBEDTLS_VERSION}-apache.tgz
[[ -e $archive ]] || \
  curl -L https://tls.mbed.org/download/${MBEDTLS_VERSION}-apache.tgz -o $archive
[[ "$MBEDTLS_CSUM" == "$(shasum -a 256 $archive | cut -d" " -f1)" ]] || \
  (echo "ERROR! MBEDTLS archive checksum does not match." && exit 1)

version=${LZ4_VERSION#*-}
archive=${DL}/${LZ4_VERSION}.tar.gz
[[ -e $archive ]] || \
  curl -L https://github.com/lz4/lz4/archive/v${version}.tar.gz -o $archive
[[ "$LZ4_CSUM" == "$(shasum -a 256 $archive | cut -d" " -f1)" ]] || \
  (echo "ERROR! LZ4 archive checksum does not match." && exit 1)

# Build dependencies
$O3/core/scripts/mac/build-all

# Build OpenVPN3 test client executable
source $O3/core/vars/vars-osx64
source $O3/core/vars/setpath

pushd $O3/core/test/ovpncli
  DEBUG=1 MTLS=1 LZ4=1 ASIO=1 build cli
  mkdir -p ${root_dir}/build/bin
  mv cli ${root_dir}/build/bin/ovpn3-test-client
  mv cli.dSYM ${root_dir}/build/bin/ovpn3-test-client.dSYM
popd
