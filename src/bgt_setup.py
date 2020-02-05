import os

DEBUG = os.getenv('DEBUG', False) == '1'
SCRIPT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app'))
SCRIPT_SRC = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src'))

BGT_OBJECTSTORE_PASSWORD = os.getenv('BGT_OBJECTSTORE_PASSWORD', 'insecure')

GOB_OBJECTSTORE_PASSWORD = os.getenv('GOB_OBJECTSTORE_PASSWORD', 'insecure')
GOB_OBJECTSTORE_USER = os.getenv('GOB_OBJECTSTORE_USER', 'user')
GOB_OBJECTSTORE_TENANT_NAME = os.getenv('GOB_OBJECTSTORE_TENANT_NAME', 'tenant_name')
GOB_OBJECTSTORE_TENANT_ID = os.getenv('GOB_OBJECTSTORE_TENANT_ID', 'tenant_id')

GOB_OBJECTSTORE_CONTAINER = 'productie'

FME_CLOUD_API_TOKEN = os.getenv('FMESERVERAPI', 'secret')
FME_INSTANCE_API_TOKEN = os.getenv('FMEAPI', 'secret')
FME_BASE_URL = os.getenv('FMESERVER', 'secret')
FME_INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
FME_DBPASS = os.getenv('FMEDBPASS', 'secret')

DB_FME_HOST = os.getenv('DATABASE_PORT_5432_TCP_ADDR', 'localhost')
DB_FME_DBNAME = os.getenv('DATABASE_ENV_POSTGRES_DB', 'bgt')
DB_FME_PW = os.getenv('DATABASE_ENV_POSTGRES_PASSWORD', 'insecure')
DB_FME_PORT = os.getenv('DATABASE_PORT_5432_TCP_PORT', '5401')
DB_FME_USER = os.getenv('BGT_DATABASE_ENV_POSTGRES_USER', 'dbuser')

FME_TEST_RUN = os.getenv('FME_TEST_RUN', False) == '1'

OBJECTSTORES = {
    'BGT': {
        'auth_version': '2.0',
        'authurl': 'https://identity.stack.cloudvps.com/v2.0',
        'user': 'basiskaart',
        'key': BGT_OBJECTSTORE_PASSWORD,
        'tenant_name': 'BGE000081_BGT',
        'os_options': {
            'tenant_id': '1776010a62684386a08b094d89ce08d9',
            'region_name': 'NL',
        }
    },
    'GOB': {
        'auth_version': '2.0',
        'authurl': 'https://identity.stack.cloudvps.com/v2.0',
        'user': GOB_OBJECTSTORE_USER,
        'key': GOB_OBJECTSTORE_PASSWORD,
        'tenant_name': GOB_OBJECTSTORE_TENANT_NAME,
        'os_options': {
            'tenant_id': GOB_OBJECTSTORE_TENANT_ID,
            'region_name': 'NL',
        }
    }
}