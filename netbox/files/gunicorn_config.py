{% from "netbox/map.jinja" import netbox with context %}
command = '{{ netbox.service.homedir }}/bin/gunicorn'
pythonpath = '{{ netbox.service.homedir }}/bin/'
bind = '127.0.0.1:8001'
workers = 3
user = '{{ netbox.service.user }}'
