# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import netbox with context %}

install_postgres:
  pkg.installed:
    - pkgs:
      {% for pkg in netbox.database_dependencies -%}
      - {{ pkg }}
      {% endfor %}

service_postgresql_running:
  service.running:
    - name: {{ netbox.database.service }}
    - enable: true
    - require:
      - pkg: install_postgres

setup_netbox_db_1:
  postgres_user.present:
    - name: {{ netbox.database.username }}
    - password: {{ netbox.database.password }}
    - refresh_password: True
    - require:
      - service: service_postgresql_running

setup_netbox_db_2:
  postgres_database.present:
    - name: {{ netbox.database.db_name }}
    - owner: {{ netbox.database.username }}
    - require:
      - postgres_user: setup_netbox_db_1
