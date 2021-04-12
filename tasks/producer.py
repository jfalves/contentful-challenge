import json

from config import channel, file_config


class Producer:
    def __init__(self, file_path, sort_key, queue_name, channel):
        self.file_path = file_path
        self.sort_key = sort_key
        self.queue_name = queue_name
        self.channel = channel

        self.data = self._sort_json_list()

    def _open_json(self):
        f = open(self.file_path, "r")
        return json.load(f)

    def _sort_json_list(self):
        data = self._open_json()

        return list(sorted(data, key=lambda item: item[config["sort_key"]]))

    def publish(self):
        self.channel.queue_declare(queue=self.queue_name)

        for record in self.data:
            channel.basic_publish(
                exchange="", routing_key=self.queue_name, body=json.dumps(record)
            )


if __name__ == "__main__":
    for config in file_config:
        p = Producer(
            config["file_path"], config["sort_key"], config["queue_name"], channel
        )
        p.publish()
