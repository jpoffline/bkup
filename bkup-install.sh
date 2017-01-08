#!/bin/bash

echo "* making directory for code"
mkdir -p ~/bin/bkup

echo "* adding line to .bash_profile"
echo "export PATH=\$PATH:~/bin/bkup" >> ~/.bash_profile
