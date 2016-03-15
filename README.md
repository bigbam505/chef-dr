Chef DR
========

The purpose of this cookbook is to test out a DR strategy of chef server to allow data to be synced to an offsite DR instance.  The main purpose is to create a test environment to be able to repeat a DR failover.  In addition it can be used to verify chef upgrades with some manual testing because the end state is essentially two chef servers on two different versions.


## Getting Started

In order to setup the environment just run `./setup` from the root.  This will do the following:

- Create a master chef server and install chef server / chef management and open it in your browser
- Seed the chef server with a data bag, role, cookbook, environment
- Create a chef client node that will connect to the master chef server node and run a converge with a role/recipe
- Take a backup of using `knife backup` of the master node
- Create a DR chef server node and install chef server / chef management and open the endpoint in the browser
- Restores the backup created into the DR chef server using `knife backup`
- Create a chef client node that will connect to the DR chef server node and run a converge with a role/recipe

\* The script can be run again safely with the same results
