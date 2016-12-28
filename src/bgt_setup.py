import os.path

DEBUG = os.getenv('DEBUG', False) == '1'
SCRIPT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app'))
SCRIPT_SRC = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src'))

BGT_OBJECTSTORE_PASSWORD = os.getenv('BGT_OBJECTSTORE_PASSWORD', 'insecure')

FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
FME_API = os.getenv('FMEAPI', 'secret')
FME_SERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
FME_DBPASS = os.getenv('FMEDBPASS', 'secret')

BGT_DBPASS = os.getenv('DB_PASSWORD', 'insecure')

BGT_USER = os.getenv('BGT_DATABASE_BGT_1_ENV_POSTGRES_USER', 'basiskaart')
BGT_HOST = os.getenv('DATABASE_BGT_1_PORT_5432_TCP_ADDR', 'localhost')
BGT_DBNAME = os.getenv('DATABASE_BGT_1_ENV_POSTGRES_DB', 'bgt')
BGT_PW = os.getenv('DATABASE_BGT_1_ENV_POSTGRES_PASSWORD', 'insecure')
BGT_PORT = os.getenv('DATABASE_BGT_1_PORT_5432_TCP_PORT', '5402')


DB_FME_HOST = os.getenv('DATABASE_FME_1_PORT_5432_TCP_ADDR', 'localhost')
DB_FME_DBNAME = os.getenv('DATABASE_FME_1_ENV_POSTGRES_DB', 'gisdb')
DB_FME_PW = os.getenv('DATABASE_FME_1_ENV_POSTGRES_PASSWORD', 'insecure')
DB_FME_PORT = os.getenv('DATABASE_FME_1_PORT_5432_TCP_PORT', '5401')
DB_FME_USER = os.getenv('BGT_DATABASE_FME_1_ENV_POSTGRES_USER', 'dbuser')

