#!/bin/bash

set -eo pipefail

root_dir=$(cd $(dirname $BASH_SOURCE)/.. && pwd)

[[ ! -e ${root_dir}/build/bin/udptunnel ]] || \
  exit 0

# Build raw tunnel cli
pushd ${root_dir}/vendor/udptunnel
  make mac
  mkdir -p ${root_dir}/build/bin
  mv speederv2 ${root_dir}/build/bin/udptunnel
  mv speederv2.dSYM ${root_dir}/build/bin/udptunnel.dSYM
popd
