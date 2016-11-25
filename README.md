# bgt
Basiskaart Grootschalige Topografie


## Python development

Dit project maakt gebruik van Python 3. 

```
cd src
pip install -r requirements.txt
python fme/core.py 
```

## Docker development

Om de applicatie te starten vanuit Docker.

    docker-compose build
    docker-compose run importer
    
## installatie van psycopg2 op OSX sierra

    env LDFLAGS="-I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib" pip install psycopg2
