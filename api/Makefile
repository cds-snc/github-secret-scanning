dev:
	uvicorn main:app --reload --host 0.0.0.0 --port 8000

fmt:
	black . $(ARGS) --target-version py311

fmt-ci:
	black --check . --target-version py311

install:
	pip3 install --user -r requirements.txt

install-dev:
	pip3 install --user -r requirements_dev.txt

lint:
	flake8 .

lint-ci:
	flake8 .

test:
	coverage run -m pytest -s -vv tests &&\
	coverage report -m

.PHONY: \
	dev \
	fmt \
	fmt-ci \
	install \
	install-dev \
	lint \
	lint-ci \
	test
