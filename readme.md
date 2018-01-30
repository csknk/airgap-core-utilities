Offline Bitcoin/Litecoin Core Utilties
=====================================
## Manage Bitcoin Core/Litecoin Core wallets in an offline Tails session
Running [Tails](https://tails.boum.org/) as an offline live session is a safe way to manage secure assets - including Bitcoin/Litecoin core cold wallets. However, because Tails is amnesiac, you need to set up the core binaries every time you boot into the live session.

This collection of BASH scripts helps connect things up so that you can easily access and manage cold wallets in Bitcoin/Litecoin Core during a Tails offline live session. They include helper scripts that act as a wrapper for the Bitcoin CLI. The script also adjusts the Tails `iptables` rules to allow `bitcoin-cli` to interacte with `bitcoind`.

If you need to open a [Bitcoin Core](https://bitcoin.org/en/bitcoin-core/) cold wallet in an offline Tails session - maybe you need to add an additional receiving address or maybe you audit cold wallet passphrases - these scripts should help.

The scripts run a zenity GUI which prompts the user to select required files (e.g. the cold wallet file, the list of public addresses for private keys etc).

A lot of the same functionality is required by the various scripts, so I've added this in a `lib` type structure, sourcing files as appropriate. This is pushing the limits of BASH a bit (for me anyway). The whole suite would probably be better in Python. I started it in BASH as I had quite a few scripts as wrappers for online `bitcoin-cli` management.

## Usage
* Clone this directory
* Copy downloaded Bitcoin/Litecoin binary directories to the root directory of this project
* Copy this directory to the encrypted persistent drive of a Tails USB drive
* Boot into Tails, navigate to `~/Persistent/airgap-core-utilities`
* Run commands (e.g. `cd ~/Persistent/airgap-core-utilities` followed by `./check-passphrase`)

## Available Commands
All commands provide an option to set up binaries - either Bitcoin or Litecoin. You will generally only need to do this step once per Tails session.

### Dump Private Keys: `dumpprivkeys`
Loads a cold wallet, loops through a list of public addresses and builds a GnuPG encrypted output file that contains the public keys with associated private keys.
This can then be used as a paper backup. Intermediate (unencrypted) files are securely deleted using the `shred` utility.

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
