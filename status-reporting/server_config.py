# server_config.py
import os

# Remote servers and commands to gather information
servers = {
    'ONYX-0186': {
        'address': 'sintela@ONYX-0186',
        'commands': [
            'df -H',
            'ls /mnt/extSSD1/ManualRecorders/decimator | tail'
        ]
    },
    'ONYX-0204': {
        'address': 'sintela@ONYX-0204',
        'commands': [
            'df -H /mnt/extSSD1 /mnt/extSSD2 /mnt/extSSD3',
            'ls /mnt/extSSD1/rainier | tail',
            'ls /mnt/extSSD2/rainier | tail',
            'ls /mnt/extSSD3/rainier | tail'
        ]
    },
    'DASSRV056': {
        'address': 'operator@DASSRV056',
        'commands': [
            'curl http://10.158.15.97:10532/optodas/api/v2/status',
            'df -H',
            'ls /mnt/usb'
        ]
    }
}

# Retrieve environment variables
passwords = {
    'ONYX-0186': os.getenv('PASSWORD_ONYX_0186'),
    'ONYX-0204': os.getenv('PASSWORD_ONYX_0204'),
    'DASSRV056': os.getenv('PASSWORD_DASSRV056')
}

