#!/bin/bash 

# Random filenames in /tmp/
file=$(mktemp)
content_file=$(mktemp)
read_back_file=$(mktemp)

# Generate a random content.
dd if=/dev/urandom of=$file bs=512K count=1 status=none

# Turn it into base32 for utf8 (exbin only accepts utf8).
content=$(base32 $file)
echo $content > $content_file 
echo "Created   $(stat --format=%s ${content_file}) random bytes"

# Post it to the local server.
result=$(echo $content | nc localhost 9999)

echo "Response: $result"

# Read back from the server.
read_back=$(curl -s $result)
echo $read_back > $read_back_file


echo "Read back $(stat --format=%s ${read_back_file}) bytes"
cmp --silent $read_back_file $content_file || echo "The response differs from the sent file!"