#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
# ------------------------------------------------------------------------------
set -o nounset
set -o errexit

THIS=$(readlink -f ${BASH_SOURCE[0]})
PROJECT_ROOT=$(dirname $THIS)
. "${PROJECT_ROOT}"/lib/config.sh
. "${PROJECT_ROOT}"/lib/select-coin.sh
. "${PROJECT_ROOT}"/lib/setup-binaries.sh
. "${PROJECT_ROOT}"/lib/setup-cold-wallet.sh

select_coin
read -p "Setup Binaries for ${COIN}? [y/N]" PROCEED
case $PROCEED in
	[Yy]*)
		setup_binaries
		;;
	[Nn]*)
		echo "No setup of binaries."
		;;
	*)i
		echo "Please answer yes or no."
		;;
esac
select_cold_wallet
copy_wallet

${COIN}-qt -wallet=cold-wallet.dat
