#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
# ------------------------------------------------------------------------------

function open_port {
  sudo iptables -I OUTPUT -d 127.0.0.1/32 -o lo -p tcp -m tcp --dport 8332 --tcp-flags FIN,SYN,RST,ACK SYN -m owner --uid-owner 1000 -j ACCEPT
}
