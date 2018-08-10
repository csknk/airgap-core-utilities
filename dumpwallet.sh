#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#
# This script runs `dumpprivkey` by safely unlocking the encrypted wallet and iterating
# over a list of supplied public addresses.
# See: https://bitcoin.org/en/developer-reference#dumpprivkey
# If necessary, prompt user for a custom data directory...in this context, we will not
# be using a custom data directory, so leave this variable set to false.
# Note that port 8332 needs to be open to allow bitcoin-cli to communicate with bitcoind.
# By default, this port is closed in TAILS - so we need to add an appropriate
# iptables rule.
# ------------------------------------------------------------------------------
set -o nounset
set -o errexit
THIS=$(readlink -f ${BASH_SOURCE[0]})
PROJECT_ROOT=$(dirname $THIS)
. "${PROJECT_ROOT}"/lib/config.sh
. "${PROJECT_ROOT}"/lib/select-coin.sh
. "${PROJECT_ROOT}"/lib/setup-binaries.sh
. "${PROJECT_ROOT}"/lib/setup-cold-wallet.sh
NAME=$0
CUSTOM_DATA_DIR='false'

read -p "Set up Binaries? [y/N]" PROCEED_BINARIES

case $PROCEED_BINARIES in
  [Yy]* )
    select_coin
    setup_binaries
  ;;
  [Nn]* )
    echo "Proceeding without setup of binaries..."
    select_coin
  ;;
  * ) echo "Please answer yes or no.";;
esac

read -p "Do you wish to set up a cold wallet? [y/N]" PROCEED

case $PROCEED in
  [Yy]* )
    select_cold_wallet
    copy_wallet
  ;;
  [Nn]* )
    echo "END"
  ;;
  * ) echo "Please answer yes or no.";;
esac

# Silently read the passphrase
# ------------------------------------------------------------------------------
function get_passphrase {
  echo "Please enter the wallet passphrase:"
  read -s WALLET_PASSPHRASE
}


# Unlock the wallet.
# ------------------------------------------------------------------------------
function unlock {
  echo "Please enter the wallet passphrase: "
  read -s WALLET_PASSPHRASE
  echo "Unlocking wallet..."
   ${COIN}-cli -wallet=cold-wallet.dat -rpcwait walletpassphrase "${WALLET_PASSPHRASE}" 600
}

# Use bitcoin-cli dumpwallet command to output private keys.
# ------------------------------------------------------------------------------
function dump_keys {
  DATE=$(date "+%Y-%m-%d-%H:%M:%S")
  DUMP_DIR=~/${COIN}-dumpwallet-${DATE}
  mkdir -p ${DUMP_DIR}
  WALLET_DUMP=${DUMP_DIR}/wallet-dump
  ${COIN}-cli dumpwallet ${WALLET_DUMP}
  ${COIN}-cli walletlock
  ${COIN}-cli stop
  echo "Your dumped wallet:"
  echo "${WALLET_DUMP}"
}

# Use GPG to symmetrically encrypt the dumped wallet data files, then securely
# delete the originals using the shred utility. Use a high-quality passphrase.
# ------------------------------------------------------------------------------
function encrypt_keyfiles_and_cleanup {
  echo "${NAME} - Encrypting wallet outputs..."
  gpg --armor --output ${WALLET_DUMP}.gpg --symmetric ${WALLET_DUMP}
  echo "${NAME} - Securely deleting the plaintext wallet dumps using shred..."
  shred -vfzu ${WALLET_DUMP}
  echo "Note that if you open the encrypted files in TAILS, they will be automatically decrypted."
}

# Execute
# ------------------------------------------------------------------------------
read -p "Do you want to do unlock the wallet and dump keys? [y/N]" YN
case $YN in
  [Yy]* )
  open_port
  start_daemon
  unlock
  dump_keys
  encrypt_keyfiles_and_cleanup
  ;;
  [Nn]* )
  echo "END."
  ;;
  * ) echo "Please answer yes or no.";;
esac
