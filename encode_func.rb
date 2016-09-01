############################################################################
# Functions for encode.rb
############################################################################

#!/bin/env ruby
# encoding: utf-8

def google_search(argumento)
  Geocoder::Configuration.lookup = :google
  #Uses google api to search for latitude,longitude
  geocoded = Geocoder.search(argumento)
  if geocoded.nil? then
    puts "Error searching with Google API"
    exit
  end
  if geocoded.count==0 then
    puts "Cant find the country"
    exit
  end
  #Get the ISO country code
  $pais= cambia(geocoded.last.data["address_components"].last["short_name"]).upcase

  # If the country is not in the list of no states countries.
  if $no_states[$pais].nil? then
    busca_estados($pais)
    # now the list of states of this country is in $pais_states
    # Search returned info from google for state info.
    geocoded.each do |q|
       if q.data["address_components"][0]["types"][0] == "administrative_area_level_1" then
           elestado = cambia(q.data['formatted_address'])
           $pais_states.each do |x|
               if x["googleName"]==elestado then
                 $estado_info << x
                 $estado = $estado_info[0]["stateCode"]
               end
           end
       end
     end
     if $estado_info.count==0 then
          # second try searching, this time fuzzy search
          encfinal = 0.0
          distancia = FuzzyStringMatch::JaroWinkler.create( :native )
          geocoded.each do |q|
             if q.data["address_components"][0]["types"][0] == "administrative_area_level_1" then
                 elestado = cambia(q.data['formatted_address'])
                 $pais_states.each do |x|
                    actual = distancia.getDistance(x["googleName"].upcase,elestado.upcase)
                     if actual > encfinal
                       encfinal= actual
                       $estado_info =[]
                       $estado_info << x
                       $estado = $estado_info[0]["stateCode"]
                     end
                 end
             end
           end
     end
     if $estado_info.count==0 then
           puts "Error, state in Google API not found on states.csv "
           exit
     end

  else
         busca_paises($pais)
         $estado_info = $pais_info
  end

end


def busca_paises(pais)
   $pais_info=[]
   if pais.length==2 then
       $paises.each do |pp1|
           if pp1["countryCode"] == pais then
                $pais_info << pp1
                $pais = pais
           end
       end
   else
      $paises.each do |busca|
          if (busca["countryName"].upcase==pais.upcase) or (busca["Nombre"].upcase==pais.upcase) then
               $pais_info << busca
                $pais = $pais_info[0]["countryCode"]
          end
      end
   end
   if $pais_info.count==0 then
       puts "Country not found on countries.csv"
       exit
   end
end

def busca_estados(pais)
  $pais_states =[]
  $estados.each do |guarda|
        if guarda["countryCode"]==pais then
          $pais_states << guarda
        end
  end
end


def controla_pais(argumentos)
  #Check if country is a valid one
    pais_estado= cambia(argumentos.dup)
    if pais_estado.split(",").count>1 then
      ppais=pais_estado.split(",")[1].strip
    else
      ppais=pais_estado.split(",")[0].strip
    end
    $pais=""
    busca_paises(ppais.upcase)

    if $pais=="" then
          xoptions=[]
          $paises.each do |busca|
           if (busca["countryName"].upcase.include? ppais.upcase) or (busca["Nombre"].upcase.include? ppais.upcase) then
              xoptions << busca
            end
          end
          puts "#{ppais} not found as a country, you might mean:"
          xoptions.each do |opci|
            puts "#{$argumentos[1].split(",")[0]},#{opci["Nombre"]}"
          end
          exit
    end
end


def controla_states(argumento)
  #Check if state exist and is valid.
  unless argumento.split(",").count ==2
    puts "Incorrect format, use: STATE, COUNTRY"
    exit
  end
  xestado = cambia(argumento.split(",")[0].strip)
  busca_estados($pais)
  $estado=""
  $pais_states.each do |recorre|
     if recorre["stateName1"].upcase==xestado.upcase or recorre["stateName2"].upcase==xestado.upcase or recorre["stateName3"].upcase==xestado.upcase or recorre["googleName"].upcase==xestado.upcase then
       $estado = recorre["stateCode"]
       $estado_info << recorre
     end
   end

 if $estado=="" then
     opciones=[]
   $pais_states.each do |recorre|
       if recorre["stateName1"].upcase.include? xestado.upcase or recorre["stateName2"].include? xestado.upcase or recorre["stateName3"].include? xestado.upcase or recorre["googleName"].include? xestado.upcase then
         opciones << recorre
       end
     end
     if opciones.count>0 then
       puts "State not found, you can try:"
       puts "#{opciones[0]["stateName1"]}, #{argum.split(",")[1].split(",")[1].strip}"
       exit
     else
       puts "State not found, you can try this options:"
       $pais_states.each do |recorre|
         puts "#{recorre["stateName2"]}"
       end
       exit
     end
 end
end



def codilalo(latini,latfin,lonini,lonfin)
  # Example : codilalo("-25","-27","-55","-57")
  # $tablalalo will get the table of possible combinations of latitude & longitude

# Create latitude and longitude tables
laat = (-90..90).to_a.collect{|i| i.to_s}.insert(90, "-0")
loon = (-180..180).to_a.collect{|i| i.to_s}.insert(180, "-0")
looni = ((-180..0).to_a.collect{|i| i.to_s}.reverse + (0..180).to_a.collect{|i| i.to_s}.reverse)
looni[0]="-0"

lai = laat.index(latini)
laf = laat.index(latfin)

exept=0
if (lonini.to_i < 0) and (lonfin.to_i >= 0) then
  loi = looni.index(lonini)
  lof = looni.index(lonfin)
  exept=1
else
  loi = loon.index(lonini)
  lof = loon.index(lonfin)
end


if lai < laf then
  latsecu = laat[lai, (laf-lai)+1 ]
else
  latsecu = laat[laf, (lai-laf)+1 ]
end

if exept==0 then
  if loi < lof then
    lonsecu = loon[loi,(lof-loi)+1]
  else
    lonsecu = loon[lof,(loi-lof)+1]
  end
else
  if loi < lof then
    lonsecu = looni[loi,(lof-loi)+1]
  else
    lonsecu = looni[lof,(loi-lof)+1]
  end
end
  $tablalalo=[]
 latsecu.each do |x|
    lonsecu.each do |y|
        guarda = x+","+y
        $tablalalo << guarda
    end
 end
    $adicional =nil
    $tablalalo.each.with_index do |x,index|
      if x.split(",")[0] == @latitud.strip and x.split(",")[1] == @longitud.strip then
        $adicional = index+1
      end
    end
      $comb =$tablalalo.count
end


def selecombi(elestadoinfo)
#Create the list of possible combinations of latitude & longitude for that state
  $combT=""
  latini = elestadoinfo[0]["bounds"].split("*")[0].split("@")[0].split(".")[0]
  latfin = elestadoinfo[0]["bounds"].split("*")[1].split("@")[0].split(".")[0]
  lonini = elestadoinfo[0]["bounds"].split("*")[0].split("@")[1].split(".")[0]
  lonfin = elestadoinfo[0]["bounds"].split("*")[1].split("@")[1].split(".")[0]
  $combT=elestadoinfo[0]["combinaciones"].to_i
  codilalo(latini,latfin,lonini,lonfin)
end

def check_arguments(argu)
  argumentos = argu.dup
  # If argument is empty shows this message and exit
  if argumentos[0].nil? then
    puts " "
    puts "ruby encode.rb 'latitude,longitude'  ('country,state') (/Language) "
    puts "***************************************************************"
    puts "latitude= with format -25.2667 "
    puts "longitude= with format -57.5334 "
    puts "country = Iso country code BO=Bolivia, US=United States."
    puts "state = State or first administrative division Ex: Florida , Misiones"
    puts "/Language = en (English default) es (Spanish)  "
    puts "*********************************************************************"
    puts "Example: ruby encode.rb '-25.2666,-57.5664' "
    puts "Example: ruby encode.rb '-18.044,-42.5646' 'Minas Gerais,Brasil' "
    puts "*********************************************************************"
    exit
  end

    # Check for language parameter
    # If the argument contains a '/' check if the language parameter is one of the defined in $lng_list
    # if found stores the result in $lng and clean it from the parameters.
    argumentos.each do |vlang|
      if vlang.include? "/" then
          error=0
          $lng_list.each do |ln|
            if ln.include? "+" then
              order= "reverse"
            else
              order= ""
            end
            if vlang.include? "+" then
              if order=="reverse" then
                order = ""
              else
                order= "reverse"
              end
            end
            x1=[]
            x1 << ["/"+ln.gsub("+","")]
            if vlang.gsub("+","").include? x1[0][0] then
              argumentos = argumentos - [vlang]
              $lng = ln.gsub("+","")
              $order = order
              error=1
            end
          end
          if error==0 then
            puts "Incorrect language, use:"
            puts $lng_list
            exit
          end
      end
    end

    # Check that it contains a ',' in the location info and other formatting requirements.
  if argumentos[0].split(",")[1].nil? then
    puts "Incorrect format, use : 'latitude,longitude'"
    puts "Example: '-18.044,-42.5646'"
    exit
  end
  if argumentos[0].split(",")[0].split(".")[1].nil? then
    puts "wrong latitude format, use: 18.3654 format"
    exit
  end
  if argumentos[0].split(",")[0].split(".")[0].gsub("-","").to_i>90 then
    puts "wrong latitude format, latitude mus be from -90 to 90"
    exit
  end
  if (argumentos[0].split(",")[0] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil? then
      puts "wrong latitude format, use: 18.3654 format no letters"
      exit
  end

  if argumentos[0].split(",")[1].split(".")[1].nil? then
    puts "wrong longitude format, use: 18.3654 format"
    exit
  end
  if argumentos[0].split(",")[1].split(".")[0].gsub("-","").to_i>180 then
    puts "wrong longitude format, longitude mus be from -180 to 180"
    exit
  end
  if (argumentos[0].split(",")[1].strip =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil? then
    puts "wrong longitude format, use: 18.3654 format no letters"
      exit
  end
    $argumentos = argumentos
    $arg_latlong = $argumentos[0]
    $arg_pais_state = $argumentos[1]
end

def codigo_imagen(texto)
  a=texto[0].ord.to_f
  if texto.length>1 then
    opera = 1
    for i in 1..texto.length-1
        if opera==1 then
           a=a / texto[i].ord
        end
        if opera==2 then
           a=a * texto[i].ord
        end
        if opera==3 then
           a=a + texto[i].ord
        end
        opera = opera +1
        if opera==4 then
           opera=1
        end
    end
  end
          long = a.to_s.split(".")[1].length
          return a.to_s.split(".")[1][long-4..long-1]
end


def despliega(indice, cuantos)
   if $estado_info[0]["stateCode"].nil? then
         estado_para_imagen= $estado_info[0]["countryCode"].gsub("-","")
         estado_nombre=""
         pais_nombre= $paises_nombres[$pais+"-"+$lng]
   else
         estado_para_imagen= $estado_info[0]["stateCode"].gsub("-","")
         estado_nombre=$estado_info[0]["stateName2"]
         pais_nombre= $paises_nombres[$pais+"-"+$lng]
   end
   if $comb.to_i>1 then
     $adjetivos_posibles[0..cuantos].each_with_index do |adj,index|
       generaimagen= $palabras_posibles[indice][0].strip+adj[0].strip+$numero+estado_para_imagen
       if $order=="" then
         puts "#{index}. #{$palabras_posibles[indice][0]} #{adj[0]} #{$numero} - #{estado_nombre}, #{pais_nombre} (#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"  #{generaimagen}"
       end
       if $order=="reverse" then
         puts "#{index}. #{$numero} #{adj[0]} #{$palabras_posibles[indice][0]} - #{estado_nombre}, #{pais_nombre} (#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"  #{generaimagen}"
       end
     end
   else
     generaimagen= $palabras_posibles[indice][0].strip+$numero+estado_para_imagen
     if $order=="" then
       puts "#{indice}. #{$palabras_posibles[indice][0]} #{$numero} - #{estado_nombre}, #{pais_nombre} (#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"  #{generaimagen}"
     end
     if $order=="reverse" then
       puts "#{indice}. #{$numero} #{$palabras_posibles[indice][0]} - #{estado_nombre}, #{pais_nombre} (#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"  #{generaimagen}"
     end
   end
     puts "Enter number or N for Next X quit"
     a = STDIN.gets
     a.gsub!("\n","")
     if a=="X" or a=="x" then
          puts "saliendo"
          exit
     end
     if (a.to_s  =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/)==0 then
        puts ""
        puts "---------------------------"
        if $comb.to_i>1 then
             generaimagen= $palabras_posibles[indice][0].strip+$adjetivos_posibles[a.to_i][0].strip+$numero+estado_para_imagen
             if $order=="" then
               puts "(#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"
               puts "#{$palabras_posibles[indice][0]} #{$adjetivos_posibles[a.to_i][0].strip} #{$numero}"
               puts "#{estado_nombre}, #{pais_nombre}"
             end
             if $order=="reverse" then
               puts "(#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"
               puts "#{$numero} #{$adjetivos_posibles[a.to_i][0].strip} #{$palabras_posibles[indice][0]}"
               puts "#{estado_nombre}, #{pais_nombre}"
             end
        else
           generaimagen= $palabras_posibles[indice][0].strip+$numero+estado_para_imagen
           if $order=="" then
             puts "(#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip})"
             puts "#{$palabras_posibles[indice][0]} #{$numero}"
             puts "#{estado_nombre}, #{pais_nombre}"
           end
           if $order=="reverse" then
             puts "#{$imagenes[codigo_imagen(generaimagen).to_s[0..1].to_i].strip}"
             puts "#{$numero} #{$palabras_posibles[indice][0]}"
             puts "#{estado_nombre}, #{pais_nombre}"
           end
        end
        puts "---------------------------"
        puts $short_code
        puts "---------------------------"
        puts ""
        exit
     end

end


def busca_adjetivos(texto)
 if $lng=="es" then
    tags = texto[3].split("@")
    mof=""
    sop=""
    tipo=""
    tags.each do |tag|
      # Search 'N' for common names and then for plural or singular
     if tag[0]=="N" then
        tipo="N"
        unless tag[2].nil?
          if tag[2]=="M" or tag[2]=="F" or tag[2]=="C" then
            mof=tag[2]
          end
        end
        unless tag[3].nil?
          if tag[3]=="S" or tag[3]=="P" then
            sop=tag[3]
          end
        end
     end
    end
    $adjetivos_posibles=[]
    if tipo=="N" then
      largo = $comb.to_s.strip.length
      $adje.each do |ad|
          if ad[3][0..largo-1].to_i==$adicional.to_i then
            if ad[1][3]==mof then
              if ad[1][4]==sop then
                $adjetivos_posibles << ad
              end
            end
          end
      end
       $adjetivos_posibles.sort! { |x,y| y[2].to_i <=> x[2].to_i }
       $adjetivos_posibles.uniq! {|x| x[0]}
        if $adjetivos_posibles.count==0 then
            $adje.each do |ad|
              if ad[3][0..largo-1].to_i==$adicional.to_i then
                    $adjetivos_posibles << ad
              end
            end
        end
     end
 end

 if $lng=="en" then
    largo = $comb.to_s.strip.length
    $adjetivos_posibles=[]
    $adje.each do |ad|
          if ad[2][0..largo-1].to_i==$adicional.to_i then
                $adjetivos_posibles << ad
          end
    end

 end
end




def cambia (texto)
    # Clean non standard chars from result
    @retorno = texto
    @retorno.gsub!("Á", "A")
    @retorno.gsub!("á", "a")
    @retorno.gsub!("ã", "a")
    @retorno.gsub!("à", "a")
    @retorno.gsub!("ä", "a")
    @retorno.gsub!("ā", "a")
    @retorno.gsub!("ă", "a")
    @retorno.gsub!("ą", "a")
    @retorno.gsub!("å", "a")
    @retorno.gsub!("â", "a")
    @retorno.gsub!("Ā", "A")
    @retorno.gsub!("ǝ", "a")
    @retorno.gsub!("ầ", "a")
    @retorno.gsub!("ả", "a")
    @retorno.gsub!("ẵ", "a")
    @retorno.gsub!("ậ", "a")
    @retorno.gsub!("ạ", "a")
    @retorno.gsub!("ắ", "a")
    @retorno.gsub!("ə", "a")
    @retorno.gsub!("ằ", "a")

    @retorno.gsub!("É", "E")
    @retorno.gsub!("é", "e")
    @retorno.gsub!("ë", "e")
    @retorno.gsub!("ě", "e")
    @retorno.gsub!("ē", "e")
    @retorno.gsub!("ė", "e")
    @retorno.gsub!("Ē", "E")
    @retorno.gsub!("ę", "e")
    @retorno.gsub!("è", "e")
    @retorno.gsub!("ê", "e")
    @retorno.gsub!("ế", "e")
    @retorno.gsub!("ệ", "e")
    @retorno.gsub!("ề", "e")

    @retorno.gsub!("Í", "I")
    @retorno.gsub!("í", "i")
    @retorno.gsub!("Î", "I")
    @retorno.gsub!("ī", "i")
    @retorno.gsub!("î", "i")
    @retorno.gsub!("ï", "i")
    @retorno.gsub!("ĭ", "i")
    @retorno.gsub!("ï", "i")
    @retorno.gsub!("ı", "i")
    @retorno.gsub!("İ", "I")
    @retorno.gsub!("Ī", "I")
    @retorno.gsub!("ị", "i")
    @retorno.gsub!("ĩ", "i")
    @retorno.gsub!("ì", "i")
    @retorno.gsub!("ỉ", "i")

    @retorno.gsub!("Ó", "O")
    @retorno.gsub!("ó", "o")
    @retorno.gsub!("ô", "o")
    @retorno.gsub!("ö", "o")
    @retorno.gsub!("õ", "o")
    @retorno.gsub!("ð", "o")
    @retorno.gsub!("ø", "o")
    @retorno.gsub!("ō", "o")
    @retorno.gsub!("Ö", "O")
    @retorno.gsub!("Ō", "O")
    @retorno.gsub!("ŏ", "o")
    @retorno.gsub!("ơ", "o")
    @retorno.gsub!("ộ", "o")
    @retorno.gsub!("ò", "o")
    @retorno.gsub!("Ŏ", "O")
    @retorno.gsub!("ő", "o")
    @retorno.gsub!("Ø", "O")
    @retorno.gsub!("ớ", "o")
    @retorno.gsub!("ồ", "o")
    @retorno.gsub!("ọ", "o")

    @retorno.gsub!("Ú", "U")
    @retorno.gsub!("ú", "u")
    @retorno.gsub!("ü", "u")
    @retorno.gsub!("ŭ", "u")
    @retorno.gsub!("ū", "u")
    @retorno.gsub!("ų", "u")
    @retorno.gsub!("ũ", "u")
    @retorno.gsub!("ư", "u")
    @retorno.gsub!("ừ", "u")

    @retorno.gsub!("ň", "n")
    @retorno.gsub!("ņ", "n")
    @retorno.gsub!("ń", "n")

    @retorno.gsub!("ç", "c")
    @retorno.gsub!("č", "c")
    @retorno.gsub!("Č", "C")
    @retorno.gsub!("ċ", "c")
    @retorno.gsub!("Ç", "C")
    @retorno.gsub!("ć", "c")

    @retorno.gsub!("Ž", "Z")
    @retorno.gsub!("ž", "z")
    @retorno.gsub!("ż", "z")
    @retorno.gsub!("Ż", "Z")
    @retorno.gsub!("Z̧", "Z")
    @retorno.gsub!("z̧", "z")
    @retorno.gsub!("z̄", "z")


    @retorno.gsub!("š", "s")
    @retorno.gsub!("Š", "S")
    @retorno.gsub!("ş", "s")
    @retorno.gsub!("Ş", "S")
    @retorno.gsub!("ś", "s")
    @retorno.gsub!("Ś", "S")

    @retorno.gsub!("ķ", "k")
    @retorno.gsub!("Ķ", "K")

    @retorno.gsub!("đ", "d")
    @retorno.gsub!("ḑ", "d")
    @retorno.gsub!("ř", "r")
    @retorno.gsub!("ý", "y")
    @retorno.gsub!("æ", "e")
    @retorno.gsub!("ļ", "l")
    @retorno.gsub!("ġ", "g")
    @retorno.gsub!("ğ", "g")
    @retorno.gsub!("ħ", "h")
    @retorno.gsub!("ḩ", "h")
    @retorno.gsub!("Ħ", "H")
    @retorno.gsub!("ţ", "t")
    @retorno.gsub!("ł", "l")
    @retorno.gsub!("Ł", "L")
    @retorno.gsub!("Ḩ", "H")
    @retorno.gsub!("Ḑ", "D")
    @retorno.gsub!("Đ", "D")
    @retorno.gsub!("ț", "t")
    @retorno.gsub!("Ð", "D")

    return @retorno
  end

def busca_palabras(palabra,ranking)
  $palabras_posibles= []
  $words.each do|x|
    if x[2].to_i==palabra.to_i then
      if x[0].length >2 and x[1].to_i>=ranking then
        $palabras_posibles << x
      end
    end
  end
   $palabras_posibles.sort! { |x,y| y[1].to_i <=> x[1].to_i }
end


def short_encode(xlatitude,xlongitude)
#Create arrays and variables.
latlong=[]
latlongms=[]
latp=[]
latn=[]
latfinal=""
lonfinal=""

consonantsplit ="BCDFGJKLMNPRSTZ".split ("")
consonants ="BCDFGJKLMNPRSTZ"
#We exclude "HQVWXY" from consonants & consonantsplit

vocals = "AEIOU"
abc = "ABCDEFGIJKLMNOPRSTUVXZ".split ("")
#We exclude "HQWY" from abc
one="DGJKLMNRST".split ("")


# Create latitude & longitude arrays.
    for i in 0..4
        for z in 0..4
            abc.each do |x|
            result= vocals[i]+x+vocals[z]
            unless result.delete("AEIOU")==""
              # We discard the all vocals combinations, Ex: AAA, AEA, etc.
                  latlong << result
            end
          end
        end
     end

# Store positive & negative values
   (0...362).step(2) do |i|
          latp << latlong[i]
          latn << latlong[i+1]
    end

#Create arrays of minutes & seconds.
    consonantsplit.each do |x|
      for i in 0..consonants.size-1
        for z in 0..vocals.size-1
          result= x+vocals[z]+consonants[i]
          latlongms << result

        end
      end
    end


#--------------------------------
latitude = xlatitude.split(".")
longitude= xlongitude.split(".")

  if latitude[0][0]=="-" then
    lati1 = latn[(latitude[0].delete! '-').to_i]
  else
    lati1 = latp[(latitude[0]).to_i]
  end

 case latitude[1].length
    when 1
     latfinal =one[latitude[1][0].to_i]+lati1
    when 2
     latfinal = latlongms[((latitude[1][0..1]).to_i*10)]+lati1
    when 3
     latfinal =latlongms[((latitude[1][0..2]).to_i)]+lati1
    when 4
     latfinal =latlongms[(latitude[1][0..2]).to_i]+lati1+one[(latitude[1][3]).to_i]
    when 5
     latfinal = latlongms[((latitude[1][0..2]).to_i)]+lati1+latlongms[((latitude[1][3..4]).to_i*10)]
    when 6
     latfinal =latlongms[((latitude[1][0..2]).to_i)]+lati1+latlongms[((latitude[1][3..5]).to_i)]
  end

  if longitude[0][0]=="-" then
    longi1 = latn[(longitude[0].delete! '-').to_i]
  else
    longi1 = latp[(longitude[0]).to_i]
  end

  case longitude[1].length
    when 1
      lonfinal=one[longitude[1][0].to_i]+longi1
    when 2
      lonfinal= latlongms[((longitude[1][0..1]).to_i*10)]+longi1
    when 3
      lonfinal= latlongms[((longitude[1][0..2]).to_i)]+longi1
    when 4
      lonfinal=latlongms[(longitude[1][0..2]).to_i]+longi1+one[(longitude[1][3]).to_i]
    when 5
      lonfinal=latlongms[((longitude[1][0..2]).to_i)]+longi1+latlongms[((longitude[1][3..4]).to_i*10)]
    when 6
      lonfinal=latlongms[((longitude[1][0..2]).to_i)]+longi1+latlongms[((longitude[1][3..5]).to_i)]
  end

    retornar = latfinal+"-"+lonfinal
    return retornar
end
