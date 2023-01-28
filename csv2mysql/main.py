import logging
import pandas as pd
import requests
import sqlalchemy as sa

class Main():
    def __init__(self) -> None:
        pass
    
    def hello(self, name):
        logging.info(f'Hello, {name}!')
        print(f'Hello, {name}!')


if __name__ == "__main__":
    MyMain = Main()
    MyMain.hello('World')