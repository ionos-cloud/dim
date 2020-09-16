from setuptools import setup
import codecs
import os

def read(rel_path):
    here = os.path.abspath(os.path.dirname(__file__))
    # intentionally *not* adding an encoding option to open, See:
    #   https://github.com/pypa/virtualenv/issues/201#issuecomment-3145690
    with codecs.open(os.path.join(here, rel_path), 'r') as fp:
        return fp.read()


def get_version(rel_path):
    for line in read(rel_path).splitlines():
        if line.startswith('__version__'):
            # __version__ = "0.9"
            delim = '"' if '"' in line else "'"
            return line.split(delim)[1]
    raise RuntimeError("Unable to find version string.")

setup(name='ndcli',
      version=get_version('dimcli/__init__.py'),
      scripts=['ndcli'],
      install_requires=['dimclient>=0.4.1',
                        'python-dateutil',
                        'dnspython'],
      packages=['dimcli'])
