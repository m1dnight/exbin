#!/bin/bash

MIX_ENV=prod

mix deps.get --only prod
mix compile
mix ecto.migrate 

cd assets 
node_modules/brunch/bin/brunch build --production

cd ..
mix phx.digest 
