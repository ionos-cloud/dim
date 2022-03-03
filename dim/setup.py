from distutils.core import setup
from dim import version

setup(name='dim',
      version=version.VERSION,
      packages=['dim', 'dim.models'],
      package_data={'dim': ['sql/*.sql']},
      scripts=['report', 'manage_db', 'manage_dim'])
