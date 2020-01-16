#!/bin/bash
# Copyright (c) 2018 David Egan
# Distributed under the MIT software license, see the accompanying
# file LICENSE or http://www.opensource.org/licenses/mit-license.php.
#
# Set up binaries for either Bitcoin or Litecoin.
#
# The location of the directory that contains the relevant binaries can be set
# in # `/lib/config`. If you do not set a location here, a Zenity GUI will run
# that prompts the user to select the directory that contains the relevant binaries.
#
# The programme binaries are symlinked into `$HOME/bin`. This directory is not in
# `$PATH` by default, so a new $PATH variable is exported for the duration of
# this script. The `$PATH` is amended thereafter by appending a line to
# `$HOME/.bashrc`, so that the user can access commands like `bitcoin-qt` when
# the script has finished. However, you need to start a new shell
# (or `source ~/.bashrc`) for this to work.
# ------------------------------------------------------------------------------
set -o nounset
set -o errexit

function set_binary_dir {
	if [[ ${OPT} == "Bitcoin" ]]; then
		CORE_DIR=${BITCOIN_CORE_BIN_DIR}
	elif [[ ${OPT} == "Litecoin" ]]; then
		CORE_DIR=${LITECOIN_CORE_BIN_DIR}
	fi
	if [[ ${CORE_DIR} == "false" ]]; then
		CORE_DIR=$(zenity --file-selection --title="Select the directory that contains ${OPT} binaries." --filename=${PWD}/ --directory)
		case $? in
			0)
				echo "\"${CORE_DIR}\" selected."
				;;
			1)
				echo "No directory selected."
				;;
			-1)
				echo "An unexpected error has occurred."
				;;
		esac
	fi
	# Confirm and repeat if necessary
	echo "The directory containing ${OPT} binaries is set to ${CORE_DIR}"
	read -p "Is this correct [Yn]? Enter N if you'd like to select a different location:" CONT
	case "${CONT}" in
		y|Y )
			;;
		n|N ) set_binary_dir ${OPT}
			;;
		* ) echo "Invalid selection"
			;;
	esac
}

function set_commands {
	echo -e ${YELLOW}
	echo "-----------------------------------------------------------------------"
	echo "WARNING. Overwriting symlinks to ${OPT} binaries."
	echo "-----------------------------------------------------------------------"
	echo -e ${NC}

	BIN_DIR=$HOME/bin
	mkdir -p ${BIN_DIR}
	THIS=$(readlink -f ${BASH_SOURCE[0]})
	PROJECT_ROOT=$(dirname $THIS)

	. "${PROJECT_ROOT}"/set-path $BIN_DIR
	echo "export PATH=$BIN_DIR:$PATH" >> $HOME/.bashrc

	read -p "Do you wish to proceed? [y/N]" PROCEED
	case $PROCEED in
		[Yy]*)
			cd ${BIN_DIR} &&
				rm -f ${COIN}-cli ${COIN}d ${COIN}-qt
			ln -s ${CORE_DIR}/${COIN}-cli ${COIN}-cli
			ln -s ${CORE_DIR}/${COIN}d ${COIN}d
			ln -s ${CORE_DIR}/${COIN}-qt ${COIN}-qt
			echo "Symlinks added. To run binaries:"
			echo "${COIN}-cli"
			echo "${COIN}d"
			echo "${COIN}-qt"
			echo "...in a new shell."
			;;
		[Nn]*)
			echo "No symlinks added. To run binaries:"
			echo "${CORE_DIR}/${COIN}-cli"
			echo "${CORE_DIR}/${COIN}d"
			echo "${CORE_DIR}/${COIN}-qt"
			echo "...in a new shell."
			;;
		*)
			echo "Please answer yes or no."
			;;
	esac
}

function setup_binaries {
	set_binary_dir
	set_commands
}
