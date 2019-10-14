{%- from tpldir ~ "/map.jinja" import netbox with context %}

include:
  - .service

netbox_install_apache:
  pkg.installed:
    - pkgs:
      - apache2

netbox_service_apache_running:
  service.running:
    - name: apache2
    - enable: true
    - require:
      - pkg: netbox_install_apache

netbox_configure_apache_vhost:
  file.managed:
  - name: /etc/apache2/sites-available/netbox.conf
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
      - libapache2-mod-wsgi
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
