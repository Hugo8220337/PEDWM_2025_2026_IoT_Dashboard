CREATE TABLE sensor (
    id            UUID        PRIMARY KEY,
    group_id      TEXT        NOT NULL,
    node_id       TEXT        NOT NULL,
    sensor_name   TEXT        NOT NULL,
    variable_name TEXT        NOT NULL,
    data_type     TEXT        NOT NULL,
    discovered_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_sensor UNIQUE (group_id, node_id, sensor_name, variable_name)
);
-- 