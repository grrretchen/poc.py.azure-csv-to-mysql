"""
Module docstring
"""

import logging
import pandas as pd
import requests
import sqlalchemy as sa

from io import StringIO

# =============================================================================
class Main():
    """
    Class docstring
    """
    def __init__(self) -> None:
        pass

    # -------------------------------------------------------------------------
    def main(self):
        csv = self.getCSV()
        print(csv)

        df = self.parseCsvToPandas(StringIO(csv))
        print(df)

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
    def getCSV(self):
        """
        Retrieve CSV from URL

        Returns:
            string: Raw CSV response, or FALSE
        """
        url = "https://raw.githubusercontent.com/shopifypartners/product-csvs/master/home-and-garden.csv"
        resp = fetch(url)
        if not resp:
            return False
        return resp

    # -------------------------------------------------------------------------
    def parseCsvToPandas(self,csv):
        """
        Method: Basic wrapper for Pandas

        Args:
            csv (_type_): _description_
        """
        df = pd.read_csv(csv)
        
        return df
        

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
