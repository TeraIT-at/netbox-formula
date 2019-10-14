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
    - file_mode: 755
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
    - target: {{ netbox.service.homedir }}
    - user: {{ netbox.service.user }}
    - require:
      - user: create_netbox_user
      - group: create_netbox_group
      - file: create_netbox_dir

setup_netbox_virtualenv:
  virtualenv.managed:
    - name: {{ netbox.service.homedir }}
    - requirements: {{ netbox.service.homedir }}/requirements.txt
    - user: {{ netbox.service.user }}
    - cwd: {{ netbox.service.homedir }}
    - pip_upgrade: True
    - python: python3
    - require:
      - git: clone_netbox_app

configure_netbox:
  file.managed:
  - name: {{ netbox.service.homedir }}/netbox/netbox/configuration.py
  - user: {{ netbox.service.user }}
  - group: {{ netbox.service.group }}
  - source: salt://{{ tpldir }}/files/netbox.config
  - template: jinja
  - context:
    tpldir: {{ tpldir }}
  - mode: 600
  - require:
    - git: clone_netbox_app
  - watch_in:
    - service: service_supervisor_netbox

setup_netbox_link_graphviz_to_venv:
  file.symlink:
    - name: /opt/netbox/bin/dot
    - target: /usr/bin/dot
    - user: {{ netbox.service.user }}
    - group: {{ netbox.service.group }}
    - require:
        - configure_netbox
        - setup_netbox_virtualenv
        - install_netbox_dependencies

restart_netbox_app:
  supervisord.running:
    - name: netbox
    - restart: true
    - onchanges:
      - git: clone_netbox_app
      - file: configure_netbox

install_gunicorn_netbox:
  pip.installed:
    - name: gunicorn
    - user: {{ netbox.service.user }}
    - cwd: {{ netbox.service.homedir }}
    - bin_env: {{ netbox.service.homedir }}
    - ignore_installed: true
    - require:
      - file: configure_netbox
      - virtualenv: setup_netbox_virtualenv

configure_gunicorn_netbox:
  file.managed:
  - name: {{ netbox.service.homedir }}/gunicorn_config.py
  - source: salt://{{ tpldir }}/files/gunicorn_config.py
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
    - name: {{ netbox.supervisor.package }}
    - enable: true
