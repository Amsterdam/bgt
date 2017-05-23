#!/usr/bin/env python3

from distutils.core import setup

setup(
    name='datapunt-bgt',
    version='0.1.0',
    author='Datapunt',
    author_email='datapunt.ois@amsterdam.nl',
    package_dir={
        '': 'src',
    },
    include_package_data=True,
    packages=['fme'],
    url='https://github.com/DatapuntAmsterdam/bgt',
    license='LICENSE.rst',
    description="Datapunt BGT transformaties in FME-cloud",
    long_description=open('README.rst').read(),
    # https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        'License :: OSI Approved :: Mozilla Public License 2.0 (MPL 2.0)',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3 :: Only',
        'Operating System :: POSIX',
    ],
    install_requires=[
        'requests',
        'psycopg2',
        'python_swiftclient',
        'python-keystoneclient'
    ],
    extras_require={
        'doc': [
            'Sphinx',
            'sphinx-rtd-theme',
            'sphinx-autobuild'
        ],
        'test': [
            'pytest',
            'pytest-cov',
            'pytest-mock',
            'requests-mock',
        ],
    },
    setup_requires=[
        'setuptools_git'
    ],
    python_requires='~=3.6',
    entry_points={
        'console_scripts': [
            'run_fme = fme.core',
        ],
    },
)
