import os.path

DEBUG = os.getenv('DEBUG', False) == '1'
SCRIPT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app'))

if os.getenv('TEST', False) == '1':
    FME_SERVER_API = 'secret'
    FME_API =  'secret'
    FME_SERVER =  'secret'
    INSTANCE_ID = 'secret'
    FME_DBPASS =  'secret'
else:
    FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
    FME_API = os.getenv('FMEAPI', 'secret')
    FME_SERVER = os.getenv('FMESERVER', 'secret')
    INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
    FME_DBPASS = os.getenv('FMEDBPASS', 'secret')
