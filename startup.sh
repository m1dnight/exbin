#!/bin/bash 

# Create the database from scratch.
mix ecto.create 
mix ecto.migrate 

# Run the application.
mix phx.server 