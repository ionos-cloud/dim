from setuptools import setup

setup(name='ndcli',
      version='2.4.0',
      scripts=['ndcli'],
      install_requires=['dimclient>=0.4.1',
                        'python-dateutil',
                        'dnspython'],
      packages=['dimcli'])
