#!/bin/bash

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
