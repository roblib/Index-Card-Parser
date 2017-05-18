#!/usr/bin/env ruby

require 'anystyle/parser'

set = ARGV[0]
loop = ARGV[1].to_i
count = 1
zeros = "000"

Anystyle.parser.train 'TrainingData.txt', true

while count <= loop
	if count == 10; zeros = "00"; end
	if count == 100; zeros = "0"; end
	if count == 1000; zeros = ""; end
	fileName = "out/"+set+"-"+zeros+"#{count}"
	begin
		inFile = File.open(fileName+"-Clean.txt", "r")
		contents = inFile.read
		inFile.close

		begin
			outFile = File.open(fileName+"-Mid.xml", "w")
			output = Anystyle.parse contents, format="xml"
			
			#a little more cleaning
			output = output.gsub(/[.,:]<\//,"</")
			output = output.gsub(/<pages>p{0,2}\./,"<pages>")
			output = output.gsub("<journal>In ","<journal>")
			#Split different references
			output = output.gsub(/(;)(<\/[a-zA-Z]*>)/, '\2</reference><reference>')
			#reformat date, might need more adjustment
			output = output.gsub(/(<date>)([a-zA-Z]{2,4}.)( ?)([0-9]{4})(<\/date>)/, '\1\4 \2\5')
			output = output.gsub(/(<date>)([a-zA-Z]{2,4}.)( ?)([0-9]{1,2})(,? ?)([0-9]{4})(<\/date>)/, '\1\6 \2 \4\7')

			outFile.puts output
			outFile.close
		rescue
			puts "ERROR: File "+set+"-"+zeros+"#{count}.xml could not be created"
		end

	rescue
		puts "ERROR: File "+set+"-"+zeros+"#{count}-MID.txt not found"
	end


	
	count += 1
end
