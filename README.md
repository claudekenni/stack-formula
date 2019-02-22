mapstack-formula
======

This is a prototype on how to create a map structure for use with Formulas / States. This is supposed to mimic the way pillarstack works (https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.stack.html)

Main usage here is that we iterate over different yaml files and then create a **yaml sdb** file which can then be queried by `salt['config.get']('key')`. 


Setup the Formula then run 
```
lab08ld201:/srv/formulas/stack-formula # salt-call state.apply stack
local:
----------
          ID: copy file
    Function: file.serialize
        Name: /etc/salt/minion.d/_stack.conf
      Result: True
     Comment: File /etc/salt/minion.d/_stack.conf updated
     Started: 19:56:41.078666
    Duration: 14.585 ms
     Changes:
              ----------
              diff:
                  New file

Summary for local
------------
Succeeded: 2 (changed=1)
Failed:    0
------------
Total states run:     2
Total run time:  15.146 ms
```

Now you should have all the values from the yml files available via config.get

```
lab08ld201:/srv/formulas/stack-formula # salt-call config.get salt
local:
    ----------
    master:
        ----------
        file_roots:
            ----------
            base:
                - /srv/salt
        fileserver_backend:
            - roots
        pillar_roots:
            ----------
            base:
                - /srv/pillar
    minion:
        ----------
        master:
            salt.lab.fit
```
