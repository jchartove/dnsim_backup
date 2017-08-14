#
# default .bashrc
# 03/31/13
#
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
 
umask 022

# disable coredumps by default
ulimit -c 0

# User specific aliases and functions

alias rm='rm -i'
export PATH=$PATH:/project/crc-nak/jchartove/dnsim/csh
