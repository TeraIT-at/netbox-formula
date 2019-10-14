# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/map.jinja" import netbox with context %}

include:
  - .service

latest_netbox_app:
  git.latest:
    - name: {{ netbox.repository.url }}
    - branch: {{ netbox.repository.branch }}
    - target: {{ netbox.service.homedir }}
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
    - cwd: {{ netbox.service.homedir }}
    - runas: {{ netbox.service.user }}
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv
    - onchanges:
      - git: latest_netbox_app

restart_netbox_app_after_upgrade:
  supervisord.running:
    - name: netbox
    - restart: true
    - require:
      - cmd: upgrade_netbox_app
    - onchanges:
      - git: latest_netbox_app
