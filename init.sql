CREATE CATALOG sales_catalog WITH (
  'type'                 = 'iceberg',
  'catalog-impl'         = 'org.apache.iceberg.rest.RESTCatalog',
  'uri'                  = 'http://iceberg-rest:8181',
  'warehouse'            = 's3://warehouse/',
  'io-impl'              = 'org.apache.iceberg.aws.s3.S3FileIO',
  's3.endpoint'          = 'http://minio:9000',
  's3.access-key-id'     = 'admin',
  's3.secret-access-key' = 'password',
  's3.path-style-access' = 'true'
);

CREATE DATABASE IF NOT EXISTS sales_catalog.sales;



CREATE TABLE sales_raw (
    country STRING,
    quantity INT,
    city STRING,
    latitude DOUBLE,
    last_name STRING,
    product_name STRING,
    price DOUBLE,
    product_id STRING,
    customer_id STRING,
    category STRING,
    order_id STRING,
    first_name STRING,
    email STRING,
    `timestamp` BIGINT,
    longitude DOUBLE
) WITH (
    'connector' = 'kafka',
    'topic' = 'sales-raw',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'sales-consumer',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);




CREATE TABLE sales_catalog.sales.orders (
    country STRING,
    quantity INT,
    city STRING,
    latitude DOUBLE,
    last_name STRING,
    product_name STRING,
    price DOUBLE,
    product_id STRING,
    customer_id STRING,
    category STRING,
    order_id STRING,
    first_name STRING,
    email STRING,
    event_time TIMESTAMP(3),
    longitude DOUBLE
)
PARTITIONED BY (category);



SET 'execution.checkpointing.interval' = '30s';

INSERT INTO sales_catalog.sales.orders
SELECT
    country,
    quantity,
    city,
    latitude,
    last_name,
    product_name,
    price,
    product_id,
    customer_id,
    category,
    order_id,
    first_name,
    email,
    TO_TIMESTAMP_LTZ(`timestamp`, 3),
    longitude
FROM sales_raw;