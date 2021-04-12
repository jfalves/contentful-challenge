CREATE DATABASE datawarehouse;

CREATE SCHEMA
IF NOT EXISTS staging;
CREATE SCHEMA
IF NOT EXISTS historical;
CREATE SCHEMA
IF NOT EXISTS snapshots;
CREATE SCHEMA
IF NOT EXISTS dimensional;

GRANT ALL PRIVILEGES ON DATABASE datawarehouse TO postgres;
