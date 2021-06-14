!/bin/bash

DB_USER="root"
DB_PASSWORD="test123.0"
DB_NAME="places"

echo "======================================="
echo "Start Create temp folder"
mkdir osmData
echo "Finish Create temp folder"

echo "======================================="
echo "Start Download Cairo OSM MAP"
wget https://download.bbbike.org/osm/bbbike/Cairo/Cairo.osm.gz -O osmData/Cairo.osm.gz
echo "Finish Download Cairo OSM MAP"

echo "======================================="
echo "Start uncompress OSM MAP"
gzip -d osmData/Cairo.osm.gz
echo "Finish uncompress OSM MAP"

echo "======================================="
echo "Start Filter OSM MAP for cafe only"
osmfilter osmData/Cairo.osm  --keep="amenity=cafe or amenity=fast_food or amenity=restaurant" --drop-ways -o=osmData/cairo_filtered.osm
echo "Finish Filter OSM MAP for cafe only"

echo "======================================="
echo "Start Convert OSM MAP TO CSV File"
osmconvert osmData/cairo_filtered.osm --all-to-nodes --csv="@lon @lat amenity name" --csv-headline -o=osmData/transformed_data.csv
echo "Finish Convert OSM MAP TO CSV File"

echo "======================================="
echo "Start Filter unnecessary rows"
awk '(NR>1) && ($4 > 2 ) ' osmData/transformed_data.csv > osmData/filtered_data.csv
echo "Finish Filter unnecessary rows"

echo "======================================="
echo "Start Make CSV Copy"
cp osmData/filtered_data.csv osmData/places.csv
echo "Finish Make CSV Copy"

echo "======================================="
echo "Start Create DB"
mysql -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME"
echo "Finish Make CSV Copy"

echo "======================================="
echo "Start Change DB CHARACTER to utf8"
mysql -u $DB_USER -p$DB_PASSWORD -e "ALTER DATABASE $DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;"
echo "Finish Change DB CHARACTER to utf8"

echo "======================================="
echo "Start Create Table"
mysql -u $DB_USER -p$DB_PASSWORD -e "CREATE TABLE IF NOT EXISTS $DB_NAME.$DB_NAME (lon decimal(9,7), lat decimal(9,7), amenity varchar(10), name varchar(46)) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
echo "Finish Create Table"

echo "======================================="
echo "Start Migrate data from csv to DB"
mysqlimport -h localhost -u $DB_USER -p$DB_PASSWORD --local --delete --fields-terminated-by='\t' --default-character-set=utf8 $DB_NAME osmData/places.csv
echo "Finish Migrate data from csv to DB"

echo "======================================="
echo "Start Create AUTO INCREMENT column (id)"
mysql -u $DB_USER -p$DB_PASSWORD -e "ALTER TABLE $DB_NAME.$DB_NAME ADD id INT PRIMARY KEY AUTO_INCREMENT FIRST;"
echo "Finish Create AUTO INCREMENT column (id)"

echo "======================================="
echo "Start Delete temp folder"
rm -r osmData/
echo "Finish Delete temp folder"



