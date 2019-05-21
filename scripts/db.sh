#!/bin/bash

docker stop pg
docker rm pg 
docker run --rm --name pg -e POSTGRESS_PASSWORD=dev -d -p 5432:5432 postgres

sleep 2 

export PGPASSWORD='exbin'
psql -h localhost -U postgres -c "CREATE USER exbin WITH PASSWORD 'exbin' CREATEDB;"