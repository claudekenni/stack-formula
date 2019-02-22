Example by using openssh-formula from saltstack-formulas
=====

The openssh-formula has been adjusted in the openssh/map.jinja file to do a config.get instead of pillar.get
```jinja
diff --git a/openssh/config.sls b/openssh/config.sls
index 76a11a1..09efb45 100644
--- a/openssh/config.sls
+++ b/openssh/config.sls
@@ -1,6 +1,6 @@
 {% from "openssh/map.jinja" import openssh with context %}

-{%- set manage_sshd_config = salt['pillar.get']('sshd_config', False) %}
+{%- set manage_sshd_config = salt['config.get']('sshd_config', False, merge='recurse') %}

 include:
   - openssh
diff --git a/openssh/map.jinja b/openssh/map.jinja
index a907f5e..f7127fb 100644
--- a/openssh/map.jinja
+++ b/openssh/map.jinja
@@ -17,6 +17,6 @@
 ) %}

 {## merge the openssh pillar ##}
-{% set openssh = salt['pillar.get']('openssh', default=defaults['openssh'], merge=True) %}
-{% set ssh_config = salt['pillar.get']('ssh_config', default=defaults['ssh_config'], merge=True) %}
-{% set sshd_config = salt['pillar.get']('sshd_config', default=defaults['sshd_config'], merge=True) %}
+{% set openssh = salt['config.get']('openssh', default=defaults['openssh'], merge='recurse') %}
+{% set ssh_config = salt['config.get']('ssh_config', default=defaults['ssh_config'], merge='recurse') %}
+{% set sshd_config = salt['config.get']('sshd_config', default=defaults['sshd_config'], merge='recurse') %}
```

The configuration comes from the following files

Defaults/Common
```
cat stack/common/Linux/sshd_config.yml
sshd_config:
  # This keyword is totally optional
  ConfigBanner: |
    # Alternative banner for the config file
    # (Indented) hash signs lose their special meaning here
    # and the lines will be written as-is.
  Port: 22
  Protocol: 2
  HostKey:
    - /etc/ssh/ssh_host_rsa_key
    - /etc/ssh/ssh_host_dsa_key
    - /etc/ssh/ssh_host_ecdsa_key
    - /etc/ssh/ssh_host_ed25519_key
  UsePrivilegeSeparation: 'sandbox'
  SyslogFacility: AUTH
  LogLevel: INFO
  ClientAliveInterval: 0
  ClientAliveCountMax: 3
  LoginGraceTime: 120
  PermitRootLogin: 'yes'
  PasswordAuthentication: 'yes'
  StrictModes: 'yes'
  MaxAuthTries: 6
  MaxSessions: 10
  AuthorizedKeysCommand: '/usr/bin/sss_ssh_authorizedkeys'
  AuthorizedKeysCommandUser: 'nobody'
  IgnoreRhosts: 'yes'
  HostbasedAuthentication: 'no'
  PermitEmptyPasswords: 'no'
  ChallengeResponseAuthentication: 'no'
  AuthorizedKeysFile: '%h/.ssh/authorized_keys'
  X11Forwarding: 'no'
  X11DisplayOffset: 10
  PrintMotd: 'yes'
  PrintLastLog: 'yes'
  TCPKeepAlive: 'yes'
  AcceptEnv: "LANG LC_*"
  Subsystem: "sftp /usr/lib/openssh/sftp-server"
  UsePAM: 'yes'
  UseDNS: 'yes'
```
Domain Override
```
lab08ld201:/srv/formulas/mapstack-formula # cat stack/domains/lab.fit/sshd_config.yml
sshd_config:
  LoginGraceTime: 300
  UseDNS: 'no'
```

These values will then be applied with the state:
```
lab08ld201:~ # salt-call state.apply stack
local:
----------
          ID: copy file
    Function: file.serialize
        Name: /etc/salt/minion.d/_stack.conf
      Result: True
     Comment: File /etc/salt/minion.d/_stack.conf updated
     Started: 12:37:08.270216
    Duration: 15.035 ms
     Changes:
              ----------
              diff:
                  New file

Summary for local
------------
Succeeded: 1 (changed=1)
Failed:    0
------------
Total states run:     1
Total run time:  15.035 ms
```

We can also add Pillar Data. 
```
lab08ld201:~ # salt-call pillar.item sshd_config
local:
    ----------
    sshd_config:
        ----------
        PubkeyAuthentication:
            no
lab08ld201:~ #
```

Now with config.get we get the merged values
```
lab08ld201:~ # salt-call config.get sshd_config
local:
    ----------
    AcceptEnv:
        LANG LC_*
    AuthenticationMethods:
        publickey,keyboard-interactive
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
        300 <<<------------------------------------ DOMAIN OVERRIDE
    MaxAuthTries:
        6
    MaxSessions:
        10
    PasswordAuthentication:
        yes
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
    PubkeyAuthentication:
        yes  <<<------------------------------------ PILLAR VALUE
    StrictModes:
        yes
    Subsystem:
        sftp /usr/lib/openssh/sftp-server
    SyslogFacility:
        AUTH
    TCPKeepAlive:
        yes
    UseDNS:
        no  <<<------------------------------------ DOMAIN OVERRIDE
    UsePAM:
        yes
    UsePrivilegeSeparation:
        sandbox
    X11DisplayOffset:
        10
    X11Forwarding:
        no
```

Running the state
```
lab08ld201:/srv/formulas/mapstack-formula # salt-call state.apply openssh.config                                                             [101/9074]
local:
----------
          ID: openssh
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 13:45:32.371509
    Duration: 3680.157 ms
     Changes:
----------
          ID: sshd_config
    Function: file.managed
        Name: /etc/ssh/sshd_config
      Result: True
     Comment: File /etc/ssh/sshd_config updated
     Started: 13:45:36.056049
    Duration: 603.641 ms
     Changes:
              ----------
              diff:
              <<<SNIP>>>
        mode:
             0644
----------
          ID: openssh
    Function: service.running
        Name: sshd
      Result: True
     Comment: Service restarted
     Started: 13:45:36.693955
    Duration: 45.092 ms
     Changes:
              ----------
              sshd:
                  True

Summary for local
------------
Succeeded: 3 (changed=2)
Failed:    0
------------
Total states run:     3
Total run time:   4.329 s
```

We get the follwing sshd_config:
```
# Alternative banner for the config file
# (Indented) hash signs lose their special meaning here
# and the lines will be written as-is.

# The contents of the original sshd_config are kept on the bottom for
# quick reference.
# See the sshd_config(5) manpage for details

Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation sandbox
SyslogFacility AUTH
LogLevel INFO
ClientAliveInterval 0
ClientAliveCountMax 3
LoginGraceTime 300
PermitRootLogin yes
StrictModes yes
MaxAuthTries 6
MaxSessions 10
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
AuthorizedKeysCommandUser nobody
IgnoreRhosts yes
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding no
X11DisplayOffset 10
PrintMotd yes
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
UseDNS no
```
