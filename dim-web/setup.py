from setuptools import setup
import glob
import os
from cas import version

# python can't handle the fact, that data_files might contain directories.
# So we have to split off every directory into its own data_files statement
# with all its files just to make this work.
data_files = []
data_files.append(('share/dim-web', []))
data_files.append(('share/dim-web/www', []))
for dir in list(filter(lambda x: os.path.isdir(x), sorted(set(
        ['www'] + \
        glob.glob('www/**', recursive=True))))):
    data_files.append((os.path.join('share/dim-web', dir), list(filter(
        lambda x: not os.path.isdir(x),
        sorted(glob.glob(os.path.join(dir, '*')))))))

setup(name='dim-web',
      packages=['cas'],
      data_files = data_files,
      version=version.VERSION)
