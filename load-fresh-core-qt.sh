#!/bin/bash
# ------------------------------------------------------------------------------
set -o nounset
set -o errexit

THIS=$(readlink -f ${BASH_SOURCE[0]})
PROJECT_ROOT=$(dirname $THIS)
. ${PROJECT_ROOT}/lib/config
. ${PROJECT_ROOT}/lib/select-coin
. ${PROJECT_ROOT}/lib/setup-binaries
. ${PROJECT_ROOT}/lib/setup-cold-wallet

select_coin
setup_binaries

${COIN}-qt
