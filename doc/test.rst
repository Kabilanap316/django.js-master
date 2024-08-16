Javascript test tools
=====================

Django.js provide tools for easy javascript testing.

Views
-----
Django.js provides base views for javascript testing.
Instead of writing a full view each time you need a Jasmine or a QUnit test view, simply use the provided ``JasmineView`` and ``QUnitView`` and add them to your test_urls.py:


.. code-block:: python

    from django.conf.urls import patterns, url, include

    from djangojs.views import JasmineView, QUnitView

    urlpatterns = patterns('',
        url(r'^jasmine$', JasmineView.as_view(js_files='js/specs/*.specs.js'), name='my_jasmine_view'),
        url(r'^qunit$', QUnitView.as_view(js_files='js/tests/*.tests.js'), name='my_qunit_view'),
    )

Both view have a js_files attribute which can be a string or and array of strings.
Each string can be a static js file path to include or a glob pattern:

.. code-block:: python

    from djangojs.views import JasmineView

    class MyJasmineView(JasmineView):
        js_files = (
            'js/lib/my-lib.js',
            'js/test/*.specs.js',
            'js/other/specs.*.js',
        )

.. note:: Files order matters and will be preserved.

jQuery can automatically be included into the view by setting the ``jquery`` attribute to ``True``:

.. code-block:: python

    from djangojs.views import JasmineView

    class MyJasmineView(JasmineView):
        jquery = True
        js_files = 'js/test/*.specs.js'

Django.js can automatically be included into the view by setting the ``django_js`` attribute to ``True``:

.. code-block:: python

    from djangojs.views import JasmineView

    class MyJasmineView(JasmineView):
        django_js = True
        js_files = 'js/test/*.specs.js'


These views extends the Django ``TemplateView`` so you can add extra context entries and you can customize the template by extending them.

.. code-block:: python

    from djangojs.views import QUnitView

    class MyQUnitView(QUnitView):
        js_files = 'js/test/*.test.js'
        template_name = 'my-qunit-runner.html'

        def get_context_data(self, **kwargs):
            context = super(MyQUnitView, self).get_context_data(**kwargs)
            context['form'] = TestForm()
            return context


Two extensible test runner templates are provided:

- ``djangojs/jasmine-runner.html`` for jasmine tests
- ``djangojs/qunit-runner.html`` for QUnit tests

Both provides a ``js_init`` block, a ``js_content`` block and a ``body_content`` block.

.. code-block:: html+django

    {% extends "djangojs/qunit-runner.html" %}

    {% block js_init %}
        {{ block.super }}
        {% js "js/init.js" %}
    {% endblock %}

    {% block js_content %}
        {% load js %}
        {% js "js/tests/my.tests.js" %}
    {% endblock %}

    {% block body_content %}
      <form id="test-form" action="{% url test_form %}" method="POST" style="display: none;">
        {{csrf_token}}
        {{form}}
      </form>
    {% endblock %}

You can inspect django.js own test suites on github.

If you just need the Django.js comptible runners, you can include the following templates (depending on your framework):

- QUnit:
    - ``djangojs/qunit-runner-head.html``
    - ``djangojs/qunit-runner-body.html``
- Jasmine:
    - ``djangojs/jasmine-runner-head.html``
    - ``djangojs/jasmine-runner-body.html``


Test cases
----------

A Phantom.js test runner parsing TAP is provided in 3 flavours:

    - ``JsTestCase`` that runs javascript tests against Django liveserver TestCase.
    - ``JsFileTestCase`` that runs javascript tests against a static html file
    - ``JsTemplateTestCase`` that runs javascript tests against a rendered html file (but without liveserver running)

.. note::

    Whatever TestCase you choose, it should output TAP.
    If you don't have complex and specific needs, you just have to use the provided template and extends them if needed.

Jasmine/QUnit support are provided with ``JasmineSuite`` and ``QUnitSuite`` mixins.

To use it with the previously defined views, just define either ``url_name`` or ``filename`` attribute:

.. code-block:: python

    from djangojs.runners import JsTestCase, JsFileTestCase, JsTemplateTestCase
    from djangojs.runners import JasmineSuite, QUnitSuite


    class JasminTests(JasmineSuite, JsTestCase):
        urls = 'myapp.test_urls'
        title = 'My Jasmine suite'
        url_name = 'my_url_name'


    class QUnitTests(QunitSuite, JsFileTestCase):
        filename = '/tmp/my-runner.html'


    class JasminTests(JasmineSuite, JsTemplateTestCase):
        template_name = 'my/template.html'
        js_files = 'js/test/other/*.js'


The verbosity is automatically adjusted with the ``-v/--verbosity`` parameter from the ``manage.py test`` command line.


.. warning::

    Phantom.js is required to use this feature and should be on your ``$PATH``.
