{%- from salt['file.join'](tpldir,"map.jinja") import stack with context %}

{# Check and Clear cached files that are missing on the master #}
include:
  - .cache


copy file:
  file.serialize: 
    - name: /etc/salt/minion.d/_stack.conf
    - dataset: 
        {{ stack|yaml }}
    - makedirs: True
    - formatter: yaml
    - serializer_opts: 
      - explicit_start: True 
      - default_flow_style: True 
      - indent: 4

