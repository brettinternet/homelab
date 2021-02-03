![desktop screenshot](./docs/screenshot.png)

### Setup

```sh
make setup
```

Configure hosts in `host_vars/`. Then, sync hosts:

```sh
ansible-playbook sync.yml
```
