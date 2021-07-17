#!/bin/bash
bin="/app/bin/exbin"

# Setup the database.
$bin eval "ExBin.Release.migrate"

# start the elixir application
exec "$bin" "start" 