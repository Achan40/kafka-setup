from setuptools import setup, find_packages

setup(
    name="hello-world",
    version="0.1.0",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "hello-world=hello_world.main:main",
        ],
    },
)