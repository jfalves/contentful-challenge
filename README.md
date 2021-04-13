#### Setup
This project assumes user has `docker`, `python pip` and gnu `make` installed and configured.

1. `make setup-local` to setup python packages and docker images.
2. `pipenv shell` to enter virtualenv.
3. `docker-compose up -d` to start docker services.
3. `make run-etl DATE=<YYYY-MM-DD>` to execute an etl run for a given date.

Optionally user can clean database data using `make clean` command.

#### Architecute description
It was decided to use [luigi](https://luigi.readthedocs.io/en/stable/) as a data processing framework/orchestration over [airflow](https://airflow.apache.org/) because airflow is more appropriate for complex flows.
Also, it was used Postgres as storage by it's capability of processing JSON document and for being SQL compliant. In the database processing it was used [dbt](https://docs.getdbt.com/) for it's capability of modularize sql and also for providing data materialization strategies such as snapshots, tables and views.

From perspective of ETL is very simple, [load_staging.py](/tasks/load_staging.py) encapsulates two classes that corresponds in luigi to tasks, one for each file. These tasks are responsible for inserting data into staging layer of database, implementing different strategies. For example, [orgs_sample.json](/data/orgs_sample.json) file is loaded completly every time whilst [events_sample.json](/data/events_sample.json) is loaded in pieces, filtered by date parameter.

![ETL diagram](/docs/etl_architecture.svg)

#### Database design
Datawarehouse was divided into layers (schemas) each one indicating different responsabilities.
First, we have a **staging layer**, it's the first point of contact of the external source inside database. Basically, it contains two tables staging.event and staging.organization, both modelled with two columns (date, json_content).
Second, we have a **historical layer**, that creates a normalised table containing all the different status of an event. This layer, in this challenge, is only applicable to event data. Based a on this layer we have **snapshots layer**, which creates a snapshot of data, this facilitates the creation of SCD type 2.
Lastly, we have a **dimensional layer**, containing all dimensional models which are dim_user, dim_organization and fac_user.

![database diagram](/docs/database_architecure.svg)

#### Endpoints

- Luigi - https://localhost:8082

#### Some remarks

- I was very satisfied with this approach despite not entirely enjoying doing etl with luigi. At the same time, I missed a framework to work with, that's why I used luigi.
- All data is being materialized as a table, but this isn't sustainable for the future as data increases. I would approach this problem by changing to an incremental strategy.
- I didn't implement the integration test using docker-compose, I never thought of doing integration test using docker and I wish I had time to do it.
- It was my first experience using DBT and I definitely love it.
