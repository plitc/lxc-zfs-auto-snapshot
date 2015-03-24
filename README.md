
Background
==========
* zfs automatic snapshots for lxc containers with mysql/postgresql

Benefits of Goal Setting
========================

WARNING
=======

Dependencies
============
* Linux (Debian)
   * zfsonlinux
   * lxc

Features
========

Platform
========
* Linux (Debian 8/jessie)

Usage
=====
```
    # usage: ./lxc-zfs-auto-snapshot.sh
```

PostgreSQL Configuration
=====
```
    vi /etc/postgresql/9.1/main/postgresql.conf

### ### ### PLITC // ### ### ###
wal_level = archive
archive_mode = on
archive_command = 'test ! -f /var/lib/postgresql/archive/%f && cp %p /var/lib/postgresql/archive/%f'  # Unix
#/ archive_timeout = 600
### ### ### // PLITC ### ### ###

    mkdir -p /var/lib/postgresql/archive
    chown postgres:postgres /var/lib/postgresql/archive
    chmod 0770 /var/lib/postgresql/archive
```

Diagram
=======

Screencast
==========

Errata
======
* 24.03.2015 - approach to robustness with mysql myisam

