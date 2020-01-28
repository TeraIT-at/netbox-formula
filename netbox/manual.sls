# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import netbox with context %}

# state.sls_id state_id sls_path
setup_netbox_load_initial_data:
  cmd.run:
    - name: ". ../../venv/bin/activate && python manage.py loaddata initial_data"
    - cwd: {{ netbox.service.homedir }}/app/netbox/
    - runas: {{ netbox.service.user }}

setup_netbox_create_superuser:
  cmd.run:
    - name: '. ../bin/activate../../venv/bin/activate && echo "from django.contrib.auth.models import User;
                                  User.objects.create_superuser(\"{{ salt['pillar.get']('services:netbox:superuser') }}\",\"{{ salt['pillar.get']('services:netbox:superuser_mail') }}\", \"{{ salt['pillar.get']('services:netbox:superuser_password') }}\")" | python manage.py shell'
    - cwd: {{ netbox.service.homedir }}/app/netbox/
    - runas: {{ netbox.service.user }}
