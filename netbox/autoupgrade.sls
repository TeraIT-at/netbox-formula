# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import netbox with context %}

include:
  - .service

latest_netbox_app:
  git.latest:
    - name: {{ netbox.repository.url }}
    - branch: {{ netbox.repository.branch }}
    - target: {{ netbox.service.homedir }}/app
    - user: {{ netbox.service.user }}
    - force_clone: true
    - force_reset: true
    - require:
      - user: create_netbox_user
      - group: create_netbox_group
      - file: create_netbox_dir

upgrade_netbox_app:
  cmd.run:
    - name: "./upgrade.sh"
    - cwd: {{ netbox.service.homedir }}/app
    - runas: {{ netbox.service.user }}
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv
    - onchanges:
      - git: latest_netbox_app

collect_static_files_netbox:
  cmd.run:
    - name: ". ../../venv/bin/activate && python manage.py collectstatic --no-input"
    - cwd: {{ netbox.service.homedir }}/app/netbox/
    - runas: {{ netbox.service.user }}
    - onchanges:
      - git: latest_netbox_app

restart_netbox_app_after_upgrade:
{%-if netbox.service.supervisor == True %}
  supervisord.running:
    - name: netbox
    - restart: true
{%- endif -%}
  service.running:
    - name: netbox
    - enable: true
{%-if netbox.service.systemd == True %}
    - require:
      - cmd: upgrade_netbox_app
    - onchanges:
      - git: latest_netbox_app
