#!/bin/bash

MIX_ENV=prod

mix deps.get
mix compile
mix ecto.migrate 

cd assets 
npm install 
node_modules/brunch/bin/brunch build --production

cd ..
mix phx.digest 
