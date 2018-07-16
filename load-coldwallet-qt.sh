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
read -p "Setup Binaries for ${COIN}? [y/N]" PROCEED
case $PROCEED in
  [Yy]* )
  setup_binaries
  ;;
  [Nn]* )
  echo "No setup of binaries."
  ;;
  * ) echo "Please answer yes or no."
  ;;
esac
select_cold_wallet
copy_wallet

${COIN}-qt -wallet=cold-wallet.dat
