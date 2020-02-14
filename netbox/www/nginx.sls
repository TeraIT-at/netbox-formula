# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/../map.jinja" import netbox with context %}
{% set tplroot = tpldir.split('/')[0] if not salt.pillar.get('netbox:tplroot_overwrite', False) else salt.pillar.get('netbox:tplroot_overwrite', False) %}

include:
  - ..service

netbox_install_nginx:
  pkg.installed:
    - pkgs:
      - {{ netbox.webserver.nginx.pkg }}

netbox_service_nginx_running:
  service.running:
    - name: {{ netbox.webserver.nginx.service }}
    - enable: true
    - require:
      - pkg: netbox_install_nginx

netbox_configure_nginx_vhost:
  file.managed:
  - name: {{ netbox.webserver.nginx.sites_available }}/netbox.conf
  - source: salt://{{ tplroot }}/files/nginx-config
  - context:
    tpldir: {{ tpldir }}
  - template: jinja
  - mode: 644
  - require:
    - pkg: netbox_install_nginx
  - watch_in:
    - service: netbox_service_nginx_running


enable_nginx_site_netbox:
  file.symlink:
    - name: {{ netbox.webserver.nginx.sites_enabled }}/netbox.conf
    - target: {{ netbox.webserver.nginx.sites_available }}/netbox.conf
    - watch_in:
      - service: netbox_service_nginx_running
    - require:
      - file: netbox_configure_nginx_vhost
