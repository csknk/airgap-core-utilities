#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#
# Open a Bitcoin Core or Litecoin core cold wallet in an offline Tails session.
# - Setup Bitcoin/Litecoin binaries
# - Select a cold wallet
# - Move cold wallet to the default data directory
# ------------------------------------------------------------------------------

set -o nounset
set -o errexit

function select_cold_wallet {
  WALLET_FILE=$(zenity --file-selection --title="Select a Cold Wallet to run." --filename=${PWD})
  case $? in
    0)
    echo "\"$WALLET_FILE\" selected.";;
    1)
    echo "No file selected.";;
    -1)
    echo "An unexpected error has occurred.";;
  esac
}

# Copy wallet to the default data directory
# ------------------------------------------------------------------------------
function copy_wallet {
  DATA_DIR=~/.${COIN}
  if [[ ! -d "${DATA_DIR}" ]]; then
    echo "Creating ${DATA_DIR}..."
    mkdir ${DATA_DIR}
  fi
  if [[ "${DATA_DIR}"/cold-wallet.dat ]]; then
    echo "Remove exisiting cold wallet, ${DATA_DIR}/cold-wallet.dat"
    rm -f ${DATA_DIR}/cold-wallet.dat
  fi
  echo "Make a copy of ${DATA_DIR}/cold-wallet.dat from ${WALLET_FILE}"
  cp "${WALLET_FILE}" ${DATA_DIR}

  # rename for later access by bitcoin-cli
  NAME=$(basename "${WALLET_FILE}")
  mv ${DATA_DIR}/"${NAME}" ${DATA_DIR}/cold-wallet.dat
}

# Start the Bitcoin daemon: bitcoind command is set up in `/lib/setup-binaries`
# ------------------------------------------------------------------------------
function start_daemon {
  echo "Starting ${COIN}d in the background..."
  (${COIN}d -wallet=cold-wallet.dat -daemon)
}

# Open the required port for the RPC server. Note that Bitcoin & Litecoin use
# different ports.
# ------------------------------------------------------------------------------
function open_port {
  if [[ ${COIN} == 'bitcoin' ]]; then
    PORT=8332
  else
    PORT=9332
  fi
  sudo iptables -I OUTPUT -d 127.0.0.1/32 -o lo -p tcp -m tcp --dport ${PORT} --tcp-flags FIN,SYN,RST,ACK SYN -m owner --uid-owner 1000 -j ACCEPT
}
