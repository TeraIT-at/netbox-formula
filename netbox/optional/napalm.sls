# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/map.jinja" import netbox with context %}

include:
  - ..service

install_napalm:
  pip.installed:
    - name: napalm
    - user: {{ netbox.service.user }}
    - cwd: {{ netbox.service.homedir }}
    - bin_env: {{ netbox.service.homedir }}/venv
    - ignore_installed: true
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv