import os

#############################
# Environment Variable Keys #
#############################

_DB_HOST_KEY = 'DB_HOST'
_DB_PORT_KEY = 'DB_PORT'
_DB_USER_KEY = 'DB_USER'
_DB_PASSWORD_KEY = 'DB_PASSWORD'
_DB_DATABASE_KEY = 'DB_DATABASE'
_DB_URI_KEY = 'DB_URI'

##################
# Default Values #
##################

_DEFAULT_DB_HOST = 'localhost'
_DEFAULT_DB_PORT = 5432
_DEFAULT_DB_USER = 'postgres'
_DEFAULT_DB_PASSWORD = 'postgres'
_DEFAULT_DB_DATABASE = 'postgres'


############
# DbConfig #
############

class DbConfig:
    uri: str
    
    def __init__(self):
        # Try to get the URI from the environment, if it exists use it
        uri = os.getenv(_DB_URI_KEY)
        if uri is not None: 
            self.uri = uri
            return

        # If no URI is given, build one from the other environment variables or defaults
        host = os.getenv(_DB_HOST_KEY, 'localhost')
        port = os.getenv(_DB_PORT_KEY, 5432)
        user = os.getenv(_DB_USER_KEY, 'postgres')
        password = os.getenv(_DB_PASSWORD_KEY, 'postgres')
        database = os.getenv(_DB_DATABASE_KEY, 'postgres')
        self.uri = f'postgresql://{user}:{password}@{host}:{port}/{database}'