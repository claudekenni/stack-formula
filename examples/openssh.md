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

The following Configuration was added to mapstack
https://github.com/claudekenni/mapstack-formula/commit/6b6783d41778232d72e06a601ef90c21be9b2aef

containing defaults `stack/common/Linux/sshd_config.yml`
and two overrides for the domain `stack/domains/lab.fit/sshd_config.yml`

These values were taken from https://github.com/saltstack-formulas/openssh-formula/blob/master/pillar.example

These values will then be applied with the state:
```
lab08ld201:~ # salt-call state.apply stack
local:
----------
          ID: copy file
    Function: file.serialize
        Name: /etc/salt/minion.d/_stack.conf
      Result: True
     Comment: File /etc/salt/minion.d/_stack.conf is in the correct state
     Started: 13:05:57.060536
    Duration: 33.792 ms
     Changes:

Summary for local
------------
Succeeded: 1
Failed:    0
------------
Total states run:     1
Total run time:  33.792 ms
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
    PubkeyAuthentication:
        no  <<<------------------------------------ PILLAR OVERRIDE
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
