![Logo](https://cloud.githubusercontent.com/assets/3354868/17249828/b7e84ef0-556f-11e6-80e7-10bd51c46143.png)
# XADDRESS
Give 7 billion people an instant physical address that can be used offline and decoded with low tech (pen & paper).
## Read it on Medium
[An Algorithm that can give an instant solution to 7b people] (https://medium.com/@roberdam/an-algorithm-that-can-give-an-instant-solution-to-7-billion-people-60bf628205a2)
## How it works.
<img src="https://cloud.githubusercontent.com/assets/3354868/17251870/6bdbda00-5578-11e6-9162-1e5200cffa34.gif" width="700">

Xaddress encodes the latitude & longitude of a place in a form that resembles a normal address and can be decoded back easily even in a low tech environment using paper, pen and a physical map.

## Demo

[TRY IT IN ENGLISH](http://www.xaddress.org/try?lng=en)    |    [PRUEBALO EN ESPAÑOL](http://www.xaddress.org/try?lng=es)

```
The demo site uses some free apis with limited requests per day, 
some functionality might be unavailable on high demand.
```
## How it looks
![looks] (https://cloud.githubusercontent.com/assets/3354868/17262858/d616e1ca-55ab-11e6-9d8a-78dd524a4063.png)

## Features
![parts] (https://cloud.githubusercontent.com/assets/3354868/17264547/bc36ac22-55b5-11e6-9aae-e64677c2d5bc.png)
####            1) VISUAL AVATAR
Used like a visual hash to ensure that you write the Xaddress right, if you change any letter it will generate another image, for example MAGICAL PEARL**S** will show you a different image so you can know that you write a wrong address.

If you want to transmit your Xaddress by phone you will say 
>    "7150 MAGICAL PEARL - Maluku ,Indonesia"   my avatar is a boot

####            2) COUNTRY AND STATE
You can see right away the country and state where that Xaddress is located, and you can recognize it as an address.

####            3) SHORT CODE
By default Xaddress create 2 kind of codes, each one independent from the other, the short code can be decoded by itself, it can have 1 meter accuracy, and is useful to storage or send it as a link, like [ubicate.me/NOMATAL-KOROFAD](http://ubicate.me/NOMATAL-KOROFAD)

## Encoding with the Ruby CLI.
Now to get started with Xaddress you would perform the following:

```
git clone https://github.com/roberdam/Xaddress.git
cd Xaddress
bundle
ruby encode.rb "-6.7184,129.5080"
```

You can use it without using geocoder by specify state and country in the command line:
```
ruby encode.rb "-6.7184,129.5080" "Maluku, Indonesia"
```
## Decoding with the Ruby CLI.
```
ruby decode.rb "7150 MAGICAL PEARL - Maluku, Indonesia"
```

## PROS:

* Instantaneous.
* Offline
* Designed to be used in low tech environments
* Multilanguage
* Error correction incorporated with visual avatar.
* Short code for storing or linking.
* Works with any map.
* Yow know is an address when you see it.


## CONS:
* May take you some effort to find a suitable address 
* 10mts accuracy with the present form.
 
## ALTERNATIVES:
* [What3words] (http://what3words.com) -  Uses 3 words to define any location *percolator.surmount.retooled*, commercial option with a patented algorithm.
* [Geohash] (http://geohash.org/) - Free and Opensource *qyu1g0by7*
* [Mapcode] (http://www.mapcode.com/) - Free with Apache License Version 2.0. *VQ6.1MFD*
* [Openlocationcode] (http://openlocationcode.com/) - Free and Opensource *6Q5F 7GJ5+J6*

## Compare encodings:
| Option           | Location :  -6.7184 , 129.5080         |
| ---------------- |:--------------------------------------:|
| XADDRESS         | 7150 Magical Pearl - Maluku, Indonesia |
| WHAT3WORDS       | percolator.surmount.retooled           |
| GEOHASH          | qyu1g0by7                              |
| MAPCODE          | VQ6.1MFD                               |
| OPENLOCATIONCODE | 6Q5F 7GJ5+J6                           |

## Port Xaddress to other languages
Check the pseudocode guide to implement Xaddress in other languages, apps or internal systems.
https://github.com/roberdam/Xaddress/tree/master/pseudocode


## Contributing
There is a lot to do if you want to contribute:
* Mobile App
* Language packs
* Spread the word
* Errors/corrections/improvement, raise an issue on Github and I would be more than happy to discuss :)

## Work in progress
[Xaddress for Node] (https://github.com/therebelrobot/Xaddress-node) by @therebelrobot

[Xaddress - The Android App] (https://github.com/spidergears/XAddress-Android) by @spidergears
