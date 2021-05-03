import setuptools
import os


thelibFolder = os.path.dirname(os.path.realpath(__file__))
requirementPath = thelibFolder + '/requirements.txt'
install_requires = []

with open("README.md", 'r') as f:
    long_description = f.read()

if os.path.isfile(requirementPath):
    with open(requirementPath) as f:
        install_requires = f.read().splitlines()

setuptools.setup(
   name='txt2actr',
   version='0.1.0',
   description='A python library for using ACT-R through text specification',
   license='',
classifiers=[
    'Development Status :: 3 - Alpha',
    'Intended Audience :: ACT-R Modellers',
    'Topic :: Software Development :: Build Tools',
    'Programming Language :: Python :: 3.8',
    ],
   long_description=long_description,
   author='',
   author_email='',
   url='https://github.com/eadietz/txt2actr',
   #packages=['digital-operator'],  #same as name
   packages=setuptools.find_packages(),
   python_requires='>=3.8.3',
   install_requires=['pandas','http://act-r.psy.cmu.edu/actr7.x/mac_standalone.zip'],
   # dependency_links does not work and it seems that external links should not be handled py setuptools
   dependency_links=['http://act-r.psy.cmu.edu/actr7.x/mac_standalone.zip'],
    entry_points={
        'console_scripts': ['run-model=run_simulation']
    }
)
