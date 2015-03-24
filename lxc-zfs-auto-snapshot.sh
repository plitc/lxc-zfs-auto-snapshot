#!/bin/sh

### LICENSE // ###
#
# Copyright (c) 2015, Daniel Plominski (Plominski IT Consulting)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
### // LICENSE ###

### ### ### PLITC // ### ### ###

###
### TODO: 24.03.2015 - MongoDB support
###

### stage0 // ###
#
## Common ZFS snapshot, exclude Database Container
EXCLUDELXC="db|db2|db3"
#
#
## Database Server 1 - MySQL (db)
MYSQLDBSRV1="db"
MYSQLDBSRVUSER1="debian-sys-maint"
MYSQLDBSRVPASSWD1="SECRET"
#
#
## Database Server 1 - PostgreSQL (db)
POSTGRESQLDBSRV1="db"
POSTGRESQLDBSRVUSER1="postgres"
#/ POSTGRESQLDBSRVPASSWD1=""
#
#
## Database Server 2 - PostgreSQL (db2)
POSTGRESQLDBSRV2="db2"
POSTGRESQLDBSRVUSER2="postgres"
#/ POSTGRESQLDBSRVPASSWD2=""
#
#
## Database Server 3 - PostgreSQL (db3)
POSTGRESQLDBSRV3="db3"
POSTGRESQLDBSRVUSER3="postgres"
#/ POSTGRESQLDBSRVPASSWD3=""
#
### // stage0 ###


### stage1 // ###
#
DATE=$(date +%Y%m%d-%H%M)
#
### // stage1 ###


### stage2 // ###
#
## MySQL       - ZFS snapshot - LXC db
echo "--- --- --- > MySQL      - LXC: $MYSQLDBSRV1 ZFS snapshotting"
lxc-attach -n $MYSQLDBSRV1 -- mysql -h localhost -u $MYSQLDBSRVUSER1 -p$MYSQLDBSRVPASSWD1 -e "set autocommit=0;FLUSH LOGS;FLUSH TABLES WITH READ LOCK;"
## PostgreSQL  - ZFS snapshot - LXC db
echo "--- --- --- > PostgreSQL - LXC: $POSTGRESQLDBSRV1 ZFS snapshotting"
lxc-attach -n $POSTGRESQLDBSRV1 -- su -m $POSTGRESQLDBSRVUSER1 -c 'psql -c "SELECT PG_START_BACKUP('\''zfs-auto-snapshot'\'', true)" postgres;'
## AUTOSNAP_DB - Database ZFS snapshot
lxc-attach -n $MYSQLDBSRV1 -- sync
zfs snapshot rpool/lxc/$MYSQLDBSRV1@_AUTOSNAP_DB_"$DATE"
## set Database online
lxc-attach -n $MYSQLDBSRV1 -- mysql -h localhost -u $MYSQLDBSRVUSER1 -p$MYSQLDBSRVPASSWD1 -e "UNLOCK TABLES;"
lxc-attach -n $POSTGRESQLDBSRV1 -- su -m $POSTGRESQLDBSRVUSER1 -c 'psql -c "SELECT PG_STOP_BACKUP();" postgres;'
#
#
## PostgreSQL  - ZFS snapshot - LXC jabber
echo "--- --- --- > PostgreSQL - LXC: $POSTGRESQLDBSRV2 ZFS snapshotting"
lxc-attach -n $POSTGRESQLDBSRV2 -- su -m $POSTGRESQLDBSRVUSER2 -c 'psql -c "SELECT PG_START_BACKUP('\''zfs-auto-snapshot'\'', true)" postgres;'
## AUTOSNAP_DB - Database ZFS snapshot
lxc-attach -n $POSTGRESQLDBSRV2 -- sync
zfs snapshot rpool/lxc/$POSTGRESQLDBSRV2@_AUTOSNAP_DB_"$DATE"
## set Database online
lxc-attach -n $POSTGRESQLDBSRV2 -- su -m $POSTGRESQLDBSRVUSER2 -c 'psql -c "SELECT PG_STOP_BACKUP();" postgres;'
#
#
## PostgreSQL  - ZFS snapshot - LXC wiki
echo "--- --- --- > PostgreSQL - LXC: $POSTGRESQLDBSRV3 ZFS snapshotting"
lxc-attach -n $POSTGRESQLDBSRV3 -- su -m $POSTGRESQLDBSRVUSER3 -c 'psql -c "SELECT PG_START_BACKUP('\''zfs-auto-snapshot'\'', true)" postgres;'
## AUTOSNAP_DB - Database ZFS snapshot
lxc-attach -n $POSTGRESQLDBSRV3 -- sync
zfs snapshot rpool/lxc/$POSTGRESQLDBSRV3@_AUTOSNAP_DB_"$DATE"
## set Database online
lxc-attach -n $POSTGRESQLDBSRV3 -- su -m $POSTGRESQLDBSRVUSER3 -c 'psql -c "SELECT PG_STOP_BACKUP();" postgres;'
#
### // stage2 ###


### stage3 // ###
#
## AUTOSNAP - Common ZFS snapshot
echo "--- --- --- > ALL        - LXC: (exclude $EXCLUDELXC) ZFS snapshotting"
lxc-ls --active | egrep -v "$EXCLUDELXC" | sed 's/^/rpool\/lxc\//' | xargs -L1 -I {} zfs snapshot {}@_AUTOSNAP_"$DATE"
#
### // stage3 ###


exit 0
### ### ### // PLITC ### ### ###
# EOF
