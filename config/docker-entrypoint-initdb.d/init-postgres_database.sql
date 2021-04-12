CREATE DATABASE datawarehouse;

CREATE SCHEMA
IF NOT EXISTS staging;
CREATE SCHEMA
IF NOT EXISTS historical;
CREATE SCHEMA
IF NOT EXISTS snapshots;
CREATE SCHEMA
IF NOT EXISTS dimensional;

CREATE TABLE staging."event"
(
    "date" date NULL,
    json_content json NULL
);

CREATE TABLE staging.organization
(
    "date" date NULL,
    json_content json NULL
);

GRANT ALL PRIVILEGES ON DATABASE datawarehouse TO postgres;
