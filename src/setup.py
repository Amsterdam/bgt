import os
import os.path

DEBUG = os.getenv('DEBUG', False) == '1'
FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
FME_API = os.getenv('FMEAPI', 'secret')
FME_SERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
FME_DBPASS = os.getenv('FMEDBPASS', 'secret')
SCRIPT_ROOT = os.path.join(os.path.dirname(__file__), '..', 'app')
