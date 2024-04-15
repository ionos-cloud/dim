Role Name
=========

A ansible playbook for deploy dim

Requirements
------------

`Sudoer user`: Ansible user should be a member of the wheel group. and can use sudo without password.

**Befor you run the ansible dim, you need to install the following packages:**

```bash
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.mysql
```

Role Variables
--------------

Check the `inventory` directory for a list of variables that can be passed into the role.


How to use
-----------

```bash
ansible-playbook -i inventory/dim-servers.ini dim.yml  --become --become-method=sudo
```

License
-------

BSD

Author Information
------------------

Milad Norouzi (milad.norouzi1370@gmail.com)
