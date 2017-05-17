Basiskaart Grootschalige Topografie
===================================


Python development
------------------

Dit project maakt gebruik van Python 3.

.. code-block:: bash

    cd src
    pip install -r requirements.txt
    export PYTHONPATH=`pwd`
    python fme/core.py


Docker development
------------------

Om de applicatie te starten vanuit Docker.

.. code-block:: bash

    docker-compose build
    docker-compose run importer


Installatie van psycopg2 op OSX sierra
--------------------------------------

.. code-block:: bash

    LDFLAGS="-I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib" \
        pip install psycopg2
