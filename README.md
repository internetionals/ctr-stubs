Container stubs
===============

This project is an attempt to make certain commands easily available by using
containers. It attempts to workaround any user/group and permissions mismatches
and by providing the homedirectory and current working directory to the command
being executed.

How to use
----------

Add to a bourne compatible shells config (eg. `$HOME/.bashrc`) the following
line:

```
source /path/to/checkout/setup
```

Afterwards, open a fresh shell and the commands provided will be *appended* to
your shell's `$PATH`.

How it works
------------

For every container there is a directory. Each directoy must contain a
`Dockerfile` that constructs the image used to perform the commands in. The
`do` executable can be used to run a command inside that container, which will
be executed with the same UID en GID as the user invoking it. The `do` command
will build the container image for that container, if it doesn't already exist.
It will also build a user specific image with the additional user information
added. Then it will start a one-shot container as the current user, forwarding
all relevant paths to the container and runs the indicated command with any
additional arguments provided.

Example:

```
./do postgres psql service=some-db
```

This will run the `psql` command, in the container using the image build from the `postgres/Dockerfile`, with `service=some-db` as command line argument.

Each directory should also contain a `bin/` directory with symlinks for all the
commands we want to expose. These symlinks should all point to
`../../argv0-stub`, which is a helper script that will call the `do` command
for that command in that command's container.
