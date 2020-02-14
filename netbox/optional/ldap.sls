# -*- coding: utf-8 -*-
# vim: ft=sls

{% set tplroot = tpldir.split('/')[0] if not salt.pillar.get('netbox:tplroot_overwrite', False) else salt.pillar.get('netbox:tplroot_overwrite', False) %}
{%- from tpldir ~ "/../map.jinja" import netbox with context %}

include:
  - ..service

{%-if netbox.service.optional.ldap.enabled == True %}
install_django_ldap_netbox:
  pip.installed:
    - name: django-auth-ldap
    - user: {{ netbox.service.user }}
    - cwd: {{ netbox.service.homedir }}
    - bin_env: {{ netbox.service.homedir }}/venv
    - ignore_installed: true
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv
    - onchanges_in:
      - netbox_app_service

configure_netbox_ldap:
  file.managed:
  - name: {{ netbox.service.homedir }}/app/netbox/netbox/ldap_config.py
  - user: {{ netbox.service.user }}
  - group: {{ netbox.service.group }}
  - source: salt://{{ tplroot }}/files/ldap.config
  - template: jinja
  - context:
    tpldir: {{ tpldir }}
  - mode: 600
  - require:
    - git: clone_netbox_app
{%- endif %}