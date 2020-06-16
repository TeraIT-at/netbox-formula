# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/map.jinja" import netbox with context %}

include:
  - .service

install_redis:
  pkg.installed:
    - name: {{ netbox.redis.package_name }}
    - enable: True
    - restart: True
    - require_in:
      - file: configure_netbox

{% if netbox.redis.bind|length -%}
bind_redis:
  file.blockreplace:
  - name: {{ netbox.redis.config }}
  - marker_start: "# BEGIN managed-by-salt netbox-formula"
  - marker_end: "# END managed-by-salt netbox-formula"
  - append_if_not_found: True
  - show_changes: True
  - backup: ".bak"
  - content: "bind {{ netbox.redis.bind }}"
  - watch_in:
    - service: service_redis_running
{%- endif %}

service_redis_running:
    service.running:
    - name: {{ netbox.redis.service_name }}
    - enable: true
    - require:
      - pkg: install_redis
    - require_in:
      - file: configure_netbox