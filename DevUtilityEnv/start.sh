#!/bin/sh

docker build -t devutilityenv:latest .

docker run -it \
   --name=DevUtilityEnv \
   devutilityenv

docker rm DevUtilityEnv -f


