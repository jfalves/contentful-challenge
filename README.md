#### Setup
This project assumes user has `docker`, `python pip` and gnu `make` installed and configured.

1. `make setup-local` to setup python packages and docker images.
2. `pipenv shell` to enter virtualenv.
3. `docker-compose up -d` to start docker services.
3. `make run-etl` to execute an etl run.

#### Architecute description
It was decided to use [pika](https://pika.readthedocs.io/en/stable/) to abstract communitation with [rabbitmq](https://www.rabbitmq.com/).
Also it was used Postgres as storage by it's capability of process JSON document and for being SQL compliant. In the database processing it was used [dbt](https://docs.getdbt.com/) for it's capability of modularize sql and also for providing data materialization strategies such as snapshots, tables and views.

From the perspective of ETL, there are two main classes [Producer](/tasks/producer.py) and [Consumer](/tasks/consumer_base.py), which respectively means, one being responsible to read json file putting it on a queue and read queue inserting it on database. In order to implement specifics of consumer it was implemented using a base class and two childs, each class for each table.

![ETL diagram](/docs/etl_architecture.svg)

#### Database design
Datawarehouse was divided into layers (schemas) each one indicating different responsabilities.
First, we have a **staging layer**, it's the first point of contact of the external source inside database. Basically, it contains two tables staging.event and staging.organization, both modelled with two columns (date, json_content).
Second, we have a **historical layer**, that creates a normalised table containing all the different status of an event. This layer, in this challenge, is only applicable to event data. Based a on this layer we have **snapshots layer**, which creates a snapshot of data, this facilitates the creation of SCD type 2.
Lastly, we have a **dimensional layer**, containing all dimensional models which are dim_user, dim_organization and fac_user.

![database diagram](/docs/database_architecure.svg)

#### Endpoints

- Rabbitmq - https://localhost:15672

#### Some remarks
- All data is being loaded before database can process sqls which doesn't make sense, in my opinion each event should trigger database processing. Also, on a event based architecture, load should be idempotent which is not the case of my approach, I would definitely change that.
- All data is being materialized as a table, but this isn't sustainable for the future as data increases. I would approach this problem by changing to an incremental strategy.
- I didn't implement the integration test using docker-compose, I never thought of doing integration test using docker and I wish I had time to do it.
- It was my first time using event based architecure, it was very exciting and I learned a lot.
