#!/bin/bash
nodescript='var codegen = require("abi-code-gen");'
mkdir json
mkdir cs

cd src

echo "Generating bytecode with solc..."
solc -o ../bin --bin *.sol
echo "Generating contract ABIs with solc..."
solc -o ../abi --abi *.sol

echo "Combining bytecode and ABIs into JSON files"
cd ..
for file in bin/*.bin
	do
		abifile=`echo $file | sed "s;bin;abi;g"`
		jsonfile=`echo $file | sed "s;bin;json;g"`
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
done

echo "Generating cs files from json files..."
cd json
echo $nodescript | sed 's;json/;;g' | node
cp *.cs ../cs
echo "Cleaning up..."

cd ..
rm -r bin json
