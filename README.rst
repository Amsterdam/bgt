.. reference this page as :ref:`index` (from which it's included)

Basiskaart Grootschalige Topografie
===================================

.. highlight:: bash


Development environment
-----------------------

Dit project maakt gebruik van Python3. Enige wenken om van start te gaan::

    # Virtual environment maken op je eigen lievelingsmanier.
    # PvB doet altijd:
    python3 -m venv --copies --prompt "`basename "$PWD"`" .venv

    # Dependencies installeren, ook voor documentatie:
    pip install -e .[doc]

    # Statische documentatie builden in ./docs/_build/html/:
    make -C docs html

    # Documentatie-server starten op http://localhost:8000/:
    make -C docs server

    # Voor meer documentatie-opties:
    make -C docs

    # Runnen van de transformaties:
    run_fme

Dit laatste commando wordt door ``setuptools`` gemaakt. Zie :file:`setup.py`.

Installatie van psycopg2 op OSX sierra::

    LDFLAGS="-I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib" \
        pip install psycopg2

.. todo::

    @thijs Kan dit niet weg? Het is heel specifiek voor ``homebrew`` gebruikers
    die hun homebrew-openssl versie niet standaard in hun LDFLAGS hebben staan.


Docker development
------------------

Om de applicatie te starten vanuit Docker::

    docker-compose build
    docker-compose run importer

