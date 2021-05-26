#!/bin/bash

db_container=exbin_db_1
exbin_container=exbin_exbin_1
backup_file=dump_`date +%d-%m-%Y"_"%H_%M_%S`.sql
backup_dir=$1
#-------------------------------------------------------------------------------
# Backup

# Create a dump file.
docker exec -t -u postgres ${db_container} pg_dumpall -c > ${backup_dir}/${backup_file}

bzip2 ${backup_dir}/${backup_file}
