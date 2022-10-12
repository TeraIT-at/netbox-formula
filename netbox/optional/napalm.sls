# -*- coding: utf-8 -*-
# vim: ft=sls

{% set tplroot = tpldir.split('/')[0] if not salt.pillar.get('netbox:tplroot_overwrite', False) else salt.pillar.get('netbox:tplroot_overwrite', False) %}
{%- from tplroot ~ "/map.jinja" import netbox with context %}

include:
  - ..service

add_napalm_requirement:
  file.blockreplace:
  - name: {{ netbox.service.homedir }}/app/local_requirements.txt
  - marker_start: "# -- napalm start -- "
  - marker_end: "# -- napalm end --"
  - append_if_not_found: True
  - content: "napalm"
  - require:
    - git: clone_netbox_app
    - file: configure_netbox_local_requirements
  - onchanges_in:
      - cmd: upgrade_netbox_app
