#!/bin/bash

MIX_ENV=prod

git pull origin master 

mix deps.get --only prod

mix compile

cd assets 

npm install --production

node_modules/brunch/bin/brunch build --production

cd ..

mix phx.digest 

mix ecto.migrate 

# git pull origin master 
# mix deps.get
# cd assets 
# npm install 
# node_modules/brunch/bin/brunch build 
# cd ..
# iex -S mix phoenix.server
