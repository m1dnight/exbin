#!/bin/bash

MIX_ENV=prod

git pull origin master 

mix deps.get --only prod

cd assets 

npm install --production

node_modules/brunch/bin/brunch build --production

cd ..

mix ecto.migrate 

mix phx.digest 



# git pull origin master 
# mix deps.get
# cd assets 
# npm install 
# node_modules/brunch/bin/brunch build 
# cd ..
# iex -S mix phoenix.server
