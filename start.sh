#!/bin/sh

## APPLICATION Configuration
app="openldap"

## LDAP Configuraiton
LDAP_ORGANISATION="Example"
LDAP_DOMAIN="example.org"
LDAP_ADMIN_PASSWORD="password123"

docker rm ldap-service -f
docker rm phpldapadmin-service -f
docker rm subversion-service -f
docker rm ldappasswd-service -f

## LDAP SERVICE
mkdir -p /opt/devutility/ldap-db
mkdir -p /opt/devutility/ldap-conf

docker run \
   --name ldap-service \
   --hostname ldap-service \
   --restart always \
   --volume /opt/devutility/ldap-db:/var/lib/ldap \
   --volume /opt/devutility/ldap-conf:/etc/ldap/slapd.d \
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
mkdir -p /opt/devutility

docker build -f SubversionEdge/Dockerfile -t subversionedge ./SubversionEdge
docker run \
   --name subversion-service \
   --hostname subversion-service \
   --restart always \
   -p 4434:4434 -p 3343:3343 -p 18080:18080 \
   --volume /opt/devutility/svndata:/opt/csvn/data \
   --detach subversionedge

## LDAPPASSWDWEBUI SERVICE
docker build -f LDAPPasswdWebui/Dockerfile -t ldappasswdwebui ./LDAPPasswdWebui

mkdir -p /opt/devutility/ldappasswd
cp ./LDAPPasswdWebui/settings.ini /opt/devutility/ldappasswd

docker run \
   --name ldappasswd-service \
   --hostname ldappasswd-service \
   --restart always \
   -p 9090:8080 \
   --volume /opt/devutility/ldappasswd:/conf \
   --env CONF_FILE="/conf/settings.ini" \
   --detach ldappasswdwebui
