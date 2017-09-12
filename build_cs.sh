#!/bin/bash

nodescript='var codegen = require("abi-code-gen");'
mkdir json
mkdir cs

cd src

echo "Installing solc v0.4.11 from GitHub"
wget https://github.com/ethereum/solidity/releases/download/v0.4.11/solc-static-linux
mv ./solc-static-linux /usr/bin/solc
chmod +x /usr/bin/solc

echo "Generating bytecode with solc..."
solc -o ../bin --bin *.sol
echo "Generating contract ABIs with solc..."
solc -o ../abi --abi *.sol

echo "Combining bytecode and ABIs into JSON files"
cd ..
for file in bin/*.bin
	do
		abifile=`echo $file | sed "s;bin;abi;g"`
		jsonfile=`echo $file | sed "s;bin;json;g" | sed "s;.sol:[a-z A-Z]*;;g"`
		templatefile=`echo $jsonfile | sed "s;.json;-cs-service.json;g"`
		nodescript="$nodescript codegen.generateCode('$jsonfile', 'cs-service');"
		echo "Reading from: "
		echo "> $file"
		echo "> $abifile"
		
		echo "Creating json file: $jsonfile"
		echo "
		{
		    \"abi\": \"`cat $abifile | sed 's/"/\\\\\"/g'`\",
		    \"bytecode\": \"`cat $file`\"
		}
		" > $jsonfile
		echo "Writing template info to $templatefile"
		echo '
		{
			"namespace":"eVi.abi.lib.pcl"
		}
		' > $templatefile
	done

echo "Generating cs files from json files..."
cd json
echo $nodescript | sed 's;json/;;g' | node
mv *.cs ../cs
echo "Renaming CS files following naming convention..."
cd ../cs
for file in ./*.cs
	do
		mv $file `echo $file | sed "s;.cs;Service.cs;g"`
	done
