{% from "netbox/map.jinja" import netbox with context %}
command = '{{ netbox.service.homedir }}/bin/gunicorn'
pythonpath = '{{ netbox.service.homedir }}/bin/'
bind = '{{ netbox.service.gunicorn.bind }}'
workers = {{ netbox.service.gunicorn.workers }}
user = '{{ netbox.service.user }}'
