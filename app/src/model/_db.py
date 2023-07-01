from psycopg_pool import ConnectionPool

from config.db import DbConfig


__pool = None

def get_conn_pool() -> ConnectionPool:
    """Get the current connection pool for the database. If one does not exist, create it.

    Returns:
        ConnectionPool: The connection pool for the database.
    """
    
    global __pool
    
    if __pool is None:
        init_conn_pool()
    
    return __pool

def init_conn_pool():
    """Initialize the connection pool for the database.
    """
    
    global __pool
    
    if __pool is None:
        config = DbConfig()
        __pool = ConnectionPool(config.uri)


def close_conn_pool():
    """Close the connection pool for the database.
    """
    
    global __pool
    
    if __pool is not None:
        __pool.close()
        __pool = None
