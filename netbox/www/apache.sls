# -*- coding: utf-8 -*-
# vim: ft=sls


{%- from tpldir ~ "/../map.jinja" import netbox with context %}
{% set tplroot = tpldir.split('/')[0] if not salt.pillar.get('netbox:tplroot_overwrite', False) else salt.pillar.get('netbox:tplroot_overwrite', False) %}

include:
  - ..service

netbox_install_apache:
  pkg.installed:
    - pkgs:
      - {{ netbox.webserver.apache.pkg }}

netbox_service_apache_running:
  service.running:
    - name: {{ netbox.webserver.apache.service }}
    - enable: true
    - require:
      - pkg: netbox_install_apache
    - watch:
      - file: netbox_configure_apache_vhost
      - pkg: netbox_install_apache_modules
      - apache_site: enable_apache_site_netbox

netbox_install_apache_modules:
  pkg.installed:
    - pkgs:
      {% for pkg in netbox.webserver.apache.dependencies -%}
      - {{ pkg }}
      {% endfor %}

netbox_enable_apache_modules:
  apache_module.enabled:
    - names:
      {% for module in netbox.webserver.apache.modules -%}
      - {{ module }}
      {% endfor %}
    - watch_in:
      - service: netbox_service_apache_running
    - require: 
      - pkg: netbox_install_apache
      - pkg: netbox_install_apache_modules

netbox_configure_apache_vhost:
  file.managed:
  - name: {{ netbox.webserver.apache.sites_available }}/netbox.conf
  - source: salt://{{ tplroot }}/files/apache-config
  - context:
    tpldir: {{ tpldir }}
  - template: jinja
  - mode: 644
  - require:
    - pkg: netbox_install_apache
    - pkg: netbox_install_apache_modules
    - apache_module: netbox_enable_apache_modules

enable_apache_site_netbox:
  apache_site.enabled:
    - name: netbox
    - require:
      - file: netbox_configure_apache_vhost
