LUIGI_TASK_FOLDER := ./tasks
DBT_PROJECT_FOLDER := ./datawarehouse

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

setup-local:
	pip install pipenv
	pipenv install
	pipenv run pre-commit install
	docker-compose build

run-etl:
	$(call check_defined, DATE)
	cd ${LUIGI_TASK_FOLDER} && python3 load_staging.py -d ${DATE}
	cd ${DBT_PROJECT_FOLDER} && dbt run --m historical
	cd ${DBT_PROJECT_FOLDER} && dbt snapshot --vars '{"received_at": "${DATE}"}'
	cd ${DBT_PROJECT_FOLDER} && dbt run --m dimensional

clean:
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.dim_organization;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.dim_user;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.dim_user_event;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists dimensional.fac_user;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists snapshots.user_snapshot;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "drop table if exists historical.user_event;"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "delete from staging."event";"
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "delete from staging.organization;";
	docker exec contentful-challenge_database_1 psql -U postgres -d datawarehouse -c "delete from public.table_updates;";
