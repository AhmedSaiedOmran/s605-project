!/bin/bash

./donwload_osm.sh && (./convert_osm.sh && ./migrate_osm_to_db.sh)
