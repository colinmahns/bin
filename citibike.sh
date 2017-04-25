#!/bin/bash
## Quick script to mention how many bikes are available near $EMPLOYER
## Will also show how many bike racks are available near PABT
## relies on curl and jq
## curl: https://curl.haxx.se/
## jq: https://stedolan.github.io/jq/

## specify starting point (bike) and destination (racks)
bikes="[INSERT BIKE STATION NAMES FROM JSON HERE]"
racks="\"W 42 St & Dyer Ave\",\"W 42 St & 8 Ave\",\"W 41 St & 8 Ave\",\"W 39 St & 9 Ave\",\"W 38 St & 8 Ave\""

## setting up the full path aliases, to deal with cron's fuckery
curl="$(which curl) -s"
echo="$(which echo)"
jq="$(which jq)"
awk="$(which awk)"
sed="$(which sed)"

url="https://feeds.citibikenyc.com/stations/stations.json"
citibike=$($curl $url)

if [ "$jq" == "" ] || [ "$curl" == "" ] ; then
    $echo ""
    $echo "Hey! looks like you don't have curl or jq installed. Going to check your distribution real quick and then attempt to install it for you!"
    $echo ""
    if [ -x /usr/bin/apt-get ]; then
        apt-get --yes --quiet install jq curl
    elif [ -x /usr/bin/yum ]; then
        yum --assumeyes --quiet install jq curl
    elif [ -x /usr/local/bin/brew ] ; then
        brew install curl jq
    else
        $echo "Can't install any of the dependencies, sorry! Please install curl and jq manually."
        exit 1
    fi
    ## grab the full paths, again
    jq="$(which jq)"
    curl="$(which curl) -s"
fi

## ready printout
$echo "Station🚏         Bikes🚲"
## grab the station names for the three racks near $EMPLOYER along with number of available bikes for rental
$echo $citibike | $jq ".stationBeanList | .[] | select(.stationName | contains($bikes)) | .stationName,.availableBikes" | $awk 'NR%2{printf "%s ",$0;next;}1' | $sed 's/\"//g' | sort -r
$echo "Station🚏         Docks🔓"
## grab the station names near pabt along with number of available bike docks
$echo $citibike | $jq ".stationBeanList | .[] | select(.stationName | contains($racks)) | .stationName,.availableDocks" | $awk 'NR%2{printf "%s ",$0;next;}1' | $sed 's/\"//g' | sort -r
