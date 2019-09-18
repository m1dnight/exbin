FROM elixir:1.8.2
LABEL maintainer "Christophe De Troyer <christophe@call-cc.be>"

# Install  Hex, Rebar, and Phoenix.
RUN mix local.hex --force &&                                  \
    mix local.rebar --force &&                                \
    mix archive.install hex phx_new 1.4.8 --force &&          \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y -q nodejs

# Add the source code. 
ADD . /app

# Build the application.
ENV MIX_ENV=prod
WORKDIR /app 
RUN mix deps.get --only prod &&                          \
    mix compile &&                                      \
    cd assets &&                                         \
    npm install &&                                       \
    node_modules/brunch/bin/brunch build --production && \
    cd ..  &&                                            \
    mix phx.digest

# ENTRYPOINT ["mix"]
ENTRYPOINT ["./startup.sh"]

# -e DB_NAME=exbindb -e DB_PASS=supersecretpassword -e DB_USER=postgres -e DB_HOST=localhost