# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `topdir` from `tpldir` #}
{%- set topdir = tpldir.split('/')[0] %}
{%- from "stack/map.jinja" import stack with context %}
{%- from "stack/macros.jinja" import files_switch with context %}
{% set map = salt['slsutil.renderer']("salt://stack/map.sls") %}

stack-config:
  file.managed:
    - name: {{ stack.sdb.config }}
    - source: {{ files_switch(
                    salt['config.get'](
                        topdir ~ ':tofs:files:stack-config',
                        ['sdb.conf']
                    )
              ) }}
    - mode: 644
    - user: root
    - group: root
    - template: jinja

stack-yaml-file:
  file.serialize: 
    - name: {{ stack.sdb.yaml }}
    - dataset: 
        {{ map|yaml }}
    - makedirs: True
    - formatter: yaml
    - serializer_opts: 
      - explicit_start: True 
      - default_flow_style: True 
      - indent: 4

stack-keys-config:
  file.managed:
    - name: {{ stack.sdb.sdb_keys }}
    - source: {{ files_switch(
                    salt['config.get'](
                        topdir ~ ':tofs:files:stack-keys-config',
                        ['sdb_keys.conf']
                    )
              ) }}
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        map: {{ map }}

