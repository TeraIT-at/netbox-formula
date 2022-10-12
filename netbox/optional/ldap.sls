# -*- coding: utf-8 -*-
# vim: ft=sls

{% set tplroot = tpldir.split('/')[0] if not salt.pillar.get('netbox:tplroot_overwrite', False) else salt.pillar.get('netbox:tplroot_overwrite', False) %}
{%- from tplroot ~ "/map.jinja" import netbox with context %}

include:
  - ..service

install_ldap_dependencies:
  pkg.installed:
    - pkgs:
      {% for pkg in netbox.optional.ldap.package_dependencies -%}
      - {{ pkg }}
      {% endfor %}
    - require:
      - git: clone_netbox_app
      - file: configure_netbox_local_requirements

add_django_ldap_requirement:
  file.blockreplace:
  - name: {{ netbox.service.homedir }}/app/local_requirements.txt
  - marker_start: "# -- ldap start -- "
  - marker_end: "# -- ldap end --"
  - append_if_not_found: True
  - content: |
      {% for pkg in netbox.optional.ldap.python_dependencies -%}
          {{ pkg }}
      {% endfor %}
  - require:
    - git: clone_netbox_app
    - file: configure_netbox_local_requirements
    - pkg: install_ldap_dependencies
  - onchanges_in:
      - cmd: upgrade_netbox_app

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
  - watch_in:
      - service: netbox_app_service
