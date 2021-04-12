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
