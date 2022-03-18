#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'roo'
require 'roo-xls'
require 'csv'

USAGE = <<END
Convert an excel file to csv via the roo library
END

def die_with_usage(msg=nil)
  puts USAGE
  puts msg if msg
  exit
end

filename = ARGV[0]

die_with_usage "You must pass a file." unless filename

if filename =~ /xlsx$/
  excel = Roo::Excelx.new(filename)
else
  excel = Roo::Excel.new(filename)
end

output = STDOUT

csvArray =[]
1.upto(excel.last_row) do |line|
  csvArray += CSV.parse("#{CSV.generate_line excel.row(line)}")
end


  countingo = 0
  csvArray.each do |line|
    countingo+=1
  end
  puts "Lines in file: #{countingo}"

  languageArray = [];


  csvArray.each do |row|
    languageArray = row;
    puts "Top Columns #{languageArray}"
    break
  end

  fileIndex = 2;



  begin
     puts("Loop fileIndex = #{fileIndex}")
     if File.directory?("GPSTracker/Localization/#{languageArray[fileIndex]}.lproj")
     puts "Directory GPSTracker/Localization/#{languageArray[fileIndex]}.lproj exists."
     else
       puts "Creating GPSTracker/Localization/#{languageArray[fileIndex]}.lproj directory."
       Dir.mkdir("GPSTracker/Localization/#{languageArray[fileIndex]}.lproj")
     end

     puts "Opening file Localizable.strings for writing"
     output = File.open("GPSTracker/Localization/#{languageArray[fileIndex]}.lproj/Localizable.strings", "w")


     output.write "\n\n\n//   PLEASE DON'T EDIT THIS FILE!! EDIT gpstracker_languages.xlsx\n\n\n"

     output.write "\n//   Localizable.strings\n//\n//   Please do not edit this file. Edit gpstracker_languages.xlsx file.\n//   This file will be then automatically generated upon project build.\n//\n\n"

     rowCounter = 0
     lastStoredSeparatorName = ""



     puts "Go through each line of previously saved csv file"
     csvArray.each do |row|
       if rowCounter != 0                                            # If it is not first line.. work on it. (first ones were simply column names)
         if row[0] != nil and row[0].start_with? '#'                                 # If line starts with #, then it is separator
           if lastStoredSeparatorName.length > 0                    # if we previously stored separator
             output.write "//=== #{lastStoredSeparatorName}\n\n\n"  # write previously stored separator (as ending)
           end
           adjustedRowName = "#{row[0]}".gsub! '#', ''                  # Adjust separator name so it is without #.
           output.write "//--- #{adjustedRowName}\n"               # write this separator and save it.
           lastStoredSeparatorName = adjustedRowName
         else
            if row[1] != nil and row[1].length
              # output.write "// #{row[0]}\n"                       # Uncomment this, if you want to also generate comments in generated files.
              if row[fileIndex] == "95.0" || row[fileIndex] == "98.0"
                output.write "\"#{row[1]}\" = \"#{row[fileIndex].to_i}\";\n"  # Simply write correct output of first an x line.
              else
                output.write "\"#{row[1]}\" = \"#{row[fileIndex]}\";\n"  # Simply write correct output of first an x line.
              end
            else
              output.write "\n"                                        #if empty line - simply new line.. (separator.)
            end
         end
       end
       rowCounter+=1;
     end

     if lastStoredSeparatorName.length > 0                    # if we previously stored separator
       output.write "//=== #{lastStoredSeparatorName}"  # write previously stored separator (as ending)
     end
     fileIndex +=1                            # Increase so that we go to next file writing
  end while fileIndex < languageArray.count;  # Do it for all columns.
