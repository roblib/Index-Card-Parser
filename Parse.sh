#!/bin/bash
for i in $(seq -f "%03g" 1 100)
	do
	for j in $(seq -f "%04g" 1 9999)
	do
		
		FILE="in/"$i"-"$j".txt"

		if [ -f $FILE ]; then
			cp "in/"$i"-"$j".tif" "out"
		else
			if [ $j -gt 1 ]; then
				echo "Found "`expr $j - 1`" items in set "$i
				echo "Cleaning set "$i"..."
				java Clean $i `expr $j - 1`
				echo "Parseing set "$i"..."
				ruby RubyParse.rb $i `expr $j - 1`
			fi
			break
		fi
	done
done
echo "Converting to MODS format"
java -jar Saxon/saxon9he.jar "-s:mid3" "-xsl:Transform.xsl" "-o:out"


