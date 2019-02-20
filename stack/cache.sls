{%- do salt['cp.cache_dir']('salt://stack') %}

{%- set master_files = salt['cp.list_master'](saltenv='base') %}
{%- set minion_files = salt['cp.list_minion'](saltenv='base') %}
{%- set repl = salt['file.join'](opts['cachedir'], 'files/base/') %}

{#
Iterate over all files, check if the file exists on the master 
and if the pillar for clean == true remove the files
#}
{%- for file in minion_files %}
  {%- set basefile = file.replace(repl, '') %}
  {%- if basefile not in master_files and not basefile.startswith('/') %} 
      {%- do salt.log.warning('Removing: ' + file) %}
remove {{ file }}:
  file.absent:
    - name: {{ file }}
{%- else %}
{%- endif %}
{%- endfor %}

Test state so minion comes back without failure:
  test.succeed_without_changes:
    - name: foo
