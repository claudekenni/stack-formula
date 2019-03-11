stack-formula
======
 
**In the current state of this formula there is a chicken egg problem. When new values are added or values change, then the highstate would need to run twice.**
 
This is a prototype on how to create a map structure for use with Formulas / States. This is supposed to mimic the way pillarstack works (https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.stack.html)

Main usage here is that we iterate over different yaml files and then create a **yaml sdb** file which can then be queried by `salt['config.get']('key')`. 

Quick overview:
- Change formulas/states to use config.get instead of pillar.get 
- Use stack state to create configuration values in `/etc/salt/minion.d/_stack.yaml`
- `/etc/salt/minion.d/_stack.yaml` is read as SDB values in 
  - `/etc/salt/minion.d/_sdb.conf` using the SDB YAML Module
  - `/etc/salt/minion.d/_sdb_keys.conf` maps the top level keys into configuration values
     - See: https://docs.saltstack.com/en/latest/topics/sdb/index.html#using-sdb-uris-in-files
- Now if we run our state, the configuration values come from SDB but we can also use Pillar as needed.
Important to note is that SDB Values take precedence over Pillar Values. This should not be a problem if we only use Pillar for secrets that should not exist in a text file anyway. 
Because SDB works as a general purpose data module, we can also use something like the vault sdb module and query our Secrets that way which would make it possible to completely go away from pillar  


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

lab08ld201:/etc/salt/minion.d # salt-call config.get linux
local:
    ----------
    var1:
        True
    var2:
        Just some example

```

```
lab08ld201:/etc/salt/minion.d # salt-call config.get sshd_config
local:
    ----------
    AcceptEnv:
        LANG LC_*
    AuthorizedKeysCommand:
        /usr/bin/sss_ssh_authorizedkeys
    AuthorizedKeysCommandUser:
        nobody
    AuthorizedKeysFile:
        %h/.ssh/authorized_keys
    ChallengeResponseAuthentication:
        no
    ClientAliveCountMax:
        3
    ClientAliveInterval:
        0
    ConfigBanner:
        # Alternative banner for the config file
        # (Indented) hash signs lose their special meaning here
        # and the lines will be written as-is.
    HostKey:
        - /etc/ssh/ssh_host_rsa_key
        - /etc/ssh/ssh_host_dsa_key
        - /etc/ssh/ssh_host_ecdsa_key
        - /etc/ssh/ssh_host_ed25519_key
    HostbasedAuthentication:
        no
    IgnoreRhosts:
        yes
    LogLevel:
        INFO
    LoginGraceTime:
        300
    MaxAuthTries:
        6
    MaxSessions:
        10
    PasswordAuthentication:
        no
    PermitEmptyPasswords:
        no
    PermitRootLogin:
        yes
    Port:
        22
    PrintLastLog:
        yes
    PrintMotd:
        yes
    Protocol:
        2
    StrictModes:
        yes
    Subsystem:
        sftp /usr/lib/openssh/sftp-server
    SyslogFacility:
        AUTH
    TCPKeepAlive:
        yes
    UseDNS:
        no
    UsePAM:
        yes
    UsePrivilegeSeparation:
        sandbox
    X11DisplayOffset:
        10
    X11Forwarding:
        no
```

Files:
```
lab08ld201:/etc/salt/minion.d # cat /etc/salt/minion.d/_sdb.conf
########################################################################
# File managed by Salt at <salt://stack/files/default/sdb.conf>.
# Your changes will be overwritten.
########################################################################
stack:
  driver: yaml
  files:
    - /etc/salt/minion.d/_stack.yaml
```

```
lab08ld201:/etc/salt/minion.d # cat /etc/salt/minion.d/_sdb_keys.conf
########################################################################
# File managed by Salt at <salt://stack/files/default/sdb_keys.conf>.
# Your changes will be overwritten.
########################################################################
sshd_config: sdb://stack/sshd_config
salt: sdb://stack/salt
linux: sdb://stack/linux
```

```
lab08ld201:/etc/salt/minion.d # cat /etc/salt/minion.d/_stack.yaml
linux:
  var1: true
  var2: Just some example
salt:
  master:
    file_roots:
      base:
      - /srv/salt
    fileserver_backend:
    - roots
    pillar_roots:
      base:
      - /srv/pillar
  minion:
    master: salt.lab.fit
sshd_config:
  AcceptEnv: LANG LC_*
  AuthorizedKeysCommand: /usr/bin/sss_ssh_authorizedkeys
  AuthorizedKeysCommandUser: nobody
  AuthorizedKeysFile: '%h/.ssh/authorized_keys'
  ChallengeResponseAuthentication: 'no'
  ClientAliveCountMax: 3
  ClientAliveInterval: 0
  ConfigBanner: '# Alternative banner for the config file

    # (Indented) hash signs lose their special meaning here

    # and the lines will be written as-is.

'
  HostKey:
  - /etc/ssh/ssh_host_rsa_key
  - /etc/ssh/ssh_host_dsa_key
  - /etc/ssh/ssh_host_ecdsa_key
  - /etc/ssh/ssh_host_ed25519_key
  HostbasedAuthentication: 'no'
  IgnoreRhosts: 'yes'
  LogLevel: INFO
  LoginGraceTime: 300
  MaxAuthTries: 6
  MaxSessions: 10
  PasswordAuthentication: 'no'
  PermitEmptyPasswords: 'no'
  PermitRootLogin: 'yes'
  Port: 22
  PrintLastLog: 'yes'
  PrintMotd: 'yes'
  Protocol: 2
  StrictModes: 'yes'
  Subsystem: sftp /usr/lib/openssh/sftp-server
  SyslogFacility: AUTH
  TCPKeepAlive: 'yes'
  UseDNS: 'no'
  UsePAM: 'yes'
  UsePrivilegeSeparation: sandbox
  X11DisplayOffset: 10
  X11Forwarding: 'no'
```

Overriding a value for a specific minion
======
```
lab08ld201:/srv/formulas/mapstack-formula/stack/stack # cat common/Linux/salt-minion.yml
salt:
  minion:
    master: 127.0.0.1
lab08ld201:/srv/formulas/mapstack-formula/stack/stack # cat minions/lab08ld201/salt-minion.yml
salt:
  minion:
    master: 10.10.10.50
lab08ld201:/srv/formulas/mapstack-formula/stack/stack # salt-call state.apply stack
[WARNING ] [u'stack/common/Linux', u'stack/domains/lab.fit', u'stack/domains/lab.fit/Linux', u'stack/minions/lab08ld201']
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/common/Linux/others.yml
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/common/Linux/salt-minion.yml
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/common/Linux/sshd_config.yml
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/domains/lab.fit/salt-minion.yml
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/domains/lab.fit/sshd_config.yml
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/minions/lab08ld201/salt-master.yml
[WARNING ] Importing: /var/cache/salt/minion/files/base/stack/stack/minions/lab08ld201/salt-minion.yml
local:
----------
          ID: stack-sdb-config
    Function: file.managed
        Name: /etc/salt/minion.d/sdb.conf
      Result: True
     Comment: File /etc/salt/minion.d/sdb.conf is in the correct state
     Started: 09:33:55.653381
    Duration: 72.556 ms
     Changes:
----------
          ID: stack-yaml-file
    Function: file.serialize
        Name: /etc/salt/sdb/stack.yaml
      Result: True
     Comment: File /etc/salt/sdb/stack.yaml updated
     Started: 09:33:55.726220
    Duration: 14.269 ms
     Changes:
              ----------
              diff:
                  ---
                  +++
                  @@ -12,7 +12,7 @@
                         base:
                         - /srv/pillar
                     minion:
                  -    master: 127.0.0.1
                  +    master: 10.10.10.50
                   sshd_config:
                     AcceptEnv: LANG LC_*
                     AuthorizedKeysCommand: /usr/bin/sss_ssh_authorizedkeys
----------
          ID: stack-keys-config
    Function: file.managed
        Name: /etc/salt/minion.d/sdb_keys.conf
      Result: True
     Comment: File /etc/salt/minion.d/sdb_keys.conf is in the correct state
     Started: 09:33:55.740775
    Duration: 67.949 ms
     Changes:
Summary for local
------------
Succeeded: 3 (changed=1)
Failed:    0
------------
Total states run:     3
Total run time: 154.774 ms
lab08ld201:/srv/formulas/mapstack-formula/stack/stack # salt-call config.get salt:minion
local:
    ----------
    master:
        10.10.10.50

```
