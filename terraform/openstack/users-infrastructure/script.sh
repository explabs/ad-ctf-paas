#!/bin/bash

server_ip="$1"
password="$2"

if [[ $# -ne 2 ]];
then
    echo "illegal number of arguments" >&2
    exit 1
fi

api_url="http://$server_ip/api/v1"
TOKEN=$(curl -s -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' \
 --data '{"username":"admin","password":"'"$password"'"}' "$api_url"/auth/login | jq -r '.token')

if [[ -z "$TOKEN" ]];
then
    echo "token is empty" >&2
    exit 1
fi


function get_data () {
  http_status=$(curl --write-out "%{http_code}" --silent --output /dev/null -H "Authorization: Bearer ${TOKEN}" "$api_url"/"$1" )
  if [[ http_status -ne 200 ]]; then
    echo "http server returns $http_status" >&2
    exit 1
  else
    wget -qO- --header="Authorization: Bearer ${TOKEN}" "$api_url"/"$1"
  fi
}

get_data admin/generate/variables > teams.tf
get_data admin/generate/sshkeys | tar -xz 2> /dev/null

