#!/bin/bash 

# This script runs in a docker-compose so we can assume that all the
# enviornment variables are set properly, and the DB is up.

# Create the database from scratch.
mix ecto.create 
mix ecto.migrate 

# Run the application.
mix phx.server 