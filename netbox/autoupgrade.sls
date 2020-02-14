# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/map.jinja" import netbox with context %}

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
    - onchanges_in:
      - upgrade_netbox_app

restart_netbox_app_after_upgrade:
{%- if netbox.service.supervisor == True %}
  supervisord.running:
    - name: netbox
    - restart: true
{%- endif %}
{%- if netbox.service.systemd == True %}
  service.running:
    - name: netbox
    - enable: true
{%- endif %}
    - require:
      - cmd: upgrade_netbox_app
    - onchanges:
      - git: latest_netbox_app
