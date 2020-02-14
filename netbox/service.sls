# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tpldir ~ "/map.jinja" import netbox with context %}

install_netbox_dependencies:
  pkg.installed:
    - pkgs:
      {% for pkg in netbox.service_dependencies -%}
      - {{ pkg }}
      {% endfor %}

create_netbox_group:
  group.present:
    - name: {{ netbox.service.group }}

create_netbox_user:
  user.present:
    - name: {{ netbox.service.user }}
    - home: {{ netbox.service.homedir }}
    - shell: /usr/sbin/nologin
    - groups:
      - {{ netbox.service.group }}
    - require:
      - group: create_netbox_group

create_netbox_dir:
  file.directory:
    - name: {{ netbox.service.homedir }}
    - user: {{ netbox.service.user }}
    - group: {{ netbox.service.group }}
    - context:
      tpldir: {{ tpldir }}
    - recurse:
      - mode
      - user
      - group
    - require:
      - pkg: install_netbox_dependencies
      - user: create_netbox_user
      - group: create_netbox_group

clone_netbox_app:
  git.cloned:
    - name: {{ netbox.repository.url }}
    - branch: {{ netbox.repository.branch }}
    - target: {{ netbox.service.homedir }}/app/
    - user: {{ netbox.service.user }}
    - require:
      - user: create_netbox_user
      - group: create_netbox_group
      - file: create_netbox_dir

setup_netbox_virtualenv:
  virtualenv.managed:
    - name: {{ netbox.service.homedir }}/venv/
    - requirements: {{ netbox.service.homedir }}/app/requirements.txt
    - user: {{ netbox.service.user }}
    - cwd: {{ netbox.service.homedir }}/
    - pip_upgrade: True
    - python: python3
    - require:
      - git: clone_netbox_app

configure_netbox:
  file.managed:
  - name: {{ netbox.service.homedir }}/app/netbox/netbox/configuration.py
  - user: {{ netbox.service.user }}
  - group: {{ netbox.service.group }}
  - source: salt://{{ tpldir }}/files/netbox.config
  - template: jinja
  - context:
    tpldir: {{ tpldir }}
  - mode: 600
  - require:
    - git: clone_netbox_app

upgrade_netbox_app:
  cmd.run:
    - name: "./upgrade.sh"
    - cwd: {{ netbox.service.homedir }}/app
    - runas: {{ netbox.service.user }}
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv
    - onchanges:
      - git: clone_netbox_app

collect_static_files_netbox:
  cmd.run:
    - name: ". ../../venv/bin/activate && python manage.py collectstatic --no-input"
    - cwd: {{ netbox.service.homedir }}/app/netbox/
    - runas: {{ netbox.service.user }}
    - onchanges:
      - git: clone_netbox_app

setup_netbox_link_graphviz_to_venv:
  file.symlink:
    - name: {{ netbox.service.homedir }}/venv/bin/dot
    - target: /usr/bin/dot
    - user: {{ netbox.service.user }}
    - group: {{ netbox.service.group }}
    - require:
        - configure_netbox
        - setup_netbox_virtualenv
        - install_netbox_dependencies
    
install_gunicorn_netbox:
  pip.installed:
    - name: gunicorn
    - user: {{ netbox.service.user }}
    - cwd: {{ netbox.service.homedir }}
    - bin_env: {{ netbox.service.homedir }}/venv
    - ignore_installed: true
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv

{%-if netbox.service.supervisor == True %}
configure_gunicorn_supervisor_netbox:
  file.managed:
  - name: {{ netbox.service.homedir }}/gunicorn_config.py
  - source: salt://{{ tpldir }}/files/gunicorn_config_supervisor.py
  - user: {{ netbox.service.user }}
  - group: {{ netbox.service.group }}
  - context:
    tpldir: {{ tpldir }}
  - template: jinja
  - watch_in:
    - service: service_supervisor_netbox

install_supervisor_netbox:
  pkg.installed:
    - pkgs:
      - {{ netbox.supervisor.package }}

configure_supervisor_netbox:
  file.managed:
    - name: /etc/supervisor/conf.d/netbox.conf
    - source: salt://{{ tpldir }}/files/supervisor-config
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
    - watch_in:
      - service: service_supervisor_netbox

service_supervisor_netbox:
  service.running:
    - name: {{ netbox.supervisor.service }}
    - enable: true
    - watch:
      - service: service_supervisor_netbox
{%- endif %}

{%-if netbox.service.systemd == True %}
configure_gunicorn_systemd_netbox:
  file.managed:
  - name: {{ netbox.service.homedir }}/gunicorn.py
  - source: salt://{{ tpldir }}/files/gunicorn_config_systemd.py
  - user: {{ netbox.service.user }}
  - group: {{ netbox.service.group }}
  - context:
    tpldir: {{ tpldir }}
  - template: jinja
  - watch_in:
    - service: netbox_app_service
    - service: netbox_rq_service

configure_systemd_netbox:
  file.managed:
    - name: {{ netbox.systemd.service_path }}/netbox.service
    - source: salt://{{ tpldir }}/files/netbox.service
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
    - watch_in:
      - service: netbox_rq_service

configure_systemd_netbox_rq:
  file.managed:
    - name: {{ netbox.systemd.service_path }}/netbox-rq.service
    - source: salt://{{ tpldir }}/files/netbox-rq.service
    - template: jinja
    - context:
      tpldir: {{ tpldir }}
    - watch_in:
      - service: netbox_rq_service
{%- endif %}

netbox_app_service:
{%-if netbox.service.supervisor == True %}
  supervisord.running:
    - name: netbox
    - restart: true
{%- endif -%}
{%-if netbox.service.systemd == True %}
  service.running:
    - name: netbox
    - enable: true
    - require: 
      - file: configure_systemd_netbox_rq
{%- endif %}
    - onchanges:
      - git: clone_netbox_app
      - file: configure_netbox

netbox_rq_service:
{%- if netbox.service.systemd == True %}
  service.running:
    - name: netbox-rq
    - enable: true   
    - require: 
      - file: configure_systemd_netbox_rq
{%- endif %}