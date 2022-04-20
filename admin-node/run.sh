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

#for subdomain in api traefik vpn-admin fileserver malwaretotal
#do
#  sudo sh -c "echo \"127.0.0.1   $subdomain.potee.local\" >> /etc/hosts"
#done
cat << EOF > .env
DOMAIN=$DOMAIN
ADMIN_PASS=$ADMIN_PASS
SERVER_IP=$SERVER_IP
HASH_ADMIN_PASS=admin:$(openssl passwd -apr1 $ADMIN_PASS)
TELEGRAM_TOKEN=$TELEGRAM_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
EOF

docker-compose -f docker-compose.defence.yml up -d --build
