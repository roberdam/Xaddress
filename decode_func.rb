def check_arguments(arguments)
  # If empty
  if arguments[0].nil?
    puts " "
    puts "ruby decode.rb 'WORD WORD NUMBER - (STATE),COUNTRY' "
    puts "ruby decode.rb 'NUMBER WORD WORD - (STATE),COUNTRY' "
    puts "***************************************************************"
    puts "Example: ruby decode.rb '7150 MAGICAL PEARL - Maluku, Indonesia' "
    puts "Example: ruby decode.rb 'RENEGADO SABIO 0989 - Rwanda' "
    puts "Example: ruby decode.rb 'LIBRES 2956 - Asuncion, Paraguay' "
    puts "*********************************************************************"
    exit
  end
  # Check formatting
  if arguments[0].split("-")[1].nil?
    puts "Incorrect format, use : 'WORD WORD NUMBER - (STATE),COUNTRY'"
    puts "Separate the address from the country and state with a - "
    puts "or XXXXXXX-XXXXXXX for short addresses"
    exit
  end
  if arguments[0].split("-")[0].strip.length < 8 and arguments[0].split("-")[1].strip.length < 8
      short_decode(arguments[0])
      exit
  end
  first_part = arguments[0].split("-")[0].split(" ")
  if first_part.count > 3 or first_part.count ==1 then
    puts "Address must have this format :"
    puts "WORD WORD NUMBER"
    puts "WORD NUMBER"
    puts "NUMBER WORD WORD"
    puts "NUMBER WORD"
    exit
  end
  okey="no"
  how_many_numbers = 0
  $number=""
  first_part.each do |dire|
    unless (dire =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil?
      how_many_numbers += 1
      if dire.to_i <10000 then
        # Find a suitable number in address, add trailing zeroes
        okey="si"
        $number = dire
        if dire.to_i<1000 then
          $number = "0"+dire.to_i.to_s.strip
        end
        if dire.to_i<100 then
          $number = "00"+dire.to_i.to_s.strip
        end
        if dire.to_i<10 then
          $number = "000"+dire.to_i.to_s.strip
        end
      else
        puts "Number in address must be < 9999"
        exit
      end
    end
  end

  if okey=="no" then
    puts "Must contain a number in address"
    exit
  end
  if how_many_numbers > 1 then
    puts "incorrect address format, use only one number"
    exit
  end

  second_part = ARGV[0].split("-")[1].strip
  # Search in second part for the country info, if found return the info in countries.csv
  country_info = check_country(second_part)
  $country = country_info[0]
  $words=[]
  first_part.each do |pala|
    unless pala == $number
      $words << clean_characters(pala).upcase
    end
  end
  if $no_states[$country].nil? then
    $estados = CSV.read("states.csv", :headers => true )
    states=[]
    $estados.each do |guarda|
      if guarda["countryCode"]==$country then
        states << guarda
      end
    end
    return states
  else
    return country_info
  end
end


def check_states(argumento)
 argum = argumento[0].dup
  xestado = clean_characters(argum.split("-")[1].split(",")[0]).strip
  estado=""
 $country_data.each do |recorre|
   if recorre["stateName1"].upcase==xestado.upcase or recorre["stateName2"].upcase==xestado.upcase or recorre["stateName3"].upcase==xestado.upcase or recorre["googleName"].upcase==xestado.upcase then
     estado = recorre
   end
 end
 if estado=="" then
     opciones=[]
     $country_data.each do |recorre|
       if recorre["stateName1"].upcase.include? xestado.upcase or recorre["stateName2"].include? xestado.upcase or recorre["stateName3"].include? xestado.upcase or recorre["googleName"].include? xestado.upcase then
         opciones << recorre
       end
     end
     if opciones.count>0 then
       puts "State not found, you can try:"
       puts "#{argum.split("-")[0]} - #{opciones[0]["stateName1"]}, #{argum.split("-")[1].split(",")[1].strip}"
       exit
     else
       puts "State not found, you can try this options:"
       $country_data.each do |recorre|
         puts "#{argum.split("-")[0]} - #{recorre["stateName2"]}, #{$country_es[$country]}"
       end
       exit
     end
 end
   return estado

end

def check_country(argument)
  # Search the country in arguments and return info about it from countries.csv
  argum = argument.dup
  location = argum.split(",")
  country = ""
  if location.count == 1
    country = clean_characters(location[0]).strip
  else
    country = clean_characters(location.last).strip
  end
  xcountry= ""
  if country.length==2
    #If is the 2 characters country code
    $countries.each do |xsearch|
      if xsearch["countryCode"]==country.upcase
        xcountry = xsearch
      end
    end
  else
    # Is not 2 character country code
    $countries.each do |xsearch|
      if (xsearch["countryName"].upcase==country.upcase) or (xsearch["Nombre"].upcase==country.upcase)
        xcountry = xsearch
      end
    end
  end
  xoptions=[]
  if xcountry==""
    $countries.each do |xsearch|
      if (xsearch["countryName"].upcase.include? country.upcase) or (xsearch["Nombre"].upcase.include? country.upcase)
        xoptions << xsearch
      end
    end

    if location.count>1
      anterior = " "+location[0]+","
    else
      anterior = ""
    end
    puts "Country not fond, You can try this instead:"
    xoptions.each do |opci|
      puts "#{ARGV[0].split("-")[0]}-#{anterior} #{opci["Nombre"]}"
    end
    exit
  else
    return xcountry
  end
end


def clean_characters(texto)
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

#    @retorno.gsub!("ñ", "n")
#    @retorno.gsub!("Ñ", "n")
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


def codilalo(latini,latfin,lonini,lonfin)
# Example: codilalo("-25","-27","-55","-57")
$laat = (-90..90).to_a.collect{|i| i.to_s}.insert(90, "-0")
$loon = (-180..180).to_a.collect{|i| i.to_s}.insert(180, "-0")
$looni = ((-180..0).to_a.collect{|i| i.to_s}.reverse + (0..180).to_a.collect{|i| i.to_s}.reverse)
$looni[0]="-0"

lai = $laat.index(latini)
laf = $laat.index(latfin)

exept=0
if (lonini.to_i < 0) and (lonfin.to_i >= 0) then
  loi = $looni.index(lonini)
  lof = $looni.index(lonfin)
  exept=1
else
  loi = $loon.index(lonini)
  lof = $loon.index(lonfin)
end
if lai < laf then
  latsecu = $laat[lai, (laf-lai)+1 ]
else
  latsecu = $laat[laf, (lai-laf)+1 ]
end

if exept==0 then
  if loi < lof then
    lonsecu = $loon[loi,(lof-loi)+1]
  else
    lonsecu = $loon[lof,(loi-lof)+1]
  end
else
  if loi < lof then
    lonsecu = $looni[loi,(lof-loi)+1]
  else
    lonsecu = $looni[lof,(loi-lof)+1]
  end
end
  $tablalalo=[]
 latsecu.each do |x|
    lonsecu.each do |y|
        guarda = x+","+y
        $tablalalo << guarda
    end
 end
  return $tablalalo[($numadjetivo.to_i-1)]
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

def latlo(texto,tipo)
  if tipo==1 then
          if $latp.index texto then
            retorno =($latp.index texto)
            if retorno>90 then
              abort ("Incorrect latitude >90")
            end
            return retorno
          else
            if $latn.index texto then
              retorno =($latn.index texto)
              if retorno>90 then
                abort ("Incorrect latitude >90")
              end
              if retorno == 0 then
                  return ("-0")
               end
              return (retorno *-1)
            else
              abort ("Latitud incorrecta 4")
            end
          end
    else
          if $latp.index texto then
            retorno =($latp.index texto)
            if retorno>180 then
              abort ("Incorrect Longitude >180")
            end
            return retorno
          else
            if $latn.index texto then
              retorno =($latn.index texto)
              if retorno>180 then
                abort ("Incorrect Longitude")
              end
              if retorno == 0 then
                  return ("-0")
              end
              return (retorno *-1)
            else
                   abort ("Incorrect Longitude")
            end
          end

    end
end

def minseg(texto)
    if $latlongms.index texto then
      retorno = ($latlongms.index texto)
      return retorno.to_s.rjust(3,'0')
    else
      abort ("Incorrect segment")
    end
end

def segu(texto)
    if $one.index texto then
      retorno = ($one.index texto)
      return retorno
    else
      abort ("Incorrect Segment")
    end
end



def decode(texto,which)
    case texto.strip.length
      when 4
        if (texto[0].upcase.delete ("DGJKLMNRST")).length ==0  then
          lat=latlo(texto[1..3],which)
          segu=segu(texto[0])
          return (lat.to_s+"."+segu.to_s)
        else
          abort ("Segment #{which} incorrect")
        end
      when 5
          abort ("Segment #{which} incorrect")
       when 6
          lat=latlo(texto[3..5].strip,which)
          minu=minseg(texto[0..2].strip)
          return (lat.to_s+"."+minu.to_s)
       when 7
          if (texto[6].upcase.delete ("DGJKLMNRST")).length ==0  then
            se= segu(texto[6])
            lat=latlo(texto[3..5].strip,which)
            minu=minseg(texto[0..2].strip)
             minu=minu.to_s+se.to_s
            return (lat.to_s+"."+minu.to_s)
           else
              abort ("Segment #{which} incorrect")
           end
        when 8
              abort ("Segment #{which} incorrect")
        when 9
            lat=latlo(texto[3..5].strip,which)
            minu=minseg(texto[0..2].strip)
            minu2= minseg(texto[6..8].strip)
            return (lat.to_s+"."+minu.to_s+minu2.to_s)
        end
end


def short_decode(codigo)
  temp = codigo.dup
  parts = temp.upcase.split("-")

  if parts[0].strip.length < 3 then
    abort ("ERROR: Wrong format on first part of short address")
  end

  if parts[1].strip.length < 3 then
    abort ("ERROR: Wrong format on second part of short address")
  end

  latlong=[]
  $latlongms=[]
  $latp=[]
  $latn=[]
  latfinal=""
  lonfinal=""

  consonantsplit ="BCDFGJKLMNPRSTZ".split ("")
  consonants ="BCDFGJKLMNPRSTZ"
  #We exclude "HQVWXY" from consonants & consonantsplit

  vocals = "AEIOU"
  abc = "ABCDEFGIJKLMNOPRSTUVXZ".split ("")
  #We exclude "HQWY" from abc
  $one="DGJKLMNRST".split ("")

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
            $latp << latlong[i]
            $latn << latlong[i+1]
      end

  #Create arrays of minutes & seconds.
      consonantsplit.each do |x|
        for i in 0..consonants.size-1
          for z in 0..vocals.size-1
            result= x+vocals[z]+consonants[i]
            $latlongms << result

          end
        end
      end

  #--------------------------------
    firstpart=parts[0].strip
    secondpart=parts[1].strip

    la = decode(firstpart,1)
    lo = decode(secondpart,2)
    puts "#{la},#{lo}"
end