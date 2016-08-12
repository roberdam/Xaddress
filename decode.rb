#encoding: utf-8
# Decode Xaddress to latitude & longitude
# usage: ruby decode.rb "LIBRES 2989 - Asuncion,Paraguay "
########################################################
require 'csv'
require_relative 'decode_func'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

$pais=""
$paises = CSV.read("countries.csv", :headers => true  )
$no_states={}
$pais_sp={}
$pais_en={}
$paises.each do |x|
  $no_states[x[0]]=x["tipo"]
  $pais_sp[x[0]] = x["Nombre"]
  $pais_en[x[0]] = x["countryName"]
end
$datospais = check_arguments(ARGV)

$imagenes =[]
CSV.read("images.csv").each do |ima|
    $imagenes[ima[0].to_i]=ima[2]+"/"+ima[1]
end

if $no_states[$pais].nil? then
      $estado = controla_states(ARGV)
      va = $estado["combinaciones"]
      com = $estado["bounds"]
      va1 = va.to_i
else
      if $datospais[9].to_i > $datospais[11].to_i then
        va = $datospais[9]
        com = $datospais[8]
      else
        va = $datospais[11]
        com = $datospais[10]
      end
      va1 = $datospais[9].to_i+$datospais[11].to_i

end

     if va1>0 and $palabras.count==1 then
        puts "Must have 2 words for your location"
        puts "Example : WORD WORD NUMBER"
        puts "NUMBER WORD WORD"
        exit
      end
      if va1==0 and $palabras.count>1 then
        puts "Must have 1 words for your location"
        puts "Example : WORD NUMBER"
        puts "NUMBER WORD"
        exit
      end
      if (ARGV[0].strip[0] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil? then
        palabra = $palabras[0]
        adjetivo = $palabras[1]
      else
        palabra = $palabras[1]
        adjetivo = $palabras[0]
      end
       if va1==0 and $palabras.count==1 then
          palabra = $palabras[0]
          adjetivo = nil
       end
      numpalabra= codigo(palabra)
      if numpalabra=="0" then
          numpalabra="0000"
      end

      if adjetivo.nil? then
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
      if $palabras[1].nil? then
          generaimagen = $palabras[0]+$numero+($estado["stateCode"].gsub("-",""))
      else
        if $estado.nil? then
          generaimagen = palabra+adjetivo+$numero+($datospais["countryCode"])
        else
          generaimagen = palabra+adjetivo+$numero+($estado["stateCode"].gsub("-",""))
        end
      end
      $lat=  lalo.split(",")[0]+"."+$numero[0..1]+numpalabra[0..1]
      $lon=  lalo.split(",")[1]+"."+$numero[2..3]+numpalabra[2..3]
      puts "Resultado= #{$lat},#{$lon}"
      puts "(#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"

