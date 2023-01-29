"""
Module docstring
"""

# standard imports
import json
import logging
import os
from io import StringIO

# third-party libraries
import pandas as pd
import requests
import sqlalchemy as sa


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
        logging.info("Creating table in MySQL")

        dataframe.to_sql(
            name=tablename,
            con=connection,
            if_exists='replace',
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

        sql_url = sa.engine.url.URL(
            drivername="mysql+pymysql",
            username=_creds['username'],
            password=_creds['password'],
            host=_creds['hostname'],
            database=database,
            port=3306,
            query={"ssl_ca" : f"{path}/ssl-certs/DigiCertGlobalRootCA.crt.pem"}
        )
        engine = sa.create_engine(sql_url)
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
