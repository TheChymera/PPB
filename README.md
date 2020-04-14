# PPB - The Personal Pastebin

A simple and emerging script allowing you to pastebin files to a webserver to which you have SSH access.

## Rationale

With pastebins becoming increasingly cluttered with ads and eye candy as well as increasingly restrictive in terms of file size and temporal persistency, it seems you need to take things into your own hands!
PPB, the Personal PasteBin is a simple script allowing you to quickly upload and share files on your machine.

## Usage

```console
user@host $ ppb somefile.png
sending incremental file list
build.log
        223,298 100%  181.70MB/s    0:00:00 (xfr#1, to-chk=0/1)

sent 223,450 bytes  received 35 bytes  148,990.00 bytes/sec
total size is 223,298  speedup is 1.00
Uploaded to: https://some.url/ppb/bb04fc.log
```

## Installation

Depending on your preferred package manager you may choose one of the following methods:

#### Portage (e.g. on Gentoo Linux):
This package is available via Portage (the package manager of Gentoo Linux, derivative distributions, and installable on [any other Linux distribution](https://wiki.gentoo.org/wiki/Project:Prefix), or BSD) via the [Chymeric Overlay](https://github.com/TheChymera/overlay).
Upon enabling the overlay, the package can be emerged:

```console
root@host # emerge ppb
```

## Further Development

Currently the software is very barebones, and only works for files, not for piped output.
Help is appreciated in extending it!
