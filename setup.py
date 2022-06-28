'''Package configuration'''

import codecs
import os

from setuptools import find_packages, setup

README = '''
java-patterns
=================
Java Design Patterns Documentation
Links
-----
* Documentation: https://alexander-rogalsky.gitbook.io/java-patterns
* Releases: https://github.com/AlexRogalskiy/java-patterns/releases
* Code: https://github.com/AlexRogalskiy/java-patterns
* Issue tracker: https://github.com/AlexRogalskiy/java-patterns/issues
'''

here = os.path.abspath(os.path.dirname(__file__))

def _strip(line):
    return line.split(" ")[0].split("#")[0].split(",")[0]

def read_file(path):
    with codecs.open(os.path.join(here, path), "r", encoding="utf-8") as f:
        return f.read()

def read_requirements(path):
    with codecs.open(os.path.join(here, 'requirements', path), "r", encoding="utf-8") as f:
        return list(f)

long_description = '\n' + read_file("README.md")
install_requirements = '\n' + read_requirements('base.in')
## install_requirements = _strip(line) for line in read_file('base.in')

setup_requires = ['setuptools', 'wheel']

setup(
    name='java-patterns',
    version=open('VERSION').read().replace('-', '.dev', 1).strip(),
    description='Java Design Patterns Documentation',
    author='Alexander Rogalskiy',
    author_email='hi@sensiblemetrics.io',
    url='https://github.com/AlexRogalskiy/java-patterns',
    include_package_data=True,
    packages=find_packages(exclude=['tests']),
    install_requires=install_requirements,
##    install_requires=[
##        _strip(line) for line in codecs.open(os.path.join('requirements', 'base.in'), "r", encoding="utf-8")
##    ],
    setup_requires=setup_requires,
    python_requires='~=3.9',
    license='GPL-3.0',
    zip_safe=False,
    keywords=['java', 'design', 'patterns'],
    long_description_content_type='text/markdown',
    long_description=long_description,
    project_urls={
            'Bug Reports': 'https://github.com/AlexRogalskiy/java-patterns/issues',
            'Read the Docs': 'https://alexander-rogalsky.gitbook.io/java-patterns',
        },
    classifiers=[
        'Development Status :: Production/Stable',
        'Intended Audience :: Developers',
        'Operating System :: POSIX :: Linux',
        'Operating System :: MacOS :: MacOS X',
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: GPL-3.0 License',
        'License :: OSI Approved :: GNU General Public License v3 or later (GPLv2+)',
        'Natural Language :: English',
        'Topic :: Utilities',
    ],
)
