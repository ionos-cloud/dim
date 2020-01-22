import copy
import logging
import threading


class Messages(list):
    '''
    Manages a list of messages for the current transaction.

    The implementation uses a thread-local list of messages that will be cleared
    at the start of each transaction.
    '''
    DEBUG = 10
    INFO = 20
    RECORD = 25
    WARNING = 30
    ERROR = 40
    LEVEL_NAME = {DEBUG: 'DEBUG',
                  INFO: 'INFO',
                  RECORD: 'RECORD',
                  WARNING: 'WARNING',
                  ERROR: 'ERROR'}
    _tlocal = threading.local()

    @staticmethod
    def _add(level, message):
        logging.log(logging.INFO, Messages.LEVEL_NAME[level][0] + ': ' + message)
        Messages._tlocal.messages.append((level, message))

    @staticmethod
    def info(message):
        Messages._add(Messages.INFO, message)

    @staticmethod
    def warn(message):
        Messages._add(Messages.WARNING, message)

    @staticmethod
    def error(message):
        Messages._add(Messages.ERROR, message)

    @staticmethod
    def record(message):
        Messages._add(Messages.RECORD, message)

    @staticmethod
    def clear():
        Messages._tlocal.messages = []
        Messages._tlocal.saved_messages = []

    @staticmethod
    def get():
        return Messages._tlocal.messages

    @staticmethod
    def save():
        '''Save a copy of the current message list'''
        Messages._tlocal.saved_messages = copy.copy(Messages._tlocal.messages)

    @staticmethod
    def restore():
        '''Overwrite the current message list with the contents of the save()d message list'''
        Messages._tlocal.messages = copy.copy(Messages._tlocal.saved_messages)
