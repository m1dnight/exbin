# ExBin

A pastebin clone written in Phoenix/Elixir. Live [here](https://exbin.call-cc.be). 

I work on this project from time to time, so the development pace is slow. If you want to dive in, feel free. The codebase is quite small, because, well, it's a simple application.

## Features

 * Post pastes publicly and privatley 
 * List of all public pastes 
 * Use `nc` to pipe text and get the URL. 
   (e.g., `cat file.txt | nc exbin.call-cc.be 9999`)
 * "Raw View" where text is presented as is, ideally to share code for copy and pasting.
 * Syntax highlighted view.
 * "Reader View" where text is presented in a more readable manner. Better suited to share prose text.

## Todo

## Docker 

First of all, create an `.env` file in the folder of the `docker-compose.yml` file and change the contents to your liking.

```
TCP_PORT=9999
TCP_IP=0.0.0.0
PORT=4001
DB_NAME=exbindb
DB_PASS=supersecretpassword
DB_USER=postgres
MAX_BYTES=1024
EXBIN_DATA=./postgres-data 
DEFAULT_VIEW=reader
PUBLIST_LIMIT=100
```

To run this entire thing in Docker:

```
docker-compose up -d
```

At this point you should be able to navigate to the site at `http://localhost:4001`.


## Develop 

```
git clone https://github.com/m1dnight/exbin.git
cd exbin
mix deps.get
mix compile
cd assets 
npm install
node_modules/brunch/bin/brunch build
cd ..
./scripts/run.sh # Creates a docker database.
mix ecto.create 
mix ecto.migrate
mix phx.server
```

## Deploy

Compile:

```
git clone https://github.com/m1dnight/exbin.git
cd exbin
export MIX_ENV=prod
mix deps.get --only prod
mix compile
cd assets 
npm install
node_modules/brunch/bin/brunch build --production
cd ..
mix phx.digest 
mix ecto.create 
mix ecto.migrate
```

Run:

Keep in mind that there are other environment variables you can set. See above, or the `.env.example` file.
```
MIX_ENV=prod TCP_PORT=6666 TCP_IP=0.0.0.0 mix phx.server
```

# Env vars

| Variable        	| Description                                                                                                     	| Values                     	| Default     	|
|-----------------	|-----------------------------------------------------------------------------------------------------------------	|----------------------------	|-------------	|
| `TCP_PORT`      	| TCP port for the socket to listen to for raw data.                                                              	| Number                     	| `9999`      	|
| `TCP_IP`        	| Interface to bind to.                                                                                           	| Interface                  	| `127.0.0.1` 	|
| `PORT`     	| Port the web app should listen to.                                                                              	| Number                     	| `4001`      	|
| `DB_NAME`       	| Name of the database.                                                                                           	| String                     	| `exbindb`   	|
| `DB_PASS`       	| Password to the database.                                                                                       	| String                     	| `pass`      	|
| `DB_USER`       	| Username to the database.                                                                                       	| String                     	| `user`      	|
| `MAX_BYTES`     	| Maximum size of text that can be dumped to the TCP socket. When the size is exceeded the connection is dropped. 	| Number                     	| `1048576`   	|
| `EXBIN_DATA`    	| The path where the database data should be stored.                                                              	| Path                       	|             	|
| `DEFAULT_VIEW`  	| Default view of snippets when they are submitted.                                                               	| `code`, `raw`, or `reader` 	| `code`      	|
| `PUBLIST_LIMIT` 	| Maximum number of snippets to show in the "Latest" page. Set a limit if you have a very busy instance.          	| Number or `nil`            	| `nil`       	|