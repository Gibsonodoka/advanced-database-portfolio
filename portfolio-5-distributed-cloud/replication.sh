#!/usr/bin/env bash
PGBIN=${PGBIN:-/usr/lib/postgresql/16/bin}
DATA=${DATA:-/tmp/pgs}
PRIMARY=${PRIMARY:-5453}
REPLICA=${REPLICA:-5454}
export PGHOST=$DATA PGUSER=postgres

run() { if [ "$(id -u)" = 0 ]; then su postgres -c "$*"; else bash -c "$*"; fi; }
primary() { psql -p $PRIMARY -d church_db -At -c "$1"; }
replica() { psql -p $REPLICA -d church_db -At -c "$1"; }

echo "1. Create replica"
run "$PGBIN/pg_ctl -D $DATA/replica -m fast stop" >/dev/null 2>&1
run "rm -rf $DATA/replica && $PGBIN/pg_basebackup -h $DATA -p $PRIMARY -D $DATA/replica -R -X stream -c fast"
run "$PGBIN/pg_ctl -D $DATA/replica -o '-p $REPLICA -k $DATA' -l $DATA/replica.log -w start" | tail -1
echo "replica in recovery mode: $(replica 'SELECT pg_is_in_recovery()')"

echo "2. Replication status on primary"
primary "SELECT client_addr, state, sync_state FROM pg_stat_replication"

echo "3. Write on primary, read on replica"
primary "SELECT cms.zhim_record_donation(1, 1, 2500, 'CARD', 'REPL-1')" >/dev/null
sleep 1
echo "primary: $(primary "SELECT count(*) FROM cms.donation WHERE reference = 'REPL-1'")  replica: $(replica "SELECT count(*) FROM cms.donation WHERE reference = 'REPL-1'")"

echo "4. Write on replica"
replica "SELECT cms.zhim_record_donation(1, 1, 2500, 'CARD', 'REPL-2')" 2>&1 | head -1

echo "5. Replication lag"
replica "SELECT pg_wal_replay_pause()" >/dev/null
primary "SELECT cms.zhim_record_donation(1, 1, 2500, 'CARD', 'REPL-3')" >/dev/null
sleep 1
echo "primary: $(primary "SELECT count(*) FROM cms.donation WHERE reference = 'REPL-3'")  replica: $(replica "SELECT count(*) FROM cms.donation WHERE reference = 'REPL-3'")"
replica "SELECT pg_wal_replay_resume()" >/dev/null
sleep 1
echo "after resume, replica: $(replica "SELECT count(*) FROM cms.donation WHERE reference = 'REPL-3'")"

echo "6. Failover: stop primary, promote replica"
run "$PGBIN/pg_ctl -D $DATA/primary -m fast stop" | tail -1
run "$PGBIN/pg_ctl -D $DATA/replica promote -w" | tail -1
replica "SELECT cms.zhim_record_donation(1, 1, 2500, 'CARD', 'REPL-4')" >/dev/null
echo "new primary accepts writes: $(replica "SELECT count(*) FROM cms.donation WHERE reference = 'REPL-4'")"
