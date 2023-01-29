# pylint: disable=C0103,E1101
"""
Default Azure Function Boilerplate
"""
# standard imports
import datetime
import logging

# third party libraries
import azure.functions as func

# local imports
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
    MyMain.main()

    logging.info('Python timer trigger function ran at %s', utc_timestamp)
