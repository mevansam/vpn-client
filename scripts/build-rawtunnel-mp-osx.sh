#!/bin/bash

set -eo pipefail

root_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)

[[ ! -e ${root_dir}/build/bin/rawtunnel ]] || \
  exit 0

# Install dependencies
brew_pkg_list=$(brew list -l | awk '{ print $9 }')
echo "$brew_pkg_list" | grep "libpcap" 2>&1 >/dev/null \
  || brew install libpcap
echo "$brew_pkg_list" | grep "libnet" 2>&1 >/dev/null \
  || brew install libnet

# Build raw tunnel cli
pushd ${root_dir}/vendor/rawtunnel-mp
  make mac
  mkdir -p ${root_dir}/build/bin
  mv udp2raw_mp ${root_dir}/build/bin/rawtunnel
  mv udp2raw_mp.dSYM ${root_dir}/build/bin/rawtunnel.dSYM
popd
