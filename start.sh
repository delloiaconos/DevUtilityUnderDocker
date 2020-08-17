#!/bin/sh

## APPLICATION Configuration
app="openldap"

## LDAP Configuraiton
LDAP_ORGANISATION="Example"
LDAP_DOMAIN="example.org"
LDAP_ADMIN_PASSWORD="password123"


## COMMON CONFIGS
BASE_PATH="/opt/devutility"


docker rm ldap-service -f
docker rm phpldapadmin-service -f
docker rm subversion-service -f
docker rm ldappasswd-service -f


## LDAP SERVICE
mkdir -p $BASE_PATH/ldap-db
mkdir -p $BASE_PATH/ldap-conf

docker run \
   --name ldap-service \
   --hostname ldap-service \
   --restart always \
   --volume $BASE_PATH/ldap-db:/var/lib/ldap \
   --volume $BASE_PATH/ldap-conf:/etc/ldap/slapd.d \
   -p 389:389 -p 636:636 \
   --env LDAP_ORGANISATION="${LDAP_ORGANISATION}" \
   --env LDAP_DOMAIN="${LDAP_DOMAIN}" \
   --env LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD}" \
   --detach osixia/openldap:1.4.0

## PHPLDAPADMIN SERVICE
docker run \
   --name phpldapadmin-service \
   --hostname phpldapadmin-service \
   --restart always \
   --link ldap-service:ldap-host \
   -p 80:80 -p 443:443\
   --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host \
   --env PHPLDAPADMIN_HTTPS=false \
   --detach osixia/phpldapadmin:0.9.0

PHPLDAP_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" phpldapadmin-service)

echo "Go to: https://$PHPLDAP_IP"
echo "Login DN: cn=admin,dc=example,dc=org"
echo "Password: admin"


## SUBVERSIONEDGE SERVICE
mkdir -p $BASE_PATH/svndata

docker build -f SubversionEdge/Dockerfile -t subversionedge ./SubversionEdge
docker run \
   --name subversion-service \
   --hostname subversion-service \
   --restart always \
   -p 4434:4434 -p 3343:3343 -p 18080:18080 \
   --volume $BASE_PATH/svndata:/opt/csvn/data \
   --detach subversionedge

## SELFSERVICEPASSWORD SERVICE
docker build -f SelfServicePassword/Dockerfile -t ldappasswd ./SelfServicePassword

mkdir -p $BASE_PATH/ldappasswd
cp ./SelfServicePassword/conf/* $BASE_PATH/ldappasswd

docker run \
   --name ldappasswd-service \
   --hostname ldappasswd-service \
   --restart always \
   -p 9090:80 \
   --volume $BASE_PATH/ldappasswd:/var/www/conf \
   --detach ldappasswd

## NETWORK
docker network create \
   --driver=bridge \
   --subnet=172.28.0.0/24 \
   --ip-range=172.28.0.0/24 \
   --gateway=172.28.0.254 \
  br0

## MYSQL SERVICE
docker run \
   --name mysql-service \
   --hostname mysql-service \
   --restart always \
   --ip 172.28.0.100 br0 \
   -e MYSQL_ROOT_PASSWORD="MySqlRootPassword" \
   -e MYSQL_USER="mysqluser" \
   -e MYSQL_PASSWORD="userpassword" \
   --detach mysql:8.0


## BUGZILLA SERVICE
docker run \
   --name bugzilla-service \
   --hostname bugzilla-service \
   --restart always \
   --ip 172.28.0.101 br0 \
   -p 8000:80 \
   --volume $BASE_DIR/bugzilla:/etc/msmtprc:ro \
   -e MYSQL_DB="172.28.0.100" \
   -e MYSQL_USER="mysqluser" \
   -e MYSQL_PWD="userpassword" \
   --detach achild/bugzilla
