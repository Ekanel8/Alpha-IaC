# Ansible Zabbix Playbook
<div align="center">

<img src="https://img.shields.io/badge/Ansible-37474F?logo=ansible&logoColor=EE0000" />
<img src="https://img.shields.io/badge/Zabbix-CC0000?logo=Zabbix&logoColor=white" />
<img src="https://img.shields.io/badge/Nginx-009639?logo=nginx&logoColor=white" />
<img src="https://img.shields.io/badge/Postgresql-4169E1?logo=postgresql&logoColor=white" />
<img src="https://img.shields.io/badge/Debian-D70A53?logo=debian&logoColor=white" />

</div>

## Overview
This project provides an automated Ansible playbook for provisioning and hardening a Linux server with:

- Base system utilities and monitoring tools
- Secure SSH configuration
- Kernel hardening (sysctl)
- Centralized logging (rsyslog)
- Time synchronization (ntpsec)
- Fail2ban protection
- Zabbix Server (latest) with Nginx and PostgreSQL
- Automatic TLS (HTTPS) setup
- Reverse proxy configuration


## Project Structure

```
.
├── ansible.cfg
├── credentials
│   └── zabbix_password <----- Generated passwd 
├── group_vars
│   ├── all.yaml 
│   └── virtual.yml <------- ansible exec user
├── hosts.txt
├── keys 
│   ├── ansible
│   └── ansible.pub
├── proxmox <--------- vm creator (proxmox WIP)
│   ├── debian.pkr.hcl
│   └── http
│       └── preseed.cfg
├── README.md
├── roles
│   └── common
│       └── tasks
│           ├── database.yaml
│           ├── install.yaml
│           ├── isconf.yaml
│           ├── kernel.yaml
│           ├── main.yaml
│           ├── nginx.yaml
│           ├── ping.yaml
│           ├── proxy.yaml
│           ├── rsyslog.yaml
│           ├── sshfail2ban.yaml
│           ├── ssl.yaml
│           ├── systemctl.yaml
│           ├── time.yaml
│           ├── user.yaml
│           └── zabbixinit.yaml
├── site.yaml <------ playbook initer
└── templates
    ├── logs.conf 
    └── ntp.conf
```

## Requirements

### Local Machine
- Ansible 
- SSH 
- Generated SSH key

### Remote Host
- Debian/Ubuntu-based system
- Installed:
  - `sudo`
  - `openssh`

---

## Setup Instructions

### 1. Generate Ansible SSH Key
```bash
ssh-keygen -t ed25519 -f ./keys/ansible
```
### 2. Copy key
```bash
ssh-copy-id -i ./keys/ansible.pub user@<TARGET_IP>
```
### 3. Conf hosts.txt (aka inventory)

```env
[target]
<TARGET_IP> ansible_user=user
```
### 4. Define .env

```yaml
TARGET_DOMAIN: infra.net
DNS_SERVER: 192.168.0.10
ADMIN_USER: JohnDoe
TIME_ZONE: UTC
```
### 5. Run and use
```bash
ansible-playbook site.yaml --key-file ./keys/ansible
```
Link:
```bash
https://zabbix.<domain>
```
## Passes

> Credentials for Zabbix are stored locally in credentials/ 

> Default Zabbix web-ui: Admin/Zabbix

## Summary

This playbook automatically provisions and hardens a Linux server.

It performs the following:

- Installs essential system packages and security tools
- Configures time synchronization and timezone
- Sets up centralized logging via rsyslog
- Hardens the kernel using sysctl (disables IPv6, mitigates common attacks)
- Secures SSH access (key-based auth, hardened config)
- Enables and configures Fail2Ban
- Deploys Zabbix Server with Nginx and PostgreSQL
- Generates and stores database credentials
- Configures Nginx:
  - Internal service on localhost:8080
  - Secure reverse proxy (HTTP → HTTPS → backend)
- Automatically **creates self-signed** TLS certificates
- Creates an administrative user