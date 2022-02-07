# django-base-deploy
Deploy Base Django Project.

## Artifacts

### `gunicorn_start`
Application execution script through Gunicorn (production server).

### `django_app.service`
Ubuntu Service for execute Gunicorn Script.

### `django_app_nginx`
Nginx configuration to make application available through port 80 and serve static and media files.

### `deploy.sh`
Script to deploy the application from a remote Git repository.

## Requirements

- A linux (Ubuntu) Server with superuser rights.
- Port 80 available.

## Instructions to deploy

1. As a good practice update and upgrade the OS:
   `sudo apt-get update`
   `sudo apt-get upgrade`
2. Install required packages:
   `sudo apt-get install python3 python3-pip python3-dev git nginx gettext`
3. Install VIRTUALENV for python:
   `sudo pip3 install virtualenv`
4. Create a group account for web applications:
   `sudo groupadd --system webapps`
5. Create a specific user for app and add it to the group created in last step:
   `sudo useradd --system --gid webapps --shell /bin/bash --home /webapps/<app_name> <user_name>`
6. Create home folder for app user:
   `sudo mkdir -p /webapps/<app_name>/`
7. Make app user owner of home folder:
   `sudo chown <user_name> /webapps/<app_name>/`
8. Become app user:
   `sudo su - <user_name>`
9.  Make sure to be in app home folder with `pwd` command. If that is not the case, go there:
   `cd ~`
11. Clone repository: (for example: [Django AdminLTE base project](https://github.com/mfjimenezco/django-adminlte-base) or project with the same structure) 
   `git clone --branch <branch_name> https://github.com/mfjimenezco/django-adminlte-base.git`
12. Set app environment variables in app user shell, in `~/.bashrc` file:
   ```bash
   ...
   # Django app environment variables
   export DJANGO_SETTINGS_MODULE="mainapp.settings.production" # or .test
   export DJANGO_D_APP_SECRET_KEY="<django-secure-key>"
   export DJANGO_D_APP_ALLOWED_HOSTS="<ip-or-url-allowed-host>"
   export DJANGO_D_APP_DEBUG="False"
   export DJANGO_D_APP_ADMIN_URL="<django-admin-url>" # for example "admin/"
   # Internationalization
   export DJANGO_D_APP_TIME_ZONE="<app-time-zone>" # for example "America/Bogota"
   # Database
   export DJANGO_D_APP_DB_ENGINE="<db-engine>"
   export DJANGO_D_APP_DB_NAME="<db-name>"
   export DJANGO_D_APP_DB_USER="<db-user>"
   export DJANGO_D_APP_DB_PASSWORD="<db-password>"
   export DJANGO_D_APP_DB_HOST="<db-host>"
   export DJANGO_D_APP_DB_PORT="<db-port>"
   # Email sender
   export DJANGO_D_APP_EMAIL_BACKEND="<email-backend>"
   export DJANGO_D_APP_EMAIL_HOST="<email-host>"
   export DJANGO_D_APP_EMAIL_USE_TLS="<email-use-tls>" # True or False
   export DJANGO_D_APP_EMAIL_PORT="<email-port>"
   export DJANGO_D_APP_EMAIL_USER="<email-user>"
   export DJANGO_D_APP_EMAIL_PASSWORD="<email-password>" # or token
   ...
   ```
13. Create virtual environment:
    `virtualenv -p $(which python3) .venv`
14. Run a sanity check at this point.
    1.  Activate virtual environment:
        `source .venv/bin/activate`
    2.  Go to repository folder, for example:
        `cd django-adminlte-base/`
    3. Install project requirements:
        `pip install -r requirements/production.txt` or `pip install -r requirements/test.txt`
    4.  Go to django project folder, for example:
        `cd mainapp/`
    5.  Load environment variables:
        `source ~/.bashrc`
    6.  Migrate data structure to test app and connection to database:
        `python manage.py migrate`
    7.  Create django super user:
        `python manage.py createsuperuser`
    8.  Run django server:
        `python manage.py runserver 0.0.0.0:<available-port>`
    9.  If last command don't generate error, then everything is ok. (Quit the server with [CTRL+C])
15. Go to app home folder:
    `cd ~`
16. Make folder for Gunicorn script:
    `mkdir bin`
17. Customize Gunicorn script file (available in this repository: `gunicorn_start`) and insert it in folder created.
18. Make the script executable:
    `chmod +x ~/bin/gunicorn_start`
19. Test `gunicorn_start` script:
    `./bin/gunicorn_start`
20. If last command don't generate error, then everything is ok. (Quit the server with [CTRL+C])
21. Login as super user:
    `sudo su -`
22. Customize service file for the app (available in this repository: `django_app.service`) and insert it in `/etc/systemd/system/` folder.
    > You can change file name to describe your app.
23. Start the service created:
    `systemctl start django_app`
24. Go to Nginx's folder:
    `cd /etc/nginx/`
25. Remove default config files:
    `rm sites-*/default`
26. Customize Nginx config file for the app (available in this repository: `django_app_nginx`) and insert it in `/etc/nginx/sites-available/` folder.
    > You can change file name to describe your app.
27. Create a symbolic link of app in `/sites-available/` folder:
    `ln -s /etc/nginx/sites-available/django_app_nginx /etc/nginx/sites-enabled/`
28. Restart Nginx service:
    `service nginx restart`
29. Test your app in *IP or URL of application host*.
    > At this point your application should work but without styles.
30. Add the following line in `/etc/sudoers.d/90-cloud-init-users` file. (need superuser rights)
    ```
    ...
    <user-name> ALL=NOPASSWD: /bin/systemctl restart <service-app>
    ...
    ```
31. Customize Deploy Script for the app (available in this repository: `deploy.sh`) and insert it in app user home folder.
32. Make Deploy Script executable:
    `chmod 774 ~/deploy.sh`
33. Run Deploy Script:
    `./deploy.sh`

## Used versions

- Ubuntu 18.04.1 LTS (GNU/Linux 4.15.0-1021-aws x86_64)
- Python3 3.6.7-1~18.04
- Python3 Dev 3.6.7-1~18.04
- Pyhton3 PIP 9.0.1-2.3~ubuntu1.18.04.5
- Git 1:2.17.1-1ubuntu0.9
- Nginx 1.14.0-0ubuntu1.9
