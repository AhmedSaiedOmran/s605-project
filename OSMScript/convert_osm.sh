if [ -p p1 ]; then
    mkfifo p1
fi

if [ -p p2 ]; then
    mkfifo p2
fi


if  [ -x "$(command -v osmfilter)" ]; then
    echo "======================================="
    echo "Start Filter OSM MAP for cafe only"
    osmfilter osmData/Cairo.osm  --keep="amenity=cafe or amenity=fast_food or amenity=restaurant" --drop-ways -o=p1
    echo "Finish Filter OSM MAP for cafe only"

    echo "======================================="
    echo "Start Convert OSM MAP TO CSV File"
    osmconvert p1 --all-to-nodes --csv="@lon @lat amenity name" --csv-headline -o=p2
    echo "Finish Convert OSM MAP TO CSV File"

    echo "======================================="
    echo "Start Filter unnecessary rows"
    awk '(NR>1) && ($4 > 2 ) ' p2 > osmData/places.csv
    echo "Finish Filter unnecessary rows"

else
    echo "Not Exist command osmfilter"
    exit 1
fi



