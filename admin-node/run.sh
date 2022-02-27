#!/usr/bin/bash
source .env

while getopts p: flag
do
    case "${flag}" in
        p) password=${OPTARG};;
    esac
done
if [ -z "$password" ]
then
  if [ -z "$ADMIN_PASS" ]
  then
    echo "Enter admin password:"
    read $ADMIN_PASS
  fi
else
  ADMIN_PASS=$password
fi


echo "admin password is '$ADMIN_PASS'"

cat << EOF >> .env
SERVER_IP=127.0.0.1
HASH_ADMIN_PASS=admin:$(openssl passwd -apr1 $ADMIN_PASS)
EOF

docker-compose -f docker-compose.defence.yml up -d
