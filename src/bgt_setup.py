import os.path

DEBUG = os.getenv('DEBUG', False) == '1'
SCRIPT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app'))
SCRIPT_SRC = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src'))

OBJECTSTORE_PASSWORD = os.getenv('OBJECTSTORE_PASSWORD', 'insecure')
BGT1_HOST = os.getenv('DATABASE_BGT1_1_PORT_5432_TCP_ADDR', 'localhost')
BGT2_HOST = os.getenv('DATABASE_BGT2_1_PORT_5432_TCP_ADDR', 'localhost')
BGT1_DBNAME = os.getenv('DATABASE_BGT1_1_ENV_POSTGRES_DB', 'gisdb')
BGT2_DBNAME = os.getenv('DATABASE_BGT2_1_ENV_POSTGRES_DB', 'bgt')
BGT1_PW = os.getenv('DATABASE_BGT1_1_ENV_POSTGRES_PASSWORD', 'insecure')
BGT2_PW = os.getenv('DATABASE_BGT2_1_ENV_POSTGRES_PASSWORD', 'insecure')
BGT1_PORT = os.getenv('DATABASE_BGT1_1_PORT_5432_TCP_PORT', '5401')
BGT2_PORT = os.getenv('DATABASE_BGT2_1_PORT_5432_TCP_PORT', '5402')
if os.getenv('TEST', False) == '1':
    FME_SERVER_API = 'secret'
    FME_API = 'secret'
    FME_SERVER = 'secret'
    INSTANCE_ID = 'secret'
    FME_DBPASS = 'secret'
    BGT_DBPASS = 'insecure'
    BGT2_USER = 'bgt'
    BGT2_PW = 'insecure'
else:
    FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
    FME_API = os.getenv('FMEAPI', 'secret')
    FME_SERVER = os.getenv('FMESERVER', 'secret')
    INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
    FME_DBPASS = os.getenv('FMEDBPASS', 'secret')
    BGT_DBPASS = os.getenv('DB_PASSWORD', 'insecure')
    BGT2_USER = os.getenv('BGT_DATABASE_BGT2_1_ENV_POSTGRES_USER', 'bgt')
    BGT2_PW = os.getenv('DATABASE_BGT2_1_ENV_POSTGRES_PASSWORD','insecure')

