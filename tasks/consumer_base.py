import json

import psycopg2
from psycopg2.extras import Json


class Consumer:
    def __init__(self, database_info, sort_key, queue_name, channel):
        self.database_info = database_info
        self.sort_key = sort_key
        self.queue_name = queue_name
        self.channel = channel

        self.channel.basic_consume(
            queue=self.queue_name, auto_ack=True, on_message_callback=self.callback
        )

        self.channel.start_consuming()

    def _get_conn(self):
        return psycopg2.connect(
            user=self.database_info["user"],
            password=self.database_info["password"],
            host=self.database_info["host"],
            port=self.database_info["port"],
            database=self.database_info["database"],
        )

    def callback(self, channel, method, properties, body):
        conn = self._get_conn()
        curs = conn.cursor()

        postgres_insert_query = f"""INSERT INTO {self.database_info["table_name"]} (date, json_content) VALUES (%s,%s)"""

        json_content = json.loads(body)
        record_to_insert = (json_content[self.sort_key], Json(json_content))

        try:
            curs.execute(postgres_insert_query, record_to_insert)
            conn.commit()
        finally:
            conn.close()
