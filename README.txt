High level concepts that need to be understood to admin OpenStack:

Swift: Object storage (database)


Glance: VM image service

Glance is the service that provides VM images to the OpenStack cloud. An image
is, for example, "Ubuntu Server" or "CentOS 6".  These images need to be
imported into Glance before they are available in the WebUI.


Keystone: Identity service

Keystone is the services that handles user authentication and authorization.
Every service in OpenStack talks to keystone to validate a users credentials.
There are 3 containers in keystone:
 - User
 - Tenant
 - Role

A "user" is an account (username/password).  A "tenant" is a container
(grouping) of users or resources.  A "role" is a personality a user has in each
tenant.  A "user" can have multiple "roles" in a single "tenant" and a users
"role" may vary from "tenant" to "tenant".

"role" is just a character string as far as keystone is concerned.  Each service
is required to use this string to match a set of rules.  These rules are defined
in the policy.json file for each service (/etc/<service>/policy.json).

For more information about users/roles/tenants, see the following:
http://docs.openstack.org/trunk/openstack-compute/admin/content/keystone-concepts.html

Dashboard: Web user interface

This is the service that services the WebUI for OpenStack. Requires apache (or
another http service). Usually accessible at http://<hostname>/dashboard

Cinder: Block storage management


Quantum: Virtual network management

OpenVSwitch is the primary piece of software behind Quantum.  OpenVSwitch is a
framework to simplifiy automated management of the network layer (VLAN tags,
routes, etc.).
