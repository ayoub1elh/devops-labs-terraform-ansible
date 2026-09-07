# Lab 11 — Ansible Roles: Refactoring Lab 10 into a `webserver` Role

Lab 10 taught you to install and configure nginx with a single flat playbook. That works, but real Ansible projects grow: playbooks get long, logic gets duplicated across environments, and sharing a setup with a teammate means copy-pasting YAML. **Roles** solve this by packaging related tasks, variables, files, templates, and handlers into a standard directory structure that Ansible loads automatically. In this lab you refactor Lab 10's nginx setup into a reusable `webserver` role and learn where each kind of variable belongs.

## Learning Objectives

- Explain the standard role directory layout (`tasks/`, `handlers/`, `defaults/`, `vars/`, `files/`, `templates/`) and what Ansible auto-loads from each.
- Refactor a flat playbook into a role invoked from `site.yml` with a `roles:` list.
- Use Jinja2 templates (`templates/nginx.conf.j2`) to render configuration from variables.
- Understand Ansible variable precedence: **role defaults < playbook vars < role vars < extra vars (`-e`)**.
- Override a role default (`nginx_port`) from the command line and from playbook variables.
- Use handlers to restart services only when configuration actually changes.

## Architecture

```mermaid
flowchart TD
    subgraph "Control node (your machine)"
        A[ansible-playbook site.yml] --> B[webserver role]
        B --> T[roles/webserver/tasks/main.yml]
        B --> H[roles/webserver/handlers/main.yml]
        B --> D[roles/webserver/defaults/main.yml<br/>nginx_port: 80]
        B --> V[roles/webserver/vars/main.yml<br/>nginx_package_name: nginx]
        B --> F[roles/webserver/files/index.html]
        B --> J[roles/webserver/templates/nginx.conf.j2]
    end
    subgraph "Managed node (webservers group)"
        M1[apt or dnf: install nginx]
        M2[/etc/nginx config rendered from template]
        M3[/var/www/html/index.html]
        M4[nginx service enabled + started]
    end
    T -->|SSH| M1
    J -->|SSH| M2
    F -->|SSH| M3
    T -->|notify: Restart nginx| M4
    H -->|handler runs once, only if config changed| M4
```

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Ansible | >= 2.14 | `ansible --version` |
| Python | >= 3.9 | Required by Ansible |
| SSH client | any | OpenSSH, used to reach the managed node |
| ansible-lint | >= 6.0 | Optional, used by `make lint` |
| Vagrant + VirtualBox | any | Optional convenience VM (see below) |

- **A Linux managed node you can SSH into** with passwordless `sudo` (a Vagrant VM, Multipass instance, or free-tier cloud VM). The node must be Debian/Ubuntu or RHEL/Rocky/Alma family.
- No cloud account is strictly required — everything runs against your own VM. If you use a free-tier cloud VM instead, see **Free Tier Notes**.
- **No secrets or environment variables are needed** for this lab. SSH keys are picked up via `ssh-agent`/your default key; add `ansible_ssh_private_key_file=...` to `inventory/hosts.ini` if your key is non-standard.

**Quick VM option (Vagrant):**

```bash
vagrant init generic/ubuntu2204
# edit the Vagrantfile: add a private network line -> config.vm.network "private_network", ip: "192.168.56.10"
vagrant up
vagrant ssh-config   # confirm the IP/user match inventory/hosts.ini
```

## Step-by-Step Instructions

1. **Clone/checkout the lab and enter its directory:**

   ```bash
   git checkout lab-11-roles
   cd lab-11-roles   # or wherever this lab's files live
   ```

2. **Verify Ansible and inspect the role layout:**

   ```bash
   make setup
   tree roles/webserver   # or: find roles -type f | sort
   ```

   Expected layout:

   ```
   roles/webserver/
   ├── defaults/main.yml      # nginx_port: 80  (LOWEST precedence — meant to be overridden)
   ├── vars/main.yml          # nginx_package_name: nginx  (ALWAYS beats defaults)
   ├── tasks/main.yml         # install, template, copy, service
   ├── handlers/main.yml      # Restart nginx (fires only on config change)
   ├── files/index.html       # static content, copied as-is
   └── templates/nginx.conf.j2  # rendered with {{ nginx_port }}
   ```

3. **Point the inventory at your managed node.** Edit `inventory/hosts.ini` and set `ansible_host`/`ansible_user` for `web1` (examples are commented in the file).

4. **Check connectivity and syntax:**

   ```bash
   make ping
   make test    # runs: ansible-playbook --syntax-check site.yml
   ```

   Expected snippet:

   ```
   web1 | SUCCESS => { "changed": false, "ping": "pong" }
   ```

5. **Deploy with the role:**

   ```bash
   make deploy    # ansible-playbook site.yml
   ```

   Expected output snippet:

   ```
   PLAY [Deploy the web server using the webserver role] ****
   TASK [webserver : Install nginx (Debian/Ubuntu family)] **
   changed: [web1]
   TASK [webserver : Deploy nginx configuration from Jinja2 template] **
   changed: [web1] => {"changed": true, ... "dest": "/etc/nginx/sites-available/default" ...}
   RUNNING HANDLER [webserver : Restart nginx] **************
   changed: [web1]
   PLAY RECAP ************************************************
   web1 : ok=6  changed=4  unreachable=0  failed=0
   ```

6. **Override the port with an extra var** (the key skill of this lab):

   ```bash
   ansible-playbook site.yml -e "nginx_port=8080"
   curl http://<web1-ip>:8080
   ```

7. **(Alternative) Override from the playbook.** Edit `site.yml` and add a `vars:` block above `roles:` (a commented example is already in the file):

   ```yaml
     vars:
       nginx_port: 8080
     roles:
       - webserver
   ```

   Because `nginx_port` is a **default** (not a role var), both methods above override it. If it lived in `vars/main.yml`, they would not — see Troubleshooting #3.

## How Do I Know This Worked?

- `make ping` returns `"pong"`.
- The playbook recap shows `failed=0`.
- From your control node (or on the VM itself):

  ```bash
  curl http://<web1-ip>            # default: port 80
  # or, after step 6:
  curl http://<web1-ip>:8080
  ```

  You should see the "It works — served by Ansible Role!" page from `roles/webserver/files/index.html`.
- On the managed node, confirm the rendered config used your variable:

  ```bash
  ansible web1 -m ansible.builtin.command -a "grep listen /etc/nginx/sites-available/default"
  # RedHat: ... -a "grep listen /etc/nginx/nginx.conf"
  ```

  Expected: `listen       8080;` (or `80;` without the override).
- Idempotency check — run `make deploy` again and confirm the recap shows `changed=0` (only the handler-heavy tasks report ok, not changed).

## Cleanup

Ansible configures an existing machine rather than creating one, so "cleanup" means removing what the role installed:

```bash
# Remove nginx and the deployed content from the managed node:
ansible webservers -m ansible.builtin.apt -a "name=nginx state=absent purge=true" --become   # Debian/Ubuntu
ansible webservers -m ansible.builtin.file -a "path=/var/www/html state=absent" --become
ansible webservers -m ansible.builtin.file -a "path=/etc/nginx state=absent" --become

# If you used a Vagrant VM, destroy it:
vagrant destroy -f

# Remove local artifacts (retry files, caches):
make clean
```

> `make destroy` also prints these removal commands as a reminder — Ansible has no built-in "undeploy", so teardown is itself a small playbook/ad-hoc command set.

## Troubleshooting

**1. `fatal: [web1]: UNREACHABLE! ... Permission denied (publickey)`**
- *Symptom:* `make ping` fails with an SSH authentication error.
- *Cause:* The key for the VM is not in your SSH agent, or `ansible_user` in `inventory/hosts.ini` is wrong.
- *Fix:* Run `ssh-add <path-to-key>` (for Vagrant: `ssh-add $(vagrant ssh-config | awk '/IdentityFile/ {print $2}' | tr -d '"')`), or add `ansible_ssh_private_key_file=/path/to/key` to the host line in `inventory/hosts.ini`, and verify `ssh <user>@<host> "sudo -n true"` works.

**2. `TASK [webserver : Install nginx ...] fatal: ... Could not get lock /var/lib/dpkg/lock` (or dnf metadata errors)**
- *Symptom:* Package installation fails on the managed node.
- *Cause:* Another package process (unattended-upgrades, another apt/dnf run) holds the lock.
- *Fix:* Wait a minute and re-run `make deploy`; on Ubuntu you can also run `sudo systemctl stop unattended-upgrades` on the node. The role sets `update_cache: true` for apt, so transient metadata failures clear on retry.

**3. "I set `nginx_port` in `site.yml` (or with `-e`) but the config still shows port 80"**
- *Symptom:* Your override seems ignored; the rendered config still listens on the old port.
- *Cause:* You moved `nginx_port` into `roles/webserver/vars/main.yml`. **Role vars always beat role defaults AND playbook vars**, so the only thing that can override a role var is `-e` extra vars (and even that is by design unusual). Tunables belong in `defaults/main.yml`.
- *Fix:* Keep `nginx_port` in `roles/webserver/defaults/main.yml`; use `vars/main.yml` only for internal constants like `nginx_package_name`. Re-run the playbook and re-check `grep listen ...`.

## Free Tier Notes

- **This lab creates no cloud resources by itself** — it configures a VM you already have (local Vagrant/VirtualBox is free).
- If you point `inventory/hosts.ini` at a **free-tier cloud VM** instead, remember: free tiers change over time, always run the **Cleanup** steps when done, and check your provider's billing console (e.g. AWS Billing & Cost Management) to confirm no charges accrued. Stop/terminate the VM when you are not using it.
