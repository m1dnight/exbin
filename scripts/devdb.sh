#!/bin/bash

# To connect to the live db use this:
# docker run --rm --name pg-tmp --net=exbinnet -e PGPASSWORD=postgres postgres psql -h exbin_dev -U postgres

# Start network 
################################################################################

docker rm -f exbindb 
docker rm -f pg-tmp
docker rm -f exbinpgadmin

timezone="Europe/Brusels"
docker network rm exbinnet 
docker network create exbinnet 

data_dir=$(mktemp -d)

# Run the database 
################################################################################

docker rm -f exbindb


docker run --rm                                  \
           -d                                    \
           --name exbindb                        \
           --net=exbinnet                        \
           -e POSTGRES_PASSWORD="postgres"       \
           -e TZ=$timezone                       \
           -p 5432:5432                          \
           -v $data_dir:/var/lib/postgresql/data \
           postgres


docker run --rm                                                      \
           -d                                                        \
           --name exbinpgadmin                                       \
           --net=exbinnet                                            \
           -p 5050:80                                                \
           -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" \
           -e "PGADMIN_DEFAULT_PASSWORD=SuperSecret" \
           dpage/pgadmin4

sleep 10 

docker run --rm                        \
           --name pg-tmp               \
           --net=exbinnet              \
           -e PGPASSWORD=postgres      \
           postgres                    \
           psql -h exbindb -U postgres -c "CREATE DATABASE exbin_dev OWNER postgres;"   