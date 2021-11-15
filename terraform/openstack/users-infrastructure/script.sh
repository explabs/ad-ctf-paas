#!/bin/bash

server_ip="$1"
password="$2"
if [[ $# -ne 2 ]]; 
then 
    echo "illegal number of arguments" >&2
    exit 1
fi
api_url="http://$server_ip/api/v1"
TOKEN=$(curl -s -X POST \
 -H 'Accept: application/json' -H 'Content-Type: application/json' \
 --data '{"username":"admin","password":"'"$password"'"}' \
 $api_url/auth/login | jq -r '.token')
if [[ -z "$TOKEN" ]];
then
    echo "token is empty" >&2
    exit 1
else
    wget -q --header="Authorization: Bearer ${TOKEN}" $api_url/admin/generate/variables -O teams.tf
    if [[ "$?" != 0 ]]; then
        echo "Error downloading file"
        exit 1
    else
        echo "teams.tf has been downloaded successfully"
    fi
    wget  -qO- --header="Authorization: Bearer ${TOKEN}" $api_url/admin/generate/sshkeys | tar -xz 2> /dev/null
    if [[ "$?" != 0 ]]; then
        echo "Error downloading file"
        exit 1
    else
         echo "keys/ directory has been downloaded successfully"
    fi
fi
