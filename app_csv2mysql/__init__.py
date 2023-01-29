"""
Default Azure Function Boilerplate
"""
import datetime
import logging

import azure.functions as func
from .main import Main


# =============================================================================
def main(mytimer: func.TimerRequest) -> None:
    """
    Azure Function Main Method

    Args:
        mytimer (func.TimerRequest): _description_
    """
    utc_timestamp = datetime.datetime.utcnow().replace(
        tzinfo=datetime.timezone.utc).isoformat()

    if mytimer.past_due:
        logging.info('The timer is past due!')

    MyMain = Main()
    MyMain.hello('World')

    logging.info('Python timer trigger function ran at %s', utc_timestamp)
