.. reference this page as :ref:`index` (from which it's included)

Basiskaart Grootschalige Topografie
===================================

.. highlight:: bash

FMEcloud
===================================
We maken gebuik van de FME cloud API en de FME instance API.
FMEcloud: https://api.fmecloud.safe.com/api_documentation/v1
FME instance API: https://docs.safe.com/fme/2016.1/html/FME_REST/v2/apidoc/
FME_BASE_URL is een variabel met de URL naar de FME instance.
Er wordt een Database "bgt" in de FME instance aangemaakt met bijbehoordde schema's, tabellen en views.
De transformatie vindplaats op de FME instance en alle producten, Esri_shape, csv, DGNv8 en worden op de BGT objectstore gedownload.

Het gebied dat periodiek wordt verwerkt is binnen de gegevensverzameling op te delen in:

    De landelijk verplichte verzameling van gegevens conform IMGEO: BGT
    De 'verplichte' verzameling gegevens aanvullend op BGT zoals gedefinieerd door de bronhouder Gemeente Amsterdam: BGT+
    De niet-verplichte en vooraf niet bekende verzameling van gegevens: IMGEO-rest



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

