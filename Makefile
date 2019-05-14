APP_PORT := $(or ${APP_PORT},${APP_PORT},5000)
APP_HOST := $(or ${APP_HOST},${APP_HOST},0.0.0.0)
PYTHONPATH := $(or ${PYTHONPATH},${PYTHONPATH},.)


.PHONY: test
test:
	@echo -n "Run tests"
#	venv/bin/alembic downgrade base
#	venv/bin/alembic upgrade head
	flake8 application app.py && \
		py.test -svvv -rs -x

.PHONY: run-local
run-local:
	@echo -n "Run server locally"
	python app.py

.PHONY: run-prod
run-prod:
	@echo "Deploying to EKS"
	./deploy.sh prod

.PHONY: run-dev
run-dev:
	@echo -n "Run server for dev"
	docker-compose up -d

.PHONY: stop-dev
stop-dev:
	@echo -n "Run server for dev"
	docker-compose stop postgres server

.PHONY: help
help:
	@echo -n "Common make targets"
	@echo ":"
	@cat Makefile | sed -n '/^\.PHONY: / h; /\(^\t@*echo\|^\t:\)/ {H; x; /PHONY/ s/.PHONY: \(.*\)\n.*"\(.*\)"/  make \1\t\2/p; d; x}'| sort -k2,2 |expand -t 20
