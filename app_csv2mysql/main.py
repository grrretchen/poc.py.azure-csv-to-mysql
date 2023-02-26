"""
Module docstring
"""

# standard imports
import json
import logging
import os
import pyodbc
import urllib
from io import StringIO

# third-party libraries
import pandas as pd
import requests
import sqlalchemy as sa

# local imports


# =============================================================================
class Main():
    """
    Class docstring
    """
    def __init__(self) -> None:
        pass

    # -------------------------------------------------------------------------
    def main(self):
        """
        Main: Update a SQL table using data retrived from an URL

        - Retrieve a CSV from a remote location
        - Convert the CSV into a Pandas Dataframe
        - Create a connection to an Azure MySQL resource
        - Push the CSV data into Azure
        """
        csv = self.fetch_csv()
        dataframe = self.parse_csv_to_pandas(StringIO(csv))
        db_engine = self.make_db_engine(database='demo')
        self.push_csv_to_mysql(
            connection=db_engine,
            tablename="products",
            dataframe=dataframe
        )
        logging.info("Exiting.")

    # -------------------------------------------------------------------------
    def push_csv_to_mysql(self,connection,tablename,dataframe):
        """
        Method: Created table in MySQL using a Pandas dataframe.

        Args:
            connection (sqlalchemy engine): Initialized SQLAlchemy connection
            tablename (string): String of destination tablename
            dataframe (pandas dataframe): Pandas dataframe containing CSV data
        """
        sa_inspector = sa.inspect(connection)

        sql_key_field = 'Handle'
        sql_key_list = []

        if sa_inspector.has_table(tablename):
            _keys = pd.read_sql_table(
                table_name = tablename,
                con = connection,
                columns = [sql_key_field]
            )
            sql_key_list = pd.unique(_keys[sql_key_field].tolist())

        diff = dataframe[~dataframe[sql_key_field].isin(sql_key_list)]

        logging.info("Creating table in MySQL")

        diff.to_sql(
            name=tablename,
            con=connection,
            if_exists='append',
            index=False
            )

    # -------------------------------------------------------------------------
    def hello(self, name):
        """
        Method doscstring

        Args:
            name (string): Will be appended to 'Hello, '
        """
        output = f"Hello, {name}!"
        logging.info(output)
        print(output)

    # -------------------------------------------------------------------------
    def fetch_csv(self):
        """
        Retrieve CSV from URL

        Returns:
            string: Raw CSV response, or FALSE
        """
        logging.info("Retrieving CSV file")
        url = "https://raw.githubusercontent.com/shopifypartners/product-csvs/master/home-and-garden.csv"
        resp = fetch(url)
        if not resp:
            return False
        return resp

    # -------------------------------------------------------------------------
    def parse_csv_to_pandas(self,csv):
        """
        Method: Basic wrapper for Pandas

        Args:
            csv (_type_): _description_
        """
        logging.info("Parsing CSV file")

        df = pd.read_csv(csv)
        return df

    # -------------------------------------------------------------------------
    def make_db_engine(self,database):
        """
        Method: Create an engine for Azure MySQL

        Args:
            database (string): Name of the database for the connection

        Returns:
            engine: An SQLAlchemy Engine object
        """
        logging.info("Creating database connection")

        _creds = json.loads(os.environ['AZURE_DATABASE_CREDENTIALS'])

        path = os.path.dirname(os.path.abspath(__file__))

        sql = "azure"
        sql_url = None

        if sql=="mysql":
          # MYSQL
          sql_url = sa.engine.URL.create(
              drivername="mysql+pymysql",
              username=_creds['username'],
              password=_creds['password'],
              host=_creds['hostname'],
              database=database,
              port=3306,
              query={"ssl_ca" : f"{path}/ssl-certs/DigiCertGlobalRootCA.crt.pem"}
          ) 

        elif sql=="azure":
          params = urllib.parse.quote_plus(
            'Driver=%s;' % '{ODBC Driver 18 for SQL Server}' +
            'Server=tcp:%s,1433;' % _creds['hostname'] +
            'Database=%s;' % database +
            'Uid=%s;' % _creds['username'] +
            'Pwd=%s;' % _creds['password'] +
            'Encrypt=yes;' +
            'TrustServerCertificate=no;' +
            'Connection Timeout=%s;' % 30
          )
          sql_url = 'mssql+pyodbc:///?odbc_connect={}'.format(params)

        engine = sa.create_engine(sql_url, echo=True)

        return engine


# -----------------------------------------------------------------------------
def fetch(url, headers=None):
    """
    Method: Basic wrapper for Requests. Provides boilerplate for error processing.

    Args:
        url (string): _description_
        headers (dict, optional): Dictionary of HTTP headers. Defaults to {}.

    Returns:
        string: content of URL, or FALSE.
    """
    headers = {} if not headers else headers

    logging.info("Retrieving data from URL %s", url)
    resp = requests.get(url, headers=headers, timeout=60)

    return resp.text if resp.status_code == 200 else False


# =============================================================================
if __name__ == "__main__":
    MyMain = Main()
    MyMain.hello('World')
    MyMain.main()
