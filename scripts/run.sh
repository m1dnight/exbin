#!/bin/bash

# Start network 
################################################################################

docker network rm exbinnet 
docker network create exbinnet 

# Run the database 
################################################################################

docker rm -f exbindb

docker run --rm                        \
           -d                          \
           --name exbindb              \
           --net=exbinnet              \
           -e POSTGRESS_PASSWORD=exbin \
           -p 5432:5432                \
           postgres

sleep 2 

docker run --rm                        \
           --name pg-tmp               \
           --net=exbinnet              \
           -e PGPASSWORD=exbin         \
           postgres                    \
           psql -h exbindb -U postgres -c "CREATE USER exbin WITH PASSWORD 'exbin' CREATEDB;"
docker run --rm                        \
           --name pg-tmp               \
           --net=exbinnet              \
           -e PGPASSWORD=exbin         \
           postgres                    \
           psql -h exbindb -U postgres -c "CREATE DATABASE exbindb OWNER exbin;"

# Run ExBin 
################################################################################
docker rm -f exbin 

docker run -it --rm                      \
           --name exbin                  \
           --net=exbinnet                \
           -e DB_USER='exbin'            \
           -e DB_PASS='exbin'            \
           -e DB_HOST='exbindb.exbinnet' \
           -e DB_NAME='exbindb'          \
           -e EXTERNAL_URL='localhost'   \
           -e TCP_PORT='9999'            \
           -e TCP_IP='127.0.0.1'         \
           -e PORT=4000                  \
           -p 4000:4000                  \
           m1dnight/exbin ecto.migrate
           
docker run -d                            \
           --name exbin                  \
           --net=exbinnet                \
           -e DB_USER='exbin'            \
           -e DB_PASS='exbin'            \
           -e DB_HOST='exbindb.exbinnet' \
           -e DB_NAME='exbindb'          \
           -e EXTERNAL_URL='localhost'   \
           -e TCP_PORT='9999'            \
           -e TCP_IP='127.0.0.1'         \
           -e PORT=4000                  \
           -p 4000:4000                  \
           m1dnight/exbin phx.server         