from consumer_base import Consumer

from config import channel, db_config, file_config

if __name__ == "__main__":
    for config in file_config:
        if config["table_name"] == "staging.organization":
            database_info = db_config
            database_info["table_name"] = config["table_name"]

            Consumer(database_info, config["sort_key"], config["queue_name"], channel)
