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
    def hello(self, name):
        """
        Method doscstring

        Args:
            name (string): Will be appended to 'Hello, '
        """
        output = f"Hello, {name}!"
        logging.info(output)
        print(output)


# =============================================================================
if __name__ == "__main__":
    MyMain = Main()
    MyMain.hello('World')
    