# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/../map.jinja" import netbox with context %}

include:
  - ..service

add_django-storages_requirement:
  file.blockreplace:
  - name: {{ netbox.service.homedir }}/app/local_requirements.txt
  - marker_start: "# -- django-storages start -- "
  - marker_end: "# -- django-storages end --"
  - append_if_not_found: True
  - content: "django-storages"
  - require:
    - git: clone_netbox_app
    - file: configure_netbox_local_requirements
  - onchanges_in:
      - cmd: upgrade_netbox_app