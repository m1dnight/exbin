#!/bin/bash
bin="/app/prod/bin/prod"
rel="/app/prod"

# Setup the database.
$bin eval "Exbin.Release.migrate"

# Initial user.
$bin eval 'Code.eval_file("/app/prod/initial_user.exs")'

# start the elixir application
exec "$bin" "start" 