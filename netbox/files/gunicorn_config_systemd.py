{% set tplroot = tpldir.split('/')[0] if not salt.pillar.get('netbox:tplroot_overwrite', False) else salt.pillar.get('netbox:tplroot_overwrite', False) %}
{%- from tplroot ~ "/map.jinja" import netbox with context %}

bind = '{{ netbox.service.gunicorn.bind }}'
workers = {{ netbox.service.gunicorn.workers }}
user = '{{ netbox.service.user }}'
threads = '{{ netbox.service.gunicorn.threads }}'
max_requests = {{ netbox.service.gunicorn.max_requests }}
max_requests_jitter = {{ netbox.service.gunicorn.max_requests_jitter }}
