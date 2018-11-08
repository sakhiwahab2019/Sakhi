#!/bin/bash

set -e

date

#################################################################
# Update Ubuntu and install prerequisites for running Sakhi   #
#################################################################
sudo apt-get update
#################################################################
# Build Sakhi from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Sakhi           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# By default, assume running within repo
repo=$(pwd)
file=$repo/src/sakhid
if [ ! -e "$file" ]; then
	# Now assume running outside and repo has been downloaded and named sakhi
	if [ ! -e "$repo/sakhi/build.sh" ]; then
		# if not, download the repo and name it sakhi
		git clone https://github.com/sakhid/source sakhi
	fi
	repo=$repo/sakhi
	file=$repo/src/sakhid
	cd $repo/src/
fi
make -j$NPROC -f makefile.unix

cp $repo/src/sakhid /usr/bin/sakhid

################################################################
# Configure to auto start at boot                                      #
################################################################
file=$HOME/.sakhi
if [ ! -e "$file" ]
then
        mkdir $HOME/.sakhi
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | tee $HOME/.sakhi/sakhi.conf
file=/etc/init.d/sakhi
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo sakhid' | sudo tee /etc/init.d/sakhi
        sudo chmod +x /etc/init.d/sakhi
        sudo update-rc.d sakhi defaults
fi

/usr/bin/sakhid
echo "Sakhi has been setup successfully and is running..."

