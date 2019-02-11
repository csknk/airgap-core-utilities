#!/bin/bash
# Copyright (c) 2019i David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#
# This script is intended for use in an offline Tails session.
#
# The bitcoin-cli dumpprivkey command is used to output private keys for specified public addresses. The public
# addresses should be stored in a manifest file, with one address per line. The script allows the mainfest
# file to be selected by means of a zenity GUI dialogue.
#
# The private key for each address is encrypted into a file whose filename corresponds to the public address.
# 
# The script uses GPG to symmetrically encrypt the dumped private key files, which requires a password. The
# original dumped files are securely deleted by means of the shred utility.
#
#
# See: https://bitcoin.org/en/developer-reference#dumpprivkey
#
# Note that port 8332 needs to be open to allow bitcoin-cli to communicate with bitcoind.
# By default, this port is closed in TAILS - so we need to add an appropriate
# iptables rule.
# ------------------------------------------------------------------------------
set -o nounset # same as set -u
set -o errexit # same as set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' ERR
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR

THIS=$(readlink -f ${BASH_SOURCE[0]})
PROJECT_ROOT=$(dirname "${THIS}")
. "${PROJECT_ROOT}"/lib/config.sh
. "${PROJECT_ROOT}"/lib/select-coin.sh
. "${PROJECT_ROOT}"/lib/setup-binaries.sh
. "${PROJECT_ROOT}"/lib/setup-cold-wallet.sh
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
  WALLET_NAME=$(basename "${WALLET_FILE}")
  ;;
  [Nn]* )
  echo "END"
  ;;
  * ) echo "Please answer yes or no.";;
esac

# Unlock the wallet.
# ------------------------------------------------------------------------------
function unlock {
  echo "Please enter the wallet passphrase: "
  read -s WALLET_PASSPHRASE
  echo "Unlocking wallet..."
   ${COIN}-cli -wallet=cold-wallet.dat -rpcwait walletpassphrase "${WALLET_PASSPHRASE}" 600
}

function select_passphrase_file {
  ENCRYPTED_PASSPHRASE=$(zenity --file-selection --title="Select a file that contains an encrypted passphrase." --filename=~/)
  case $? in
    0)
      echo "\"${ENCRYPTED_PASSPHRASE}\" selected.";;
    1)
      echo "No file selected.";;
    -1)
      echo "An unexpected error has occurred.";;
  esac
}

function create_passphrase_file {
  PASSPHRASE_FILE=$(zenity --file-selection --save --title="Create a file that will contain your encrypted passphrase file. This file should be kept permanently offline." --filename=~/)
  case $? in
    0)
      echo "\"${PASSPHRASE_FILE}\" selected.";;
    1)
      echo "No file selected.";;
    -1)
      echo "An unexpected error has occurred.";;
  esac
  echo "Creating passphrase file using openssl..."
  # Note that openssl rand -base64 adds a newline at char 65 so we remove this with tr
  openssl rand -base64 64 | tr -d '\n ' > ${PASSPHRASE_FILE}
  gpg --armor --output ${PASSPHRASE_FILE}.gpg --batch --symmetric ${PASSPHRASE_FILE}
  shred -vfzu ${PASSPHRASE_FILE}
  ENCRYPTED_PASSPHRASE=${PASSPHRASE_FILE}.gpg
}

function dump_keys {
  DATE=$(date "+%Y-%m-%d-%H:%M:%S")
  DUMP_DIR=~/${COIN}-dumpwallet-${WALLET_NAME}
  mkdir -p ${DUMP_DIR}

  echo "Select a File that contains a list of public addresses to backup."
  PUB_ADDRESSES_LIST=$(zenity --file-selection --title="Select a file that contains a list of public addresses to be dumped." --filename=~/)
  case $? in
    0)
      echo "\"${PUB_ADDRESSES_LIST}\" selected.";;
    1)
      echo "No file selected.";;
    -1)
      echo "An unexpected error has occurred.";;
  esac

  echo "Your private keys will be encrypted symmetrically using GPG."
  echo "If you already have a file containing a passphrase, encrypted by your main passphrase, you may use this."
  echo "NOTE: The encrypted passphrase file should be held offline."
  read -p "Do you want to do select an existing passphrase file? [y/N]" YN
  case $YN in
    [Yy]*)
      select_passphrase_file ;;
    [Nn]*)
      create_passphrase_file ;;
    *) echo "Please answer yes or no.";;
  esac

  # Create a temporary file containing the plaintext passphrase. Read this into
  # a variable, then securely delete the file.
  echo "Decrypt the passphrase..."
  gpg -o temp-decrypted-passphrase --decrypt ${ENCRYPTED_PASSPHRASE}
  GPG_PASS=$(< temp-decrypted-passphrase)
  shred -vfzu temp-decrypted-passphrase

  echo "Key Backups: ${WALLET_NAME}, ${DATE}" > ${DUMP_DIR}/readme.md
  echo "============================================" >> ${DUMP_DIR}/readme.md
  echo "This directory contains private keys for the following public addresses:" >> ${DUMP_DIR}/readme.md

  PUB_ADDRESSES=$(< "${PUB_ADDRESSES_LIST}")
  for PUB in $PUB_ADDRESSES; do
    PRIV=$(${COIN}-cli dumpprivkey ${PUB})
    echo "${PUB}" >> ${DUMP_DIR}/readme.md
    echo "${PRIV}" > ${DUMP_DIR}/${PUB}
    echo "Encrypting private key for ${PUB} to ${DUMP_DIR}/${PUB}.gpg"
    gpg --armor --output ${DUMP_DIR}/${PUB}.gpg --batch --passphrase ${GPG_PASS} --symmetric ${DUMP_DIR}/${PUB}
    echo "Deleting temporary file ${DUMP_DIR}/${PUB}"
    shred -fzu ${DUMP_DIR}/${PUB}
  done

  unset GPG_PASS
  unset MAIN_PASS
  ${COIN}-cli walletlock
  ${COIN}-cli stop

  echo "Your dumped keys:"
  echo "${DUMP_DIR}"
}

# Execute
# ------------------------------------------------------------------------------
clear
cat << EOF

SECURELY BACKUP PRIVATE KEYS
============================
This programme securely backs up the private keys for a specified list of Bitcoin
public addresses managed by a Bitcoin Core wallet.

The bitcoin-cli dumpprivkey command is used to output the private keys for the
specified public addresses, which are saved in plaintext into a temporary file.
GPG is then used to symmetrically encrypt the dumped private key files. The
plaintext temporary files are then securely deleted by means of the shred utility.

Notes on Encryption
-------------------
If you choose to generate an encryption passphrase (recommended), a 64 character
base 64 random number is generated using the openssl rand command. This
is then used as a passphrase for GPG symmetric encryption of private keys.

Once your private keys are encrypted, it should be safe to expose them on an
online computer for the purposes of backup. To ensure security however, the
encryption passphrase should remain offline - it should never be loaded onto an
online or otherwise insecure computer.

In order to make it possible to print the encryption passphrase for backup
purposes, the encryption passphrase is itself ecrypted, using the master
passphrase of your security system. This allows you to safely lodge backup
paper copies of the encryption passphrase without compromising security. Note
that your master passphrase should be backed up using Shamir's Secret Sharing
Scheme or similar protocol.

Requirements
------------
Before starting you need:

- A manifest file containing a list of public addresses, one address per line
- A Bitcoin Core wallet (.dat file) that manages the specified addresses
- The wallet passphrase - you will be prompted to unlock your wallet
- The Bitcoin Core client (bitcoind and bitcoin-cli)

It is recommended that you run this utility on an offline secure computer - for
example an offline Tails session.

Output
------
Encrypted key files are saved into a specified directory. Each file contains the
corresponding Bitcoin public address in the filename.

The directory will contain a readme.md file that consists of a manifest showing
the addresses backed up, and decryption instructions.

References
----------
- dumprivkey: https://bitcoin.org/en/developer-reference#dumpprivkey

--------------------------------------------------------------------------------

EOF
read -p "Do you want to proceed? [y/N]" YN
case $YN in
  [Yy]*)
    open_port
    start_daemon
    unlock
    dump_keys
    ;;
  *)
    echo "Programme terminated."
    exit
    ;;
esac
