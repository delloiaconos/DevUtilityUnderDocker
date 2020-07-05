docker build . -t mysvn
docker run -d -p 3343:3343 -p 4434:4434 -p 18080:18080  --name svn-server mysvn:latest
