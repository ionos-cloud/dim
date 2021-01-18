from setuptools import setup

setup(name='dim-bind-file-agent',
      version='0.1',
      scripts=['dim-bind-file-agent'],
      install_requires=['dimclient==0.2',
                        'argparse']
      )
