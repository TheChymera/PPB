# PPB - The Personal Pastebin

A simple and emerging script allowing you to pastebin files and terminal output to a webserver to which you have SSH access.

## Rationale

With pastebins becoming increasingly cluttered with ads and eye candy as well as increasingly restrictive in terms of file size and temporal persistency, it seems you need to take things into your own hands!
PPB, the Personal PasteBin, is a simple script allowing you to quickly upload and share files on your machine.
It comes replete with utility improvements such as automatic clipboard update as well as most-recent-file-in-directory upload via the `rppb` wrapper command.

## Usage

```console
user@host $ ppb somefile.png
Upload succeeded and URL added to clipboard:
https://some.url/ppb/bb04fc.png
```

## Installation

### Manual

If you are using a Linux distribution which makes PPB available via your package manager, **this approach is not recommeded**.

PPB consists of a single script and a single config file.
You can install them manually at the system level via the following commands:

```console
user@host $ cd /some/path/you/like
user@host $ git clone git@github.com:TheChymera/PPB.git
user@host $ su -
root@host # cd /some/path/you/like/PPB
root@host # cp bin/ppb /usr/bin/
root@host # cp config/ppb.conf /etc/
```

### Gentoo

#### Via the Chymeric Overlay

After [enabling](https://github.com/TheChymera/overlay#install) the Chymeric Overlay, you can simply emerge the package by running:

```console
root@host # emerge ppb
```

#### From the cloned Git repository

Currently, the script can be installed automatically on Gentoo Linux systems, via the [`.gentoo` synchronously developed install specification](http://chymera.eu/docs/dominik_semesterarbeit.pdf).
To use this functionality, you can run the following commands:

```console
user@host $ cd /some/path/you/like 
user@host $ git clone git@github.com:TheChymera/PPB.git 
user@host $ su -
root@host # cd /some/path/you/like/PPB/.gentoo
root@host # ./install.sh
```

Following this the package is installed and managed by your package manager, correspondingly it can be uninstalled via `emerge -C ppb`.

## Further Development

Currently the software is very minimal.
Help is appreciated in extending it!
