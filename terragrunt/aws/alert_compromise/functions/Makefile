fmt:
	black .

install_dev:
	pip3 install --user -r requirements_dev.txt

lint:
	flake8 broadcast_alert.py

test:
	python -m pytest -s -vv broadcast_alert_tests.py

.PHONY: \
	fmt \
	install_dev	\
	lint \
	test
