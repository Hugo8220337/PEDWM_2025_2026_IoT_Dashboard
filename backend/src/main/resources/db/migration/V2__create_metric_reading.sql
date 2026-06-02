CREATE TABLE metric_reading (
    id        UUID             PRIMARY KEY,
    sensor_id UUID             NOT NULL REFERENCES sensor(id),
    timestamp TIMESTAMPTZ      NOT NULL,
    value     DOUBLE PRECISION NOT NULL
);

CREATE INDEX idx_metric_reading_sensor_time ON metric_reading (sensor_id, timestamp DESC);
