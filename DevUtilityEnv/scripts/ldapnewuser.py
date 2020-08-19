import ldap
import ldap.modlist as modlist

LOGIN = "cn=admin,dc=example,dc=org"
PASSWORD = "password123"
LDAP_URL = "ldap://ldap-host:389"

#user='grant'
l = ldap.initialize(LDAP_URL)
l.bind(LOGIN, PASSWORD)
dn="cn=Py User,ou=nisc2020,dc=example,dc=org"

attrs = {}
attrs['objectclass'] = [b'inetOrgPerson']
attrs['cn'] = b'Py User'
attrs['sn'] = b'Python'
attrs['uid'] = b'pyuser'
attrs['userPassword'] = b'pyuser'
#attrs['description'] = b'User object for replication using slurpd'
attrs['mail']=b"pyuser@email.com"

# Convert our dict to nice syntax for the add-function using modlist-module
ldif = modlist.addModlist(attrs)

# Do the actual synchronous add-operation to the ldapserver
l.add_s(dn,ldif)

# Its nice to the server to disconnect and free resources when done
l.unbind_s()
