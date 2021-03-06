TWINE_CONFIG_FILE ?= .pypirc

clean:
	rm -rf dist
check:
	flake8 --config .flake8
	isort -rc -c $(git ls-tree -r HEAD --name-only | grep "\.py")
build: clean check
	python setup.py sdist bdist_wheel

publish-check:
	@if [[ $$(git rev-parse --abbrev-ref HEAD) != "master" ]]; then \
		echo "error: not in master"; \
		exit 1; \
	fi; \

	@if [[ $$(git fetch | git rev-list HEAD...origin/master --count) -ne 0 ]]; then \
		echo "error: master not updated"; \
		exit 1; \
	fi; \

	git describe --exact-match HEAD

publish-pypi:
	twine check dist/*
	twine upload --config-file $(TWINE_CONFIG_FILE) --repository $(PYPI_REPOSITORY) dist/*

publish-test: PYPI_REPOSITORY=testpypi
publish-test: build publish-pypi
publish: PYPI_REPOSITORY=pypi
publish: build publish-check publish-pypi
	git push origin --tags

bump-major: PART = major
bump-minor: PART = minor
bump-patch: PART = patch

bump-major bump-minor bump-patch:
	bumpversion $(PART)

.PHONY: clean check build publish-check publish bump-major bump-minor bump-patch
