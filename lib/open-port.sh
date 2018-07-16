#!/bin/bash

function open_port {
  sudo iptables -I OUTPUT -d 127.0.0.1/32 -o lo -p tcp -m tcp --dport 8332 --tcp-flags FIN,SYN,RST,ACK SYN -m owner --uid-owner 1000 -j ACCEPT
}
