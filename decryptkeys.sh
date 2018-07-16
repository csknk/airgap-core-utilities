#!/bin/bash
#
# Decrypt key file into WIF format
#
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
  OUTPUT_DIR=$(zenity --file-selection --directory --title="Select a directory in which to save the DECRYPTED key.")
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
  echo "Enter the main passphrase."
  echo "This will be used to decrypt the passphrase that will be used for GPG decryption:"
  read -s MAIN_PASS
  gpg -o temp-decrypted-passphrase --passphrase ${MAIN_PASS} --decrypt ${ENCRYPTED_PASSPHRASE}
  GPG_PASS=$(< temp-decrypted-passphrase)
  shred -vfzu temp-decrypted-passphrase
  echo "Decrypting key..."
  FILENAME=$(basename "${PRIVATE_KEY}").txt
  gpg -o ${OUTPUT_DIR}/${FILENAME} --passphrase ${GPG_PASS} --decrypt ${PRIVATE_KEY}

}

# Execute
# ------------------------------------------------------------------------------
select_private_key
select_passphrase_file
select_output_dir
decrypt_key
