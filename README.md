# Reproduce Errors With Marking Data Nodes Unavailable
There are two errors that occur when marking a data node unavailable.  They both occur on the first insert immediately following the alter_data_node call, and only occur when two or more processes are attempting to insert into a distributed hypertable.

## Reproduce "tuple concurrently deleted" error
The error manifests on the insert operation immediately following marking a data node unavailable, but only when certain conditions are met.  The first condition is that there must be a larger number of unique values in the partition column (500 in this case).  The second is that there must be at least two separate clients attempting to insert into a distributed hypertable immediately after the data node is marked unavailable.

### Run Test
```
./run-test.sh tuple
```

## Reproduce Deadlock
Reproducing this error involves a similar setup to reproducing the previous error except in this case a lower number of unique values are used for the partition key (20 is used in the test).

NOTE: This reproduction is more inconsistent, but does happen in the majority of runs.

### Run Test
```
./run-test.sh deadlock
```

## Test Overview
The test will do the following
* Create a Timescale cluster with 1 access node and 4 data nodes
* Create a distributed hypertable with timestamp, value, dev_id (the partition column)
* Insert data into it
* Stop data node 4 (dn4)
* Mark the data node as unavailable using the alter_data_node function
* Launch two processes each attempting to insert data into the table
* Error will manifest depending on how many unique dev_ids are used

NOTE: The processes are inserting non-overlapping values for the partition column