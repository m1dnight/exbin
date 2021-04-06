#!/bin/bash 

result=$(curl --header "Content-Type: application/json" --request POST  --data '{"content":"snippetcontent","private":"true"}' http://localhost:4001/api/snippet)

content=$(curl ${result//4001/4001\/raw})

if [ "$content" = "snippetcontent" ]; then
    echo "Works."
else
    echo "Nen error."
fi