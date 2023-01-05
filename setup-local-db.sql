-- Connect access node to data nodes
CREATE EXTENSION IF NOT EXISTS timescaledb;
SELECT add_data_node('dn1', host => 'tsdb-data1');
SELECT add_data_node('dn2', host => 'tsdb-data2');
SELECT add_data_node('dn3', host => 'tsdb-data3');
SELECT add_data_node('dn4', host => 'tsdb-data4');

CREATE TABLE metric1 (ts TIMESTAMPTZ NOT NULL, val FLOAT8 NOT NULL, dev_id INT4 NOT NULL);
SELECT create_distributed_hypertable('metric1', 'ts', 'dev_id', chunk_time_interval => INTERVAL '1 hour', replication_factor => 3);
