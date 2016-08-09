#encoding: utf-8
# Create a Xaddress from a latitude & longitude
# usage:
# ruby encode.rb "-25.2969,-57.5666"
# Requirements:
# - gem install geocoder
#
###########################################################################
# More info on xaddress.org or https://github.com/roberdam/Xaddress
###########################################################################

require 'csv'
require 'geocoder'    
require_relative 'encode_func'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

#################################################################################
#                                START
#################################################################################

# List of possible languages to encode,  default "en".
# The + sign is used to alter the order from WORD WORD NUMBER to NUMBER WORD WORD display
$lng_list=["es","en+"]
$lng="en+"
if $lng.include? "+"
  $order="reverse"
  $lng= $lng.gsub("+","")
else
  $order=""
end

#Check arguments for formatting errors
check_arguments(ARGV)
$paises = CSV.read("countries.csv", :headers => true  )
$estados = CSV.read("states.csv", :headers => true )

#$no_states contains the lists of countries that does not need to be divided in states.
#$paises_nombres contains the names in english/spanish of countries.

$no_states={}
$paises_nombres={}
$paises.each do |x|
  $no_states[x[0]]=x["tipo"]
  $paises_nombres[x["countryCode"]+"-es"]=x["Nombre"]
  $paises_nombres[x["countryCode"]+"-en"]=x["countryName"]
end
$pais =""

# How is composed
# ---------------------------------------
# if the location is -25.296945,-57.566654
@latitud= $arg_latlong.split(",")[0].split(".")[0].strip
#Latitude = "-25"

@longitud= $arg_latlong.split(",")[1].split(".")[0].strip
#Longitude = "-57"

@mlatitud = $arg_latlong.split(",")[0].split(".")[1][0..3].ljust(4, "0")
#Minute from latitude = "2969"

@mlongitud = $arg_latlong.split(",")[1].split(".")[1][0..3].ljust(4, "0")
#Minute from longitude = "5666"

$latitud=@latitud+"."+@mlatitud
$longitud=@longitud+"."+@mlongitud

# Find the short code for this location.
$short_code = short_encode($latitud,$longitud)

# if location is -25.2969,-57.5666 $palabra = 6966
$palabra = @mlatitud[2..3]+@mlongitud[2..3]

# if location is -25.2969,-57.5666 $numero = 2956
$numero = @mlatitud[0..1]+@mlongitud[0..1]
#---------------------------------------------------------
# So far we have the number and first word of the xaddress
# we need to know the state and get the second word.
#---------------------------------------------------------

$estado_info=[]
# if no STATE,COUNTRY is given with the arguments we use google api to search this location info
if $arg_pais_state.nil? then
    busca = $latitud+","+$longitud
    google_search(busca)
else
    #if STATE,COUNTRY is given with the arguments, check if the info is correct.
    controla_pais($arg_pais_state)
    selecombi($pais_info)
    if $adicional.nil? then
      puts "This latitude and Longitude does not correspond to #{$pais_info[0][1]}"
      exit
    end
    # If states subdivision is used in this country
    if $no_states[$pais].nil? then
        $region=[]
        $region= controla_states($arg_pais_state)
     else
      $estado_info=$pais_info
    end
end

$adicional =nil
selecombi($estado_info)
if $adicional.nil? then
  puts "This latitude and Longitude does not correspond to this state"
    exit
end

archivo_palabras=$lng+"/"+$lng+".csv"
archivo_adjetivos =$lng+"/"+"adj_"+$lng+".csv"
$words = CSV.read(archivo_palabras)
$adje = CSV.read(archivo_adjetivos)
$imagenes =[]
CSV.read("images.csv").each do |ima|
  if $lng=="es"
    $imagenes[ima[0].to_i]=ima[2]
  end
  if $lng=="en"
    $imagenes[ima[0].to_i]=ima[1]
  end

end

busca_palabras($palabra,10)
if $palabras_posibles.count < 3 then
  busca_palabras($palabra,5)
  if $palabras_posibles.count==0 then
    puts "Can't find suitable words, try a near location"
    exit
  end
end

$palabras_posibles.each_with_index do |opcion,indice|
     busca_adjetivos(opcion)
     unless $adjetivos_posibles.count==0
       despliega(indice, 100)
     end
end



