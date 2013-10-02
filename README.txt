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


NODE TYPES

There are (logically) 3 main node "types":
1) Compute Node
2) Controller Node
3) Network Node

The "Compute Node" contains a hypervisor (likely KVM) and openstack-nova-compute
which allows it to communicate with the controller node.  The Compute Nodes are
where the VMs will run.

The "Controller Node" hosts the OpenStack Nova API services.  Any actions that
happen within the OpenStack cluster will likely be relayed through this node.

The "Network Node" manages the network stack for OpenStack.  The bring up and
tear down of VLANs/subnets/routers/load balancers/etc are all managed by the
Network Node.  For this puppet class, the Network Node will be installed along
side the Controller Node.  This class assumes this node will have 3 interfaces:
eth0 - "Administrative" stuff (so you don't lose connectivity when you are
mucking with bridges)
eth1 - "private network" communication. eth1 will need to have all the
OpenStack VLANs bridged to it
eth2 - "public network" communication.  Traffic to the floating IPs will flow
out this interface.
eth0 can have an IP on it directly, but eth1 and eth2 will have bridges created
for them (by quantum) and an IP needs to be assigned to br-eth1 and br-eth2.

All of these node types can reside on a single server, or they can be seperated
to allow for higher resiliance.
