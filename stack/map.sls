#!py

import os 

def run():
  map = {}
  
  master_files = __salt__['cp.list_master'](saltenv='base')
  minion_files = __salt__['cp.list_minion'](saltenv='base')
  repl = __salt__['file.join'](opts['cachedir'], 'files/base/')

  for filepath in minion_files:
    basefile = filepath.replace(repl, '')
    if basefile not in master_files and basefile.startswith('stack'):
      __salt__['file.remove'](filepath)


  dirname = os.path.dirname(os.path.realpath(__file__))

  config = __salt__['slsutil.renderer']('salt://stack/stack.conf')
  __salt__['log.warning'](config)

  for folder in config:
    configpath = __salt__['file.join'](dirname,folder)
    __salt__['cp.cache_dir']('salt://stack/' + folder)
    for filepath in __salt__['file.find'](configpath, name='*.yml'):
      __salt__['log.warning']("Importing: {}".format(filepath))
      data = __salt__['slsutil.renderer'](filepath)
      __salt__['slsutil.update'](map, data)
  
  return map