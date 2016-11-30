#encoding: utf-8
# Decode Xaddress to latitude & longitude
# usage: ruby decode.rb "LIBRES 2989 - Asuncion,Paraguay "
########################################################
require 'csv'
require 'byebug'
require_relative 'decode_func'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

$country = ""
$countries = CSV.read("countries.csv", :headers => true  )
$no_states = {}
$country_es = {}
$country_en = {}
$countries.each do |x|
  # X in $no_states mean that no states subdivision will be required for that country. (too small)
  $no_states[x[0]]=x["tipo"]
  # Arrays with the country name in english or spanish.
  $country_es[x[0]] = x["Nombre"]
  $country_en[x[0]] = x["countryName"]
end

# $country_data will contain the record of the country.csv or list of states of that country from states.csv
$country_data = check_arguments(ARGV)

# Array with the description for the checksum or 'avatar' images displayed in spanish/english
$images =[]
CSV.read("images.csv").each do |ima|
    $images[ima[0].to_i]=ima[2]+"/"+ima[1]
end

# If states are used for this country, we get states boundaries and combination, else we get country boundaries and combinations.
if $no_states[$country].nil?
  country_state = check_states(ARGV)
  va = country_state["combinaciones"]
  com = country_state["bounds"]
  va1 = va.to_i
else
  va = $country_data["combinaciones"]
  com = $country_data["bounds"]
  va1 = va.to_i
end

# Checks for one word addresses
if va1>0 and $words.count==1
  puts "Must have 2 words for your location"
  puts "Example : WORD WORD NUMBER"
  puts "NUMBER WORD WORD"
  exit
end
if va1==0 and $words.count>1
  puts "Must have 1 words for your location"
  puts "Example : WORD NUMBER"
  puts "NUMBER WORD"
  exit
end

if (ARGV[0].strip[0] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil?
        palabra = $words[0]
        adjetivo = $words[1]
      else
        palabra = $words[1]
        adjetivo = $words[0]
      end
       if va1==0 and $words.count==1
          palabra = $words[0]
          adjetivo = nil
       end
      numpalabra= codigo(palabra)
      if numpalabra=="0"
          numpalabra="0000"
      end

      if adjetivo.nil?
         latini=com.split("*")[0].split("@")[0].split(".")[0]
         lonini=com.split("*")[0].split("@")[1].split(".")[0]
         lalo = latini+","+lonini
      else
          $numadjetivo= codigo(adjetivo).to_s[0..va.to_s.strip.length-1]
          latini=com.split("*")[0].split("@")[0].split(".")[0]
          latfin=com.split("*")[1].split("@")[0].split(".")[0]
          lonini=com.split("*")[0].split("@")[1].split(".")[0]
          lonfin=com.split("*")[1].split("@")[1].split(".")[0]
          lalo= codilalo(latini,latfin,lonini,lonfin)
      end
      if $words[1].nil?
        if country_state.nil?
          generaimagen = $words[0]+$number+($country_data["countryCode"])
        else
          generaimagen = $words[0]+$number+(country_state["stateCode"].gsub("-",""))
        end
      else
        if country_state.nil?
          generaimagen = palabra+adjetivo+$number+($country_data["countryCode"])
        else
          generaimagen = palabra+adjetivo+$number+(country_state["stateCode"].gsub("-",""))
        end
      end
      $lat=  lalo.split(",")[0]+"."+$number[0..1]+numpalabra[0..1]
      $lon=  lalo.split(",")[1]+"."+$number[2..3]+numpalabra[2..3]
      puts "Location = #{$lat},#{$lon}"
      puts "(#{$images[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"


