#!/bin/bash
# This script allows you to check your wallet passphrase without exposing it to
# the screen or adding it to the BASH history.
#
# Remember that obfuscation alone is not good security.
# ------------------------------------------------------------------------------
set -o nounset
set -o errexit

THIS=$(readlink -f ${BASH_SOURCE[0]})
PROJECT_ROOT=$(dirname $THIS)
. ${PROJECT_ROOT}/lib/config
. ${PROJECT_ROOT}/lib/select-coin
. ${PROJECT_ROOT}/lib/setup-binaries
. ${PROJECT_ROOT}/lib/setup-cold-wallet

echo -e ${YELLOW}
echo "-------------------------------------------------------------------------"
echo "ONLY RUN IN AN OFFLINE TAILS SESSION!"
echo "-------------------------------------------------------------------------"
echo -e ${NC}

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

# Unlock the wallet
# ------------------------------------------------------------------------------
function run_passphrase {
  ${COIN}-cli -wallet=cold-wallet.dat -rpcwait walletpassphrase "${WALLET_PASSPHRASE}" 600 && rc=$? || rc=$?
  if [[ $rc -eq 0  ]]; then
    echo -e ${GREEN}
    echo ""
    printf "  SUCCESS: You entered the CORRECT passphrase."
    echo ""
    echo -e ${NC}
    echo "Locking wallet..."
    ${COIN}-cli walletlock
    if [[ $? -eq 0  ]]; then
      echo "Wallet is LOCKED."
    else
      echo "Problem locking wallet."
    fi
  else
    echo -e ${RED}
    echo ""
    printf "  WARNING: You entered an INCORRECT passphrase."
    echo ""
    echo -e ${NC}
  fi
}

# Wrapper function
# ------------------------------------------------------------------------------
function check_passphrase {
  get_passphrase
  run_passphrase
  read -p "Do you want to try again with this wallet? [y/N]" REPEAT
  case $REPEAT in
    [Yy]* )
      check_passphrase
    ;;
    [Nn]* )
      echo "Finished"
    ;;
    * ) echo "Please answer yes or no.";;
  esac
}

open_port
start_daemon
check_passphrase
${COIN}-cli stop
