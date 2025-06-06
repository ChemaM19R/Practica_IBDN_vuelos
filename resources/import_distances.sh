#!/bin/bash

# Import our enriched airline data as the 'airlines' collection
mongoimport -h mongo -d agile_data_science -c origin_dest_distances --file resources/data/origin_dest_distances.jsonl
mongo mongo/agile_data_science --eval 'db.origin_dest_distances.createIndex({Origin: 1, Dest: 1})'
