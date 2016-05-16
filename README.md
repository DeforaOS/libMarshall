DeforaOS libMarshall
====================

About libMarshall
-----------------

libMarshall is a marshalling library, allowing the execution of function calls
of any prototype across a number of combinations of Operating Systems. hardware
architectures and calling conventions. It is notably used by libApp, a
message-passing framework at the core of the DeforaOS Project.

Dependencies for libMarshall
----------------------------

libMarshall depends on the following software components:
- pkg-config from the freedesktop software collection, as found in most
  software distributions already; otherwise at
  <http://www.freedesktop.org/wiki/Software/pkg-config/>
- libSystem from the DeforaOS Project, as found at
  <http://www.defora.org/os/project/27/libSystem> if not packaged for your
  system.
- configure from the DeforaOS Project, likewise found at
  <http://www.defora.org/os/project/16/configure>


Configuring libMarshall
-----------------------

Before being able to build libMarshall, it is necessary to generate Makefiles
with `configure(1)`. It should be enough to run this tool as follows:

    $ configure

Please refer to the documentation of DeforaOS configure for further
instructions.


Compiling libMarshall
---------------------

It is then possible to build the project with `make(1)` as usual. The following
command should therefore be enough:

    $ make

To install libMarshall in a dedicated directory, like `/path/to/libMarshall`:

    $ make PREFIX="/path/to/libMarshall" install
