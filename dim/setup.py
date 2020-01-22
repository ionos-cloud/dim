from distutils.core import setup
import versioneer

setup(name='dim',
      version=versioneer.get_version(),
      cmdclass=versioneer.get_cmdclass(),
      packages=['dim', 'dim.models'],
      package_data={'dim': ['sql/*.sql']},
      scripts=['report', 'manage_dim', 'manage_db'])
