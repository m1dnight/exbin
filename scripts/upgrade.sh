#!/bin/bash

# Fetch newest image
docker pull m1dnight/exbin:latest

# Create backup.
./backup.sh .

# Remove the container.
docker rm -f exbin_exbin_1

# Start the container.
docker-compose up -d 
