# DevUtilityUnderDocker

Develope environment under docker, composed by:
- Subversion EDGE
- Bugzilla

It includes also:
- OpenLDAP for authentication
- phpLDAPAdmin (for users management)
- SelfServicePassword (for user password change)
- MySQL (for Bugzilla)


## Install
Get repository via git (user recursive option), apply your settings and run start.sh

git clone --recursive https://github.com/delloiaconos/DevUtilityUnderDocker.git DevUtility
cd DevUtility
bash start.sh

