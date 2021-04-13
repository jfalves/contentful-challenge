TASK_FOLDER := ./tasks
DBT_PROJECT_FOLDER := ./datawarehouse

setup-local:
	pip install pipenv
	pipenv install
	pipenv run pre-commit install
	docker-compose build

run-etl:
	make clean
	cd ${TASK_FOLDER} && python3 consumer_event.py&
	cd ${TASK_FOLDER} && python3 consumer_organization.py&
	cd ${TASK_FOLDER} && python3 producer.py&

	cd ${DBT_PROJECT_FOLDER} && dbt run --m historical
	cd ${DBT_PROJECT_FOLDER} && dbt snapshot
	cd ${DBT_PROJECT_FOLDER} && dbt run --m dimensional

clean:
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.dim_organization;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.dim_user;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.dim_user_event;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.fac_user;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists snapshots.user_snapshot;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists historical.user_event;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "delete from staging."event";"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "delete from staging.organization";
