#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
# ------------------------------------------------------------------------------

function select_coin {
  TITLE="Select a Core Client to Use"
  PROMPT="Pick an option:"
  OPTIONS=("Bitcoin" "Litecoin")
  echo "$TITLE"
  PS3="$PROMPT "
  select OPT in "${OPTIONS[@]}" "Quit"; do
    case "$REPLY" in
      1) break;;
      2) break;;
      $((${#OPTIONS[@]}+1))) echo "End"; break;;
      *) echo "Invalid option. Try again.";
      continue;;
    esac
  done
  echo "You selected $OPT."
  COIN="${OPT,,}"
}
