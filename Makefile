TASK_FOLDER := ./tasks
DBT_PROJECT_FOLDER := ./datawarehouse

setup-local:
	pip install pipenv
	pipenv install
	pipenv run pre-commit install
	docker-compose build

run-etl:
	cd ${TASK_FOLDER} && python3 consumer_event.py&
	cd ${TASK_FOLDER} && python3 consumer_organization.py&
	cd ${TASK_FOLDER} && python3 producer.py&

	cd ${DBT_PROJECT_FOLDER} && dbt run --m historical
	cd ${DBT_PROJECT_FOLDER} && dbt snapshot
	cd ${DBT_PROJECT_FOLDER} && dbt run --m dimensional
