# import urllib
# from sqlalchemy import create_engine

from dataclasses import dataclass
from typing import Dict, Any, Iterable
# from pandas import DataFrame
from sqlalchemy import create_engine, inspect
import urllib

# from .db_azure_sql import AzureDbConnection as AzDB
from db_azure_sql import DatabaseConnection as AzDB

CREDS = {
    "username" : "myadmin",
    "password" : "my:d3m0@p@ssw0rd",
    "hostname" : "scraperdbzecgn33sde264.database.windows.net",
    "database" : "demo",
    "driver" : "{ODBC Driver 18 for SQL Server}",
    "timeout" : 30
}


def sample1():
  timeout = CREDS['timeout']
  driver = CREDS['driver']
  server = CREDS['hostname']
  database = CREDS['database']
  username = CREDS['username']
  password = CREDS['password']

  conn = f"""Driver={driver};Server=tcp:{server},1433;Database={database};
  Uid={username};Pwd={password};Encrypt=yes;TrustServerCertificate=no;Connection Timeout={timeout};"""

  params = urllib.parse.quote_plus(conn)
  conn_str = 'mssql+pyodbc:///?autocommit=true&odbc_connect={}'.format(params)
  engine = create_engine(conn_str, echo=True)
  engine.execute("SELECT 1")

@dataclass(frozen=True)
class ConnectionSettings:
    """Connection Settings."""
    server: str
    database: str
    username: str
    password: str
    driver: str = '{ODBC Driver 18 for SQL Server}'
    timeout: int = 30

conn_settings = ConnectionSettings(
    server = CREDS['hostname'],
    database = CREDS['database'],
    username = CREDS['username'],
    password = CREDS['password']
)

class AzureDbConnection:
    """
    Azure SQL database connection.
    """
    def __init__(self, conn_settings: ConnectionSettings, echo: bool = False) -> None:
        conn_params = urllib.parse.quote_plus(
            'Driver=%s;' % conn_settings.driver +
            'Server=tcp:%s,1433;' % conn_settings.server +
            'Database=%s;' % conn_settings.database +
            'Uid=%s;' % conn_settings.username +
            'Pwd=%s;' % conn_settings.password +
            'Encrypt=yes;' +
            'TrustServerCertificate=no;' +
            'Connection Timeout=%s;' % conn_settings.timeout
        )
        conn_string = f'mssql+pyodbc:///?odbc_connect={conn_params}'

        self.db = create_engine(conn_string, echo=echo)

    def connect(self) -> None:
        """Estimate connection."""
        self.conn = self.db.connect()

    def get_tables(self) -> Iterable[str]:
        """Get list of tables."""
        inspector = inspect(self.db)
        return [t for t in inspector.get_table_names()]
    
    def test(self):
        self.db.execute("SELECT 1")


    def dispose(self) -> None:
        """Dispose opened connections."""
        self.conn.close()
        self.db.dispose()

sample1()

MyAzSql = AzDB(
    conn_settings,
    echo=True
    )

MyAzSql.connect()
MyAzSql.test()
t = MyAzSql.get_tables()
print(t)
