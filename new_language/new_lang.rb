# Xaddress - Add new language.
# Hash a list of words, because encoding is case sensitive, we consider all words as uppercase words.
# use: rails new_lang.rb file
# format: The file format will have one word per line
# Example:
# HOUSE
# COW
# DESK
#------------------------------------------------------------
# Result: file.csv
# HOUSE,4014
# COW,7848
# DESK,0906
##############################################################
require 'csv'

def codigo(palabra)
texto=palabra
  a=texto[0].ord.to_f
    ope=0
    if texto.length>1 then
          for i in 1..texto.length-1
            if ope==0 then
              a=a / texto[i].ord
              ope=1
            else
              a=a * texto[i].ord
              ope=0
            end
          end
         largo = (a - a.to_i).to_s.split(".")[1][0..2].to_i
            completo = (a - a.to_i).to_s.split(".")[1]
            long= completo.length
            return completo[0..3]
     end
end

if ARGV[0].nil?
  puts "use: rails new_lang.rb FILE"
  puts "where FILE is a list of words, one line per word."
  exit
end

archivo = CSV.read(ARGV[0])

CSV.open(ARGV[0].split(".")[0]+"-lang.csv", "w") do |csv|
      archivo.each do |word|
        csv << [word[0].upcase,codigo(word[0].upcase)]
      end
end
puts "#{ARGV[0]} Processed with #{archivo.count} words - #{ARGV[0]}-lang.csv ready."