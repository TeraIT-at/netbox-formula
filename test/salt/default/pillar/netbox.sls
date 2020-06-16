# -*- coding: utf-8 -*-
# vim: ft=yaml
---

netbox:
  service:
    config:
      ALLOWED_HOSTS: ["localhost"]
      DATABASE:
        NAME: "netbox"
        USER: "netbox"
        PASSWORD: "netbox"
        HOST: "localhost"
      REDIS:
        webhooks:
          HOST: "localhost"
          PORT: 6379
          PASSWORD: ""
          DATABASE: 0
          DEFAULT_TIMEOUT: 300
          SSL: False
        caching:
          HOST: "localhost"
          PORT: 6379
          PASSWORD: ""
          DATABASE: 1
          DEFAULT_TIMEOUT: 300
          SSL: False
      SECRET_KEY: "qui2igh7pohl1veif8riul6ko3povou9ael4Axa8aurah6ooni"
    optional:
      ldap:
        enabled: false
        config:
          AUTH_LDAP_SERVER_URI: "\"ldaps://ad.example.com\""
          AUTH_LDAP_CONNECTION_OPTIONS:
            ldap.OPT_REFERRALS: 0
          AUTH_LDAP_BIND_DN: "\"CN=NETBOXSA, OU=Service Accounts,DC=example,DC=com\""
          AUTH_LDAP_BIND_PASSWORD: "\"demo\""
          LDAP_IGNORE_CERT_ERRORS: True
          AUTH_LDAP_USER_SEARCH: LDAPSearch("ou=Users,dc=example,dc=com",ldap.SCOPE_SUBTREE,"(sAMAccountName=%(user)s)")
          AUTH_LDAP_USER_DN_TEMPLATE: "\"uid=%(user)s,ou=users,dc=example,dc=com\""
          AUTH_LDAP_USER_ATTR_MAP:
            "\"first_name\"": "givenName"
            "\"last_name\"": "sn"
            "\"email\"": "mail"
          AUTH_LDAP_GROUP_SEARCH: LDAPSearch("dc=example,dc=com", ldap.SCOPE_SUBTREE,"(objectClass=group)")
          AUTH_LDAP_GROUP_TYPE: GroupOfNamesType()
          AUTH_LDAP_REQUIRE_GROUP: "\"CN=NETBOX_USERS,DC=example,DC=com\""
          AUTH_LDAP_MIRROR_GROUPS: True
          AUTH_LDAP_USER_FLAGS_BY_GROUP:
            "\"is_active\"": "cn=active,ou=groups,dc=example,dc=com"
            "\"is_staff\"": "cn=staff,ou=groups,dc=example,dc=com"
            "\"is_superuser\"": "cn=superuser,ou=groups,dc=example,dc=com"
          AUTH_LDAP_FIND_GROUP_PERMS: True
          AUTH_LDAP_CACHE_GROUPS: True
          AUTH_LDAP_GROUP_CACHE_TIMEOUT: 3600
  database:
    db_name: "netbox"
    username: "netbox"
    password: "netbox"
  webserver:
    servername: "localhost"
  redis:
    bind: "127.0.0.1"
  repository:
    url: https://github.com/netbox-community/netbox.git
    branch: master
