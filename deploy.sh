#!/bin/bash

MIX_ENV=prod

mix deps.get --only prod

cd assets 
npm install --production
node_modules/brunch/bin/brunch build --production
cd ..

mix phx.digest 

mix ecto.migrate
mix phx.digest
