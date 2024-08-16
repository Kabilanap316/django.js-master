BASEDIR=$(CURDIR)
DOCDIR=$(BASEDIR)/doc
DISTDIR=$(BASEDIR)/dist
PACKAGE='djangojs'
suite=$(or $(subst :, ,$(tests)), $(PACKAGE))

help:
	@echo 'Makefile for Django.js                                               '
	@echo '                                                                     '
	@echo 'Usage:                                                               '
	@echo '   make serve            Run the test server                         '
	@echo '   make test             Run the test suite                          '
	@echo '   make coverage         Run a caoverage report from the test suite  '
	@echo '   make pep8             Run the PEP8 report                         '
	@echo '   make pylint           Run the pylint report                       '
	@echo '   make doc              Generate the documentation                  '
	@echo '   make minify           Minify all JS files with yuglify            '
	@echo '   make dist             Generate a distributable package            '
	@echo '   make clean            Remove all temporary and generated artifacts'
	@echo '                                                                     '


serve:
	@echo 'Running test server'
	@python manage.py runserver

test:
	@echo 'Running test suite'
	@python manage.py test $(suite)

coverage:
	@echo 'Running test suite with coverage'
	@coverage erase
	@coverage run --rcfile=coverage.rc manage.py test $(suite)
	@echo
	@coverage report --rcfile=coverage.rc

pep8:
	@pep8 $(PACKAGE) --config=pep8.rc
	@echo 'PEP8: OK'

pylint:
	@pylint --reports=n --rcfile=pylint.rc $(PACKAGE)

doc:
	@echo 'Generating documentation'
	@cd $(DOCDIR) && make html
	@echo 'Done'

dist: minify
	@echo 'Generating a distributable python package'
	@python setup.py sdist
	@echo 'Done'

minify:
	@echo 'Minifying javascript'
	@yuglify djangojs/static/js/djangojs/django.js

clean:
	rm -fr $(DISTDIR)

.PHONY: doc help clean test dist release
