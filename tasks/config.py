import pika

file_config = [
    {
        "file_path": "../data/events_sample.json",
        "sort_key": "received_at",
        "queue_name": "event",
        "table_name": "staging.event",
    },
    {
        "file_path": "../data/orgs_sample.json",
        "sort_key": "created_at",
        "queue_name": "organization",
        "table_name": "staging.organization",
    },
]

db_config = {
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432",
    "database": "datawarehouse",
}

connection = pika.BlockingConnection(pika.ConnectionParameters("localhost"))
channel = connection.channel()
