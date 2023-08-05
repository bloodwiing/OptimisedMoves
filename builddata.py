from os import environ
import json


with open('_metadata', 'r') as file:
    metadata = json.load(file)

    # Automatically read the name from metadata
    MOD_NAME = metadata['name']
    # Make the MOD_SUFFIX match the version (example: ".1.2.4")
    MOD_SUFFIX = '.' + metadata['version']

YOMIH_PATH = environ.get('YOMIH_PATH')
