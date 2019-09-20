import os

DEBUG = os.getenv('DEBUG', False) == '1'
SCRIPT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app'))
SCRIPT_SRC = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src'))

BGT_OBJECTSTORE_PASSWORD = os.getenv('BGT_OBJECTSTORE_PASSWORD', 'insecure')

FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
FME_API = os.getenv('FMEAPI', 'secret')
FME_SERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
FME_DBPASS = os.getenv('FMEDBPASS', 'secret')

DB_FME_HOST = os.getenv('DATABASE_PORT_5432_TCP_ADDR', 'localhost')
DB_FME_DBNAME = os.getenv('DATABASE_ENV_POSTGRES_DB', 'gisdb')
DB_FME_PW = os.getenv('DATABASE_ENV_POSTGRES_PASSWORD', 'insecure')
DB_FME_PORT = os.getenv('DATABASE_PORT_5432_TCP_PORT', '5401')
DB_FME_USER = os.getenv('BGT_DATABASE_ENV_POSTGRES_USER', 'dbuser')

FME_TEST_RUN = os.getenv('FME_TEST_RUN', False)