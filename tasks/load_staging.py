import getopt
import json
import sys
from abc import ABC
from datetime import date

import luigi
from dateutil import parser
from luigi import DateParameter, Parameter
from luigi.contrib.postgres import CopyToTable


class LoadJsonBase(ABC, CopyToTable):
    date = DateParameter(default=date.today())
    file_path = Parameter()

    host = "localhost"
    database = "datawarehouse"
    user = "postgres"
    password = "postgres"

    columns = [
        ("date", "DATE"),
        ("json_content", "JSON"),
    ]


class LoadEvent(LoadJsonBase):
    table = "staging.event"

    def rows(self):
        with open(self.file_path) as f:
            data = json.load(f)

        yield from (
            (self.date, json.dumps(record))
            for record in data
            if parser.parse(record["received_at"]).date() == self.date
        )


class LoadOrg(LoadJsonBase):
    table = "staging.organization"

    def init_copy(self, connection):
        query_truncate = f"truncate {self.table}"
        query_delete = f"""delete from table_updates
                            where target_table='{self.table}'"""
        cursor = connection.cursor()
        try:
            cursor.execute(query_truncate)
            cursor.execute(query_delete)
        finally:
            cursor.close()

    def rows(self):
        with open(self.file_path) as f:
            data = json.load(f)

        yield from ((self.date, json.dumps(record)) for record in data)


if __name__ == "__main__":

    try:
        opts, _ = getopt.gnu_getopt(sys.argv[1:], "d:", ["date="])
    except getopt.GetoptError:
        print("Usage: load_staging.py [-d|--date] <YYYY-MM-DD>")
        raise

    execution_date = date.today()
    if opts[0][0] in ("-d", "--date"):
        execution_date = parser.parse(opts[0][1])

    luigi.build(
        [
            LoadOrg(
                date=execution_date,
                file_path="../data/orgs_sample.json",
            ),
            LoadEvent(
                date=execution_date,
                file_path="../data/events_sample.json",
            ),
        ]
    )
