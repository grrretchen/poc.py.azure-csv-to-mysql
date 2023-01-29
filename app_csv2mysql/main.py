"""
Module docstring
"""

import logging
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
        csv = self.getCSV()
        print(csv)

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


# -----------------------------------------------------------------------------
def fetch(url,headers={}):
    """
    Method: Basic wrapper for Requests. Provides boilerplate for error processing.

    Args:
        url (string): _description_
        headers (dict, optional): Dictionary of HTTP headers. Defaults to {}.

    Returns:
        string: content of URL, or FALSE.
    """
    logging.info('Retrieving data from URL %s'%url)
    resp = requests.get(url,headers=headers)
    if not resp.status_code==200:
        return False
    return resp.text
    
# =============================================================================
if __name__ == "__main__":
    MyMain = Main()
    MyMain.hello('World')
    MyMain.main()
