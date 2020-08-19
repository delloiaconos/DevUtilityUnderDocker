FROM ubuntu:20.04

MAINTAINER Salvatore Dello Iacono <delloiaconos@gmail.com>

RUN apt-get update -y; \
    apt-get install ldap-utils python3 python3-pip python3-dev \
                    libsasl2-dev libldap2-dev libssl-dev -y; \
    pip3 install python-ldap smtp;

#CMD pip install ldap

ENTRYPOINT bash

