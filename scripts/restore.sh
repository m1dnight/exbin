#!/bin/bash

db_container=exbin_db_1
exbin_container=exbin_exbin_1
backup_file=$1

#-------------------------------------------------------------------------------
# Restore

# Stop the exbin container to safely drop the database.
docker stop ${exbin_container}

# Put the data in the db container.
cat ${backup_file}  | docker exec -i exbin_db_1 psql -Upostgres

# Restart the containers.
docker-compose restart 


