'''Package configuration'''

import codecs
import os
from setuptools import setup, find_packages

VERSION = '1.0.1'

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

with open(os.path.join('requirements', 'base.in')) as fp:
    REQUIREMENTS = list(fp)

with codecs.open(os.path.join(here, 'README.md'), encoding='utf-8') as fh:
    long_description = '\n' + fh.read()

setup(
    name='java-patterns',
    version=VERSION,
    description='Java Design Patterns Documentation',
    author='Alexander Rogalskiy',
    author_email='hi@sensiblemetrics.io',
    url='https://github.com/AlexRogalskiy/java-patterns',
    include_package_data=True,
    packages=find_packages(exclude=['tests']),
    install_requires=REQUIREMENTS,
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
        'License :: OSI Approved :: GPL-3.0 License',
        'Natural Language :: English',
        'Topic :: Utilities',
    ],
    setup_requires=['setuptools', 'wheel'],
)
