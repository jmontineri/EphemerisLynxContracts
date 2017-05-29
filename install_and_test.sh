#!/bin/bash
echo "Installing solc v0.4.11 from GitHub"
wget https://github.com/ethereum/solidity/releases/download/v0.4.11/solc-static-linux
mv ./solc-static-linux /usr/bin/solc
chmod +x /usr/bin/solc

echo "Running unit tests with Dapple..."
dapple test
