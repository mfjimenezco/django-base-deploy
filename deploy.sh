#!/bin/bash

# Replace <...> for your variables

cd ~/<repository-folder>/ ; git pull
source ~/.venv/bin/activate ; pip3 install -r ~/<repository-folder>/requirements/test.txt ; deactivate
source ~/.bashrc ; source ~/.venv/bin/activate ; python ~/<repository-folder>/<main-app-folder>/manage.py migrate ; deactivate
source ~/.bashrc ; source ~/.venv/bin/activate ; python ~/<repository-folder>/<main-app-folder>/manage.py collectstatic --noinput; deactivate
source ~/.bashrc ; source ~/.venv/bin/activate ; python ~/<repository-folder>/<main-app-folder>/manage.py compilemessages; deactivate
sudo /bin/systemctl restart <service-app>