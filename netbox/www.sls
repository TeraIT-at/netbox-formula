{%- from tpldir ~ "/map.jinja" import netbox with context %}

include:
  - .service

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

netbox_configure_apache_vhost:
  file.managed:
  - name: {{ netbox.webserver.apache.sites_available }}/netbox.conf
  - source: salt://{{ tpldir }}/files/apache-config
  - context:
    tpldir: {{ tpldir }}
  - template: jinja
  - mode: 644
  - require:
    - pkg: netbox_install_apache

netbox_install_apache_modules:
  pkg.installed:
    - pkgs:
      {% for pkg in netbox.webserver.apache.dependencies -%}
      - {{ pkg }}
      {% endfor %}
    - watch_in:
      - service: netbox_service_apache_running


netbox_enable_apache_modules:
  apache_module.enabled:
    - names:
      - proxy
      - proxy_http
      - wsgi
    - watch_in:
      - service: netbox_service_apache_running

enable_apache_site_netbox:
  apache_site.enabled:
    - name: netbox
    - watch_in:
      - service: netbox_service_apache_running
    - require:
      - file: netbox_configure_apache_vhost
