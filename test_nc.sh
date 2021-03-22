#!/bin/bash 

# Random filename in /tmp.
file=$(mktemp)

# Generate a random content.
dd if=/dev/urandom of=$file bs=50M count=1 status=none

# Turn it into base32 for utf8 (exbin only accepts utf8).
content=$(base32 $file)

# Post it to the local server.
result=$(echo $content | nc localhost 9999)

# Read back from the server.
read_back=$(curl -s $result)

# Verify the contents of the original file and the read back content.
read_back_file=$(mktemp)
content_file=$(mktemp)
cmp --silent $read_back_file $content_file || echo "The response differs from the sent file!"