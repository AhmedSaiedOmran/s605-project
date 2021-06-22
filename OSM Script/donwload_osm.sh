!/bin/bash

FILE=osmData/Cairo.osm.gz
echo "======================================="
echo "Start Create temp folder"
mkdir osmData
echo "Finish Create temp folder"

echo "======================================="
echo "Start Download Cairo OSM MAP"
wget https://download.bbbike.org/osm/bbbike/Cairo/Cairo.osm.gz -O $FILE --no-check-certificate
echo "Finish Download Cairo OSM MAP"

if [ -f "$FILE" ]; then
    echo "======================================="
    echo "Start uncompress OSM MAP"
    gzip -d $FILE
    echo "Finish uncompress OSM MAP"
fi

