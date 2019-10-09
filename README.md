DeforaOS libMarshall
====================

About libMarshall
-----------------

libMarshall is a marshalling library, allowing the execution of function calls
of any prototype across a number of combinations of Operating Systems, hardware
architectures, and calling conventions. It is notably used by libApp, a
message-passing framework at the core of the DeforaOS Project.

Dependencies for libMarshall
----------------------------

libMarshall depends on the following software components:
- pkg-config from the freedesktop software collection, as found in most
  software distributions already; otherwise at
  <http://www.freedesktop.org/wiki/Software/pkg-config/>
- libSystem from the DeforaOS Project, as found at
  <https://www.defora.org/os/project/27/libSystem> if not packaged for your
  system.

And optionally:
- configure from the DeforaOS Project, likewise found at
  <https://www.defora.org/os/project/16/configure>
- GTK-Doc (for the API documentation), found at
  <http://www.gtk.org/gtk-doc/>


Configuring libMarshall
-----------------------

When building libMarshall from the development sources, it is necessary to
generate Makefiles with `configure(1)`. It should be enough to run this tool as
follows:

    $ configure

Please refer to the documentation of DeforaOS configure for further
instructions.

A default set of Makefiles is provided with releases of this project in order
to help building and packaging. The Makefiles provided target the NetBSD
Operating System <https://www.netbsd.org/> by default, but should work on most
platforms without changes.


Compiling libMarshall
---------------------

It is then possible to build the project with `make(1)` as usual. The following
command should therefore be enough:

    $ make

To build libMarshall for installation in a different directory than the default
`/usr/local`, use the `PREFIX` variable as follows:

    $ make PREFIX="/path/to/destination"

Then use the `install` target to effectively install libMarshall on the system.
