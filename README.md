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
