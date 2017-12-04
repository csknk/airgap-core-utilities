Offline Bitcoin Core Utilties
=============================
## BASH scripts to manage Bitcoin Core/Litecoin Core wallets in an offline Tails session

You may need to open a [Bitcoin Core](https://bitcoin.org/en/bitcoin-core/) cold wallet in an offline Tails session - maybe you need to add an additional receiving address or maybe you wake up in a cold sweat wondering if you still have the correct passphrase for your cold wallet.

This collection of scripts helps connect things up so that you can access and manage cold wallets in Bitcoin Core.

It runs a zenity GUI which prompts the user to select:
* The cold wallet file
* The directory that contains binaries, if this has not been specified in `/lib/config`

These files might be on your Tails persistent volume, or on any USB drive.

## Usage
* Clone this directory
* Copy downloaded Bitcoin/Litecoin binary directories to the root directory of this project
* Copy this directory to the encrypted persistent drive of a Tails USB drive
* Boot into Tails, navigate to `~/Persistent/airgap-core-utilities`
* Run commands

## Available Commands
All commands provide an option to set up binaries - either Bitcoin or Litecoin. You will generally only need to do this step once per Tails session.

### `dumpprivkeys`
Loads a cold wallet, loops through a list of public addresses and builds a GnuPG encrypted output file that contains the public keys with associated private keys. This can then be used as a paper backup. Intermediate (unencrypted) files are securely deleted using the `shred` utility.

### `check-passphrase`
Loads a cold wallet and allows the user to check the passphrase.

### `load-fresh-core-qt`
Run a clean instance of either Bitcoin or Litecoin core. Useful when creating a new cold wallet.

### `dumpwallet`
Run the `dumpwallet` utility on a selected wallet.

### `load-coldwallet-qt`
Launch a specified cold wallet in the Core QT client.


## Update
As of v0.15.0, the Bitcoin Core client will not allow symlinked wallets. As such, the script will copy your specified cold wallet into the default Bitcoin data directory: (`~/.bitcoin/cold-wallet.dat`).

This script is designed to run in a TAILS session in which the `~/.bitcoin` directory won't be persisted after shutting down. Because of this, the script does not remove the copied cold wallet file. This may be important if you run the script in a live environment.
