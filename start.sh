#!/bin/sh

export BASEPATH="/opt/devutility"

mkdir -p $BASEPATH

mkdir -p $BASEPATH/ldappasswd/conf
mkdir -p $BASEPATH/ldappasswd/images
cp ./SelfServicePassword/conf/* $BASEPATH/ldappasswd/conf
cp ./SelfServicePassword/htdocs/images/* $BASEPATH/ldappasswd/images

mkdir $BASEPATH/bugzilla
curl https://raw.githubusercontent.com/herzcthu/bugzilla/master/localconfig > $BASEPATH/bugzilla/localconfig

docker-compose up --force-recreate -d

sleep 300;

docker exec -it bugzilla-service bash -c "cd htdocs; ./checksetup.pl"

