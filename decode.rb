#encoding: utf-8
# Decode Xaddress to latitude & longitude
# usage: ruby decode.rb "LIBRES 2989 - Asuncion,Paraguay "
########################################################
require 'csv'
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
  $country_es[x[0]] = x["Nombre"]
  $country_en[x[0]] = x["countryName"]
end
$datospais = check_arguments(ARGV)
$images =[]
CSV.read("images.csv").each do |ima|
    $images[ima[0].to_i]=ima[2]+"/"+ima[1]
end

if $no_states[$country].nil?
      $estado = controla_states(ARGV)
      va = $estado["combinaciones"]
      com = $estado["bounds"]
      va1 = va.to_i
else
      va = $datospais["combinaciones"]
      com = $datospais["bounds"]
      va1 = va.to_i
end

     if va1>0 and $palabras.count==1
        puts "Must have 2 words for your location"
        puts "Example : WORD WORD NUMBER"
        puts "NUMBER WORD WORD"
        exit
      end
      if va1==0 and $palabras.count>1
        puts "Must have 1 words for your location"
        puts "Example : WORD NUMBER"
        puts "NUMBER WORD"
        exit
      end
      if (ARGV[0].strip[0] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil?
        palabra = $palabras[0]
        adjetivo = $palabras[1]
      else
        palabra = $palabras[1]
        adjetivo = $palabras[0]
      end
       if va1==0 and $palabras.count==1
          palabra = $palabras[0]
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
      if $palabras[1].nil?
          generaimagen = $palabras[0]+$numero+($estado["stateCode"].gsub("-",""))
      else
        if $estado.nil?
          generaimagen = palabra+adjetivo+$numero+($datospais["countryCode"])
        else
          generaimagen = palabra+adjetivo+$numero+($estado["stateCode"].gsub("-",""))
        end
      end
      $lat=  lalo.split(",")[0]+"."+$numero[0..1]+numpalabra[0..1]
      $lon=  lalo.split(",")[1]+"."+$numero[2..3]+numpalabra[2..3]
      puts "Location = #{$lat},#{$lon}"
      puts "(#{$images[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"

