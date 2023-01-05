#! /bin/bash

function process_data() {
  psql -h localhost -p 9433 -U postgres -d testdb -c "INSERT INTO metric1 (ts, val, dev_id) SELECT s.*, 3.14, d.* FROM generate_series('2021-08-17 00:0$3:00'::timestamp, '2021-08-17 00:0$3:59'::timestamp, '1 s'::interval) s CROSS JOIN generate_series($1, $2) d;"
}

function teardown() {
  docker-compose down -v
  echo "done"
  exit 2
}

trap teardown SIGINT

if [ -z "$1" ]; then
  echo "Must specify either deadlock or tuple"
  exit 1
fi

echo "launch test docker environment"
docker-compose up -d

echo "wait for Postgres to be fully up"
sleep 10 

echo "load initial data"
process_data 1 500 0

echo "stop data node 4"
docker-compose stop tsdb-data4

echo "mark data node 4 as unavailable"
psql -h localhost -p 9433 -U postgres -d testdb -c "select alter_data_node('dn4', available=>false);"

echo "attempt to insert next batch of data"
if [ "$1" == "deadlock" ]; then
  process_data 1 9 1 &
  pids[0]=$!
  process_data 10 20 1 &
  pids[1]=$!
fi

if [ "$1" == "tuple" ]; then
  process_data 1 249 1 &
  pids[0]=$!
  process_data 250 499 1 &
  pids[1]=$!
fi

for pid in ${pids[*]}; do
    wait $pid
done

read -p "DONE, press any key to tear down test docker environment"
teardown
