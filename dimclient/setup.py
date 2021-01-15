from setuptools import setup
from dimclient import version

setup(name='dimclient',
      version=version.VERSION,
      install_requires=['simplejson'],
      packages=['dimclient'])
