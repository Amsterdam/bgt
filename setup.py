from distutils.core import setup
import sys
from setuptools.command.test import test as test_command


class PyTest(test_command):
    user_options = [('pytest-args=', 'a', "Arguments to pass to pytest")]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.pytest_args = []

    def run_tests(self):
        import shlex
        # import here, cause outside the eggs aren't loaded
        import pytest
        errno = pytest.main(shlex.split(self.pytest_args))
        sys.exit(errno)


setup(
    name='datapunt-bgt',
    version='0.1.0',
    author='Datapunt',
    author_email='datapunt.ois@amsterdam.nl',
    package_dir={'': 'src'},
    packages=['fme'],
    scripts=[],
    url='https://github.com/DatapuntAmsterdam/bgt',
    license='LICENSE.rst',
    description="Datapunt BGT transformaties in FME-cloud",
    long_description=open('README.rst').read(),
    install_requires=[
        'requests',
        'psycopg2',
        'python_swiftclient',
        'python-keystoneclient'
    ],
    tests_require=[
        'pytest',
        'pytest-mock',
        'requests-mock',
    ],
    extras_require={
        'doc': [
            'Sphinx',
            'sphinx-rtd-theme',
            'sphinx-autobuild'
        ]
    },
    # setup_requires=[],
    python_requires='=~3.5',
    entry_points={
        'console_scripts': [
            'fme_run = fme.core',
        ],
    },
)

# requests==2.11.1
# pytest==3.0.2
# pytest-mock==0.4.3
# requests-mock==1.1.0
# psycopg2==2.6.2
# python_swiftclient==3.2.0
# python-keystoneclient
# Sphinx
# sphinx-rtd-theme
# sphinx-autobuild
