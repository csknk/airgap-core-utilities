#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#
# Decrypt key file into WIF format
# ------------------------------------------------------------------------------
# set -o nounset # same as set -u
set -o errexit # same as set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

function select_private_key {
  PRIVATE_KEY=$(zenity --file-selection --title="Select a file that contains an encrypted private key." --filename=~/)
  case $? in
    0)
    echo "\"${PRIVATE_KEY}\" selected.";;
    1)
    echo "No file selected.";;
    -1)
    echo "An unexpected error has occurred.";;
  esac
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

function select_output_dir {
  OUTPUT_DIR=$(zenity --file-selection --title="Select a directory in which to save the DECRYPTED key." --directory)
  case $? in
    0)
    echo "\"${OUTPUT_DIR}\" selected.";;
    1)
    echo "No file selected.";;
    -1)
    echo "An unexpected error has occurred.";;
  esac
}

function decrypt_key {
  #gpg -o temp-decrypted-passphrase --passphrase ${MAIN_PASS} --decrypt ${ENCRYPTED_PASSPHRASE}
  gpg -o temp-decrypted-passphrase --decrypt "${ENCRYPTED_PASSPHRASE}"
  GPG_PASS=$(< temp-decrypted-passphrase)
  echo "passphrase is ${GPG_PASS}"
  echo "---------------------------------"
  shred -vfzu temp-decrypted-passphrase
  echo "Decrypting key..."
  FILENAME=$(basename "${PRIVATE_KEY}").txt
  echo "Decrypting ${PRIVATE_KEY} to ${OUTPUT_DIR}/${FILENAME}"
  echo ${GPG_PASS} | gpg --batch -o "${OUTPUT_DIR}/${FILENAME}" --passphrase-fd 0 "${PRIVATE_KEY}"
  #gpg --batch -o "${OUTPUT_DIR}/${FILENAME}" --passphrase ${GPG_PASS} --symmetric --decrypt "${PRIVATE_KEY}"

}

# Execute
# ------------------------------------------------------------------------------
select_private_key
select_passphrase_file
select_output_dir
decrypt_key
